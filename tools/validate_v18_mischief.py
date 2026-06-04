#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_JSON = [
    "data/mischief/pranks.json",
    "data/mischief/prank_backfires.json",
    "data/mischief/prank_war_chains.json",
    "data/mischief/prank_side_quests.json",
    "data/mischief/daily_tasks.json",
    "data/mischief/restaurant_story_events.json",
    "data/mischief/restaurant_damage_events.json",
    "data/mischief/mischief_stats.json",
    "data/mischief/prank_consequence_matrix.json",
]

REQUIRED_SCRIPTS = [
    "scripts/mischief/MischiefDirector.gd",
    "scripts/mischief/PrankWarManager.gd",
    "scripts/mischief/DailyTaskManager.gd",
    "scripts/mischief/RestaurantDamageManager.gd",
    "scripts/mischief/MischiefRecapManager.gd",
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

    pranks = load("data/mischief/pranks.json").get("pranks", [])
    assert len(pranks) >= 25, f"Expected at least 25 pranks, found {len(pranks)}"
    levels = {int(p.get("severity_level", 0)) for p in pranks}
    assert {1, 2, 3, 4}.issubset(levels), f"Missing prank severity levels: {levels}"
    for prank in pranks:
        for key in ["id", "description", "severity_level", "systems_affected", "eventlog_tags", "fallback", "safety_note"]:
            assert key in prank, f"Prank missing {key}: {prank}"

    backfires = load("data/mischief/prank_backfires.json").get("backfire_types", [])
    assert len(backfires) >= 5, "Expected at least five backfire types"

    chains = load("data/mischief/prank_war_chains.json").get("chains", [])
    assert len(chains) >= 5, "Expected at least five prank war chains"
    for chain in chains:
        assert len(chain.get("steps", [])) >= 5, f"Prank chain too shallow: {chain.get('id')}"

    quests = load("data/mischief/prank_side_quests.json").get("side_quests", [])
    assert len(quests) >= 7, "Expected at least seven prank side quests"
    for quest in quests:
        assert quest.get("optional") is True, f"Prank quest must be optional: {quest.get('id')}"

    tasks = load("data/mischief/daily_tasks.json").get("categories", {})
    for category in ["normal", "fast_food_chaos", "manager", "prank", "karma"]:
        assert category in tasks, f"Missing daily task category: {category}"
        assert len(tasks[category]) >= 8, f"Not enough tasks in category {category}"

    story_events = load("data/mischief/restaurant_story_events.json").get("events", [])
    assert len(story_events) >= 170, f"Expected at least 170 restaurant story events, found {len(story_events)}"
    categories = {e.get("category") for e in story_events}
    for needed in ["drive_thru", "sauce", "register_payment", "food_kitchen", "coworker", "manager", "corporate", "prank", "home_outside", "review_viral"]:
        assert needed in categories, f"Missing story event category: {needed}"
    for event in story_events:
        for key in ["id", "category", "description", "severity", "systems_affected", "eventlog_tags", "fallback", "safety_note"]:
            assert key in event, f"Story event missing {key}: {event}"

    damage = load("data/mischief/restaurant_damage_events.json").get("damage_events", [])
    assert len(damage) >= 20, "Expected at least 20 restaurant damage events"
    for d in damage:
        assert d.get("repair_tasks"), f"Damage event lacks repair task: {d}"

    matrix = load("data/mischief/prank_consequence_matrix.json").get("tracked_values", [])
    for key in ["staff_morale", "manager_suspicion", "promotion_progress", "restaurant_stability", "prank_war_heat"]:
        assert key in matrix, f"Consequence matrix missing {key}"

    print("✅ V18 workplace mischief validation passed")

if __name__ == "__main__":
    main()
