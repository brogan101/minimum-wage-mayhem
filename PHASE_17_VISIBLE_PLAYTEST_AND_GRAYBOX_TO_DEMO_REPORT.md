# Phase 17 Visible Playtest And Graybox To Demo Report

Date: 2026-06-04

## Result

Phase 17 moved the current build from a bare graybox systems test toward a readable 3D cartoon fast-food vertical-slice demo without adding a new systems layer.

The proven loop is still the same local-only single-player MVP loop: menu, New Game, 3D shift, active order, drive-thru handoff, end shift, recap, local save/load, and progression. The Phase 17 work improves how that loop reads on screen.

## Implemented

- Added runtime restaurant dressing in `scripts/Main.gd` through `_apply_phase17_demo_visuals()`.
- Added sky/background color, warmer ambient light, stronger demo lights, wall blocks, front counter zone, kitchen color zone, drive-thru lane, handoff mat, and menu board dressing.
- Added cartoon material colors for floor, counters, grill, fryer, prep/bagging, sauce/restock, cleaning, trash, register, drive-thru, coworkers, and food placeholders.
- Added `Label3D` station signs for register, drive-thru handoff, grill, fryer, prep/bagging, sauce/restock, fix-it, trash, clean, and clock-out/end-shift guidance.
- Added a physical `ClockOutStation` interactable that calls the existing end-shift/recap path.
- Added `scenes/customers/CustomerCar.tscn`.
- Reworked `scripts/customers/CustomerCar.gd` so it is safe for the MVP: it spawns visibly, drives to the window, generates the proven burger order through `OrderManager.generate_new_order()`, updates HUD customer state, logs the waiting customer, and exits after order fulfillment.
- Preserved the fallback order path if the customer car scene is missing or fails to load.
- Reworked `scripts/ui/GameHUD.gd` into readable runtime panels: order ticket, objective, customer status, held item, first-shift guidance, event feed, task panel, timer, wallet/rank, staff, and store status.
- Added held-item HUD updates from `scripts/player/PlayerInteraction.gd`.
- Added correct/wrong handoff HUD feedback from `scripts/stations/DriveThruWindow.gd`.
- Added task completion feedback/audio hook from `scripts/store/StoreOpsStation.gd`.
- Added placeholder-safe audio hooks in `scripts/managers/AudioManager.gd` for interact, pickup, drop, order received, correct handoff, wrong handoff, task complete, shift start, and shift end.
- Added `tools/phase17_demo_visual_check.gd`.
- Added `tools/phase17_rendered_screenshot.gd`.
- Added `tools/phase17_player_view_screenshot.gd`.
- Extended `tools/validate_all.py` with a Phase 17 graybox-to-demo contract.

## Validation Proof

Static validation:

```text
python tools/validate_all.py
[PASS] Validation suite passed
[PASS] Phase 17 graybox-to-demo contract valid
[PASS] Restaurant story event count preserved at 180
```

Godot boot:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --quit
MVP boot: Player spawned.
```

Full-shift runtime:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase14_full_shift_smoke.gd
[PASS] One full shift can complete
[PASS] Save/load roundtrip works
[PASS] Phase 14 full shift stabilization smoke check passed
```

Menu/playability runtime:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase15_menu_playability_check.gd
[PASS] Phase 15 menu playability smoke check passed
```

Phase 17 demo visual runtime:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase17_demo_visual_check.gd
[PASS] Phase 17 demo dressing exists
[PASS] Station has readable sign: DriveThruStation
[PASS] CustomerCar scene loads
[PASS] Visible CustomerCar spawns
[PASS] Customer car creates active order
[PASS] HUD shows customer drive-thru status
[PASS] HUD shows readable order ticket
[PASS] CustomerCar shows exactly one color body
[PASS] Physical clock-out station is interactable
[PASS] Physical clock-out opens shift recap
[PASS] Phase 17 demo visual smoke check passed
```

## Screenshot Status

Rendered screenshot proof now exists:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --path . --script tools/phase17_rendered_screenshot.gd
[PASS] Phase 17 rendered screenshot saved: res://artifacts/phase17_rendered_demo.png
```

Overview artifact:

```text
artifacts/phase17_rendered_demo.png
```

Player-view screenshot proof:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --path . --script tools/phase17_player_view_screenshot.gd
[PASS] Phase 17 player-view screenshot saved: res://artifacts/phase17_player_view_demo.png
```

Player-view artifact:

```text
artifacts/phase17_player_view_demo.png
```

The screenshots use scripted cameras and the real Vulkan renderer. They are rendered proof, not a manual controller/human playtest.

## Playable Now

- A new player starts from the menu into the local 3D shift.
- The restaurant has a sky/background color, lit interior, walls, distinct floor zones, counter/kitchen/drive-thru separation, and a visible drive-thru lane.
- Major stations are labeled in-world.
- The drive-thru handoff mat and drive-thru sign make the delivery destination clearer.
- The clock-out station gives ending the shift a visible physical target as well as the pause-menu path.
- A lightweight customer car scene spawns and reaches the window.
- The active order appears as a HUD order ticket.
- The HUD shows first-shift guidance, customer status, held item, objective, timer, wallet/rank, tasks, station feedback, and event feed.
- Correct/wrong handoff feedback is surfaced through HUD and audio hooks.
- One full shift still starts, runs, ends, saves, loads, and records progression.

## Still Not Proven

- Manual visible playtest with player-controlled movement/camera is still pending.
- Physical controller validation is still pending.
- The rendered overview and player-view screenshots prove current visual direction, but do not prove final camera feel, sign readability at every angle, or text overlap at every viewport.
- Final audio files are not present; audio hooks currently fall back safely.
- Bagging/drink/fries are still affordance-level, not a richer prep minigame.
- Export presets and final release assets remain pending.

## Story Event Count

`data/mischief/restaurant_story_events.json` was not edited. The validator still reports:

```text
[PASS] Restaurant story event count preserved at 180
```

## Next Recommended Work

Run the first true visible/manual demo QA pass:

- open the game in a real Godot window
- capture desktop screenshots
- verify camera/spawn/sign readability
- test keyboard/mouse movement feel
- test a physical controller
- adjust HUD for real viewport sizes
- tune collision and station placement from actual play
