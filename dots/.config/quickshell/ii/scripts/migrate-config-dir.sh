#!/usr/bin/env bash
# migrate-config-dir.sh — one-time move of the ImI data dir from the old
# illogical-impulse name. Idempotent: no-op if the new dir exists or the old
# one is absent.
set -euo pipefail

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
old="$config_home/illogical-impulse"
new="$config_home/immaterial-impulse"

if [[ -d "$new" ]]; then
    exit 0            # already migrated / fresh install
fi
if [[ ! -d "$old" ]]; then
    exit 0            # nothing to migrate
fi

mv "$old" "$new"
echo "[ImI] migrated config dir: $old -> $new" >&2
