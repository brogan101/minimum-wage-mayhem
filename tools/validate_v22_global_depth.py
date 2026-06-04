#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EXPECTED_STORY_COUNT_FILE = ROOT / "V22_RESTAURANT_STORY_EVENT_COUNT_LOCK.json"

REQUIRED_JSON = [
    "data/depth/depth_bundles.json",
    "data/depth/shift_texture_layers.json",
    "data/depth/customer_memory_arcs.json",
    "data/depth/customer_normalcy_profiles.json",
    "data/depth/coworker_social_web.json",
    "data/depth/manager_pressure_situations.json",
    "data/depth/home_life_depth_events.json",
    "data/depth/commute_micro_events.json",
    "data/depth/store_ops_depth.json",
    "data/depth/equipment_personality.json",
    "data/depth/minigames.json",
    "data/depth/story_arc_expansion.json",
    "data/depth/world_rumors.json",
    "data/depth/quiet_normal_events.json",
    "data/depth/escalation_ladders.json",
    "data/depth/customer_customer_interactions.json",
    "data/depth/recovery_routes.json",
    "data/depth/promotion_detours.json",
    "data/depth/store_identity_mutations.json",
    "data/depth/audio_visual_asset_requirements.json",
    "data/depth/performance_budgets.json",
    "data/depth/bug_fallback_requirements.json",
    "data/depth/research_inspired_patterns.json",
    "data/depth/phase_13_acceptance_matrix.json",
]

REQUIRED_SCRIPTS = [
    "scripts/depth/DepthDirector.gd",
    "scripts/depth/NormalcyBalanceDirector.gd",
    "scripts/depth/DepthEventLinker.gd",
    "scripts/depth/WorldTextureManager.gd",
    "scripts/depth/ShiftFlavorManager.gd",
    "scripts/depth/ContentDensityValidatorRuntime.gd",
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

    bundles = load("data/depth/depth_bundles.json").get("bundles", [])
    assert len(bundles) >= 30, f"Expected at least 30 depth bundles, found {len(bundles)}"
    for bundle in bundles:
        assert len(bundle.get("systems_connected", [])) >= 3, f"Bundle lacks 3+ system links: {bundle.get('id')}"
        assert bundle.get("fallback"), f"Bundle lacks fallback: {bundle.get('id')}"
        assert bundle.get("required_hooks"), f"Bundle lacks required hooks: {bundle.get('id')}"

    layers = load("data/depth/shift_texture_layers.json").get("layers", [])
    assert len(layers) >= 4, "Need normal/friction/weird/wild shift texture layers"
    layer_ids = {x.get("id") for x in layers}
    for needed in ["normal_orders", "service_friction", "funny_weird", "wild_spike"]:
        assert needed in layer_ids, f"Missing shift layer: {needed}"

    for rel, key, minimum in [
        ("data/depth/customer_memory_arcs.json", "arcs", 8),
        ("data/depth/customer_normalcy_profiles.json", "profiles", 8),
        ("data/depth/coworker_social_web.json", "coworkers", 6),
        ("data/depth/manager_pressure_situations.json", "situations", 6),
        ("data/depth/home_life_depth_events.json", "events", 8),
        ("data/depth/commute_micro_events.json", "events", 8),
        ("data/depth/store_ops_depth.json", "ops", 8),
        ("data/depth/equipment_personality.json", "equipment", 7),
        ("data/depth/minigames.json", "minigames", 8),
        ("data/depth/quiet_normal_events.json", "events", 8),
        ("data/depth/recovery_routes.json", "routes", 8),
        ("data/depth/research_inspired_patterns.json", "patterns", 10),
    ]:
        data = load(rel).get(key, [])
        assert len(data) >= minimum, f"{rel} expected {minimum}+ {key}, found {len(data)}"

    asset_reqs = load("data/depth/audio_visual_asset_requirements.json").get("requirements", [])
    assert len(asset_reqs) >= 7, "Need asset/audio requirements"
    for req in asset_reqs:
        assert req.get("fallback"), f"Asset requirement lacks fallback: {req}"

    budgets = load("data/depth/performance_budgets.json").get("budgets", {})
    for needed in ["active_customers", "active_depth_events", "active_wild_events", "active_memory_entries_per_shift"]:
        assert needed in budgets, f"Missing performance budget: {needed}"

    fallbacks = load("data/depth/bug_fallback_requirements.json").get("fallbacks", [])
    assert len(fallbacks) >= 8, "Need fallback requirements"

    story = load("data/mischief/restaurant_story_events.json").get("events", [])
    lock = load("V22_RESTAURANT_STORY_EVENT_COUNT_LOCK.json")
    assert len(story) == lock["before_count"] == lock["after_count"], (
        f"Restaurant story events count changed: before={lock['before_count']} after_lock={lock['after_count']} actual={len(story)}"
    )

    print("✅ V22 global depth expansion validation passed")
    print(f"✅ Restaurant story event count preserved at {len(story)}")

if __name__ == "__main__":
    main()
