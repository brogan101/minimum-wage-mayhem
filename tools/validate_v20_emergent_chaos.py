#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_JSON = [
    "data/emergent/event_components.json",
    "data/emergent/event_formula.json",
    "data/emergent/generated_event_templates.json",
    "data/emergent/hr_interpretations.json",
    "data/emergent/review_interpretations.json",
    "data/emergent/career_impacts.json",
    "data/emergent/future_chain_triggers.json",
    "data/memory/evidence_types.json",
    "data/memory/memory_flags.json",
    "data/memory/recurring_rumor_templates.json",
    "data/memory/store_object_memory_targets.json",
    "data/memory/object_reputation_labels.json",
    "data/karma/karma_types.json",
    "data/karma/karma_event_triggers.json",
    "data/reputation/dynamic_reputation_rules.json",
    "data/missions/mission_components.json",
    "data/missions/mission_routes.json",
    "data/missions/generated_mission_archetypes.json",
    "data/consequences/consequence_rules.json",
    "data/consequences/outcome_modifiers.json",
    "data/consequences/future_chain_triggers.json",
    "data/recap/generated_recap_fields.json",
]

REQUIRED_SCRIPTS = [
    "scripts/emergent/EmergentEventDirector.gd",
    "scripts/emergent/IncidentComposer.gd",
    "scripts/memory/RestaurantMemoryManager.gd",
    "scripts/memory/EvidenceManager.gd",
    "scripts/memory/StoreObjectMemoryManager.gd",
    "scripts/consequences/ConsequenceMatrixManager.gd",
    "scripts/missions/EmergentMissionGenerator.gd",
    "scripts/karma/MultiKarmaManager.gd",
    "scripts/reputation/DynamicReputationLabelManager.gd",
    "scripts/recap/GeneratedRecapManager.gd",
    "scripts/emergent/FutureChainTriggerManager.gd",
]

def load(rel):
    path = ROOT / rel
    if not path.exists():
        raise AssertionError(f"Missing required file: {rel}")
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception as e:
        raise AssertionError(f"Invalid JSON in {rel}: {e}")

def main():
    for rel in REQUIRED_JSON:
        load(rel)
    for rel in REQUIRED_SCRIPTS:
        if not (ROOT / rel).exists():
            raise AssertionError(f"Missing required script: {rel}")

    components = load("data/emergent/event_components.json")
    for key, minimum in [
        ("actors", 8),
        ("problems", 8),
        ("locations", 8),
        ("objects", 8),
        ("witnesses", 5),
        ("cover_stories", 5),
        ("immediate_consequences", 5),
        ("delayed_consequences", 5),
    ]:
        assert key in components, f"Missing event component category: {key}"
        assert len(components[key]) >= minimum, f"{key} needs {minimum}+ entries"

    formula = load("data/emergent/event_formula.json").get("formula", [])
    expected_formula = ["actor", "problem", "location", "object", "witness", "cover_story", "immediate_consequence", "delayed_consequence", "hr_interpretation", "review_interpretation", "career_impact"]
    for part in expected_formula:
        assert part in formula, f"Event formula missing {part}"

    mission_arch = load("data/missions/generated_mission_archetypes.json").get("archetypes", [])
    assert len(mission_arch) >= 5, "Need at least 5 generated mission archetypes"
    for arch in mission_arch:
        assert arch.get("component_tags"), f"Mission archetype missing component tags: {arch.get('id')}"
        assert arch.get("routes"), f"Mission archetype missing routes: {arch.get('id')}"

    evidence = load("data/memory/evidence_types.json").get("evidence_types", [])
    assert len(evidence) >= 12, "Need 12+ evidence types"

    object_targets = load("data/memory/store_object_memory_targets.json").get("objects", [])
    assert len(object_targets) >= 15, "Need 15+ store object memory targets"

    karma_types = load("data/karma/karma_types.json").get("karma_types", [])
    assert len(karma_types) >= 10, "Need multi-karma types"

    consequence_values = load("data/consequences/consequence_rules.json").get("tracked_values", [])
    for key in ["cash_delta", "customer_beef", "staff_morale", "manager_trust", "suspicion", "evidence_created", "promotion_progress", "future_chain_chance"]:
        assert key in consequence_values, f"Consequence matrix missing {key}"

    recap_fields = load("data/recap/generated_recap_fields.json").get("fields", [])
    for key in ["most_unhinged_moment", "funniest_object", "worst_decision", "best_recovery", "next_shift_warning"]:
        assert key in recap_fields, f"Generated recap missing {key}"

    print("✅ V20 emergent chaos / restaurant memory validation passed")

if __name__ == "__main__":
    main()
