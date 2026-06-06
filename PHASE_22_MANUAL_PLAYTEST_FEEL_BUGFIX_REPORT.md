# Phase 22 Manual Playtest Feel Bugfix Report

Date: 2026-06-05

## Objective

Test the current first-shift experience like a first-time player and fix scoped friction, softlocks, and unclear feel without adding major systems.

## Baseline

- Pulled latest `master`; repo was already up to date.
- Read Phase 21 redo report, source of truth, implementation status, validation report, phase log, solo-shift acceptance, and known issues.
- Ran `python tools/validate_all.py` before edits; validation passed and restaurant story-event count remained 180.
- Ran the existing full-shift and Phase 21 redo smokes before edits.

## Fixes Made

- Fixed held-item interaction feel:
  - `E / A` now uses a held item on the station the player is aiming at.
  - `Q / X` is now the explicit drop action.
  - Holding food while aiming at the drive-thru now completes the handoff through `PlayerInteraction`, not only through direct test calls.
- Updated controls text to match the new behavior.
- Added clearer held-item prompts:
  - station target: use held item at station
  - no station target: press `Q / X` to drop
- Added a runtime `HandOffArea` fallback to `DriveThruWindow`.
  - The build no longer prints the missing `HandOffArea` warning on boot.
  - The drive-thru now has a real handoff target volume while keeping the interact fallback.
- Added `tools/phase22_manual_playtest_feel_check.gd`.
- Extended `tools/validate_all.py` with a Phase 22 contract.

## Validation

Static validation:

```text
python tools/validate_all.py
[PASS] Validation suite passed
[PASS] Phase 22 manual playtest/feel contract valid
[PASS] Restaurant story event count preserved at 180
```

Phase 22 feel smoke:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase22_manual_playtest_feel_check.gd
[PASS] Drive-thru has real handoff area
[PASS] E no longer doubles as drop while holding food
[PASS] Held food can be used on the drive-thru station
[PASS] Drive-thru order completes through player interaction path
[PASS] Empty handoff gives recovery feedback
[PASS] Phase 22 manual playtest feel smoke check passed
```

Full-shift regression:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase14_full_shift_smoke.gd
[PASS] Phase 14 full shift stabilization smoke check passed
```

Pause/save/menu regression:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase18_softlock_feel_check.gd
[PASS] Pause menu opens and pauses
[PASS] Pause menu returns to gameplay
[PASS] Physical clock-out ends shift and opens recap
[PASS] Local save/load roundtrip remains valid
[PASS] Return-to-menu works after results
[PASS] Phase 18 softlock/feel smoke check passed
```

Menu/playability regression:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase15_menu_playability_check.gd
[PASS] HUD objective tracker is populated
[PASS] Phase 15 menu playability smoke check passed
```

## Manual Status

No human player-controlled manual session was claimed. Godot automated and scripted runtime checks were run. Physical controller hardware was not detected during the Phase 22 smoke, so controller hardware proof remains pending; InputMap controller bindings were validated.

## Acceptance

| Requirement | Status |
|---|---|
| First shift understandable without docs | Passed through Phase 21 route/HUD plus Phase 22 handoff prompt fix |
| Movement/camera feel better | Passed through Phase 21 FOV/look tuning and Phase 18/21 smokes |
| No known first-shift softlock | Passed through Phase 14/18/22 smokes |
| HUD/layout readable | Passed through Phase 21 redo and Phase 19 viewport checks |
| Validation passes | Passed |
| Godot smoke passes | Passed |
| Story event count remains 180 | Passed |
| Clean commit/push | Passed; see final git proof |

## Remaining Work

- True human-controlled visible playtest is still pending.
- Physical controller hardware validation remains pending unless a controller is connected.
- Drink, fry, and bagging remain visual affordances rather than full prep loops.
- Final audio assets, export presets, and release packaging remain unfinished.
