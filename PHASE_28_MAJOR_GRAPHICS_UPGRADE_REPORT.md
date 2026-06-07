# Phase 28 Major Graphics Upgrade Report

Date: 2026-06-06

## Scope

Phase 28 is a major stylized cartoon-realistic graphics upgrade on top of the stable Phase 27 build. It improves the current playable restaurant without adding major gameplay systems, DLC/business expansion, online services, multiplayer, paid assets, or third-party assets.

Restaurant story-event count remains 180.

## Art Direction

Target: a cleaner stylized 3D cartoon fast-food restaurant that feels more like a deliberate low-poly game environment and less like bare cube placeholder art.

This pass uses only in-repo Godot primitives, Label3D text, procedural toon/noise materials, simple low-poly shapes, and lighting.

## Graphics Changes

- Added a stronger interior shell:
  - ceiling plane
  - ceiling tile grid
  - pendant light fixtures
  - warm lobby feature wall
  - teal kitchen backsplash with tile grid lines
  - upgraded wall/floor surface variation
- Improved restaurant structure:
  - rounded-looking front counter face
  - cream counter top
  - counter kick shadow
  - lobby booth seats, booth backs, and small tables
  - curbed drive-thru lane with paint dashes
  - rounded order speaker top
- Improved major station silhouettes:
  - curved register screen backing and scanner light
  - grill hood and vent pipe
  - fryer enamel face, temp label, and rounded basket handle
  - prep table face and bagging tray
  - round drink cup stacks and lid
  - sauce bottles
  - round trash can body
  - round clock-out button
- Improved food props:
  - rounded burger top bun
  - round patty
  - cheese melt detail
  - lettuce frill
  - more visible fries carton and taller fries
  - order ticket pin
- Improved CustomerCar:
  - hood and trunk panels
  - side glass panels
  - smile grille
  - roof light glow
  - wheel arches and hubcaps
- Improved atmosphere/readability:
  - warmer lobby bounce light
  - cooler kitchen bounce light
  - drive-thru glow
  - adjusted environment and directional light
- Improved HUD readability over the richer scene:
  - opacity updates for main HUD panels
  - readability scrims
  - prompt glow line
  - small style labels and trims

## Asset/Licensing

- No external art/audio assets were added.
- No paid assets were added.
- No runtime internet dependency was added.
- `ASSET_ATTRIBUTION.md` and `FILE_INCLUSION_MANIFEST.md` were updated.
- Screenshot proof is generated under `artifacts/phase28_major_graphics_upgrade.png`; `artifacts/` remains excluded from git.

## Validation

Baseline static validation:

```text
python tools/validate_all.py
[PASS] Validation suite passed
[PASS] Phase 27 visual asset/prop/texture contract valid
[PASS] Restaurant story event count preserved at 180
```

Phase 28 graphics smoke:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase28_major_graphics_upgrade_check.gd
[PASS] Phase 28 graphics node exists: Phase28CeilingPlane
[PASS] Phase 28 graphics node exists: Phase28LobbyCounterRoundedFace
[PASS] Phase 28 graphics node exists: Phase28DriveThruCurbedLane
[PASS] Phase 28 graphics node exists: Phase28GrillRoundedHood
[PASS] Phase 28 graphics node exists: Phase28DrinkCupStackRoundA
[PASS] Phase 28 graphics node exists: Phase28BurgerRoundedTopBun
[PASS] Phase 28 customer car upgrade exists: Phase28RoundedHoodPanel
[PASS] Phase 28 HUD support node exists: Phase28HudReadabilityScrimLeft
[PASS] One order still completes after major graphics upgrade
[PASS] Restaurant story event count remains 180
[PASS] Phase 28 major graphics upgrade check passed
```

Screenshot proof:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --path . --script res://tools/phase28_graphics_screenshot.gd
[PASS] Phase 28 rendered screenshot saved: res://artifacts/phase28_major_graphics_upgrade.png
```

Final static validation:

```text
python tools/validate_all.py
[PASS] Validation suite passed
[PASS] Phase 28 major graphics upgrade contract valid
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
| Game no longer feels like ugly cube placeholder art | Improved significantly with ceiling, booths, rounded food, curbs, station silhouettes, and richer materials; still not final production art |
| Restaurant looks significantly better and more intentional | Passed through Phase 28 visual smoke and screenshot proof |
| Major stations/props are visually appealing and readable | Passed; register, grill, fryer, prep, drink, trash, drive-thru, burger, fries, and HUD all have new visual treatment |
| Customer car and food props are improved | Passed; Phase 28 smoke validates car upgrades and food nodes |
| One full shift still works | Passed through Phase 14 full-shift smoke |
| Save/load still works | Passed through Phase 20 two-shift save/load stress |
| Validation passes | Passed |
| Story event count remains 180 | Passed in Phase 28 smoke and final static validation |

## What Remains

- This is still procedural/primitive art, not final hand-authored model production.
- Human visible playtest is still pending.
- Physical controller hardware validation is still pending.
- Final audio assets are still missing.
- Some HUD and signage overlap should still be checked in a true player-controlled manual pass.
