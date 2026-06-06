# Phase 24 Career Store Manager Loop Report

Date: 2026-06-06

## Objective

Make the current build feel like it is going somewhere across multiple shifts. This pass focuses on visible Store Manager progression, cash/tips/XP continuity, rank movement, trust/morale/corporate consequences, recovery routes, next-shift setup, save/load persistence, and a lightweight life-like cartoon material polish.

## Baseline

- Ran `git pull --ff-only`; repo was already up to date.
- Read `PHASE_23_CORE_GAMEPLAY_DEPTH_REPORT.md`, `PROJECT_SOURCE_OF_TRUTH.md`, `IMPLEMENTATION_STATUS.md`, `VALIDATION_REPORT.md`, `PHASE_LOG.md`, `SOLO_SHIFT_ACCEPTANCE_TEST.md`, and `KNOWN_ISSUES.md`.
- Ran `python tools/validate_all.py` before edits; validation passed and restaurant story-event count remained 180.
- Phase 23 was confirmed as complete enough to start this phase: bagging, Burger, Fries, Soda, wrong-order retry, recap, and save/load were automated-validated.

## Career Changes

- Replaced the older 11-rank specialist split with the Phase 24 requested nine-rank path:
  - Trainee
  - Crew Member
  - Station Specialist
  - Shift Lead Candidate
  - Shift Lead
  - Assistant Manager Candidate
  - Assistant Manager
  - Acting Store Manager
  - Store Manager
- Added explicit career delta tracking for each completed shift: XP, cash, tips, promotion progress, manager trust, staff morale, corporate approval, warnings, write-ups, demotion risk, and fired risk.
- Added visible career reasons explaining why progression changed, based on accuracy, patience, tasks, Beef, reviews, money, tips, mistakes, and consequences.
- Added a recovery plan/focus after each shift, so bad or messy shifts point toward a recoverable next step rather than a dead end.
- Added pre-shift modifier history, sourced from the existing Phase 13 shift flavor/home-life/commute scaffold and persisted in career save data.
- Updated next-shift setup to carry career rank, promotion requirements, recovery focus, pre-shift modifier, unlock hooks, and warning count.
- Updated the shift recap with a new `Career Path` section showing current/next rank, score, gains, trust changes, promotion needs, reasons, and recovery focus.
- Updated the HUD rank line so the player sees current rank, next rank, XP, promotion progress, and manager trust during the shift.
- Increased results-screen report allowance so the new career explanation is not immediately truncated.

## Material And Texture Polish

- Added procedural toon/noise texture treatment to runtime materials using Godot resources only; no external assets were added.
- Added small life-like cartoon details to the current primitive restaurant dressing:
  - paper bag folds and highlights
  - burger sesame details
  - tile scuffs
  - fry salt flecks
  - soda straw
  - ketchup bottle
  - visible career path board
- This is a lightweight runtime polish pass, not a final asset pipeline or licensed texture pass.

## Validation

Static validation:

```text
python tools/validate_all.py
[PASS] Validation suite passed
[PASS] Phase 24 career/store-manager loop contract valid
[PASS] Restaurant story event count preserved at 180
```

Phase 24 Godot multi-shift smoke:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase24_career_multi_shift_loop_check.gd
[PASS] Phase 24 rank ladder matches requested path
[PASS] Career path board is visible in the restaurant
[PASS] Shift 1 recap explains career changes
[PASS] Next shift setup carries career focus
[PASS] Career reasons persist after shift 1 reload
[PASS] Shift 2 recap shows money, tips, XP, and promotion gains
[PASS] Two-shift career history persists in save
[PASS] Two-shift career history persists after reload
[PASS] Phase 24 career multi-shift loop check passed
```

Godot dummy renderer note: the Phase 24 headless smoke exits successfully but may print non-blocking `mesh_get_surface_count` cleanup messages after passing assertions.

Regression smokes:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase8_runtime_check.gd
[PASS] Store Manager rank ladder has Phase 24's 9 ranks
[PASS] Career progression reasons are visible
[PASS] Phase 8 runtime career campaign progression check passed

tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase23_core_gameplay_depth_check.gd
[PASS] Phase 23 core gameplay depth check passed

tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase20_multi_shift_save_load_stress.gd
[PASS] Phase 20 two-shift save/load progression stress check passed

tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase14_full_shift_smoke.gd
[PASS] Phase 14 full shift stabilization smoke check passed
```

## Acceptance

| Requirement | Status |
|---|---|
| Player can complete multiple shifts | Passed in Phase 24 Godot smoke |
| Career state changes between shifts | Passed: Trainee promoted to Crew Member, then Station Specialist |
| Save/load preserves progression | Passed after shift 1 and shift 2 reloads |
| Player can see why promotion/trust/money changed | Passed: recap now includes career score, gains, reasons, needs, and recovery focus |
| One full shift still works | Passed through Phase 24 multi-shift smoke and Phase 14 regression |
| Validation passes | Passed |
| Story event count remains 180 | Passed |

## Remaining Work

- Human-controlled visible playtest is still pending.
- Physical controller hardware validation is still pending.
- The material polish is still procedural and primitive; it is better than flat placeholders but not final art.
- Career progression is now visible and persistent, but the manager trial remains a setup hook rather than a full playable trial.
- Store Manager endgame, DLC, multi-store/business expansion, and online systems remain out of scope.
