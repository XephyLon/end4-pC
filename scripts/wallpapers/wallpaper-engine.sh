#!/usr/bin/env bash
set -u

action="${1:-}"
project_path="${2:-}"
fps="${3:-30}"
scaling="${4:-fill}"
silent="${5:-true}"

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/user/wallpaper-engine"
restore_dir="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/custom/scripts"
restore_script="$restore_dir/__restore_video_wallpaper.sh"
log_file="$state_dir/runtime.log"
pid_file="$state_dir/runtime.pid"
runner_path="$(readlink -f "$0")"

stop_engine() {
    local pid=""
    [[ -r "$pid_file" ]] && read -r pid <"$pid_file"
    if [[ "$pid" =~ ^[0-9]+$ && -r "/proc/$pid/cmdline" ]]; then
        local command_line
        command_line="$(tr '\0' ' ' <"/proc/$pid/cmdline")"
        if [[ "$command_line" == *linux-wallpaperengine* && "$command_line" == *"--layer background"* ]]; then
            # The runtime is its own session/process group. Stop the complete
            # tree so mpv/CEF helpers cannot survive wallpaper changes.
            kill -- "-$pid" 2>/dev/null || kill "$pid" 2>/dev/null || true
            local waited=0
            while kill -0 "$pid" 2>/dev/null && (( waited < 20 )); do
                sleep 0.05
                waited=$((waited + 1))
            done
            kill -9 -- "-$pid" 2>/dev/null || kill -9 "$pid" 2>/dev/null || true
        fi
    fi
    rm -f "$pid_file"
    # Backward-compatible cleanup for a runtime started before PID tracking.
    # Restrict the fallback to background-layer instances so offscreen still
    # renderers are never killed by an unrelated live-wallpaper apply.
    pkill -f '(^|/)[l]inux-wallpaperengine .*--layer background( |$)' 2>/dev/null || true
}

# Render a scene to a still image for use as a peel/lock transition texture.
# No --screen-root is passed, so the sized --window render remains an offscreen
# screenshot target rather than a live wallpaper layer. The throwaway process
# group is stopped once the file lands. Results are cached for later reuse.
generate_screenshot() {
    local dir="$1" out="$2" scaling="${3:-fill}" force="${4:-}"
    [[ -d "$dir" && -n "$out" ]] || return 2
    command -v linux-wallpaperengine >/dev/null 2>&1 || return 127
    if [[ -n "$force" ]]; then
        rm -f "$out"                     # re-cache: drop the stale still
    else
        [[ -s "$out" ]] && return 0
    fi
    mkdir -p "$(dirname "$out")" || return 1
    case "$scaling" in fill|fit|stretch|default) ;; *) scaling=fill ;; esac

    # Render into a window sized to the focused monitor so the still matches the
    # live wallpaper's framing. A geometry-less --screenshot renders a small
    # square buffer instead, which would crop-zoom on a wide screen. The window
    # is short-lived and lands on a hidden workspace, so it never displays.
    local geo="0x0x1920x1080"
    if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
        local detected
        detected="$(hyprctl monitors -j 2>/dev/null | jq -r 'first(.[] | select(.focused)) | "0x0x\(.width)x\(.height)"')"
        [[ "$detected" =~ ^0x0x[0-9]+x[0-9]+$ ]] && geo="$detected"
    fi

    local tmp
    tmp="$(mktemp --suffix=.png)" || return 1
    setsid linux-wallpaperengine --window "$geo" --scaling "$scaling" \
        --screenshot "$tmp" --screenshot-delay 5 --silent "$dir" >/dev/null 2>&1 &
    local pid=$! waited=0
    while (( waited < 200 )); do        # wait up to ~20s for the render
        [[ -s "$tmp" ]] && break
        sleep 0.1
        waited=$((waited + 1))
    done
    sleep 0.3                            # let the writer flush
    kill -- "-$pid" 2>/dev/null || kill "$pid" 2>/dev/null || true
    sleep 0.2
    kill -9 -- "-$pid" 2>/dev/null || kill -9 "$pid" 2>/dev/null || true

    if [[ -s "$tmp" ]]; then
        mv "$tmp" "$out"
        return 0
    fi
    rm -f "$tmp"
    return 1
}

if [[ "$action" == "stop" ]]; then
    stop_engine
    exit 0
fi

if [[ "$action" == "screenshot" ]]; then
    generate_screenshot "$project_path" "${3:-}" "${4:-fill}" "${5:-}"
    exit $?
fi

if [[ "$action" != "apply" || ! -d "$project_path" ]]; then
    echo "Usage: $0 apply PROJECT_PATH [FPS] [SCALING] [SILENT]" >&2
    exit 2
fi

for tool in linux-wallpaperengine hyprctl jq; do
    command -v "$tool" >/dev/null 2>&1 || {
        echo "$tool is not installed" >&2
        exit 127
    }
done

if ! linux-wallpaperengine --help 2>&1 | grep -q -- '--layer'; then
    echo "linux-wallpaperengine is too old: rebuild linux-wallpaperengine-git for --layer background support" >&2
    exit 65
fi

[[ "$fps" =~ ^[0-9]+$ ]] || fps=30
case "$scaling" in fill|fit|stretch|default) ;; *) scaling=fill ;; esac

mapfile -t monitors < <(hyprctl monitors -j | jq -r '.[].name')
if (( ${#monitors[@]} == 0 )); then
    echo "No Hyprland monitors found" >&2
    exit 1
fi

args=(--layer background --fps "$fps")
[[ "$silent" == "true" ]] && args+=(--silent)
for monitor in "${monitors[@]}"; do
    args+=(--screen-root "$monitor" --scaling "$scaling")
done
args+=("$project_path")

mkdir -p "$state_dir" "$restore_dir"
stop_engine
pkill -x mpvpaper 2>/dev/null || true
setsid linux-wallpaperengine "${args[@]}" >>"$log_file" 2>&1 &
runtime_pid=$!
pid_tmp="$pid_file.$$"
printf '%s\n' "$runtime_pid" >"$pid_tmp"
mv "$pid_tmp" "$pid_file"

{
    printf '#!/usr/bin/env bash\n'
    printf '%q ' "$runner_path" apply "$project_path" "$fps" "$scaling" "$silent"
    printf '\n'
} >"$restore_script"
chmod +x "$restore_script"
