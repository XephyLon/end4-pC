#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${ILLOGICAL_IMPULSE_VIRTUAL_ENV:-}"

if [[ -z "$VENV_DIR" || ! -f "$VENV_DIR/bin/activate" ]]; then
    echo "generate-colors-venv: ILLOGICAL_IMPULSE_VIRTUAL_ENV is not a valid virtual environment" >&2
    exit 1
fi

source "$VENV_DIR/bin/activate"
exec python3 "$SCRIPT_DIR/generate_colors_material.py" "$@"
