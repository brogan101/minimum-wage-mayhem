# Phase 20 Save/Load Progression Stress Report

Date: 2026-06-04

## Objective

Use the current GitHub repo as source of truth, clean up stale repo documentation, and prove multi-shift local save/load/progression/memory continuity without adding major new content.

## Repo Sync And Cleanup

- Ran `git pull --ff-only`; output: `Already up to date.`
- Confirmed remote: `origin https://github.com/brogan101/minimum-wage-mayhem.git`.
- Confirmed GitHub visibility with `gh repo view brogan101/minimum-wage-mayhem --json name,url,visibility,isPrivate`: repo is `PUBLIC`, `isPrivate=false`.
- Corrected stale docs that claimed the repo was private.
- Confirmed `scenes/customers/CustomerCar.tscn` exists and is tracked.
- Corrected stale source-of-truth docs that claimed `CustomerCar` was missing and fallback-only.
- Reviewed `.gitignore`; needed game/build/test files are not excluded.
- Scanned tracked files for cache/download/prompt/archive clutter. No real `.godot/`, `.import/`, `tools/downloads/`, `tools/bin/`, `artifacts/`, zips, caches, prompt packs, disabled scope folders, or validation snapshot clutter are tracked. Pattern scan false positives: `project.godot`, `tools/validate_phase_pack.py`.

## Implementation Changes

- `SaveSystem.gd` now uses schema version 3.
- `SaveSystem.gd` now saves and restores:
  - wallet
  - career
  - stats
  - corporate approval
  - EventLog history
  - restaurant memory
  - store object memory
  - dynamic reputation labels/history
  - progression hooks
  - last shift
  - next shift
- Added save/load hooks to:
  - `EventLog.gd`
  - `RestaurantMemoryManager.gd`
  - `StoreObjectMemoryManager.gd`
  - `DynamicReputationLabelManager.gd`
- Added `tools/phase20_multi_shift_save_load_stress.gd`.
- Extended `tools/validate_all.py` with a Phase 20 save/load stress contract.

## Godot Stress Proof

Command:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase20_multi_shift_save_load_stress.gd
```

Result:

```text
[PASS] Shift 1 completes and saves a served customer
[PASS] Shift 1 save records career history
[PASS] Shift 1 save includes restaurant memory flag
[PASS] Shift 1 save includes object memory
[PASS] Shift 1 save includes dynamic reputation labels
[PASS] Load after shift 1 returns save data
[PASS] Wallet persists after shift 1 reload
[PASS] Career history persists after shift 1 reload
[PASS] Corporate approval persists after shift 1 reload
[PASS] Restaurant memory persists after shift 1 reload
[PASS] Dynamic reputation persists after shift 1 reload
[PASS] Shift 2 completes and saves
[PASS] Two-shift career history persists in save
[PASS] XP/progression persists in save
[PASS] Promotion progress persists in save
[PASS] Trust/morale/corporate career fields persist in save
[PASS] Reviews/writeups are preserved in last shift
[PASS] Daily task recap is preserved in last shift
[PASS] EventLog history carries into shift 2 save
[PASS] Next shift setup advances after shift 2
[PASS] Load after shift 2 returns save data
[PASS] Wallet persists after shift 2 reload
[PASS] Two-shift career history survives final reload
[PASS] Shift 2 restaurant memory survives final reload
[PASS] Object memory incident count survives final reload
[PASS] Reputation evaluation history survives final reload
[PASS] Corrupt save falls back safely
[PASS] Phase 20 two-shift save/load progression stress check passed
```

Non-blocking Godot note: the stress run still prints `WARNING: Target object freed before starting, aborting Tweener.` after the handoff object is consumed. No assertion failed and no script error remains.

Regression smoke:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase14_full_shift_smoke.gd
[PASS] Phase 14 full shift stabilization smoke check passed
```

## Static Validation

Command:

```text
python tools/validate_all.py
```

Initial Phase 20 pre-edit run passed. Final post-edit run should include the new Phase 20 contract.

## Continuity Results

| Requirement | Status |
|---|---|
| New game | Passed in Godot stress |
| Complete shift 1 | Passed |
| Save shift 1 | Passed |
| Load/continue after shift 1 | Passed |
| Complete shift 2 | Passed |
| Save/load after shift 2 | Passed |
| Wallet/cash persists | Passed |
| XP/rank/promotion progress persists | Passed |
| Shift count/history persists | Passed |
| Manager trust/staff morale/corporate approval career fields persist | Passed |
| Reviews/HR/writeups if wired persist | Passed for reviews/writeups in `last_shift` |
| Daily tasks persist or reset correctly | Passed through saved recap entries |
| EventLog/recap history behaves correctly | Passed |
| Restaurant memory persists if wired | Passed |
| Object memory persists if wired | Passed |
| Reputation labels/history persists if wired | Passed |
| Bad/missing/corrupt save fallback safe | Passed |

## Restaurant Story Event Count

`data/mischief/restaurant_story_events.json` was not edited. Validation preserved the locked count at 180.

## Manual/Controller Status

- Manual visible/windowed playtest: not performed in Phase 20.
- Physical controller hardware test: not performed in Phase 20.
- Controller-compatible InputMap remains covered by prior automated validation.

## Remaining Work

- Run a real visible playtest from a player perspective.
- Test a physical controller.
- Add/validate real bagging, drink, and fries prep loops beyond visual affordances.
- Add or wire `DriveThruWindow.HandOffArea` if trigger-volume handoff is desired; interact fallback works.
- Polish HUD/menu/result presentation.
- Add final audio/assets/export presets.
- Decide whether GitHub repo should stay public or be switched private.
