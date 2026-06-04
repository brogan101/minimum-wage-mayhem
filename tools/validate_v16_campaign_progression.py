#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def load_json(rel):
    path = ROOT / rel
    if not path.exists():
        raise AssertionError(f"Missing required file: {rel}")
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception as e:
        raise AssertionError(f"Invalid JSON in {rel}: {e}")

def main():
    ladder = load_json("data/progression/career_ladder.json")
    ranks = ladder.get("ranks", [])
    assert len(ranks) >= 11, f"Expected at least 11 ranks, found {len(ranks)}"
    assert ladder.get("campaign_tagline") == "A full comedy campaign where every dumb shift is pushing the player toward Store Manager and insanity."
    ids = [r.get("id") for r in ranks]
    assert "store_manager" in ids, "Store Manager rank missing"
    for r in ranks:
        for key in ["id", "name", "pay_rate", "unlocks"]:
            assert key in r, f"Rank missing {key}: {r}"

    req = load_json("data/progression/promotion_requirements.json")
    for needed in ["trainee", "crew_member", "store_manager"]:
        assert needed in req, f"Promotion requirements missing {needed}"

    certs = load_json("data/progression/station_certifications.json").get("certifications", [])
    assert len(certs) >= 8, "Not enough station certifications"

    writeups = load_json("data/progression/writeup_templates.json").get("writeups", [])
    assert len(writeups) >= 5, "Not enough write-up templates"
    for w in writeups:
        assert "recovery_task" in w, f"Write-up lacks recovery task: {w}"

    trial = load_json("data/missions/manager_trial_shift.json")
    assert trial.get("mission_id") == "manager_trial_shift"
    assert len(trial.get("required_events", [])) >= 5, "Manager Trial needs multiple pressure events"

    duties = load_json("data/store/store_duties.json")
    for section in ["opening", "mid_shift", "closing"]:
        assert section in duties and duties[section], f"Missing store duty section: {section}"

    flags = load_json("data/progression/future_backend_flags.json")
    for flag in ["district_manager_unlocked", "ceo_path_unlocked", "custom_brand_unlocked", "multi_store_unlocked"]:
        assert flag in flags, f"Missing future backend flag: {flag}"

    print("✅ V16 campaign progression validation passed")

if __name__ == "__main__":
    main()
