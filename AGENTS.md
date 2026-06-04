# AGENTS.md — Minimum Wage Mayhem

## Project Identity

Minimum Wage Mayhem is a Godot 4.x / GDScript, single-player, local-only, offline-first, 3D walk-around adult comedy service-job chaos game.

Base game: fast-food drive-thru.
Campaign description: a full comedy campaign where every dumb shift pushes the player toward Store Manager and insanity.

## Hard Rules

- Godot 4.x.
- GDScript.
- Fully 3D walk-around interaction.
- Single-player local-only.
- Offline-first.
- Local save files only.
- Controller-compatible through Godot InputMap actions.
- No servers.
- No online backend.
- No remote database.
- No multiplayer or co-op unless explicitly rescheduled later.
- Do not build DLC/full multi-store/future businesses before the fast-food MVP is playable.
- Adult/shady/risky content must stay fictional, abstract, UI-choice based, non-instructional, and consequence-driven.

## Required Reading Order

1. `CODEX_START_HERE.md`
2. `PHASE_RUN_ALL_PROMPT.txt`
3. `V21_HARD_AUDIT_REPORT.md`
4. `PHASE_0_REPO_AUDIT_AND_VALIDATION.md`
5. `PHASE_1_BOOT_PLAYER_INPUT.md`
6. `SOLO_SHIFT_ACCEPTANCE_TEST.md`
7. Later phase files only after prior acceptance criteria pass.

## Required End-Of-Task Update

After every phase, update:
- `IMPLEMENTATION_STATUS.md`
- `VALIDATION_REPORT.md`
- `PHASE_LOG.md`
- `SOLO_SHIFT_ACCEPTANCE_TEST.md`

## Do Not Claim Completion

Use proof. Run validation. Say what works and what is still partial. If Godot cannot be run, say so and run all static validators.

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
