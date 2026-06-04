# Phase 13 — Global Depth Expansion And Balance

## Start Condition

Do not start Phase 13 until:
- MVP full solo shift works.
- Phase 8 campaign spine exists structurally.
- Phase 9 maximum chaos exists structurally.
- Phase 10 mischief exists structurally.
- Phase 11 suspicion/fireable systems exist structurally.
- Phase 12 emergent memory systems exist structurally.

## Goal

Wire the V22 global depth systems so the game has richer normal play, better comedy pacing, deeper mission/context links, more coherent customer/coworker/manager/home/store interactions, and stronger fallback/validation.

## Required Data

Load:
- `data/depth/depth_bundles.json`
- `data/depth/shift_texture_layers.json`
- `data/depth/customer_memory_arcs.json`
- `data/depth/customer_normalcy_profiles.json`
- `data/depth/coworker_social_web.json`
- `data/depth/manager_pressure_situations.json`
- `data/depth/home_life_depth_events.json`
- `data/depth/commute_micro_events.json`
- `data/depth/store_ops_depth.json`
- `data/depth/equipment_personality.json`
- `data/depth/minigames.json`
- `data/depth/story_arc_expansion.json`
- `data/depth/world_rumors.json`
- `data/depth/quiet_normal_events.json`
- `data/depth/escalation_ladders.json`
- `data/depth/customer_customer_interactions.json`
- `data/depth/recovery_routes.json`
- `data/depth/promotion_detours.json`
- `data/depth/store_identity_mutations.json`
- `data/depth/audio_visual_asset_requirements.json`
- `data/depth/performance_budgets.json`
- `data/depth/bug_fallback_requirements.json`
- `data/depth/research_inspired_patterns.json`
- `data/depth/phase_13_acceptance_matrix.json`

## Required Managers

Add/connect:
- `scripts/depth/DepthDirector.gd`
- `scripts/depth/NormalcyBalanceDirector.gd`
- `scripts/depth/DepthEventLinker.gd`
- `scripts/depth/WorldTextureManager.gd`
- `scripts/depth/ShiftFlavorManager.gd`
- `scripts/depth/ContentDensityValidatorRuntime.gd`

## Tasks

1. Load depth bundles.
2. Validate all bundles connect to at least three systems.
3. Use NormalcyBalanceDirector to prevent chaos overload.
4. Add quiet normal events to most shifts.
5. Add one or two linked service-friction events per shift.
6. Add wild/legendary events only when budget allows.
7. Connect depth entries to RestaurantMemory and EventLog.
8. Add mission hooks from depth entries.
9. Add recovery routes for failures.
10. Add fallback rules and performance budgets.
11. Verify restaurant story-event count did not change.
12. Run validation.

## Acceptance

Phase 13 is ready when:
- normal shifts feel less empty
- chaotic shifts are paced
- customers/coworkers/managers feel less samey
- home and commute have work impact
- missions have linked context
- failures create recovery paths
- validators pass
- restaurant story-event count is unchanged
