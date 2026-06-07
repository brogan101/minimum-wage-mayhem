# Phase 27 Visual Asset Prop Texture Report

Date: 2026-06-06

## Scope

Phase 27 upgrades the current playable restaurant presentation with project-local Godot primitives, procedural cartoon materials, labels, trim pieces, station silhouettes, lighting, and HUD polish. No external art/audio assets, paid assets, online dependencies, DLC/business expansion, multiplayer, or new major gameplay systems were added.

Restaurant story-event count remains 180.

## Visual Changes

- Added a stronger fake restaurant identity around the `Minimum Wage Mayhem` fast-food brand:
  - exterior/front brand sign
  - menu-board panels and item labels
  - warmer lobby wall panels
  - cooler kitchen tile wall panels
  - drive-thru speaker/order landmark
  - clock-out wall poster
- Made major zones more readable:
  - lobby/front counter
  - drive-thru lane/window
  - prep/bagging
  - hot line/grill/fryer
  - drink/sauce/restock
  - trash/cleaning
  - clock-out
- Improved station silhouettes with handmade primitive props:
  - register drawer, receipt curl, total screen
  - grill grease guard and spatula
  - fryer basket mesh
  - wrapper stack and folded bag details
  - drink dispenser body, screen, and nozzles
  - sauce packet rack
  - trash lid
  - mop bucket and handle
  - drive-thru pickup shelf and handoff arrow
- Improved CustomerCar readability with:
  - side stripes
  - roof order sign
  - windshield shine
  - front plate
  - door handles
- Improved HUD presentation with:
  - ticket-paper treatment
  - branded ticket edge
  - objective/timer badges
  - manager clipboard styling
  - career ribbon
  - prompt key badge

## Asset/Licensing

- No external assets were added.
- No paid assets were added.
- All Phase 27 visuals are Godot primitives, Label3D text, runtime-generated procedural materials, and project-local GDScript.
- `ASSET_ATTRIBUTION.md` and `FILE_INCLUSION_MANIFEST.md` were updated.
- Screenshot proof is generated under `artifacts/phase27_visual_asset_prop_texture.png`; `artifacts/` remains excluded from git.

## Validation

Baseline static validation:

```text
python tools/validate_all.py
[PASS] Validation suite passed
[PASS] Phase 26 fun content/shift variety contract valid
[PASS] Restaurant story event count preserved at 180
```

Phase 27 visual smoke:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase27_visual_asset_prop_texture_check.gd
[PASS] Phase 27 visual node exists: Phase27ExteriorBrandSign
[PASS] Phase 27 visual node exists: Phase27DriveThruOrderSpeaker
[PASS] Phase 27 visual node exists: Phase27RegisterDrawer
[PASS] Phase 27 visual node exists: Phase27GrillGreaseGuard
[PASS] Phase 27 visual node exists: Phase27FryerBasketMeshA
[PASS] Phase 27 visual node exists: Phase27DrinkDispenserBody
[PASS] Phase 27 customer car detail exists: Phase27RoofOrderSign
[PASS] Phase 27 HUD polish node exists: Phase27OrderTicketPaper
[PASS] One order still completes after visual upgrade
[PASS] Restaurant story event count remains 180
[PASS] Phase 27 visual asset prop texture check passed
```

Screenshot proof:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --path . --script res://tools/phase27_visual_screenshot.gd
[PASS] Phase 27 rendered screenshot saved: res://artifacts/phase27_visual_asset_prop_texture.png
```

Final static validation:

```text
python tools/validate_all.py
[PASS] Validation suite passed
[PASS] Phase 27 visual asset/prop/texture contract valid
[PASS] Restaurant story event count preserved at 180
```

Final regression smokes:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase14_full_shift_smoke.gd
[PASS] Phase 14 full shift stabilization smoke check passed

tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase20_multi_shift_save_load_stress.gd
[PASS] Phase 20 two-shift save/load progression stress check passed
```

## Acceptance

| Requirement | Status |
|---|---|
| Restaurant no longer feels like plain prototype boxes | Passed; added branded signage, richer wall/floor treatments, station props, and identity landmarks |
| Major stations are visually recognizable | Passed; register, grill, fryer, drink, sauce, trash, drive-thru, prep, and clock-out have clearer silhouettes/signage |
| Props/food/customer car are more readable | Passed; added station props and Phase 27 car details while preserving Phase 21/24 food props |
| HUD looks more game-like and less debug-like | Passed; ticket paper, clipboard, prompt, objective, timer, and career trim were added |
| One full shift still works | Passed through Phase 14 full-shift smoke |
| Multi-shift save/load still works | Passed through Phase 20 two-shift stress smoke |
| Validation passes | Passed |
| Story event count remains 180 | Passed in Phase 27 smoke and final static validation |

## What Remains

- Human-controlled visible playtest is still needed.
- Physical controller hardware validation is still pending.
- Final production art, animation, and audio assets are still not complete.
- HUD scaling should still get a dedicated manual/multi-resolution pass.
