# Phase 19 GitHub Playtest Prep Report

Date: 2026-06-04

## Result

Phase 19 prepared the repo for a clean GitHub publish and added a small first-shift prep-affordance pass without adding major content or changing the local-only single-player scope.

## Implemented

- Added a Godot-focused `.gitignore` that excludes editor/import caches, local Godot binaries/downloads, generated screenshots, Python caches, secrets, OS/editor junk, large historical prompt packs, disabled multiplayer/co-op material, and historical validation clutter.
- Added `FILE_INCLUSION_MANIFEST.md`.
- Added `GITHUB_PUBLISH_REPORT.md`.
- Added prep-flow visual affordances in `scripts/Main.gd`: bag stack, fries bin, soda cup stack, prep arrows, and concise labels.
- Updated `scripts/ui/GameHUD.gd` first-shift guidance to mention bags, soda, and fries as marked prep affordances while keeping Burger as the current first-shift item.
- Added `tools/phase19_playtest_prep_check.gd`.
- Extended validation plan to include Phase 19 proof.

## Validation So Far

Baseline before edits:

```text
python tools/validate_all.py
[PASS] Validation suite passed
[PASS] Phase 18 playtest/softlock/feel contract valid
[PASS] Restaurant story event count preserved at 180
```

Phase 19 Godot prep smoke:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase19_playtest_prep_check.gd
[PASS] Main scene loads
[PASS] HUD exists
[PASS] Demo dressing exists
[PASS] Prep affordance exists: PrepFlowArrowTicket
[PASS] Prep affordance exists: PrepFlowArrowWindow
[PASS] Prep affordance exists: BaggingPaperBags
[PASS] Prep affordance exists: FriesReadyBin
[PASS] Prep affordance exists: SodaCupStack
[PASS] Prep affordance exists: PrepFlowLabel
[PASS] Prep affordance exists: SodaAffordanceLabel
[PASS] Prep affordance exists: FriesAffordanceLabel
[PASS] HUD guidance names prep affordances
[PASS] Objective fits viewport (1280, 720)
[PASS] Prompt fits viewport (1280, 720)
[PASS] Task list fits viewport (1280, 720)
[PASS] Objective fits viewport (1366, 768)
[PASS] Prompt fits viewport (1366, 768)
[PASS] Task list fits viewport (1366, 768)
[PASS] Objective fits viewport (1920, 1080)
[PASS] Prompt fits viewport (1920, 1080)
[PASS] Task list fits viewport (1920, 1080)
[PASS] One order still completes after prep affordance pass
[WARN] No physical controller detected; controller hardware playtest still pending
[PASS] Controller InputMap remains wired
[PASS] Phase 19 playtest prep smoke check passed
```

## Manual And Controller Status

- Manual human-controlled windowed playtest: still pending; not claimed.
- Windowed automated renderer checks: pending final command pass.
- Physical controller: no connected controller detected by Godot; InputMap compatibility remains validated.

## Story Event Count

`data/mischief/restaurant_story_events.json` was not edited. The count remains locked at 180 through validation.

## Remaining Before Content Expansion

- Run a real human windowed keyboard/mouse playtest.
- Test a physical controller with actual hardware.
- Add richer functional bagging/drink/fry prep only after the first-shift demo remains stable.
- Add final audio/assets/export presets later.
