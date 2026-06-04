#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_JSON = [
    "data/fireable/offense_categories.json",
    "data/fireable/fireable_offenses.json",
    "data/fireable/caught_levels.json",
    "data/fireable/firing_routes.json",
    "data/fireable/shady_manager_promotion_outcomes.json",
    "data/fireable/ui_choice_templates.json",
    "data/fireable/weird_fireable_events.json",
    "data/fireable/coworker_fireable_activity.json",
    "data/fireable/manager_coverups.json",
    "data/fireable/consequence_matrix.json",
    "data/fireable/end_shift_consequence_recap.json",
    "data/shady/tip_jar_actions.json",
    "data/shady/register_misconduct_actions.json",
    "data/shady/inventory_misconduct_actions.json",
    "data/shady/food_karma_actions.json",
    "data/shady/abstract_impairment_events.json",
]

REQUIRED_SCRIPTS = [
    "scripts/consequences/SuspicionManager.gd",
    "scripts/consequences/FireableOffenseManager.gd",
    "scripts/consequences/ShadyChoiceManager.gd",
    "scripts/consequences/TipJarManager.gd",
    "scripts/consequences/RegisterIntegrityManager.gd",
    "scripts/consequences/InventoryMisconductManager.gd",
    "scripts/consequences/FoodKarmaManager.gd",
    "scripts/consequences/AbstractImpairmentManager.gd",
    "scripts/consequences/ManagerCoverupManager.gd",
    "scripts/consequences/FiringRecoveryManager.gd",
]

UNSAFE_POSITIVE_PATTERNS = [
    "instructions for crime",
    "how to steal",
    "how to hide drugs",
    "how to tamper",
    "drug dosage",
    "real-world theft method",
    "real-world evasion method",
    "violence is optimal",
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

    categories = load("data/fireable/offense_categories.json").get("categories", [])
    assert len(categories) >= 25, f"Expected 25+ offense categories, found {len(categories)}"

    offenses = load("data/fireable/fireable_offenses.json").get("offenses", [])
    assert len(offenses) >= 10, f"Expected 10+ fireable offenses, found {len(offenses)}"
    for offense in offenses:
        for key in ["offense_id", "display_name", "category", "severity", "base_detection_chance", "promotion_delta", "demotion_risk_delta", "fired_risk_delta", "possible_recovery_actions", "safety_note"]:
            assert key in offense, f"Offense missing {key}: {offense}"
        assert "instruction" not in offense.get("safety_note", "").lower() or "no real-world" in offense.get("safety_note", "").lower()

    caught = load("data/fireable/caught_levels.json").get("levels", [])
    assert len(caught) >= 5, "Need at least 5 caught levels"

    firing_routes = load("data/fireable/firing_routes.json").get("routes", [])
    assert len(firing_routes) >= 8, "Need at least 8 firing recovery routes"

    promotion_outcomes = load("data/fireable/shady_manager_promotion_outcomes.json").get("outcomes", [])
    assert len(promotion_outcomes) >= 8, "Need shady manager promotion outcomes"

    ui_templates = load("data/fireable/ui_choice_templates.json").get("templates", [])
    assert len(ui_templates) >= 5, "Need at least 5 UI choice templates"
    for template in ui_templates:
        assert len(template.get("choices", [])) >= 4, f"UI template too shallow: {template.get('id')}"

    weird = load("data/fireable/weird_fireable_events.json").get("events", [])
    assert len(weird) >= 45, f"Need 45+ weird fireable events, found {len(weird)}"

    coworker = load("data/fireable/coworker_fireable_activity.json").get("events", [])
    assert len(coworker) >= 25, f"Need 25+ coworker dirty events, found {len(coworker)}"

    coverups = load("data/fireable/manager_coverups.json").get("coverups", [])
    assert len(coverups) >= 15, f"Need 15+ manager coverups, found {len(coverups)}"

    for rel, key, minimum in [
        ("data/shady/tip_jar_actions.json", "actions", 15),
        ("data/shady/register_misconduct_actions.json", "actions", 15),
        ("data/shady/inventory_misconduct_actions.json", "actions", 15),
        ("data/shady/food_karma_actions.json", "actions", 15),
        ("data/shady/abstract_impairment_events.json", "events", 10),
    ]:
        data = load(rel).get(key, [])
        assert len(data) >= minimum, f"{rel} expected {minimum}+ entries, got {len(data)}"

    all_text = "\n".join((ROOT / rel).read_text(encoding="utf-8", errors="ignore").lower() for rel in REQUIRED_JSON)
    for pattern in UNSAFE_POSITIVE_PATTERNS:
        if pattern in all_text and "no " + pattern not in all_text:
            raise AssertionError(f"Unsafe positive phrase found: {pattern}")

    print("✅ V19 fireable offenses / suspicion / consequence validation passed")

if __name__ == "__main__":
    main()
