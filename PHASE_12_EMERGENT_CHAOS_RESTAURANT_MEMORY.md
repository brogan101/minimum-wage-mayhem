# Phase 12 — Emergent Chaos / Restaurant Memory / Mission Composer

## Start Condition

Do not start Phase 12 until:
- MVP full solo shift works.
- EventLog works.
- Shift results work.
- V16 career/write-up systems exist.
- V17 maximum chaos exists structurally.
- V18 workplace mischief exists structurally.
- V19 fireable/suspicion systems exist structurally.

## Goal

Make the game feel unscripted by generating events, missions, evidence, consequences, HR reports, reviews, reputation labels, object histories, and shift recaps from shared state.

## Required Data

Load:

- `data/emergent/event_components.json`
- `data/emergent/event_formula.json`
- `data/emergent/generated_event_templates.json`
- `data/emergent/hr_interpretations.json`
- `data/emergent/review_interpretations.json`
- `data/emergent/career_impacts.json`
- `data/emergent/future_chain_triggers.json`
- `data/memory/evidence_types.json`
- `data/memory/memory_flags.json`
- `data/memory/recurring_rumor_templates.json`
- `data/memory/store_object_memory_targets.json`
- `data/memory/object_reputation_labels.json`
- `data/karma/karma_types.json`
- `data/karma/karma_event_triggers.json`
- `data/reputation/dynamic_reputation_rules.json`
- `data/missions/mission_components.json`
- `data/missions/mission_routes.json`
- `data/missions/generated_mission_archetypes.json`
- `data/consequences/consequence_rules.json`
- `data/consequences/outcome_modifiers.json`
- `data/recap/generated_recap_fields.json`

## Required Managers

Add/connect:

- `scripts/emergent/EmergentEventDirector.gd`
- `scripts/emergent/IncidentComposer.gd`
- `scripts/memory/RestaurantMemoryManager.gd`
- `scripts/memory/EvidenceManager.gd`
- `scripts/memory/StoreObjectMemoryManager.gd`
- `scripts/consequences/ConsequenceMatrixManager.gd`
- `scripts/missions/EmergentMissionGenerator.gd`
- `scripts/karma/MultiKarmaManager.gd`
- `scripts/reputation/DynamicReputationLabelManager.gd`
- `scripts/recap/GeneratedRecapManager.gd`
- `scripts/emergent/FutureChainTriggerManager.gd`

## Tasks

1. Compose one generated event from state.
2. Record that event in RestaurantMemory.
3. Create evidence for the event if applicable.
4. Apply consequence matrix results.
5. Update karma.
6. Update reputation labels.
7. Update store object memory if an object is involved.
8. Generate possible mission from the event.
9. Generate HR/review/recap interpretations from event components.
10. Save event history/career history.
11. Add validation.
12. Update Codex status docs after each pass.

## Acceptance

Phase 12 is ready when:
- Events can be composed from components.
- Missions can be generated from event components.
- Evidence can persist beyond the shift.
- Objects can gain reputation labels.
- Karma/reputation updates from real events.
- End-of-shift recap uses actual event history.
- Future chains can trigger from repeated patterns.
- Validation passes.
