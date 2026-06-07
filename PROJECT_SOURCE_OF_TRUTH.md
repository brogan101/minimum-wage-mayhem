# Project Source Of Truth

Date: 2026-06-06

## Read First

For future Codex runs, read in this order:

1. `AGENTS.md`
2. `PROJECT_SOURCE_OF_TRUTH.md`
3. `IMPLEMENTATION_STATUS.md`
4. `VALIDATION_REPORT.md`
5. `PHASE_LOG.md`
6. `SOLO_SHIFT_ACCEPTANCE_TEST.md`
7. `PHASE_25_FULL_BUILD_AUDIT_AND_FIX_REPORT.md`
8. `PHASE_26_FUN_CONTENT_SHIFT_VARIETY_REPORT.md`
9. `PHASE_24_CAREER_STORE_MANAGER_LOOP_REPORT.md`
10. `PHASE_23_CORE_GAMEPLAY_DEPTH_REPORT.md`
11. `PHASE_20_SAVE_LOAD_PROGRESSION_STRESS_REPORT.md`
12. `PHASE_19_GITHUB_PLAYTEST_PREP_REPORT.md`
13. `PHASE_18_PLAYTEST_SOFTLOCK_FEEL_REPORT.md`
14. Earlier `PHASE_*.md` files as phase briefs/history, not as proof.

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
- expanded normal/mild order variety with customer moments, combo/soda tasks, and order-variety recap proof
- grill food state changes and carried-bag Burger prep
- store duty stations
- coworker/staff systems
- visible `CustomerCar` drive-thru arrival/order flow with fallback order generation if the car scene is missing
- drive-thru handoff through `DriveThruWindow`, including a runtime `HandOffArea` fallback, wrong-order feedback, retry-active tickets, and cash/tip/XP payout
- active shift timer/HUD
- physical and menu end-shift flows
- end-of-shift recap
- local save/load
- career progression toward Store Manager with Phase 24's nine-rank path, visible recap reasons, recovery focus, next-shift setup, and multi-shift save/load proof
- first-pass life-like cartoon material polish using procedural toon/noise runtime materials and small restaurant/food surface details
- runtime-wired chaos, mischief, consequences, restaurant memory, object memory, dynamic reputation, and depth/balance systems

Phase 20 specifically proves two-shift local continuity in automation: complete shift 1, save, reload, complete shift 2, save, reload again, and verify wallet, XP/rank/promotion progress, shift history, manager/staff/corporate career fields, reviews/writeups, daily task recap, EventLog history, restaurant memory, object memory, dynamic reputation, and corrupt-save fallback.

Phase 24 specifically proves the visible career loop in automation: complete shift 1, save/load, complete shift 2, save/load again, verify career reasons, rank movement from Trainee to Crew Member to Station Specialist, cash/tips/XP continuity, promotion progress, manager trust, staff morale, corporate approval, recovery focus, pre-shift modifier history, and expanded save persistence.

Phase 25 proves the full audited demo loop after cleanup: full shift smoke, Phase 20 two-shift save/load stress, Phase 23 gameplay-depth smoke, Phase 24 career loop smoke, menu playability smoke, and the new Phase 25 audit smoke pass. Phase 25 also fixes menu-save preservation of completed shift/next-shift data and makes the shift recap body scroll instead of truncating long reports.

Phase 26 proves safe fun-content expansion through existing gameplay paths: more normal/mild customer orders, customer-moment logging, rotating daily tasks after the first shift, HUD ticket mood/target details, order-variety recap lines, and save/load persistence.

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
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase25_full_build_audit_check.gd
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase26_fun_content_shift_variety_check.gd
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
- Phase 24 career recap reasons, next-shift career focus, recovery plan, pre-shift modifier history, and nine-rank Store Manager ladder.
- EventLog.
- Phase 9 chaos runtime, Phase 10 mischief runtime, Phase 11 consequence runtime, Phase 12 emergent memory runtime, Phase 13 global depth runtime.
- Phase 20 save/load persistence for wallet, career, stats, corporate approval, EventLog, restaurant memory, store object memory, dynamic reputation, last shift, next shift, and progression hooks.
- Phase 25 menu-save preservation for completed-shift and next-shift data when the player saves from the pause/menu path.
- Phase 25 scrollable shift recap presentation for long career/depth reports.
- Phase 26 order/customer variety, customer moments, rotating daily tasks, order-variety recap, and save/load persistence for customer moments.

