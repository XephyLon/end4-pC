#!/usr/bin/env bash
# presets.sh - manage shell config presets | just for fun I could have done it from quickshell directly =P
# Usage:
#   presets.sh --save <name>
#   presets.sh --remove <name>
#   presets.sh --apply <name>

CONFIG_DIR="$HOME/.config/illogical-impulse"
CONFIG_FILE="$CONFIG_DIR/config.json"
PRESETS_DIR="$CONFIG_DIR/presets"
SCRIPT_DIR="$HOME/.config/quickshell/end4-pC/scripts"
SWITCHWALL="$HOME/.config/quickshell/end4-pC/scripts/colors/switchwall.sh"
WALLPAPER_ENGINE="$HOME/.config/quickshell/end4-pC/scripts/wallpapers/wallpaper-engine.sh"

mkdir -p "$PRESETS_DIR"

action="$1"
name="$2"

if [ -z "$name" ]; then
    echo "Error: missing preset name" >&2
    exit 1
fi

case "$action" in
    --save)
        description="$3"
        jq 'del(._presetMeta)' "$CONFIG_FILE" > "$PRESETS_DIR/${name}.json"
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
        jq -s '.[0] * .[1] | del(._presetMeta)' "$CONFIG_FILE" "$preset_file" \
            > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
        engine_path="$(jq -r '.wallpaperSelector.wallpaperEngine.activePath // empty' "$CONFIG_FILE")"
        if [ -n "$engine_path" ] && [ -d "$engine_path" ]; then
            engine_preview="$(jq -r '.wallpaperSelector.wallpaperEngine.activePreview // empty' "$CONFIG_FILE")"
            engine_fps="$(jq -r '.wallpaperSelector.wallpaperEngine.fps // 30' "$CONFIG_FILE")"
            engine_scaling="$(jq -r '.wallpaperSelector.wallpaperEngine.scaling // "fill"' "$CONFIG_FILE")"
            engine_silent="$(jq -r '.wallpaperSelector.wallpaperEngine.silent // true' "$CONFIG_FILE")"
            if [ -n "$engine_preview" ]; then
                "$SWITCHWALL" --noswitch --coloronly --image "$engine_preview"
            fi
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
