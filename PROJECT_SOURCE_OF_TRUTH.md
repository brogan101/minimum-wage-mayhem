# Project Source Of Truth

Date: 2026-06-04

## Read First

For future Codex runs, read in this order:

1. `AGENTS.md`
2. `PROJECT_SOURCE_OF_TRUTH.md`
3. `IMPLEMENTATION_STATUS.md`
4. `VALIDATION_REPORT.md`
5. `PHASE_LOG.md`
6. `SOLO_SHIFT_ACCEPTANCE_TEST.md`
7. `PHASE_20_SAVE_LOAD_PROGRESSION_STRESS_REPORT.md`
8. `PHASE_19_GITHUB_PLAYTEST_PREP_REPORT.md`
9. `PHASE_18_PLAYTEST_SOFTLOCK_FEEL_REPORT.md`
10. Earlier `PHASE_*.md` files as phase briefs/history, not as proof.

Use actual files, validator output, GitHub state, and Godot runtime smoke checks as the source of truth. Do not infer implementation from markdown design docs or JSON catalogs alone.

## Current Repo Truth

- Git remote: `https://github.com/brogan101/minimum-wage-mayhem.git`.
- Default local branch in this workspace: `master`.
- GitHub visibility checked with `gh repo view brogan101/minimum-wage-mayhem --json name,url,visibility,isPrivate`: `PUBLIC`, `isPrivate=false`.
- `scenes/customers/CustomerCar.tscn` exists and is tracked.
- `.gitignore` is not excluding needed project files; `project.godot`, `scenes/`, `scripts/`, `data/`, `assets/`, `tools/`, and current docs are tracked or trackable.
- Tracked-file clutter scan found no actual `.godot/`, `.import/`, `tools/downloads/`, `tools/bin/`, `artifacts/`, prompt packs, zips, caches, disabled content, or historical validation snapshots. The only text-pattern hits were false positives: `project.godot` and `tools/validate_phase_pack.py`.

## Current Playable State

The current build is an early playable local-only Godot 4.x/GDScript slice. It supports:

- main menu first screen
- New Game and Continue/Load flows
- player spawn in a 3D restaurant scene
- action-based keyboard/mouse and controller-compatible InputMap controls
- pickup/drop/interact flow
- first-pass order bagging with Burger, Fries, and Soda station components
- grill food state changes and carried-bag Burger prep
- store duty stations
- coworker/staff systems
- visible `CustomerCar` drive-thru arrival/order flow with fallback order generation if the car scene is missing
- drive-thru handoff through `DriveThruWindow`, including a runtime `HandOffArea` fallback, wrong-order feedback, retry-active tickets, and cash/tip/XP payout
- active shift timer/HUD
- physical and menu end-shift flows
- end-of-shift recap
- local save/load
- career progression toward Store Manager
- runtime-wired chaos, mischief, consequences, restaurant memory, object memory, dynamic reputation, and depth/balance systems

Phase 20 specifically proves two-shift local continuity in automation: complete shift 1, save, reload, complete shift 2, save, reload again, and verify wallet, XP/rank/promotion progress, shift history, manager/staff/corporate career fields, reviews/writeups, daily task recap, EventLog history, restaurant memory, object memory, dynamic reputation, and corrupt-save fallback.

This is not a finished game and not a Steam demo. Manual visible playtest and physical controller proof are still pending.

## Validation Commands

Canonical static validation:

```text
python tools/validate_all.py
```

Main Godot runtime smokes:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase14_full_shift_smoke.gd
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase20_multi_shift_save_load_stress.gd
```

The console Godot binary may need filesystem access outside the workspace to write `user://logs` and local save data.

## Systems Actually Wired Into Gameplay

- Menu/new game/continue/pause/save/load/end-shift flow.
- Player movement/camera/input/interaction.
- Pickup/drop and station interaction.
- Grill/food-state station.
- Store ops stations and duty effects.
- Daily tasks and rewards.
- Staff/coworker modifiers.
- CustomerCar/order/handoff path.
- Shift timer, recap, next-shift setup.
- Wallet, CareerManager progression, CorporateManager approval.
- EventLog.
- Phase 9 chaos runtime, Phase 10 mischief runtime, Phase 11 consequence runtime, Phase 12 emergent memory runtime, Phase 13 global depth runtime.
- Phase 20 save/load persistence for wallet, career, stats, corporate approval, EventLog, restaurant memory, store object memory, dynamic reputation, last shift, next shift, and progression hooks.

## Scaffolded Only

- Drink, fries, and bagging have a functional first-pass loop through carried order bags, but still need animation/timing/presentation polish.
- Manager trial exists as career readiness/setup data, not a full playable trial.
- Store Manager/future district hooks exist but are intentionally not expanded.
- Settings UI exists, but persistent settings storage is not final.
- Export presets and Steam demo packaging are not final.
- Final audio assets are missing; audio hooks fall back safely.

## Data/Docs Only

- Many large content catalogs under `data/` are loaded or validated but not all entries are surfaced as rich visible gameplay.
- Historical roadmap/design docs describe future breadth and should not be treated as current playable proof.
- `PHASE_PACK/V13_REFERENCE/` remains reference/design-only and is not tracked in the clean GitHub repo.

## Current Blockers

- Manual visible playtest is still pending.
- Physical controller validation is still pending.
- Food prep needs manual feel, animation, timing, and presentation polish beyond the Phase 23 functional pass.
- HUD/menu/result presentation is functional but visually basic.
- Final audio/assets/export presets are not ready.
- GitHub repo visibility is public; if the desired state is private, change visibility in GitHub settings or via `gh repo edit brogan101/minimum-wage-mayhem --visibility private`.

## Next Recommended Phase

Next phase should be:

`Phase 24 - Career, Store Manager Path, Multi-Shift Loop, and Life-Like Cartoon Material Polish`

Do not add another large content/depth pack before this. The next work should make the multi-shift career path visible and continue improving the procedural placeholder materials toward a more life-like cartoon style.
