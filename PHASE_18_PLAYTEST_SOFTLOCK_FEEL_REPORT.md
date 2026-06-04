# Phase 18 Playtest Softlock Feel Report

Date: 2026-06-04

## Result

Phase 18 made the current first shift easier to understand and less brittle without adding a major new system or new content catalog.

The proven loop remains local-only and single-player: main menu, New Game, player spawn, active customer order, drive-thru handoff, clock-out/end shift, recap, local save/load, and return to menu.

## Changes Made

- Tuned first-shift movement in `scripts/player/PlayerController.gd`: walk speed 4.2, sprint speed 6.5, mouse sensitivity 0.0018, controller look sensitivity 2.1.
- Added a player fall reset in `PlayerController.gd` so falling out of the restaurant bounds returns the player to the spawn position instead of softlocking.
- Increased interaction reach in `scripts/player/PlayerInteraction.gd` from 2.5 to 3.2.
- Added HUD feedback when the player presses interact while looking at nothing usable or an object that is not currently interactable.
- Increased first-shift duration in `scripts/managers/ShiftManager.gd` from 300 seconds to 360 seconds.
- Updated first-shift HUD guidance in `scripts/Main.gd` and `scripts/ui/GameHUD.gd` to explicitly name ORDER TICKET, Training Burger, DRIVE-THRU, and CLOCK OUT.
- Added clearer drive-thru feedback in `scripts/stations/DriveThruWindow.gd` for empty or invalid handoff attempts.
- Added `tools/phase18_softlock_feel_check.gd`.
- Extended `tools/validate_all.py` with a Phase 18 playtest/softlock/feel contract.

## Runtime Proof

Godot Phase 18 softlock/feel smoke:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase18_softlock_feel_check.gd
[PASS] Main scene loads
[PASS] New player starts at main menu
[PASS] HUD stays hidden before shift
[PASS] Player spawns in the 3D restaurant
[PASS] Player spawn is stable and predictable
[PASS] Walk speed is tuned for first-time control
[PASS] Sprint speed is restrained for the demo layout
[PASS] Mouse look is calmer for first shift
[PASS] Controller look default is calmer
[PASS] Interaction range is forgiving
[PASS] Shift starts from New Game
[PASS] Shift timer gives a first-time player breathing room
[PASS] Objective names delivery and clock-out
[PASS] First-shift guidance is understandable without docs
[PASS] Task list is visible during the shift
[PASS] Customer/order flow creates an active order
[PASS] Active order has a known fallback item
[PASS] Drive-thru handoff attempts the current order
[PASS] Drive-thru handoff can complete successfully
[PASS] Successful handoff is logged
[PASS] Customer car is not stuck waiting forever after fulfillment
[PASS] Out-of-bounds fall resets player to spawn
[PASS] Pause menu opens and pauses
[PASS] Pause menu returns to gameplay
[PASS] Physical clock-out ends shift and opens recap
[PASS] End shift saves completed customer result
[PASS] Local save/load roundtrip remains valid
[PASS] End-shift flow leaves no active-shift softlock
[PASS] Return-to-menu works after results
[PASS] Keyboard interact input is mapped
[PASS] Keyboard movement inputs are mapped
[PASS] Pause input is mapped
[WARN] No physical controller detected; controller InputMap only was checked
[PASS] Controller-compatible InputMap events exist
[PASS] Phase 18 softlock/feel smoke check passed
```

## Acceptance Status

| Requirement | Status | Evidence |
|---|---|---|
| One full shift starts, runs, ends, and saves | Passed | `tools/phase18_softlock_feel_check.gd` |
| Player understands what to do without docs | Improved and runtime-checked | HUD objective/guidance checks in Phase 18 smoke |
| No known softlock blocks the first shift | Passed for automated first-shift path | Customer clear, fall reset, clock-out, save/load, return-to-menu checks |
| Static validation passes | Passed | `python tools/validate_all.py` |
| Godot runtime validation | Passed for automated headless smoke | Phase 18 smoke output above |
| Manual human playtest | Still pending | No manual keyboard/mouse session was claimed |
| Physical controller validation | Still pending | No controller detected; InputMap only checked |

## Softlock Checks Covered

- Customer does not remain in waiting state forever after a correct handoff.
- The first order is a known Burger fallback item.
- Drive-thru handoff succeeds through the current interact fallback.
- Empty/invalid drive-thru attempts now give clearer HUD feedback.
- Player falling below the world resets to spawn.
- Clock-out station ends the shift and opens the recap.
- End shift writes a local save with the completed customer result.
- Save/load roundtrip returns valid local data.
- Return-to-menu works after results.
- Daily tasks remain optional and do not block shift completion.

## What Feels Better

- Movement is less fast in the small restaurant footprint.
- Mouse/controller look defaults are calmer.
- Interact range is more forgiving around stations.
- The HUD tells a first-time player the core route: ticket, burger, drive-thru, clock out.
- The drive-thru window gives actionable feedback when the player has empty hands or the wrong item.
- A fall out of bounds no longer strands the shift.

## Still Pending

- Manual player-controlled keyboard/mouse playtest in a real window.
- Physical controller test with actual hardware.
- More viewport/resolution HUD QA.
- Richer prep affordances for bagging, drinks, and fries.
- Optional real `HandOffArea` collision/drop zone for the drive-thru.
- Final audio assets, final visual assets, export presets, and public-demo polish.

## Story Event Count

`data/mischief/restaurant_story_events.json` was not edited in Phase 18. The validator reports:

```text
[PASS] Restaurant story event count preserved at 180
```

## Final Validation

```text
python tools/validate_all.py
[PASS] Validation suite passed
[PASS] Main scene path exists: res://scenes/world/Main.tscn
[PASS] Scene resource paths valid: 21
[PASS] Phase 1 player scene/input contract valid
[PASS] Phase 2 interaction/pickup contract valid
[PASS] Phase 3 station food-state contract valid
[PASS] Phase 4 staff/coworker contract valid
[PASS] Phase 5 store operations contract valid
[PASS] Phase 6 daily tasks contract valid
[PASS] Phase 7 shift results/save contract valid
[PASS] Phase 8 campaign progression contract valid
[PASS] Phase 9 maximum chaos incident contract valid
[PASS] Phase 10 workplace mischief/pranks contract valid
[PASS] Phase 11 fireable offense consequence contract valid
[PASS] Phase 12 emergent restaurant memory contract valid
[PASS] Phase 13 global depth balance contract valid
[PASS] Phase 14 stabilization contract valid
[PASS] Phase 15 playability/Steam prep contract valid
[PASS] Phase 17 graybox-to-demo contract valid
[PASS] Phase 18 playtest/softlock/feel contract valid
[PASS] JSON files valid: 137
[PASS] Python tools compile: 24
[PASS] Restaurant story event count preserved at 180
[PASS] Depth bundles validated: 30
[PASS] Active GDScript placeholder/local-only blockers: 0
```
