# Phase 21 Art Texture Prop Pass Report

Date: 2026-06-04

## Objective

Make the current playable shift read more like a simple 3D cartoon fast-food demo instead of a graybox, without adding major gameplay systems or hiding broken gameplay with art.

## Repo And Baseline

- Ran `git pull --ff-only`; repo was already up to date.
- Read the requested source-of-truth, Phase 19/20, validation, status, manifest, publish, acceptance, and known-issues docs.
- Ran `python tools/validate_all.py` before Phase 21 edits; validation passed and restaurant story-event count remained 180.
- No external art/audio assets were added.
- `data/mischief/restaurant_story_events.json` was not edited.

## Implemented Visual Work

Phase 21 builds on the existing Phase 17/19 runtime primitive dressing in `scripts/Main.gd`.

- Improved lighting/environment:
  - brighter sky color
  - warmer ambient light
  - stronger directional light
  - adjusted shadow/light angle
  - added menu/prep glow lights
- Improved restaurant identity:
  - tile grout lines
  - wall stripes
  - baseboards
  - branded wall sign
  - counter trim
  - clearer store boundary accents
- Improved drive-thru/handoff:
  - window frame
  - red awning
  - painted drive-thru lane borders
  - bright handoff target ring
  - handoff cue label
- Improved station recognition:
  - register screen, glow, receipt printer, keypad
  - grill flat-top, grate lines, heat knobs
  - fryer vat, oil surface, basket handle, fry sticks
  - prep ticket rail, order ticket card, cutting board
  - soda cups, fry carton lip
  - clock-out face/button/stripe
- Improved food/order readability:
  - static layered burger prop on prep counter
  - readable raw patty prop
  - order ticket card/text
  - preserved Training Burger gameplay pickup item
- Improved CustomerCar visuals:
  - windshield
  - rear window
  - bumpers
  - headlights/tail lights
  - order bubble card/text
  - preserved existing color variants
- Improved HUD styling:
  - game-like panel header strips
  - prompt accent strip
  - stronger panel colors
  - font shadow styling

## Validation

Static validation:

```text
python tools/validate_all.py
[PASS] Validation suite passed
[PASS] Restaurant story event count preserved at 180
```

Phase 21 normal-renderer runtime art check:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --path . --script res://tools/phase21_art_direction_check.gd
[PASS] Phase 21 art direction runtime check passed
```

Phase 21 rendered screenshot:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --path . --script res://tools/phase21_rendered_screenshot.gd
[PASS] Phase 21 rendered screenshot saved: res://artifacts/phase21_art_direction_demo.png
```

Full-shift regression:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase14_full_shift_smoke.gd
[PASS] Phase 14 full shift stabilization smoke check passed
```

## Visual Proof

Screenshot artifact generated locally:

```text
artifacts/phase21_art_direction_demo.png
```

The screenshot is intentionally excluded from GitHub by `.gitignore` because artifacts are generated proof, not required project source.

## Godot Status

- Godot automated runtime validation passed.
- Real renderer Phase 21 art check passed.
- Headless full-shift smoke passed.
- Manual player-controlled playtest was not performed.
- Physical controller hardware testing was not performed.

Known note: the headless dummy renderer can emit a non-blocking mesh cleanup error in the Phase 21 visual smoke after dynamic visual checks. The same Phase 21 script passes cleanly with the normal renderer, and the canonical full-shift headless smoke passes cleanly.

## Acceptance

| Requirement | Status |
|---|---|
| Restaurant no longer plain graybox blocks | Passed via Phase 21 props/materials/screenshot |
| Main stations visually recognizable | Passed |
| Drive-thru/customer handoff visually clear | Passed |
| Food/order items more readable | Passed |
| HUD more game-like | Passed |
| One full shift still passes | Passed through Phase 14 full-shift smoke |
| Validation passes | Passed |
| Story event count remains 180 | Passed |
| Clean commit/push | Passed; see final git proof for commit hash and push status |

## Remaining Work

- Manual visible playtest from the player camera.
- Physical controller hardware test.
- Functional drink/fry/bagging prep loops beyond visual affordances.
- Optional `DriveThruWindow.HandOffArea` trigger-volume handoff.
- Final audio assets.
- Export presets and release packaging.
