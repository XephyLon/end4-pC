#!/usr/bin/env bash
# presets.sh - manage shell config presets | just for fun I could have done it from quickshell directly =P
# Usage:
#   presets.sh --save <name>
#   presets.sh --remove <name>
#   presets.sh --apply <name>

CONFIG_DIR="$HOME/.config/illogical-impulse"
CONFIG_FILE="$CONFIG_DIR/config.json"
PLUGIN_STATE_FILE="$CONFIG_DIR/plugin-state.json"
PRESETS_DIR="$CONFIG_DIR/presets"
SCRIPT_DIR="$HOME/.config/quickshell/end4-pC/scripts"
SWITCHWALL="$HOME/.config/quickshell/end4-pC/scripts/colors/switchwall.sh"
WALLPAPER_ENGINE="$HOME/.config/quickshell/end4-pC/scripts/wallpapers/wallpaper-engine.sh"

mkdir -p "$PRESETS_DIR"

# FileView reacts to every replacement of these files. Avoid replacing an
# identical document: doing so needlessly rebuilds plugin delegates and their
# (potentially monitor-sized) blur textures while a preset is being applied.
replace_if_changed() {
    local candidate="$1"
    local destination="$2"

    if [ -f "$destination" ] && cmp -s "$candidate" "$destination"; then
        rm -f "$candidate"
        return 1
    fi
    mv "$candidate" "$destination"
    return 0
}

action="$1"
name="$2"

if [ -z "$name" ]; then
    echo "Error: missing preset name" >&2
    exit 1
fi

case "$action" in
    --save)
        description="$3"
        plugin_state="$(jq -c '{
            version: (.version // 2),
            desktopPositions: (.desktopPositions // {}),
            pluginOptions: (.pluginOptions // {})
        }' "$PLUGIN_STATE_FILE" 2>/dev/null \
            || printf '{"version":2,"desktopPositions":{},"pluginOptions":{}}')"
        jq --argjson pluginState "$plugin_state" \
            'del(._presetMeta, ._pluginState) | ._pluginState = $pluginState' \
            "$CONFIG_FILE" > "$PRESETS_DIR/${name}.json"
        if [ -n "$description" ]; then
            jq --arg desc "$description" '._presetMeta = {"description": $desc}' \
                "$PRESETS_DIR/${name}.json" > "$PRESETS_DIR/${name}.json.tmp" \
                && mv "$PRESETS_DIR/${name}.json.tmp" "$PRESETS_DIR/${name}.json"
        fi
        ;;
    --remove)
        rm -f "$PRESETS_DIR/${name}.json"
        ;;
    --apply)
        preset_file="$PRESETS_DIR/${name}.json"
        if [ ! -f "$preset_file" ]; then
            echo "Error: preset not found: $name" >&2
            exit 1
        fi
        previous_engine_project="$(jq -r '.wallpaperSelector.wallpaperEngine.activeProject // empty' "$CONFIG_FILE")"
        previous_engine_still="$(jq -r '.wallpaperSelector.wallpaperEngine.activeStill // empty' "$CONFIG_FILE")"
        previous_engine_preview="$(jq -r '.wallpaperSelector.wallpaperEngine.activePreview // empty' "$CONFIG_FILE")"
        if [ -z "$previous_engine_project" ]; then
            previous_engine_preview="$(jq -r '.background.wallpaperPath // empty' "$CONFIG_FILE")"
        fi
        preset_plugin_state="$(jq -c '._pluginState // empty' "$preset_file")"
        if [ -n "$preset_plugin_state" ]; then
            current_plugin_state="$(jq -c '{
                version: (.version // 2),
                desktopPositions: (.desktopPositions // {}),
                pluginOptions: (.pluginOptions // {})
            }' "$PLUGIN_STATE_FILE" 2>/dev/null \
                || printf '{"version":2,"desktopPositions":{},"pluginOptions":{}}')"
            # Top-level merging keeps fields omitted by older position-only
            # presets, while a new preset's complete maps replace current state.
            jq -n --argjson current "$current_plugin_state" --argjson preset "$preset_plugin_state" \
                '$current * $preset
                    | .version = 2
                    | .desktopPositions = (if ($preset | has("desktopPositions"))
                        then ($preset.desktopPositions // {})
                        else ($current.desktopPositions // {}) end)
                    | .pluginOptions = (if ($preset | has("pluginOptions"))
                        then ($preset.pluginOptions // {})
                        else ($current.pluginOptions // {}) end)' \
                > "${PLUGIN_STATE_FILE}.tmp" \
                && replace_if_changed "${PLUGIN_STATE_FILE}.tmp" "$PLUGIN_STATE_FILE" || true
        fi
        jq -s '.[0] * .[1] | del(._presetMeta, ._pluginState)' "$CONFIG_FILE" "$preset_file" \
            > "${CONFIG_FILE}.tmp" \
            && replace_if_changed "${CONFIG_FILE}.tmp" "$CONFIG_FILE" || true
        engine_path="$(jq -r '.wallpaperSelector.wallpaperEngine.activePath // empty' "$CONFIG_FILE")"
        if [ -n "$engine_path" ] && [ -d "$engine_path" ]; then
            engine_still="$(jq -r '.wallpaperSelector.wallpaperEngine.activeStill // empty' "$CONFIG_FILE")"
            engine_preview="$(jq -r '.wallpaperSelector.wallpaperEngine.activePreview // empty' "$CONFIG_FILE")"
            engine_fps="$(jq -r '.wallpaperSelector.wallpaperEngine.fps // 30' "$CONFIG_FILE")"
            engine_scaling="$(jq -r '.wallpaperSelector.wallpaperEngine.scaling // "fill"' "$CONFIG_FILE")"
            engine_silent="$(jq -r '.wallpaperSelector.wallpaperEngine.silent // true' "$CONFIG_FILE")"
            if [ -n "$engine_preview" ]; then
                "$SWITCHWALL" --noswitch --coloronly --image "$engine_preview"
            fi
            qs -p "$HOME/.config/quickshell/end4-pC" ipc call wallpaperEngine transition \
                "$previous_engine_still" "$previous_engine_preview" "$engine_still" "$engine_preview" \
                >/dev/null 2>&1 || true
            "$WALLPAPER_ENGINE" apply "$engine_path" "$engine_fps" "$engine_scaling" "$engine_silent"
        else
            "$WALLPAPER_ENGINE" stop
            "$SWITCHWALL" --noswitch
        fi
        ;;
    *)
        echo "Error: unknown action: $action" >&2
        exit 1
        ;;
esac
