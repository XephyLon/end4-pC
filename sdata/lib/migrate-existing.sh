#!/usr/bin/env bash
# migrate-existing.sh — detect + transition a prior illogical-impulse install.
# Sourced by the installer. Package query is injectable for testing.

## NOTE: this is intentionally `declare -g`, not `: "${VAR:=default}"`.
## Under a bare `VAR=val source this-file`, bash treats VAR as a
## command-prefix assignment that is torn down the moment the `source`
## statement finishes (non-POSIX bash default) — a plain assignment made
## *inside* the sourced file inherits that same transient scope and also
## evaporates. `declare -g` explicitly (re)binds it as a real global, so
## callers that source this file and then call has_legacy_packages/
## legacy_packages afterwards (as the test harness and the installer do)
## still see the override.
declare -g IMI_PKG_QUERY_CMD="${IMI_PKG_QUERY_CMD:-pacman -Qq}"   # per-distro caller overrides this

has_legacy_packages() {
    eval "$IMI_PKG_QUERY_CMD" 2>/dev/null | grep -q '^illogical-impulse-'
}

# Print the legacy package basenames for the caller to map onto
# immaterial-impulse-* and remove.
legacy_packages() {
    eval "$IMI_PKG_QUERY_CMD" 2>/dev/null | grep '^illogical-impulse-'
}
