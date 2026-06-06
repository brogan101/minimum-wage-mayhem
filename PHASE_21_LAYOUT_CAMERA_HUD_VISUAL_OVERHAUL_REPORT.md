# Phase 21 Layout Camera HUD Visual Overhaul Report

Date: 2026-06-05

## Objective

Redo the Phase 21 player-facing pass so the current build feels more like a playable 3D cartoon fast-food vertical slice and less like a decorated prototype. This pass does not add major gameplay systems.

## Baseline

- Pulled latest `master`; repo was already up to date.
- Read the current source-of-truth, implementation, validation, phase log, solo-shift acceptance, known-issues, and Phase 21 art report docs.
- Ran `python tools/validate_all.py` before edits; validation passed and restaurant story-event count remained 180.
- No external assets were added.
- `data/mischief/restaurant_story_events.json` was not edited.

## Implemented Redo Work

- Moved the player start to the front aisle and faced the player into the restaurant.
- Widened first-person FOV and third-person FOV.
- Increased mouse/controller look responsiveness.
- Oriented the third-person camera rig so the toggle gives a usable view.
- Added readable room zones:
  - lobby/front counter
  - drive-thru service window
  - prep/bagging
  - kitchen hot line
  - sauce/restock/clean
  - clock-out
- Added stronger layout boundaries and landmarks:
  - customer counter
  - kitchen rail
  - drive-thru divider
  - clock-out stripe
  - overhead zone signs
- Added numbered first-shift floor route markers:
  - `1 TICKET`
  - `2 BURGER`
  - `3 WINDOW`
  - `4 CLOCK`
- Added route arrows and station halos to make the first shift readable without docs.
- Cleaned HUD hierarchy:
  - active order
  - objective/timer
  - window/customer state
  - hands/held item
  - concise guidance
  - short event feed
  - daily tasks
  - money/rank/team/store summaries
- Hid debug-like boot/progress bars from the normal HUD presentation.
- Preserved Phase 19 prep affordances and the Phase 21 cartoon prop layer.

## Validation

Static validation:

```text
python tools/validate_all.py
[PASS] Validation suite passed
[PASS] Phase 21 art direction/prop contract valid
[PASS] Restaurant story event count preserved at 180
```

Runtime redo check:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase21_layout_camera_hud_overhaul_check.gd
[PASS] Phase 21 layout/camera/HUD overhaul check passed
```

Full-shift regression:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase14_full_shift_smoke.gd
[PASS] Phase 14 full shift stabilization smoke check passed
```

Rendered visual proof:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --path . --script res://tools/phase21_layout_camera_hud_screenshot.gd
[PASS] Phase 21 redo rendered screenshot saved: res://artifacts/phase21_layout_camera_hud_overhaul.png
```

## Acceptance

| Requirement | Status |
|---|---|
| Map is organized and readable | Passed via zones, counters, rails, route markers, and screenshot proof |
| Player can look around comfortably | Passed via wider FOV, more responsive look, and runtime camera check |
| HUD looks like a game, not debug text | Passed via compact panels and hidden debug-like boot/bars |
| Stations are visually obvious | Passed via station halos, signs, props, and Phase 21 art layer |
| First shift is understandable | Passed via numbered floor route and HUD objective/guidance |
| Validation passes | Passed |
| Godot smoke passes | Passed |
| Story event count remains 180 | Passed |
| Clean commit/push | Passed; see final git proof |

## Remaining Work

- Manual player-controlled playtest is still the honest next proof gap.
- Physical controller hardware validation remains pending unless a controller is connected and tested.
- Drink, fry, and bagging gameplay remain visual affordances, not complete prep loops.
- Final audio assets, export presets, and release packaging are not done.
