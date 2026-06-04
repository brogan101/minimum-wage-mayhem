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
7. `PHASE_16_FULL_REPO_STATE_AUDIT_AND_CLEANUP.md`
8. `PHASE_RUN_ALL_PROMPT.txt`
9. Root `PHASE_*.md` files only as phase briefs/history, not as proof.

Use actual files, validation output, and runtime smoke checks as the source of truth. Do not infer implementation from markdown design docs or JSON catalogs alone.

## Current Playable State

The current build is an early playable local-only Godot 4.x/GDScript slice. It supports:

- main menu first screen
- New Game and Continue/Load flows
- player spawn in a 3D restaurant scene
- action-based keyboard/mouse and controller-compatible InputMap controls
- pickup/drop/interact flow
- grill food state changes
- store duty stations
- coworker/staff systems
- fallback customer order generation
- drive-thru handoff through `DriveThruWindow`
- active shift timer/HUD
- end-of-shift recap
- local save/load
- career progression toward Store Manager
- runtime-wired chaos, mischief, consequences, restaurant memory, and depth/balance systems

This is not a finished game and not a Steam demo. The full-shift proof currently uses fallback order/customer flow and simple placeholder visuals.

## Active Root Phase Files

Treat these as active phase briefs and history:

- `PHASE_0_REPO_AUDIT_AND_VALIDATION.md`
- `PHASE_1_BOOT_PLAYER_INPUT.md`
- `PHASE_2_INTERACTION_PICKUP_DROP.md`
- `PHASE_3_STATIONS_FOOD_STATE.md`
- `PHASE_4_CUSTOMER_ORDER_DELIVERY.md`
- `PHASE_5_FULL_MINI_SHIFT.md`
- `PHASE_6_DEPTH_EXAMPLES.md`
- `PHASE_7_CONTENT_DEPTH_AND_LINKAGE.md`
- `PHASE_8_CAMPAIGN_PROGRESSION_AND_MANAGER_PATH.md`
- `PHASE_9_MAXIMUM_CHAOS_WTF_INCIDENT_LAYER.md`
- `PHASE_10_WORKPLACE_MISCHIEF_PRANKS_AND_DAILY_TASKS.md`
- `PHASE_11_FIREABLE_OFFENSES_DIRTY_EMPLOYEE_CONSEQUENCE_LAYER.md`
- `PHASE_12_EMERGENT_CHAOS_RESTAURANT_MEMORY.md`
- `PHASE_13_GLOBAL_DEPTH_EXPANSION_AND_BALANCE.md`
- `PHASE_14_STABILIZATION_AUDIT.md`
- `PHASE_16_FULL_REPO_STATE_AUDIT_AND_CLEANUP.md`

Phase 15 was implemented and validated through code, tools, and status docs, but there is no root `PHASE_15_*.md` brief.

## How To Treat `PHASE_PACK/V13_REFERENCE`

`PHASE_PACK/V13_REFERENCE/` is reference/design-only material. It is not the current phase order and should not be treated as 48 runnable phases.

The numbered files present are `00` through `35`, `41` through `48`, and `99`. Files `36` through `40` are not present in this repo; they are only proposed by the V12 continuity audit.

Use the V13 pack only to answer design questions or compare old requirements. Do not let it override current validation, current root status docs, or the local-only fast-food MVP priority.

## Historical Docs

Keep these for context, but do not treat them as current proof:

- `V14_PACKAGE_AUDIT_SUMMARY.md`
- `V21_HARD_AUDIT_REPORT.md`
- `V22_*_OUTPUT.txt`
- `V22_*_RESULT.txt`
- `V23_FINAL_AUDIT_REPORT.md`
- `CODEX_RUN_ALL_PHASES_PROMPT_V21.txt`
- `RUN_ALL_PHASES_PROMPT_COPY_THIS.txt`
- `PHASE_PACK/V13_REFERENCE/*`

Some historical docs say Godot was not installed or runtime validation was pending. That was true in those earlier contexts. In this workspace, repo-local Godot 4.3 exists and headless/menu smoke validation has run.

## Validation Commands

Canonical static validation:

```text
python tools/validate_all.py
```

Godot version and boot:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --version
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --quit
```

Main runtime smokes:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase14_full_shift_smoke.gd
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase15_menu_playability_check.gd
```

The console Godot binary may need filesystem access outside the workspace to write `user://logs`.

## Current Blockers

- Manual visible playtest is still pending.
- Physical controller validation is still pending.
- `CustomerCar.tscn` visual arrival scene is missing, so fallback order generation is used.
- Bagging/drink/fry prep are not yet as clear as the fallback Training Burger handoff.
- HUD/menu/result presentation is functional but visually basic.
- Final audio/assets/export presets are not ready.
- No `.git` directory is present in this workspace, so `git diff --stat` cannot produce repo diff proof here.

## Next Recommended Phase

Next phase should be:

`PHASE_17_VISIBLE_PLAYTEST_CONTROLLER_CUSTOMER_CAR_AND_EXPORT_PREP`

Do not add another big content/depth pack before this. The next work should make the already-proven shift visibly playable and demo-readable.
