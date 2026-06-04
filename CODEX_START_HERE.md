# CODEX START HERE - CURRENT HANDOFF

You are working inside the Godot 4.x repo for **Minimum Wage Mayhem**.

## Current Source Of Truth

1. `AGENTS.md`
2. `PROJECT_SOURCE_OF_TRUTH.md`
3. `IMPLEMENTATION_STATUS.md`
4. `VALIDATION_REPORT.md`
5. `PHASE_LOG.md`
6. `SOLO_SHIFT_ACCEPTANCE_TEST.md`
7. `PHASE_16_FULL_REPO_STATE_AUDIT_AND_CLEANUP.md`
8. `PHASE_RUN_ALL_PROMPT.txt`
9. Root phase files as briefs/history, not proof by themselves.

## Absolute Priority

Make one complete solo fast-food shift playable from start to finish before wiring the deep systems into live gameplay.

## What This Repo Contains Now

This repo contains:
- a Godot project structure
- main scene/player/HUD files
- core MVP scripts
- extensive data catalogs from V15-V23
- runtime-wired campaign, chaos, mischief, consequences, emergent memory, and depth systems
- validation scripts and Godot runtime smokes proving the current fallback shift path

## Important Reality Rule

The game is not finished and is not Steam-ready. It does have an early playable menu-first shift path with fallback order generation, drive-thru handoff, recap, save/load, and progression. Do not claim richer visual customer flow, final assets/audio, physical controller validation, or Steam demo quality until those are proven.

## Start

Read `PROJECT_SOURCE_OF_TRUTH.md` and `PHASE_16_FULL_REPO_STATE_AUDIT_AND_CLEANUP.md` before choosing work.

After Phase 12 and after MVP/V16/V17/V18/V19/V20 are working structurally, run Phase 13 using `PHASE_13_GLOBAL_DEPTH_EXPANSION_AND_BALANCE.md`.

Phase 13 integrates:
- DepthDirector
- NormalcyBalanceDirector
- DepthEventLinker
- WorldTextureManager
- ShiftFlavorManager
- ContentDensityValidatorRuntime
- 30 global depth bundles
- normal/friction/weird/wild shift balancing
- customer memory arcs
- coworker social web
- manager/home/commute/store operations depth
- minigames
- recovery routes
- store identity mutations
- asset/audio/performance/fallback requirements

Do not change the restaurant story-event count. Keep wild chaos paced and balanced with normal playable work.


## V23 Final Audit Note

`V23_FINAL_AUDIT_REPORT.md` is retained as historical handoff context. Its note that Godot was unavailable is stale for this workspace; repo-local Godot 4.3 is present and current runtime status is documented in `VALIDATION_REPORT.md` and `PHASE_16_FULL_REPO_STATE_AUDIT_AND_CLEANUP.md`.

Before starting work, run `python tools/validate_all.py` from the repo root.