## Partially Working

- Manual movement/camera feel is automated-validated but not human-verified in a visible playtest.
- HUD and menu readability are improved and automated-checked, but final multi-resolution/manual QA is still pending.
- Food prep is functionally playable with bag/Burger/Fries/Soda and retry logic, but needs animation, timing, and tactile polish.
- Customer/coworker/manager moments are surfaced through text, tasks, logs, rewards, and recap, but not animated performances.
- Controller-compatible InputMap actions exist; physical controller hardware validation remains pending.
- Life-like cartoon visuals are improved with procedural materials and props; final production textures/assets are not done.

## Scaffolded Only

- Drink, fries, and bagging have a functional first-pass loop through carried order bags, but still need animation/timing/presentation polish.
- Manager trial exists as career readiness/setup data, not a full playable trial.
- Store Manager/future district hooks exist but are intentionally not expanded.
- Settings UI exists, but persistent settings storage is not final.
- Export presets and Steam demo packaging are not final.
- Final audio assets are missing; audio hooks fall back safely.
- Phase 24 material polish is procedural and runtime-generated; final life-like cartoon texture production remains a future asset pass.

## Broken

- No known first-shift or multi-shift blocker is currently reproduced by automated smokes.
- No Phase 25 audit blocker remains reproduced by automated Phase 26 smokes.
- Non-blocking Godot dummy-renderer cleanup messages can appear after some headless visual/runtime smokes pass.

## Duplicate/Overlapping

- Historical phase docs still contain old snapshots, including the pre-Phase-24 11-rank career wording in historical validation output. Current truth is the Phase 24 nine-rank path.
- Several large design docs and JSON catalogs describe future breadth beyond the current playable demo; use runtime smokes and current status docs for proof.

## Should Be Deferred

- DLC, multi-store/business expansion, online services, multiplayer/co-op, Steam integrations, and giant event-pack expansion.
- Full Store Manager trial content should wait until the current first-store demo has a visible manual playtest and art/audio pass.

## Data/Docs Only

- Many large content catalogs under `data/` are loaded or validated but not all entries are surfaced as rich visible gameplay.
- Historical roadmap/design docs describe future breadth and should not be treated as current playable proof.
- `PHASE_PACK/V13_REFERENCE/` remains reference/design-only and is not tracked in the clean GitHub repo.

## Current Blockers

- Manual visible playtest is still pending.
- Physical controller validation is still pending.
- Food prep needs manual feel, animation, timing, and presentation polish beyond the Phase 23 functional pass.
- HUD/menu/result presentation is functional and the Phase 25 recap no longer truncates long reports, but visual polish is still basic.
- Final audio/assets/export presets are not ready.
- Full production-quality life-like cartoon textures/materials are not done; Phase 24 only starts this direction with procedural material polish and small surface details.
- GitHub repo visibility is public; if the desired state is private, change visibility in GitHub settings or via `gh repo edit brogan101/minimum-wage-mayhem --visibility private`.

## Next Recommended Phase

Next phase should be:

`Phase 27 - Visible Manual Playtest, Controller Hardware, Manager Trial Prep, and Art/Audio Polish`

Do not add DLC, multi-store/business expansion, online systems, or another large event pack before this. The next work should run a real visible playtest, verify physical controller hardware if available, polish the manager-trial setup into a clearer playable goal, and continue improving the procedural placeholder materials toward production-ready life-like cartoon art.
