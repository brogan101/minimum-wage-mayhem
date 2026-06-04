# Phase 14 Stabilization Audit

## Scope

Phase 14 is a stabilization and bug-fix pass, not a content expansion. The audit checked scene references, runtime scripts, autoload usage, interaction prompts, station interactions, order handoff, shift start/end, recap generation, save/load, campaign progression, Phase 13 depth wiring, status docs, and the restaurant story-event count lock.

## What Was Checked

- `python tools/validate_all.py` Phase 1-13 baseline before stabilization.
- Godot headless project boot with `godot --headless --path . --quit`.
- Full-shift smoke path through `tools/phase14_full_shift_smoke.gd`.
- Scene resource references in `scenes/world/Main.tscn`.
- Drive-thru/order handoff connection from the 3D station.
- Save/load roundtrip through `SaveSystem`.
- Campaign progression through `CareerManager`.
- Phase 13 depth recap/save continuity.
- Brittle direct node lookups in older active scripts.
- Restaurant story-event count in `data/mischief/restaurant_story_events.json`.

## What Was Broken

- `DriveThruStation` in `scenes/world/Main.tscn` was still using the generic `Interactable` script, so it could log an interaction but could not actually hand off an order.
- `DriveThruWindow.gd` used hard autoload references such as `OrderManager.validate_bag(...)`, which is fragile during parse/import and makes fallback behavior harder to validate.
- `DriveThruWindow.gd` extended `Interactable` by global class name, which Godot exposed as a class-order parse problem when the scene switched to that script.
- The drive-thru handoff had no robust interact fallback for the current MVP setup without a `HandOffArea`.
- Older active helper scripts had brittle direct node lookups:
  - `scripts/employees/EmployeeAI.gd`
  - `scripts/employees/EmployeeAI_Actions.gd`
  - `scripts/stations/DrinkStation.gd`
  - `scripts/ui/BeefBattleUI.gd`
- The first drive-thru success cleanup produced a tween warning by triggering a pop effect on an item and freeing that item in the same tick.

## What Was Fixed

- Wired `DriveThruStation` to `scripts/stations/DriveThruWindow.gd`.
- Changed `DriveThruWindow.gd` to extend `res://scripts/stations/Interactable.gd` directly.
- Added a safe 3D interact fallback to `DriveThruWindow.gd` so the player can hand off a carried `FoodBag`, burger, patty, fries, or soda item.
- Routed drive-thru validation through runtime autoload lookups with missing-manager fallbacks.
- Added EventLog entries for empty, invalid, successful, failed, and missing-manager drive-thru handoffs.
- Moved the success pop effect to the station instead of the delivered item before freeing the item.
- Hardened older scripts to use safe `find_child` / `get_node_or_null` / `_autoload` patterns instead of direct node assumptions.
- Added `tools/phase14_full_shift_smoke.gd` to prove at least one full shift can complete without softlocking.
- Extended `tools/validate_all.py` with a Phase 14 stabilization contract.

## Validation Output

Latest static validation:

```text
[PASS] Validation suite passed
[PASS] Main scene path exists: res://scenes/world/Main.tscn
[PASS] Scene resource paths valid: 20
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
[PASS] JSON files valid: 137
[PASS] Python tools compile: 24
[PASS] Restaurant story event count preserved at 180
[PASS] Depth bundles validated: 30
[PASS] Active GDScript placeholder/local-only blockers: 0
```

## Godot Runtime Status

Godot is available repo-locally:

```text
godot --headless --version
4.3.stable.official.77dcf97d8
```

Headless boot status:

```text
godot --headless --path . --quit
Godot Engine v4.3.stable.official.77dcf97d8 - https://godotengine.org
TUTORIAL START: Welcome to the grind, rookie.
CURRENT TASK: Walk to the Grill
DriveThruWindow missing HandOffArea; use interact fallback in MVP.
MVP boot: Player spawned.
Transitioning to Apartment Hub...
Apartment hub requested. Using lightweight MVP boot path.
--- STARTING NEW SHIFT ---
SHIFT STARTED: You have 300 seconds to survive.
CustomerCar scene missing. Generating fallback MVP order.
```

## Full Shift Smoke Status

One full shift is playable through automated smoke proof:

```text
godot --headless --path . --script tools/phase14_full_shift_smoke.gd
[PASS] Player exists for playable shift
[PASS] Drive-thru station has handoff interaction
[PASS] Training burger exists for fallback order handoff
[PASS] Core shift/save/progression autoloads exist
[PASS] Phase 13 depth runtime remains wired
[PASS] Player interaction handler exists
[PASS] Order handoff attempts an order
[PASS] Order handoff can complete successfully
[PASS] Order handoff pays out or tracks earnings
[PASS] Drive-thru delivery logged
[PASS] One full shift can complete
[PASS] Full shift recap keeps Phase 13 depth section
[PASS] Shift result records served customer
[PASS] Shift result applies campaign progression
[PASS] Save contains completed shift
[PASS] Save preserves depth summary
[PASS] Save/load roundtrip works
[PASS] Progression records shift history
[PASS] Phase 14 full shift stabilization smoke check passed
```

## Save/Load Status

Save/load works in the full-shift smoke test. The saved payload includes `last_shift`, `next_shift`, career data, completed customer count, and Phase 13 `depth_summary`. `SaveSystem.load_game()` returns the saved career and shift data successfully.

## Progression Status

Progression works in the smoke path. Completing the order gives cash/earnings, XP, shift performance history, and campaign progression fields through `CareerManager`.

## Restaurant Story Event Count

The restaurant story event count is still locked at 180. `python tools/validate_all.py` validates the count against `V22_RESTAURANT_STORY_EVENT_COUNT_LOCK.json`.

## What Remains

- The current smoke path uses the MVP fallback order and Training Burger handoff. The richer customer-car scene still needs a real `CustomerCar.tscn` or equivalent visual customer arrival scene.
- `DriveThruWindow` currently reports that `HandOffArea` is missing and correctly uses the interact fallback. Adding the area would improve physical drop-off affordance, but the current 3D interact path works.
- Manual visible-play verification is still needed for player movement feel, camera toggling, and HUD placement.
- Missing audio files fall back cleanly through `AudioManager`; final audio assets remain polish work.
