# CONTRIBUTING.md — for coding agents

This is a workflow guide for agents (Claude Code or similar) making changes in this repo. For what
the project *is* and how it's structured, read `AGENT.md` first.

## Verify against the live shell, not just "no syntax errors"

There's no test suite and no compiler to catch mistakes — QML errors only surface at runtime, in
the log, when the affected component is actually reached. "The file saved without an Edit-tool
error" is not evidence a change works.

The reliable loop used throughout this project's history:

1. Make the edit.
2. Wait ~2-3s for the hot-reload, then check the log for new errors:
   ```bash
   LOG=/run/user/$(id -u)/quickshell/by-id/$(ls /run/user/$(id -u)/quickshell/by-id/ | head -1)/log.log
   tail -30 "$LOG" | grep -iE 'error|WARN scene'
   ```
   (`WARN scene: <file>[<line>]: ...` is a QML runtime error/warning with a precise location — treat
   these as real bugs to fix, not noise, unless you recognize them as pre-existing/unrelated.)
3. If the change is behavioral (not just visual), **drive the actual state change and read back a
   real value**, rather than reasoning about it in the abstract. This project's Hyprland/PipeWire
   integrations are full of "should be reactive" assumptions that turned out subtly wrong in
   practice (see the two examples below). A temporary `console.log` in an `onXChanged` handler,
   checked against `grep` on the log file, then removed once confirmed, is the standard technique:
   ```qml
   onSomePropertyChanged: console.log("[TempDebug] someProperty ->", someProperty)
   ```
   Always remove these before considering the change done — check with `git diff` that no stray
   `console.log`/`[TempDebug]`/similar markers are left in the final diff.
4. Don't stop at "the property changed" if the ask was about visible/clickable behavior — a property
   can be logically correct while the compositor still doesn't render or route input to it correctly
   (see the layer-shell gotchas in `AGENT.md`). When in doubt, ask the user to confirm the actual
   visual/interactive result before declaring it fixed.

Two real examples from this project's history that justify the paranoia:
- A gate (`if (!Audio.ready) return`) copied from a nearby, superficially similar handler silently
  ate every audio-device-switch toast, because the *new* device's `ready` flag lags the pointer
  swap by a tick. Nothing about this was visible from reading the code; only driving a real device
  switch and reading the log exposed it.
- A "fix" that made a bar clickable under fullscreen+special-workspace, verified via debug logging
  as "layer and mask both correct," still failed for an unrelated reason (a same-layer stacking
  conflict with a different widget) that only showed up once the user tried it for real.
- A new toast's background used `Appearance.colors.colLayer1` - a legitimate, correctly
  transparency-aware design token, chosen by reasonable-looking analogy to other cards in the
  codebase. It still rendered as flat unblurred transparency in practice, for two compounding
  reasons invisible from reading the QML alone: `contentTransparency` (which `colLayer1` derives
  from) wasn't gated on the `transparency.enable` toggle the way `backgroundTransparency` was, and
  even after fixing that, `colLayer1`'s alpha never cleared the Hyprland companion config's
  per-namespace `ignore_alpha` blur threshold the way `colLayer0` does. "Uses a real design token"
  is not the same as "uses the *right* design token for this position in the surface hierarchy" -
  see AGENT.md's `colLayer0` vs `colLayer1` note.

## Don't guess at `hyprctl` CLI syntax on this machine

This machine's Hyprland config uses a Lua binding layer, which changes what `hyprctl dispatch ...`
needs to look like when invoked manually from a shell (see `AGENT.md`). If a `hyprctl dispatch`
command errors with something mentioning Lua, don't retry variations blindly - work out the
`hl.dsp....(...)` form from the relevant `~/.config/hypr/hyprland/*.lua` file instead of guessing.
This only affects manual/CLI invocations for testing, not the QML code itself.

## Reuse before building new

Check `modules/common/widgets/` before writing a new UI primitive - tooltips, combo boxes, sliders,
form rows for the settings page, card/tile layouts, etc. almost all already exist there and are used
throughout `modules/ii/`. A fix or feature that touches a shared widget (e.g. `StyledComboBox`)
benefits every place that widget is used - that's usually preferable to a one-off local
implementation, but also means changes there have wider blast radius, so verify a couple of call
sites, not just the one you were asked about.

Pull visual values (colors, spacing, font sizes, animation curves) from `Appearance.qml` rather than
hardcoding. This is a Material 3 / Material 3 Expressive shell — match that language for new UI
(rounded containers, tonal color roles, expressive motion) rather than introducing a different look.

## Settings additions are two-sided

A new persisted option needs both halves, or it silently does nothing:
1. The schema property in `Config.qml` (inside the correct nested `JsonObject`).
2. A corresponding row in the relevant `modules/ii/settings/pages/*.qml` file, wired with
   `checked`/`value`/`currentValue` reading from `Config.options....` and an `on*Changed` handler
   writing back to it.

If a feature is gated by config (e.g. "always show X"), search for where the sibling options are
consumed (usually a `Resource`/similar component's `shown`/`visible` binding) and wire the new one
into every layout variant that repeats the pattern (this codebase often has near-duplicate blocks
for e.g. horizontal-bar vs vertical-bar vs "material style" variants of the same widget - grep for
the sibling property name to find all of them before considering the wiring complete).

## Git conventions

- Commit **one logical change per commit** unless told otherwise - a bug fix, a new feature, a typo
  fix, and a UI enhancement discovered along the way are separate commits, even if they landed in
  the same conversation back to back.
- Write real commit messages (not caveman-terse, regardless of any session-level tone setting) -
  explain *why*, especially for anything non-obvious (a gotcha worked around, a race condition
  fixed, a naming/priority decision). Future-you (or the next agent) won't have this conversation's
  context.
- Never push without explicit confirmation for that specific push. An earlier approval to push
  doesn't carry forward to later, unrelated changes.
- `git remote -v` before assuming which remote is "upstream" vs "the fork you push to" - this repo
  has both, and they matter for where a `git pull`/`git push` actually lands.

## Style

- No comments explaining *what* code does - names should do that. A comment is only worth adding for
  a non-obvious *why*: a compositor quirk being worked around, a unit conversion that isn't visually
  obvious (e.g. MiB→KB to match `/proc/meminfo`'s units), a gate that looks redundant but isn't.
- Don't add config options, abstractions, or generalized "for future use" plumbing beyond what was
  asked. This is a personal shell config, not a library - concrete and specific beats flexible and
  speculative.
