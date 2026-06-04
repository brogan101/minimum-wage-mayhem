#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_JSON = [
    "data/incidents/unhinged_incidents.json",
    "data/incidents/incident_severity.json",
    "data/incidents/incident_chains.json",
    "data/incidents/legendary_shift_chains.json",
    "data/fights/brawl_triggers.json",
    "data/fights/brawl_objects.json",
    "data/fights/brawl_outcomes.json",
    "data/fights/brawl_actions.json",
    "data/shady/shady_actions.json",
    "data/shady/shady_outcomes.json",
    "data/shady/theft_suspicion_rules.json",
    "data/staff/callout_excuses.json",
    "data/staff/manager_archetypes.json",
    "data/staff/coworker_drama_chains.json",
    "data/staff/snitch_events.json",
    "data/staff/break_room_events.json",
    "data/home/home_chaos_events.json",
    "data/home/home_modifiers.json",
    "data/home/commute_events.json",
    "data/hr/hr_report_templates.json",
    "data/hr/fake_training_modules.json",
    "data/reviews/incident_review_templates.json",
    "data/reviews/viral_clip_events.json",
    "data/career/demotion_rules.json",
    "data/career/promotion_setback_events.json",
    "data/career/manager_trial_events.json",
    "data/reputation/player_reputation_labels.json",
]

REQUIRED_SCRIPTS = [
    "scripts/drama/UnhingedIncidentDirector.gd",
    "scripts/drama/SlapstickBrawlManager.gd",
    "scripts/drama/ShadySuspicionManager.gd",
    "scripts/drama/IncidentChainManager.gd",
    "scripts/drama/HRIncidentReporter.gd",
    "scripts/drama/ViralClipManager.gd",
    "scripts/staff/CalloutManager.gd",
    "scripts/staff/ManagerArchetypeManager.gd",
    "scripts/home/HomeChaosManager.gd",
    "scripts/home/HomeModifierManager.gd",
    "scripts/career/DemotionManager.gd",
    "scripts/career/ManagerTrialManager.gd",
    "scripts/reputation/PlayerReputationManager.gd",
]

UNSAFE_POSITIVE_PATTERNS = [
    "how to rob",
    "how to steal",
    "how to hide drugs",
    "drug dealing instructions",
    "weapon tactics guide",
    "real crime instructions are allowed",
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

    incidents = load("data/incidents/unhinged_incidents.json").get("incidents", [])
    assert len(incidents) >= 4, "Need at least 4 unhinged incidents"
    for inc in incidents:
        for key in ["id", "category", "severity", "trigger_conditions", "blocked_conditions", "consequences", "eventlog_tags", "fallback", "safety_note"]:
            assert key in inc, f"Incident missing {key}: {inc}"
        if inc.get("severity") in ["moderate", "major", "legendary"]:
            assert "tutorial_shift" in inc.get("blocked_conditions", []), f"Moderate+ incident should block tutorial: {inc.get('id')}"

    legendary = load("data/incidents/legendary_shift_chains.json").get("legendary_shift_chains", [])
    assert len(legendary) >= 5, "Need at least 5 legendary shift chains"
    for chain in legendary:
        assert len(chain.get("steps", [])) >= 5, f"Legendary chain too shallow: {chain.get('id')}"
        assert chain.get("gated") is True, f"Legendary chain must be gated: {chain.get('id')}"

    brawl_actions = load("data/fights/brawl_actions.json").get("actions", [])
    assert any(a.get("type") == "deescalate" for a in brawl_actions), "Brawl system needs de-escalation actions"

    managers = load("data/staff/manager_archetypes.json").get("managers", [])
    assert len(managers) >= 10, "Need at least 10 manager archetypes"

    callouts = load("data/staff/callout_excuses.json").get("excuses", [])
    assert len(callouts) >= 15, "Need at least 15 callout excuses"

    labels = load("data/reputation/player_reputation_labels.json").get("labels", [])
    assert len(labels) >= 15, "Need at least 15 player reputation labels"

    all_text = "\n".join((ROOT / rel).read_text(encoding="utf-8", errors="ignore").lower() for rel in REQUIRED_JSON)
    for pattern in UNSAFE_POSITIVE_PATTERNS:
        assert pattern not in all_text, f"Unsafe positive instruction phrase found: {pattern}"

    print("✅ V17 maximum chaos integration validation passed")

if __name__ == "__main__":
    main()
