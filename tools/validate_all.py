#!/usr/bin/env python3
"""
Minimum Wage Mayhem repo-local validation runner.

This validates the current V22/V23 handoff without machine-specific paths or subprocess chaining.
For deeper phase-specific checks, run individual validators in tools/ after Codex wires the matching phase.
"""
from pathlib import Path
import ast
import json
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_HANDOFF = [
    "AGENTS.md",
    "CODEX_START_HERE.md",
    "V23_FINAL_AUDIT_REPORT.md",
    "PHASE_RUN_ALL_PROMPT.txt",
    "RUN_ALL_PHASES_PROMPT_COPY_THIS.txt",
    "IMPLEMENTATION_STATUS.md",
    "VALIDATION_REPORT.md",
    "PHASE_LOG.md",
    "SOLO_SHIFT_ACCEPTANCE_TEST.md",
    "PHASE_0_REPO_AUDIT_AND_VALIDATION.md",
    "PHASE_1_BOOT_PLAYER_INPUT.md",
    "PHASE_2_INTERACTION_PICKUP_DROP.md",
    "PHASE_3_STATIONS_FOOD_STATE.md",
    "PHASE_4_CUSTOMER_ORDER_DELIVERY.md",
    "PHASE_5_FULL_MINI_SHIFT.md",
    "PHASE_6_DEPTH_EXAMPLES.md",
    "PHASE_7_CONTENT_DEPTH_AND_LINKAGE.md",
    "PHASE_8_CAMPAIGN_PROGRESSION_AND_MANAGER_PATH.md",
    "PHASE_9_MAXIMUM_CHAOS_WTF_INCIDENT_LAYER.md",
    "PHASE_10_WORKPLACE_MISCHIEF_PRANKS_AND_DAILY_TASKS.md",
    "PHASE_11_FIREABLE_OFFENSES_DIRTY_EMPLOYEE_CONSEQUENCE_LAYER.md",
    "PHASE_12_EMERGENT_CHAOS_RESTAURANT_MEMORY.md",
    "PHASE_13_GLOBAL_DEPTH_EXPANSION_AND_BALANCE.md",
]

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
    "data/mischief/restaurant_story_events.json",
    "V22_RESTAURANT_STORY_EVENT_COUNT_LOCK.json",
]

REQUIRED_SCRIPTS = [
    "scripts/depth/DepthDirector.gd",
    "scripts/depth/NormalcyBalanceDirector.gd",
    "scripts/depth/DepthEventLinker.gd",
    "scripts/depth/WorldTextureManager.gd",
    "scripts/depth/ShiftFlavorManager.gd",
    "scripts/depth/ContentDensityValidatorRuntime.gd",
]

def load_json(rel: str):
    path = ROOT / rel
    if not path.exists():
        raise AssertionError(f"Missing required file: {rel}")
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        raise AssertionError(f"Invalid JSON in {rel}: {exc}") from exc

def validate_project_config() -> str:
    path = ROOT / "project.godot"
    if not path.exists():
        raise AssertionError("Missing project.godot")
    text = path.read_text(encoding="utf-8")
    marker = 'run/main_scene="'
    if marker not in text:
        raise AssertionError("project.godot does not declare run/main_scene")
    main_scene = text.split(marker, 1)[1].split('"', 1)[0]
    if not main_scene.startswith("res://"):
        raise AssertionError(f"Main scene is not a res:// path: {main_scene}")
    scene_path = ROOT / main_scene.replace("res://", "")
    if not scene_path.exists():
        raise AssertionError(f"Main scene path does not exist: {main_scene}")
    return main_scene

def validate_scene_resource_paths() -> int:
    checked = 0
    for scene in ROOT.rglob("*.tscn"):
        text = scene.read_text(encoding="utf-8")
        for part in text.split('path="')[1:]:
            resource_path = part.split('"', 1)[0]
            if resource_path.startswith("res://"):
                checked += 1
                local_path = ROOT / resource_path.replace("res://", "")
                if not local_path.exists():
                    rel = scene.relative_to(ROOT).as_posix()
                    raise AssertionError(f"{rel} references missing resource: {resource_path}")
    return checked

def validate_phase_1_player_scene():
    player_scene = ROOT / "scenes/player/Player.tscn"
    if not player_scene.exists():
        raise AssertionError("Missing Phase 1 player scene: scenes/player/Player.tscn")
    text = player_scene.read_text(encoding="utf-8")
    required_fragments = [
        '[node name="Player" type="CharacterBody3D"]',
        '[node name="CollisionShape3D" type="CollisionShape3D" parent="."]',
        '[node name="Head" type="Node3D" parent="."]',
        '[node name="Camera3D" type="Camera3D" parent="Head"]',
        '[node name="RayCast3D" type="RayCast3D" parent="Head/Camera3D"]',
        '[node name="HoldPosition" type="Marker3D" parent="Head/Camera3D"]',
    ]
    for fragment in required_fragments:
        if fragment not in text:
            raise AssertionError(f"Player scene lacks required Phase 1 node: {fragment}")

def validate_phase_1_input_actions():
    project_text = (ROOT / "project.godot").read_text(encoding="utf-8")
    bootstrap_text = (ROOT / "scripts/managers/InputBootstrap.gd").read_text(encoding="utf-8")
    for action in [
        "move_forward",
        "move_back",
        "move_left",
        "move_right",
        "look_left",
        "look_right",
        "look_up",
        "look_down",
        "sprint",
        "jump",
        "pause",
        "toggle_perspective",
    ]:
        if f"{action}=" not in project_text:
            raise AssertionError(f"project.godot lacks Phase 1 input action: {action}")
        if action not in bootstrap_text:
            raise AssertionError(f"InputBootstrap.gd does not wire Phase 1 input action: {action}")

def validate_phase_2_interaction_contract():
    main_scene = (ROOT / "scenes/world/Main.tscn").read_text(encoding="utf-8")
    player_interaction = (ROOT / "scripts/player/PlayerInteraction.gd").read_text(encoding="utf-8")
    hud_scene = (ROOT / "scenes/ui/GameHUD.tscn").read_text(encoding="utf-8")
    hud_script = (ROOT / "scripts/ui/GameHUD.gd").read_text(encoding="utf-8")
    pickup_script = (ROOT / "scripts/items/PickupItem.gd").read_text(encoding="utf-8")

    for fragment in [
        'path="res://scripts/items/PickupItem.gd"',
        'path="res://scripts/stations/Interactable.gd"',
        '[node name="TrainingBurger" type="RigidBody3D" parent="World"]',
        '[node name="TrainingCounter" type="StaticBody3D" parent="World"]',
        '[node name="RegisterStation" type="StaticBody3D" parent="World"]',
        '[node name="DriveThruStation" type="StaticBody3D" parent="World"]',
    ]:
        if fragment not in main_scene:
            raise AssertionError(f"Phase 2 main scene contract missing: {fragment}")

    for fragment in ["InteractionPromptLabel", "set_interaction_prompt"]:
        if fragment not in hud_scene + hud_script:
            raise AssertionError(f"Phase 2 HUD prompt contract missing: {fragment}")

    for fragment in ["item_picked_up", "item_dropped", "item_thrown", "_update_prompt", "_is_pickup_item"]:
        if fragment not in player_interaction:
            raise AssertionError(f"Phase 2 player interaction contract missing: {fragment}")

    for fragment in ["reset_to_spawn", "pickup_item_reset"]:
        if fragment not in pickup_script:
            raise AssertionError(f"Phase 2 pickup fallback contract missing: {fragment}")
    if not (ROOT / "tools/phase2_runtime_check.gd").exists():
        raise AssertionError("Missing Phase 2 runtime check: tools/phase2_runtime_check.gd")

def validate_phase_3_station_contract():
    main_scene = (ROOT / "scenes/world/Main.tscn").read_text(encoding="utf-8")
    cooking_station = (ROOT / "scripts/stations/CookingStation.gd").read_text(encoding="utf-8")
    food_item = (ROOT / "scripts/items/FoodItem.gd").read_text(encoding="utf-8")

    for fragment in [
        'path="res://scripts/items/FoodItem.gd"',
        'path="res://scripts/stations/GrillStation.gd"',
        '[node name="GrillStation" type="StaticBody3D" parent="World"]',
        '[node name="CookingArea" type="Area3D" parent="World/GrillStation"]',
        '[node name="RawPatty" type="RigidBody3D" parent="World"]',
    ]:
        if fragment not in main_scene:
            raise AssertionError(f"Phase 3 station scene contract missing: {fragment}")

    for fragment in ["advance_item_state", "station_item_placed", "station_item_advanced"]:
        if fragment not in cooking_station:
            raise AssertionError(f"Phase 3 cooking station contract missing: {fragment}")

    for fragment in ["State { RAW, COOKED, BURNT }", "item_state_changed", "material_override"]:
        if fragment not in food_item:
            raise AssertionError(f"Phase 3 food item contract missing: {fragment}")

    if not (ROOT / "tools/phase3_runtime_check.gd").exists():
        raise AssertionError("Missing Phase 3 runtime check: tools/phase3_runtime_check.gd")

def validate_phase_4_staff_contract():
    main_scene = (ROOT / "scenes/world/Main.tscn").read_text(encoding="utf-8")
    staff_director = (ROOT / "scripts/staff/StaffDirector.gd").read_text(encoding="utf-8")
    coworker_npc = (ROOT / "scripts/staff/CoworkerNPC.gd").read_text(encoding="utf-8")
    hud_scene = (ROOT / "scenes/ui/GameHUD.tscn").read_text(encoding="utf-8")
    hud_script = (ROOT / "scripts/ui/GameHUD.gd").read_text(encoding="utf-8")

    for fragment in [
        'path="res://scripts/staff/StaffDirector.gd"',
        'path="res://scripts/staff/CoworkerNPC.gd"',
        '[node name="StaffDirector" type="Node" parent="."]',
        '[node name="CoworkerRiley" type="StaticBody3D" parent="World"]',
        '[node name="CoworkerCasey" type="StaticBody3D" parent="World"]',
        '[node name="CoworkerMorgan" type="StaticBody3D" parent="World"]',
    ]:
        if fragment not in main_scene:
            raise AssertionError(f"Phase 4 staff scene contract missing: {fragment}")

    for fragment in [
        "request_help",
        "record_mistake",
        "swap_station",
        "generate_callout",
        "staff_morale",
        "manager_trust",
        "station_coverage",
        "customer_patience",
        "coworker_callout",
        "manager_callout_handled",
    ]:
        if fragment not in staff_director:
            raise AssertionError(f"Phase 4 StaffDirector contract missing: {fragment}")

    for fragment in ["CoworkerNPC", "request_help", "dialogue_for"]:
        if fragment not in coworker_npc:
            raise AssertionError(f"Phase 4 CoworkerNPC contract missing: {fragment}")

    for fragment in ["StaffStatusLabel", "set_staff_status"]:
        if fragment not in hud_scene + hud_script:
            raise AssertionError(f"Phase 4 HUD staff contract missing: {fragment}")

    if not (ROOT / "tools/phase4_runtime_check.gd").exists():
        raise AssertionError("Missing Phase 4 runtime check: tools/phase4_runtime_check.gd")

def validate_phase_5_store_ops_contract():
    main_scene = (ROOT / "scenes/world/Main.tscn").read_text(encoding="utf-8")
    store_director = (ROOT / "scripts/store/StoreOpsDirector.gd").read_text(encoding="utf-8")
    store_station = (ROOT / "scripts/store/StoreOpsStation.gd").read_text(encoding="utf-8")
    hud_scene = (ROOT / "scenes/ui/GameHUD.tscn").read_text(encoding="utf-8")
    hud_script = (ROOT / "scripts/ui/GameHUD.gd").read_text(encoding="utf-8")
    shift_results = (ROOT / "scripts/managers/ShiftResultManager.gd").read_text(encoding="utf-8")

    for fragment in [
        'path="res://scripts/store/StoreOpsDirector.gd"',
        'path="res://scripts/store/StoreOpsStation.gd"',
        '[node name="StoreOpsDirector" type="Node" parent="."]',
        '[node name="SauceStockStation" type="StaticBody3D" parent="World"]',
        '[node name="BaggingTableStation" type="StaticBody3D" parent="World"]',
        '[node name="FryerCheckStation" type="StaticBody3D" parent="World"]',
        '[node name="TrashRunStation" type="StaticBody3D" parent="World"]',
        '[node name="CleaningStation" type="StaticBody3D" parent="World"]',
        '[node name="RegisterCheckStation" type="StaticBody3D" parent="World"]',
        '[node name="RecoveryStation" type="StaticBody3D" parent="World"]',
    ]:
        if fragment not in main_scene:
            raise AssertionError(f"Phase 5 store ops scene contract missing: {fragment}")

    for fragment in [
        "complete_duty",
        "trigger_minor_issue",
        "repair_issue",
        "get_recap_entries",
        "sauce_stock",
        "bagging_table_ready",
        "fryer_health",
        "register_balanced",
        "trash_level",
        "cleanliness",
        "customer_patience",
        "store_duty_completed",
        "store_issue_triggered",
        "store_issue_repaired",
    ]:
        if fragment not in store_director:
            raise AssertionError(f"Phase 5 StoreOpsDirector contract missing: {fragment}")

    for fragment in ["StoreOpsStation", "complete_duty", "repair_issue", "set_interaction_prompt"]:
        if fragment not in store_station:
            raise AssertionError(f"Phase 5 StoreOpsStation contract missing: {fragment}")

    for fragment in ["StoreOpsStatusLabel", "set_store_ops_status"]:
        if fragment not in hud_scene + hud_script:
            raise AssertionError(f"Phase 5 HUD store ops contract missing: {fragment}")

    if "Store Duties:" not in shift_results or "get_recap_entries" not in shift_results:
        raise AssertionError("Phase 5 shift recap contract missing Store Duties entries")

    if not (ROOT / "tools/phase5_runtime_check.gd").exists():
        raise AssertionError("Missing Phase 5 runtime check: tools/phase5_runtime_check.gd")

def validate_phase_6_daily_tasks_contract():
    main_scene = (ROOT / "scenes/world/Main.tscn").read_text(encoding="utf-8")
    daily_tasks = (ROOT / "scripts/mischief/DailyTaskManager.gd").read_text(encoding="utf-8")
    store_director = (ROOT / "scripts/store/StoreOpsDirector.gd").read_text(encoding="utf-8")
    hud_scene = (ROOT / "scenes/ui/GameHUD.tscn").read_text(encoding="utf-8")
    hud_script = (ROOT / "scripts/ui/GameHUD.gd").read_text(encoding="utf-8")
    shift_results = (ROOT / "scripts/managers/ShiftResultManager.gd").read_text(encoding="utf-8")

    for fragment in [
        'path="res://scripts/mischief/DailyTaskManager.gd"',
        '[node name="DailyTaskManager" type="Node" parent="."]',
    ]:
        if fragment not in main_scene:
            raise AssertionError(f"Phase 6 daily task scene contract missing: {fragment}")

    for fragment in [
        "generate_daily_tasks",
        "record_progress",
        "finish_shift",
        "get_recap_entries",
        "get_reward_totals",
        "normal_work",
        "customer_service",
        "station",
        "manager_request",
        "recovery",
        "small_funny",
        "daily_task_completed",
        "daily_tasks_finalized",
    ]:
        if fragment not in daily_tasks:
            raise AssertionError(f"Phase 6 DailyTaskManager contract missing: {fragment}")

    for fragment in ["record_progress", "store_duty", "store_issue_repaired"]:
        if fragment not in store_director:
            raise AssertionError(f"Phase 6 store ops daily task hook missing: {fragment}")

    for fragment in ["DailyTasksLabel", "set_daily_tasks"]:
        if fragment not in hud_scene + hud_script:
            raise AssertionError(f"Phase 6 HUD daily task contract missing: {fragment}")

    if "Daily Tasks:" not in shift_results or "finish_shift" not in shift_results:
        raise AssertionError("Phase 6 shift recap contract missing Daily Tasks entries")

    if not (ROOT / "tools/phase6_runtime_check.gd").exists():
        raise AssertionError("Missing Phase 6 runtime check: tools/phase6_runtime_check.gd")

def validate_phase_7_shift_results_contract():
    shift_results = (ROOT / "scripts/managers/ShiftResultManager.gd").read_text(encoding="utf-8")
    save_system = (ROOT / "scripts/managers/SaveSystem.gd").read_text(encoding="utf-8")
    shift_manager = (ROOT / "scripts/managers/ShiftManager.gd").read_text(encoding="utf-8")
    order_manager = (ROOT / "scripts/managers/OrderManager.gd").read_text(encoding="utf-8")
    beef_manager = (ROOT / "scripts/managers/BeefManager.gd").read_text(encoding="utf-8")

    for fragment in [
        "begin_shift_snapshot",
        "complete_shift",
        "build_shift_result_data",
        "format_shift_report",
        "prepare_next_shift",
        "money_earned",
        "xp_earned",
        "tips",
        "customers_served",
        "order_accuracy",
        "average_wait",
        "average_patience",
        "beef_incidents",
        "staff_morale_change",
        "manager_trust_change",
        "corporate_approval_change",
        "daily_tasks_completed",
        "reviews",
        "writeups",
        "notable_moment",
        "unlock_hooks",
        "fail_state",
    ]:
        if fragment not in shift_results:
            raise AssertionError(f"Phase 7 ShiftResultManager contract missing: {fragment}")

    for fragment in ["schema_version", "last_shift", "next_shift", "verify_save_roundtrip", "get_last_save_data"]:
        if fragment not in save_system:
            raise AssertionError(f"Phase 7 SaveSystem contract missing: {fragment}")

    if "complete_shift" not in shift_manager or "begin_shift_snapshot" not in shift_manager:
        raise AssertionError("Phase 7 ShiftManager does not call result snapshot/complete hooks")

    for fragment in ["orders_attempted", "orders_failed", "get_order_accuracy", "get_average_wait", "get_average_patience"]:
        if fragment not in order_manager:
            raise AssertionError(f"Phase 7 OrderManager metric contract missing: {fragment}")

    if "beef_incident" not in beef_manager:
        raise AssertionError("Phase 7 BeefManager does not log Beef incidents")

    if not (ROOT / "tools/phase7_runtime_check.gd").exists():
        raise AssertionError("Missing Phase 7 runtime check: tools/phase7_runtime_check.gd")

def validate_phase_8_campaign_progression_contract():
    career = (ROOT / "scripts/managers/CareerManager.gd").read_text(encoding="utf-8")
    shift_results = (ROOT / "scripts/managers/ShiftResultManager.gd").read_text(encoding="utf-8")
    save_system = (ROOT / "scripts/managers/SaveSystem.gd").read_text(encoding="utf-8")
    hud = (ROOT / "scripts/ui/GameHUD.gd").read_text(encoding="utf-8")
    main = (ROOT / "scripts/Main.gd").read_text(encoding="utf-8")

    for rank in [
        "Trainee",
        "Crew Member",
        "Station Specialist",
        "Shift Lead Candidate",
        "Shift Lead",
        "Assistant Manager Candidate",
        "Assistant Manager",
        "Acting Store Manager",
        "Store Manager",
    ]:
        if rank not in career:
            raise AssertionError(f"Phase 8 career rank missing: {rank}")

    for fragment in [
        "apply_shift_result",
        "calculate_shift_score",
        "promotion_progress",
        "manager_trust",
        "staff_morale",
        "corporate_approval",
        "writeups",
        "warnings",
        "demotion_risk",
        "fired_risk",
        "shift_performance_history",
        "promotion_requirements",
        "campaign_milestones",
        "manager_trial_setup",
        "manager_trial_unlocked",
        "manager_trial_passed",
        "complete_manager_trial",
        "get_career_save_data",
        "load_career_save_data",
        "career_recap_history",
        "future_expansion_hooks",
    ]:
        if fragment not in career:
            raise AssertionError(f"Phase 8 CareerManager contract missing: {fragment}")

    if "apply_shift_result" not in shift_results or "career_status" not in shift_results:
        raise AssertionError("Phase 8 ShiftResultManager does not apply career progression")

    if "get_career_save_data" not in save_system or "load_career_save_data" not in save_system:
        raise AssertionError("Phase 8 SaveSystem does not persist career progress")

    if "set_career_status" not in hud or "_connect_career_hud" not in main:
        raise AssertionError("Phase 8 HUD career status hook missing")

    if not (ROOT / "tools/phase8_runtime_check.gd").exists():
        raise AssertionError("Missing Phase 8 runtime check: tools/phase8_runtime_check.gd")

def validate_phase_9_maximum_chaos_contract():
    chaos_runtime_path = ROOT / "scripts/drama/ChaosIncidentRuntime.gd"
    if not chaos_runtime_path.exists():
        raise AssertionError("Missing Phase 9 coordinator: scripts/drama/ChaosIncidentRuntime.gd")
    chaos_runtime = chaos_runtime_path.read_text(encoding="utf-8")
    shift_results = (ROOT / "scripts/managers/ShiftResultManager.gd").read_text(encoding="utf-8")
    career = (ROOT / "scripts/managers/CareerManager.gd").read_text(encoding="utf-8")
    main = (ROOT / "scripts/Main.gd").read_text(encoding="utf-8")

    for fragment in [
        "UnhingedIncidentDirector",
        "SlapstickBrawlManager",
        "ShadySuspicionManager",
        "IncidentChainManager",
        "HRIncidentReporter",
        "ViralClipManager",
        "CalloutManager",
        "ManagerArchetypeManager",
        "PlayerReputationManager",
        "DemotionManager",
        "ManagerTrialManager",
        "data/incidents/unhinged_incidents.json",
        "data/incidents/incident_chains.json",
        "data/incidents/legendary_shift_chains.json",
        "res://data/fights",
        "res://data/shady",
        "res://data/staff",
        "res://data/hr",
        "res://data/reviews",
        "res://data/career",
        "res://data/reputation",
        "chaos_budget",
        "rarity",
        "incident_cooldowns",
        "recovery_window",
        "tutorial_shift",
        "EventLog",
        "hr_reports",
        "reviews",
        "manager_trust",
        "staff_morale",
        "promotion_progress",
        "demotion_risk",
        "fired_risk",
        "reputation",
        "cartoonish",
        "non_gory",
    ]:
        if fragment not in chaos_runtime:
            raise AssertionError(f"Phase 9 chaos runtime contract missing: {fragment}")

    for fragment in [
        "phase9_incidents",
        "phase9_hr_reports",
        "phase9_viral_clips",
        "reputation_labels",
        "Chaos Incidents:",
        "get_phase9_summary",
    ]:
        if fragment not in shift_results:
            raise AssertionError(f"Phase 9 ShiftResultManager contract missing: {fragment}")

    for fragment in ["apply_incident_impact", "career_incident_impact"]:
        if fragment not in career:
            raise AssertionError(f"Phase 9 CareerManager contract missing: {fragment}")

    if "ChaosIncidentRuntime" not in main:
        raise AssertionError("Phase 9 Main scene boot hook missing ChaosIncidentRuntime")

    for rel in [
        "data/incidents/unhinged_incidents.json",
        "data/incidents/incident_chains.json",
        "data/incidents/legendary_shift_chains.json",
        "data/fights/brawl_triggers.json",
        "data/fights/brawl_actions.json",
        "data/fights/brawl_outcomes.json",
        "data/fights/brawl_objects.json",
        "data/shady/shady_actions.json",
        "data/staff/callout_excuses.json",
        "data/staff/manager_archetypes.json",
        "data/hr/hr_report_templates.json",
        "data/reviews/incident_review_templates.json",
        "data/reviews/viral_clip_events.json",
        "data/career/demotion_rules.json",
        "data/reputation/player_reputation_labels.json",
    ]:
        load_json(rel)

    if not (ROOT / "tools/phase9_runtime_check.gd").exists():
        raise AssertionError("Missing Phase 9 runtime check: tools/phase9_runtime_check.gd")

def validate_phase_10_mischief_contract():
    main = (ROOT / "scripts/Main.gd").read_text(encoding="utf-8")
    mischief = (ROOT / "scripts/mischief/MischiefDirector.gd").read_text(encoding="utf-8")
    prank_war = (ROOT / "scripts/mischief/PrankWarManager.gd").read_text(encoding="utf-8")
    daily = (ROOT / "scripts/mischief/DailyTaskManager.gd").read_text(encoding="utf-8")
    damage = (ROOT / "scripts/mischief/RestaurantDamageManager.gd").read_text(encoding="utf-8")
    recap = (ROOT / "scripts/mischief/MischiefRecapManager.gd").read_text(encoding="utf-8")
    shift_results = (ROOT / "scripts/managers/ShiftResultManager.gd").read_text(encoding="utf-8")

    for rel in [
        "data/mischief/pranks.json",
        "data/mischief/prank_backfires.json",
        "data/mischief/prank_war_chains.json",
        "data/mischief/prank_side_quests.json",
        "data/mischief/daily_tasks.json",
        "data/mischief/restaurant_story_events.json",
        "data/mischief/restaurant_damage_events.json",
        "data/mischief/mischief_stats.json",
        "data/mischief/prank_consequence_matrix.json",
    ]:
        load_json(rel)

    for fragment in [
        "MischiefDirector",
        "PrankWarManager",
        "DailyTaskManager",
        "RestaurantDamageManager",
        "MischiefRecapManager",
        "_spawn_mischief_runtime_if_missing",
    ]:
        if fragment not in main:
            raise AssertionError(f"Phase 10 Main boot contract missing: {fragment}")

    for fragment in [
        "data/mischief/pranks.json",
        "data/mischief/prank_backfires.json",
        "data/mischief/prank_side_quests.json",
        "data/mischief/restaurant_story_events.json",
        "data/mischief/mischief_stats.json",
        "data/mischief/prank_consequence_matrix.json",
        "pull_optional_prank",
        "coworker_prank_player",
        "roll_backfire",
        "prank_budget",
        "manager_suspicion",
        "prank_war_heat",
        "restaurant_stability",
        "generate_side_quest",
        "get_mischief_summary",
        "mischief_prank_resolved",
    ]:
        if fragment not in mischief:
            raise AssertionError(f"Phase 10 MischiefDirector contract missing: {fragment}")

    for fragment in ["data/mischief/prank_war_chains.json", "consider_escalation", "cooldown_turns", "prank_war_escalated", "deescalate"]:
        if fragment not in prank_war:
            raise AssertionError(f"Phase 10 PrankWarManager contract missing: {fragment}")

    for fragment in ["data/mischief/daily_tasks.json", "generate_daily_tasks", "reward", "promotion_progress", "reputation"]:
        if fragment not in daily:
            raise AssertionError(f"Phase 10 DailyTaskManager contract missing: {fragment}")

    for fragment in ["data/mischief/restaurant_damage_events.json", "trigger_damage", "repair_damage", "repairable", "restaurant_damage_triggered", "restaurant_damage_repaired"]:
        if fragment not in damage:
            raise AssertionError(f"Phase 10 RestaurantDamageManager contract missing: {fragment}")

    for fragment in ["build_recap", "pranks_pulled", "prank_backfires", "restaurant_damage_repaired", "prank_war_heat", "mischief_recap_generated"]:
        if fragment not in recap:
            raise AssertionError(f"Phase 10 MischiefRecapManager contract missing: {fragment}")

    for fragment in ["mischief_recap", "mischief_pranks", "mischief_backfires", "restaurant_damage_repaired", "Mischief:"]:
        if fragment not in shift_results:
            raise AssertionError(f"Phase 10 ShiftResultManager contract missing: {fragment}")

    story = load_json("data/mischief/restaurant_story_events.json").get("events", [])
    if len(story) != 180:
        raise AssertionError(f"Phase 10 story event count must remain 180, found {len(story)}")

    if not (ROOT / "tools/phase10_runtime_check.gd").exists():
        raise AssertionError("Missing Phase 10 runtime check: tools/phase10_runtime_check.gd")

def validate_phase_11_fireable_consequence_contract():
    main = (ROOT / "scripts/Main.gd").read_text(encoding="utf-8")
    shift_results = (ROOT / "scripts/managers/ShiftResultManager.gd").read_text(encoding="utf-8")
    fireable = (ROOT / "scripts/consequences/FireableOffenseManager.gd").read_text(encoding="utf-8")
    suspicion = (ROOT / "scripts/consequences/SuspicionManager.gd").read_text(encoding="utf-8")
    shady = (ROOT / "scripts/consequences/ShadyChoiceManager.gd").read_text(encoding="utf-8")

    for rel in [
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
    ]:
        load_json(rel)

    for fragment in [
        "SuspicionManager",
        "FireableOffenseManager",
        "ShadyChoiceManager",
        "TipJarManager",
        "RegisterIntegrityManager",
        "InventoryMisconductManager",
        "FoodKarmaManager",
        "AbstractImpairmentManager",
        "ManagerCoverupManager",
        "FiringRecoveryManager",
        "_spawn_consequence_runtime_if_missing",
    ]:
        if fragment not in main:
            raise AssertionError(f"Phase 11 Main boot contract missing: {fragment}")

    for fragment in [
        "process_shady_choice",
        "record_clean_choice",
        "get_consequence_summary",
        "loaded_fireable_catalogs",
        "apply_caught_level",
        "select_firing_route",
        "recovery_route",
        "abstract_ui_choice",
        "consequence_heavy",
        "non_instructional",
        "demotion_risk",
        "fired_risk",
        "promotion_progress",
        "career",
        "hr_reports",
        "reviews",
        "fireable_offense_recorded",
        "shady_choice_processed",
    ]:
        if fragment not in fireable:
            raise AssertionError(f"Phase 11 FireableOffenseManager contract missing: {fragment}")

    for fragment in ["add_suspicion", "reduce_suspicion", "roll_detection", "detection_history", "investigation_history", "get_summary"]:
        if fragment not in suspicion:
            raise AssertionError(f"Phase 11 SuspicionManager contract missing: {fragment}")

    for fragment in ["ui_choice_templates.json", "select_choice", "abstract_ui_choice", "clean_choice", "process_shady_choice"]:
        if fragment not in shady:
            raise AssertionError(f"Phase 11 ShadyChoiceManager contract missing: {fragment}")

    for path, fragments in {
        "scripts/consequences/TipJarManager.gd": ["tip_jar_actions.json", "apply_action", "process_shady_choice", "record_clean_choice"],
        "scripts/consequences/RegisterIntegrityManager.gd": ["register_misconduct_actions.json", "register_discrepancy", "process_shady_choice"],
        "scripts/consequences/InventoryMisconductManager.gd": ["inventory_misconduct_actions.json", "inventory_discrepancy", "process_shady_choice"],
        "scripts/consequences/FoodKarmaManager.gd": ["food_karma_actions.json", "food_karma", "process_shady_choice"],
        "scripts/consequences/AbstractImpairmentManager.gd": ["abstract_impairment_events.json", "abstract_only", "process_shady_choice"],
        "scripts/consequences/ManagerCoverupManager.gd": ["manager_coverups.json", "choose_response", "process_shady_choice"],
        "scripts/consequences/FiringRecoveryManager.gd": ["firing_routes.json", "recoverable", "get_summary"],
    }.items():
        text = (ROOT / path).read_text(encoding="utf-8")
        for fragment in fragments:
            if fragment not in text:
                raise AssertionError(f"Phase 11 {path} contract missing: {fragment}")

    for fragment in [
        "fireable_consequence_summary",
        "fireable_offenses",
        "caught_levels",
        "firing_recovery_routes",
        "suspicion_summary",
        "Consequences:",
    ]:
        if fragment not in shift_results:
            raise AssertionError(f"Phase 11 ShiftResultManager contract missing: {fragment}")

    if not (ROOT / "tools/phase11_runtime_check.gd").exists():
        raise AssertionError("Missing Phase 11 runtime check: tools/phase11_runtime_check.gd")

def validate_phase_12_emergent_memory_contract():
    main = (ROOT / "scripts/Main.gd").read_text(encoding="utf-8")
    shift_results = (ROOT / "scripts/managers/ShiftResultManager.gd").read_text(encoding="utf-8")
    emergent = (ROOT / "scripts/emergent/EmergentEventDirector.gd").read_text(encoding="utf-8")
    composer = (ROOT / "scripts/emergent/IncidentComposer.gd").read_text(encoding="utf-8")

    for rel in [
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
        "data/recap/generated_recap_fields.json",
    ]:
        load_json(rel)

    for fragment in [
        "EmergentEventDirector",
        "RestaurantMemoryManager",
        "EvidenceManager",
        "StoreObjectMemoryManager",
        "ConsequenceMatrixManager",
        "EmergentMissionGenerator",
        "MultiKarmaManager",
        "DynamicReputationLabelManager",
        "GeneratedRecapManager",
        "FutureChainTriggerManager",
        "_spawn_emergent_runtime_if_missing",
    ]:
        if fragment not in main:
            raise AssertionError(f"Phase 12 Main boot contract missing: {fragment}")

    for fragment in [
        "get_emergent_summary",
        "_process_event",
        "RestaurantMemoryManager",
        "EvidenceManager",
        "StoreObjectMemoryManager",
        "ConsequenceMatrixManager",
        "EmergentMissionGenerator",
        "MultiKarmaManager",
        "DynamicReputationLabelManager",
        "GeneratedRecapManager",
        "FutureChainTriggerManager",
        "loaded_emergent_catalogs",
        "generated_missions",
        "generated_evidence",
        "future_chains",
        "dynamic_labels",
        "emergent_event_generated",
    ]:
        if fragment not in emergent:
            raise AssertionError(f"Phase 12 EmergentEventDirector contract missing: {fragment}")

    if "force_actor_id" not in composer or "force_object_id" not in composer:
        raise AssertionError("Phase 12 IncidentComposer lacks deterministic state component selection")

    for path, fragments in {
        "scripts/memory/RestaurantMemoryManager.gd": ["record_event", "career_memory", "active_flags", "get_summary"],
        "scripts/memory/EvidenceManager.gd": ["create_evidence", "active_evidence", "get_summary"],
        "scripts/memory/StoreObjectMemoryManager.gd": ["record_object_incident", "object_memory", "object_label_added", "get_summary"],
        "scripts/consequences/ConsequenceMatrixManager.gd": ["calculate", "calculation_history", "get_summary"],
        "scripts/missions/EmergentMissionGenerator.gd": ["generate_from_event", "mission_components.json", "generated_missions", "get_summary"],
        "scripts/karma/MultiKarmaManager.gd": ["apply_event", "karma_history", "get_summary"],
        "scripts/reputation/DynamicReputationLabelManager.gd": ["evaluate", "active_labels", "get_summary"],
        "scripts/recap/GeneratedRecapManager.gd": ["build_recap", "recap_history", "get_summary"],
        "scripts/emergent/FutureChainTriggerManager.gd": ["evaluate", "fired_history", "get_summary"],
    }.items():
        text = (ROOT / path).read_text(encoding="utf-8")
        for fragment in fragments:
            if fragment not in text:
                raise AssertionError(f"Phase 12 {path} contract missing: {fragment}")

    for fragment in [
        "emergent_summary",
        "emergent_events",
        "emergent_missions",
        "emergent_evidence",
        "dynamic_reputation_labels",
        "generated_recaps",
        "Restaurant Memory:",
    ]:
        if fragment not in shift_results:
            raise AssertionError(f"Phase 12 ShiftResultManager contract missing: {fragment}")

    if not (ROOT / "tools/phase12_runtime_check.gd").exists():
        raise AssertionError("Missing Phase 12 runtime check: tools/phase12_runtime_check.gd")

def validate_phase_13_global_depth_contract():
    main = (ROOT / "scripts/Main.gd").read_text(encoding="utf-8")
    shift_results = (ROOT / "scripts/managers/ShiftResultManager.gd").read_text(encoding="utf-8")
    depth_director = (ROOT / "scripts/depth/DepthDirector.gd").read_text(encoding="utf-8")
    normalcy = (ROOT / "scripts/depth/NormalcyBalanceDirector.gd").read_text(encoding="utf-8")

    depth_files = [
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
    for rel in depth_files:
        load_json(rel)

    for fragment in [
        "DepthDirector",
        "NormalcyBalanceDirector",
        "DepthEventLinker",
        "WorldTextureManager",
        "ShiftFlavorManager",
        "ContentDensityValidatorRuntime",
        "_spawn_depth_runtime_if_missing",
        "generate_shift_depth",
    ]:
        if fragment not in main:
            raise AssertionError(f"Phase 13 Main boot contract missing: {fragment}")

    for fragment in [
        "generate_shift_depth",
        "get_depth_summary",
        "loaded_depth_catalogs",
        "balanced_sequence",
        "linked_entries",
        "generated_depth_events",
        "customer_memory_arcs.json",
        "customer_normalcy_profiles.json",
        "coworker_social_web.json",
        "manager_pressure_situations.json",
        "home_life_depth_events.json",
        "commute_micro_events.json",
        "store_ops_depth.json",
        "equipment_personality.json",
        "minigames.json",
        "escalation_ladders.json",
        "recovery_routes.json",
        "promotion_detours.json",
        "store_identity_mutations.json",
        "performance_budgets.json",
        "bug_fallback_requirements.json",
        "phase13_depth_generated",
    ]:
        if fragment not in depth_director:
            raise AssertionError(f"Phase 13 DepthDirector contract missing: {fragment}")

    for fragment in [
        "build_balanced_sequence",
        "get_balance_ratio",
        "within_target",
        "normal_orders",
        "service_friction",
        "funny_weird",
        "wild_spike",
    ]:
        if fragment not in normalcy:
            raise AssertionError(f"Phase 13 NormalcyBalanceDirector contract missing: {fragment}")

    for path, fragments in {
        "scripts/depth/DepthEventLinker.gd": ["link_depth_entry", "RestaurantMemoryManager", "depth_event_linked"],
        "scripts/depth/WorldTextureManager.gd": ["generate_rumor", "generate_quiet_event", "get_summary"],
        "scripts/depth/ShiftFlavorManager.gd": ["build_shift_flavor", "store_ops_depth", "minigame", "get_summary"],
        "scripts/depth/ContentDensityValidatorRuntime.gd": ["check_runtime_counts", "fallback_rules", "get_summary"],
    }.items():
        text = (ROOT / path).read_text(encoding="utf-8")
        for fragment in fragments:
            if fragment not in text:
                raise AssertionError(f"Phase 13 {path} contract missing: {fragment}")

    for fragment in [
        "depth_summary",
        "depth_bundles",
        "depth_balance",
        "depth_recovery_routes",
        "depth_promotion_detours",
        "depth_store_mutations",
        "depth_generated_events",
        "Global Depth:",
        "Depth Balance:",
    ]:
        if fragment not in shift_results:
            raise AssertionError(f"Phase 13 ShiftResultManager contract missing: {fragment}")

    if not (ROOT / "tools/phase13_runtime_check.gd").exists():
        raise AssertionError("Missing Phase 13 runtime check: tools/phase13_runtime_check.gd")

def validate_phase_14_stabilization_contract():
    main_scene = (ROOT / "scenes/world/Main.tscn").read_text(encoding="utf-8")
    drive_thru = (ROOT / "scripts/stations/DriveThruWindow.gd").read_text(encoding="utf-8")
    smoke = ROOT / "tools/phase14_full_shift_smoke.gd"
    audit = ROOT / "PHASE_14_STABILIZATION_AUDIT.md"

    for fragment in [
        'path="res://scripts/stations/DriveThruWindow.gd"',
        '[node name="DriveThruStation" type="StaticBody3D" parent="World"]',
        'script = ExtResource("11_drive_thru")',
    ]:
        if fragment not in main_scene:
            raise AssertionError(f"Phase 14 drive-thru scene stabilization missing: {fragment}")

    for fragment in [
        "get_node_or_null",
        "validate_bag",
        "fulfill_order",
        "drive_thru_order_delivered",
        "generate_new_order",
        "_autoload",
    ]:
        if fragment not in drive_thru:
            raise AssertionError(f"Phase 14 DriveThruWindow fallback missing: {fragment}")
    for forbidden in [
        "OrderManager.validate_bag",
        "BeefManager.decrease_beef",
        "JuiceManager.trigger_pop",
        "AudioManager.play_sfx",
    ]:
        if forbidden in drive_thru:
            raise AssertionError(f"Phase 14 DriveThruWindow still has hard autoload reference: {forbidden}")

    for path, forbidden in {
        "scripts/employees/EmployeeAI.gd": 'get_node("Player")',
        "scripts/employees/EmployeeAI_Actions.gd": 'get_node("Player")',
        "scripts/stations/DrinkStation.gd": 'get_node("PlayerInteraction")',
        "scripts/ui/BeefBattleUI.gd": 'get_node("Main/Player")',
    }.items():
        text = (ROOT / path).read_text(encoding="utf-8")
        if forbidden in text:
            raise AssertionError(f"Phase 14 brittle direct node lookup remains in {path}: {forbidden}")

    if not smoke.exists():
        raise AssertionError("Missing Phase 14 full shift smoke check: tools/phase14_full_shift_smoke.gd")
    smoke_text = smoke.read_text(encoding="utf-8")
    for fragment in [
        "drive_thru_order_delivered",
        "complete_shift",
        "load_game",
        "depth_summary",
        "shift_performance_history",
        "Phase 14 full shift stabilization smoke check passed",
    ]:
        if fragment not in smoke_text:
            raise AssertionError(f"Phase 14 smoke contract missing: {fragment}")

    if not audit.exists():
        raise AssertionError("Missing Phase 14 stabilization audit: PHASE_14_STABILIZATION_AUDIT.md")

def validate_phase_15_playability_prep_contract():
    main = (ROOT / "scripts/Main.gd").read_text(encoding="utf-8")
    hud = (ROOT / "scripts/ui/GameHUD.gd").read_text(encoding="utf-8")
    menu = (ROOT / "scripts/ui/MainMenuUI.gd").read_text(encoding="utf-8")
    smoke = ROOT / "tools/phase15_menu_playability_check.gd"

    for fragment in [
        "MainMenuUI",
        "_connect_menu",
        "start_new_game",
        "continue_game",
        "pause_game",
        "resume_game",
        "end_current_shift",
        "return_to_main_menu",
        "save_game_from_menu",
        "load_game_from_menu",
        "apply_menu_settings",
    ]:
        if fragment not in main:
            raise AssertionError(f"Phase 15 Main playability contract missing: {fragment}")

    for fragment in [
        "show_main_menu",
        "show_pause_menu",
        "show_settings",
        "show_controls",
        "show_results",
        "fullscreen",
        "reduced_motion",
        "high_contrast",
        "performance_mode",
        "master_volume",
        "Controller",
        "Keyboard",
    ]:
        if fragment not in menu:
            raise AssertionError(f"Phase 15 MainMenuUI contract missing: {fragment}")

    for fragment in [
        "set_shift_timer",
        "set_objective_status",
        "set_station_feedback",
        "apply_accessibility_settings",
        "ShiftTimerLabel",
        "ObjectiveLabel",
        "StationFeedbackLabel",
    ]:
        if fragment not in hud + (ROOT / "scenes/ui/GameHUD.tscn").read_text(encoding="utf-8"):
            raise AssertionError(f"Phase 15 HUD clarity contract missing: {fragment}")

    if not smoke.exists():
        raise AssertionError("Missing Phase 15 menu playability smoke check: tools/phase15_menu_playability_check.gd")
    smoke_text = smoke.read_text(encoding="utf-8")
    for fragment in [
        "Main menu is first playable screen",
        "Controls screen covers keyboard/mouse and controller",
        "Pause menu opens",
        "Save/load UX reports status",
        "End shift opens recap presentation",
        "Return to menu works",
        "Continue/load starts playable shift",
        "Phase 15 menu playability smoke check passed",
    ]:
        if fragment not in smoke_text:
            raise AssertionError(f"Phase 15 smoke contract missing: {fragment}")

    for rel, fragments in {
        "README.md": ["Run Locally", "Local-Only Statement", "Controls"],
        "STEAM_READINESS_CHECKLIST.md": ["This file tracks preparation", "Build Checklist", "Demo Quality Gate"],
        "PLAYTEST_CHECKLIST.md": ["Startup", "In Shift", "End Shift", "Controller"],
        "KNOWN_ISSUES.md": ["CustomerCar", "DriveThruWindow", "Steamworks"],
        "ASSET_ATTRIBUTION.md": ["No paid assets", "Required Entry Format"],
        "EXPORT_NOTES.md": ["Export presets are not finalized", "Network/backend requirement: none"],
    }.items():
        path = ROOT / rel
        if not path.exists():
            raise AssertionError(f"Missing Phase 15 prep doc: {rel}")
        text = path.read_text(encoding="utf-8")
        for fragment in fragments:
            if fragment not in text:
                raise AssertionError(f"Phase 15 prep doc {rel} missing: {fragment}")

def validate_phase_17_demo_contract():
    main = (ROOT / "scripts/Main.gd").read_text(encoding="utf-8")
    hud = (ROOT / "scripts/ui/GameHUD.gd").read_text(encoding="utf-8")
    car = (ROOT / "scripts/customers/CustomerCar.gd").read_text(encoding="utf-8")
    clock_out = (ROOT / "scripts/stations/ClockOutStation.gd").read_text(encoding="utf-8")
    audio = (ROOT / "scripts/managers/AudioManager.gd").read_text(encoding="utf-8")
    car_scene = ROOT / "scenes/customers/CustomerCar.tscn"
    smoke = ROOT / "tools/phase17_demo_visual_check.gd"
    screenshot_script = ROOT / "tools/phase17_rendered_screenshot.gd"
    player_view_script = ROOT / "tools/phase17_player_view_screenshot.gd"
    report = ROOT / "PHASE_17_VISIBLE_PLAYTEST_AND_GRAYBOX_TO_DEMO_REPORT.md"

    for fragment in [
        "_apply_phase17_demo_visuals",
        "Phase17DemoDressing",
        "DriveThruHandoffMat",
        "DriveThruLane",
        "ClockOutStationScript",
        "ClockOutStation",
        "Phase17Sign",
        "CustomerCar.tscn",
        "set_first_shift_guidance",
    ]:
        if fragment not in main:
            raise AssertionError(f"Phase 17 Main demo contract missing: {fragment}")

    for fragment in [
        "OrderPanel",
        "ObjectivePanel",
        "TaskPanel",
        "CustomerStatusLabel",
        "HeldItemLabel",
        "GuidanceLabel",
        "EventFeedLabel",
        "set_customer_status",
        "set_held_item",
        "set_first_shift_guidance",
    ]:
        if fragment not in hud:
            raise AssertionError(f"Phase 17 HUD demo contract missing: {fragment}")

    if not car_scene.exists():
        raise AssertionError("Missing Phase 17 customer car scene: scenes/customers/CustomerCar.tscn")
    for fragment in [
        "configure_route",
        "drive_to_window",
        "generate_new_order",
        "customer_car_waiting",
        "leave_restaurant",
        "_apply_customer_variant",
        "active_color_name",
        "BodyRed",
        "BodyBlue",
        "BodyYellow",
        "BodyGreen",
    ]:
        if fragment not in car:
            raise AssertionError(f"Phase 17 CustomerCar contract missing: {fragment}")

    for hook in [
        "interact",
        "pickup",
        "drop",
        "order_received",
        "correct_handoff",
        "wrong_handoff",
        "task_complete",
        "shift_start",
        "shift_end",
    ]:
        if hook not in audio:
            raise AssertionError(f"Phase 17 audio hook missing: {hook}")

    for fragment in [
        "ClockOutStation",
        "Clock out / end shift",
        "end_current_shift",
        "Clocked out. Shift recap opening.",
    ]:
        if fragment not in clock_out:
            raise AssertionError(f"Phase 17 ClockOutStation contract missing: {fragment}")

    if not smoke.exists():
        raise AssertionError("Missing Phase 17 demo visual smoke check: tools/phase17_demo_visual_check.gd")
    smoke_text = smoke.read_text(encoding="utf-8")
    for fragment in [
        "Phase 17 demo dressing exists",
        "Visible CustomerCar spawns",
        "CustomerCar shows exactly one color body",
        "HUD shows readable order ticket",
        "Physical clock-out station is interactable",
        "Physical clock-out opens shift recap",
        "Phase 17 demo visual smoke check passed",
    ]:
        if fragment not in smoke_text:
            raise AssertionError(f"Phase 17 smoke contract missing: {fragment}")

    if not screenshot_script.exists():
        raise AssertionError("Missing Phase 17 rendered screenshot script: tools/phase17_rendered_screenshot.gd")
    screenshot_text = screenshot_script.read_text(encoding="utf-8")
    for fragment in [
        "phase17_rendered_demo.png",
        "Phase17OverviewCamera",
        "Phase 17 rendered screenshot saved",
    ]:
        if fragment not in screenshot_text:
            raise AssertionError(f"Phase 17 screenshot script contract missing: {fragment}")

    if not player_view_script.exists():
        raise AssertionError("Missing Phase 17 player-view screenshot script: tools/phase17_player_view_screenshot.gd")
    player_view_text = player_view_script.read_text(encoding="utf-8")
    for fragment in [
        "phase17_player_view_demo.png",
        "Head/Camera3D",
        "Phase 17 player-view screenshot saved",
    ]:
        if fragment not in player_view_text:
            raise AssertionError(f"Phase 17 player-view screenshot script contract missing: {fragment}")

    if not report.exists():
        raise AssertionError("Missing Phase 17 report: PHASE_17_VISIBLE_PLAYTEST_AND_GRAYBOX_TO_DEMO_REPORT.md")

def validate_phase_18_softlock_feel_contract():
    main = (ROOT / "scripts/Main.gd").read_text(encoding="utf-8")
    player = (ROOT / "scripts/player/PlayerController.gd").read_text(encoding="utf-8")
    interaction = (ROOT / "scripts/player/PlayerInteraction.gd").read_text(encoding="utf-8")
    shift = (ROOT / "scripts/managers/ShiftManager.gd").read_text(encoding="utf-8")
    drive_thru = (ROOT / "scripts/stations/DriveThruWindow.gd").read_text(encoding="utf-8")
    hud = (ROOT / "scripts/ui/GameHUD.gd").read_text(encoding="utf-8")
    smoke = ROOT / "tools/phase18_softlock_feel_check.gd"
    report = ROOT / "PHASE_18_PLAYTEST_SOFTLOCK_FEEL_REPORT.md"

    for fragment in [
        "walk_speed: float = 4.2",
        "sprint_speed: float = 6.5",
        "mouse_sensitivity: float = 0.0023",
        "controller_look_sensitivity: float = 2.8",
        "fall_reset_y",
        "_reset_to_spawn",
    ]:
        if fragment not in player:
            raise AssertionError(f"Phase 18 player feel contract missing: {fragment}")

    for fragment in [
        "interaction_range: float = 3.2",
        "Look at a labeled station or item",
        "That is not usable yet",
    ]:
        if fragment not in interaction:
            raise AssertionError(f"Phase 18 interaction clarity contract missing: {fragment}")

    if "shift_duration: float = 360.0" not in shift:
        raise AssertionError("Phase 18 shift duration tuning missing")

    for fragment in [
        "ORDER TICKET",
        "CLOCK OUT",
        "DRIVE-THRU",
        "Bag -> Burger/Fries/Soda",
    ]:
        if fragment not in main + hud:
            raise AssertionError(f"Phase 18 first-shift guidance missing: {fragment}")

    for fragment in [
        "Bring the ticket item here first",
        "That is not part of this order",
    ]:
        if fragment not in drive_thru:
            raise AssertionError(f"Phase 18 drive-thru fallback feedback missing: {fragment}")

    if not smoke.exists():
        raise AssertionError("Missing Phase 18 softlock/feel smoke check: tools/phase18_softlock_feel_check.gd")
    smoke_text = smoke.read_text(encoding="utf-8")
    for fragment in [
        "Player spawns in the 3D restaurant",
        "Interaction range is forgiving",
        "Customer/order flow creates an active order",
        "Drive-thru handoff can complete successfully",
        "Customer car is not stuck waiting forever after fulfillment",
        "Out-of-bounds fall resets player to spawn",
        "Physical clock-out ends shift and opens recap",
        "Local save/load roundtrip remains valid",
        "Controller-compatible InputMap events exist",
        "Phase 18 softlock/feel smoke check passed",
    ]:
        if fragment not in smoke_text:
            raise AssertionError(f"Phase 18 smoke contract missing: {fragment}")

    if not report.exists():
        raise AssertionError("Missing Phase 18 report: PHASE_18_PLAYTEST_SOFTLOCK_FEEL_REPORT.md")

def validate_phase_19_github_playtest_prep_contract():
    main = (ROOT / "scripts/Main.gd").read_text(encoding="utf-8")
    hud = (ROOT / "scripts/ui/GameHUD.gd").read_text(encoding="utf-8")
    smoke = ROOT / "tools/phase19_playtest_prep_check.gd"

    for rel in [
        ".gitignore",
        "FILE_INCLUSION_MANIFEST.md",
        "GITHUB_PUBLISH_REPORT.md",
        "PHASE_19_GITHUB_PLAYTEST_PREP_REPORT.md",
    ]:
        if not (ROOT / rel).exists():
            raise AssertionError(f"Missing Phase 19 repo/playtest file: {rel}")

    gitignore = (ROOT / ".gitignore").read_text(encoding="utf-8")
    for fragment in [
        ".godot/",
        ".import/",
        "tools/downloads/",
        "tools/bin/",
        "artifacts/",
        "__pycache__/",
        "PHASE_PACK/",
        "disabled_not_in_scope/",
    ]:
        if fragment not in gitignore:
            raise AssertionError(f"Phase 19 .gitignore missing exclusion: {fragment}")

    manifest = (ROOT / "FILE_INCLUSION_MANIFEST.md").read_text(encoding="utf-8")
    for fragment in [
        "project.godot",
        "scenes/",
        "scripts/",
        "data/",
        "tools/*.py",
        "tools/*.gd",
        "tools/downloads/",
        "PHASE_PACK/",
        "disabled_not_in_scope/",
    ]:
        if fragment not in manifest:
            raise AssertionError(f"Phase 19 manifest missing: {fragment}")

    for fragment in [
        "PrepFlowArrowTicket",
        "PrepFlowArrowWindow",
        "BaggingPaperBags",
        "FriesReadyBin",
        "SodaCupStack",
        "PrepFlowLabel",
        "SodaAffordanceLabel",
        "FriesAffordanceLabel",
    ]:
        if fragment not in main:
            raise AssertionError(f"Phase 19 prep affordance missing: {fragment}")

    for fragment in ["bags", "soda", "fries"]:
        if fragment not in hud:
            raise AssertionError(f"Phase 19 HUD prep guidance missing: {fragment}")

    if not smoke.exists():
        raise AssertionError("Missing Phase 19 playtest prep smoke: tools/phase19_playtest_prep_check.gd")
    smoke_text = smoke.read_text(encoding="utf-8")
    for fragment in [
        "BaggingPaperBags",
        "FriesReadyBin",
        "SodaCupStack",
        "Objective fits viewport",
        "One order still completes after prep affordance pass",
        "Controller InputMap remains wired",
        "Phase 19 playtest prep smoke check passed",
    ]:
        if fragment not in smoke_text:
            raise AssertionError(f"Phase 19 smoke contract missing: {fragment}")

def validate_phase_20_save_load_stress_contract():
    save_system = (ROOT / "scripts/managers/SaveSystem.gd").read_text(encoding="utf-8")
    event_log = (ROOT / "scripts/managers/EventLog.gd").read_text(encoding="utf-8")
    restaurant_memory = (ROOT / "scripts/memory/RestaurantMemoryManager.gd").read_text(encoding="utf-8")
    object_memory = (ROOT / "scripts/memory/StoreObjectMemoryManager.gd").read_text(encoding="utf-8")
    reputation = (ROOT / "scripts/reputation/DynamicReputationLabelManager.gd").read_text(encoding="utf-8")
    smoke = ROOT / "tools/phase20_multi_shift_save_load_stress.gd"
    report = ROOT / "PHASE_20_SAVE_LOAD_PROGRESSION_STRESS_REPORT.md"

    for rel in [
        "PHASE_20_SAVE_LOAD_PROGRESSION_STRESS_REPORT.md",
        "PROJECT_SOURCE_OF_TRUTH.md",
        "GITHUB_PUBLISH_REPORT.md",
        "FILE_INCLUSION_MANIFEST.md",
    ]:
        if not (ROOT / rel).exists():
            raise AssertionError(f"Missing Phase 20 repo/status file: {rel}")

    for fragment in [
        '"schema_version": 4',
        '"corporate_approval"',
        '"event_log"',
        '"restaurant_memory"',
        '"store_object_memory"',
        '"dynamic_reputation"',
        "load_save_data",
        "_runtime",
    ]:
        if fragment not in save_system:
            raise AssertionError(f"Phase 20 SaveSystem persistence contract missing: {fragment}")

    for script_name, text in {
        "EventLog.gd": event_log,
        "RestaurantMemoryManager.gd": restaurant_memory,
        "StoreObjectMemoryManager.gd": object_memory,
        "DynamicReputationLabelManager.gd": reputation,
    }.items():
        for fragment in ["get_save_data", "load_save_data"]:
            if fragment not in text:
                raise AssertionError(f"Phase 20 {script_name} missing save/load hook: {fragment}")

    if not smoke.exists():
        raise AssertionError("Missing Phase 20 multi-shift stress check: tools/phase20_multi_shift_save_load_stress.gd")
    smoke_text = smoke.read_text(encoding="utf-8")
    for fragment in [
        "Shift 1 completes and saves a served customer",
        "Load after shift 1 returns save data",
        "Shift 2 completes and saves",
        "Two-shift career history persists in save",
        "Corporate approval persists after shift 1 reload",
        "Restaurant memory persists after shift 1 reload",
        "Object memory incident count survives final reload",
        "Corrupt save falls back safely",
        "Phase 20 two-shift save/load progression stress check passed",
    ]:
        if fragment not in smoke_text:
            raise AssertionError(f"Phase 20 smoke contract missing: {fragment}")

    if not report.exists():
        raise AssertionError("Missing Phase 20 report: PHASE_20_SAVE_LOAD_PROGRESSION_STRESS_REPORT.md")

def validate_phase_21_art_direction_contract():
    main = (ROOT / "scripts/Main.gd").read_text(encoding="utf-8")
    hud = (ROOT / "scripts/ui/GameHUD.gd").read_text(encoding="utf-8")
    car = (ROOT / "scripts/customers/CustomerCar.gd").read_text(encoding="utf-8")
    smoke = ROOT / "tools/phase21_art_direction_check.gd"
    screenshot = ROOT / "tools/phase21_rendered_screenshot.gd"
    report = ROOT / "PHASE_21_ART_TEXTURE_PROP_PASS_REPORT.md"
    redo_report = ROOT / "PHASE_21_LAYOUT_CAMERA_HUD_VISUAL_OVERHAUL_REPORT.md"
    redo_smoke = ROOT / "tools/phase21_layout_camera_hud_overhaul_check.gd"
    redo_screenshot = ROOT / "tools/phase21_layout_camera_hud_screenshot.gd"
    attribution = (ROOT / "ASSET_ATTRIBUTION.md").read_text(encoding="utf-8")

    if not report.exists():
        raise AssertionError("Missing Phase 21 report: PHASE_21_ART_TEXTURE_PROP_PASS_REPORT.md")
    if not redo_report.exists():
        raise AssertionError("Missing Phase 21 redo report: PHASE_21_LAYOUT_CAMERA_HUD_VISUAL_OVERHAUL_REPORT.md")

    for fragment in [
        "_apply_phase21_cartoon_identity",
        "Phase21WallStripeBack",
        "Phase21FloorGroutX",
        "Phase21DriveThruWindowFrame",
        "Phase21DriveThruAwning",
        "Phase21HandoffTargetRing",
        "Phase21RegisterScreen",
        "Phase21GrillFlatTop",
        "Phase21FryerVat",
        "Phase21TicketRail",
        "Phase21OrderTicketCard",
        "Phase21SodaCupA",
        "Phase21FryCartonLip",
        "Phase21ClockFace",
        "Phase21BrandWallSign",
        "Phase21BurgerBunTop",
        "_apply_phase21_redo_layout",
        "Phase21RedoLobbyZone",
        "Phase21RedoServiceZone",
        "Phase21RedoPrepZone",
        "Phase21RedoKitchenZone",
        "Phase21RedoStep1Ticket",
        "Phase21RedoStep2Burger",
        "Phase21RedoStep3Window",
        "Phase21RedoStep4ClockOut",
        "Phase21RedoPathArrowTicketToBurger",
        "Phase21RedoHandoffSpot",
        "Phase21RedoPlayerStartSign",
    ]:
        if fragment not in main:
            raise AssertionError(f"Phase 21 Main art contract missing: {fragment}")

    for fragment in [
        "OrderPanelHeader",
        "ObjectivePanelHeader",
        "TaskPanelHeader",
        "PromptPanelAccent",
        "font_shadow_color",
        "Recent",
    ]:
        if fragment not in hud:
            raise AssertionError(f"Phase 21 HUD art contract missing: {fragment}")

    player = (ROOT / "scripts/player/PlayerController.gd").read_text(encoding="utf-8")
    perspective = (ROOT / "scripts/player/PerspectiveManager.gd").read_text(encoding="utf-8")
    for fragment in [
        "first_person_fov: float = 78.0",
        "third_person_fov: float = 72.0",
        "mouse_sensitivity: float = 0.0023",
        "controller_look_sensitivity: float = 2.8",
    ]:
        if fragment not in player:
            raise AssertionError(f"Phase 21 camera feel contract missing: {fragment}")
    if "third_person_rig.look_at" not in perspective:
        raise AssertionError("Phase 21 third-person camera orientation contract missing")

    for fragment in [
        "_apply_phase21_cartoon_details",
        "Phase21Windshield",
        "Phase21FrontBumper",
        "Phase21HeadlightL",
        "Phase21OrderBubbleCard",
        "Phase21OrderBubbleText",
    ]:
        if fragment not in car:
            raise AssertionError(f"Phase 21 CustomerCar art contract missing: {fragment}")

    if not smoke.exists():
        raise AssertionError("Missing Phase 21 art smoke: tools/phase21_art_direction_check.gd")
    smoke_text = smoke.read_text(encoding="utf-8")
    for fragment in [
        "Phase 21 prop exists:",
        "Phase21WallStripeBack",
        "Phase 19 prep affordance preserved",
        "CustomerCar cartoon detail exists",
        "HUD game-style panel exists",
        "Art pass preserves active customer order flow",
        "Phase 21 art direction runtime check passed",
    ]:
        if fragment not in smoke_text:
            raise AssertionError(f"Phase 21 smoke contract missing: {fragment}")

    if not screenshot.exists():
        raise AssertionError("Missing Phase 21 screenshot helper: tools/phase21_rendered_screenshot.gd")
    screenshot_text = screenshot.read_text(encoding="utf-8")
    for fragment in ["phase21_art_direction_demo.png", "Phase21OverviewCamera", "Phase 21 rendered screenshot saved"]:
        if fragment not in screenshot_text:
            raise AssertionError(f"Phase 21 screenshot helper missing: {fragment}")

    if not redo_smoke.exists():
        raise AssertionError("Missing Phase 21 redo smoke: tools/phase21_layout_camera_hud_overhaul_check.gd")
    redo_smoke_text = redo_smoke.read_text(encoding="utf-8")
    for fragment in [
        "Redo layout node exists:",
        "Player starts in readable front aisle",
        "First-person FOV widened for room readability",
        "Debug-like HUD elements are hidden",
        "One order still completes after redo",
        "Phase 21 layout/camera/HUD overhaul check passed",
    ]:
        if fragment not in redo_smoke_text:
            raise AssertionError(f"Phase 21 redo smoke contract missing: {fragment}")

    if not redo_screenshot.exists():
        raise AssertionError("Missing Phase 21 redo screenshot helper: tools/phase21_layout_camera_hud_screenshot.gd")
    redo_screenshot_text = redo_screenshot.read_text(encoding="utf-8")
    for fragment in [
        "phase21_layout_camera_hud_overhaul.png",
        "Phase21RedoOverviewCamera",
        "Phase 21 redo rendered screenshot saved",
    ]:
        if fragment not in redo_screenshot_text:
            raise AssertionError(f"Phase 21 redo screenshot helper missing: {fragment}")

    if "Phase 21" not in attribution or "No external art/audio assets were added during Phase 21" not in attribution:
        raise AssertionError("Phase 21 asset attribution note missing")

def validate_phase_22_manual_playtest_feel_contract():
    report = ROOT / "PHASE_22_MANUAL_PLAYTEST_FEEL_BUGFIX_REPORT.md"
    smoke = ROOT / "tools/phase22_manual_playtest_feel_check.gd"
    interaction = (ROOT / "scripts/player/PlayerInteraction.gd").read_text(encoding="utf-8")
    drive_thru = (ROOT / "scripts/stations/DriveThruWindow.gd").read_text(encoding="utf-8")
    input_bootstrap = (ROOT / "scripts/managers/InputBootstrap.gd").read_text(encoding="utf-8")
    menu = (ROOT / "scripts/ui/MainMenuUI.gd").read_text(encoding="utf-8")

    if not report.exists():
        raise AssertionError("Missing Phase 22 report: PHASE_22_MANUAL_PLAYTEST_FEEL_BUGFIX_REPORT.md")
    if not smoke.exists():
        raise AssertionError("Missing Phase 22 smoke: tools/phase22_manual_playtest_feel_check.gd")

    for fragment in [
        "use_carried_item_on",
        "Aim at a station to use",
        "Q / X: Drop",
        "carried_item_used_on_station",
    ]:
        if fragment not in interaction:
            raise AssertionError(f"Phase 22 interaction feel contract missing: {fragment}")

    for fragment in [
        "_create_handoff_area",
        "HandOffAreaCollision",
        "_clear_carried_item_if_needed",
    ]:
        if fragment not in drive_thru:
            raise AssertionError(f"Phase 22 drive-thru target contract missing: {fragment}")

    if '_add_key_action("pickup_drop", [KEY_Q])' not in input_bootstrap:
        raise AssertionError("Phase 22 drop key mapping contract missing")
    if "E interact/use, Q drop" not in menu:
        raise AssertionError("Phase 22 controls copy contract missing")

    smoke_text = smoke.read_text(encoding="utf-8")
    for fragment in [
        "E no longer doubles as drop while holding food",
        "Drive-thru has real handoff area",
        "Held food can be used on the drive-thru station",
        "Successful handoff clears held item",
        "Empty handoff gives recovery feedback",
        "Phase 22 manual playtest feel smoke check passed",
    ]:
        if fragment not in smoke_text:
            raise AssertionError(f"Phase 22 smoke contract missing: {fragment}")

def validate_phase_23_core_gameplay_depth_contract():
    report = ROOT / "PHASE_23_CORE_GAMEPLAY_DEPTH_REPORT.md"
    smoke = ROOT / "tools/phase23_core_gameplay_depth_check.gd"
    food_bag = (ROOT / "scripts/items/FoodBag.gd").read_text(encoding="utf-8")
    store_station = (ROOT / "scripts/store/StoreOpsStation.gd").read_text(encoding="utf-8")
    grill = (ROOT / "scripts/stations/GrillStation.gd").read_text(encoding="utf-8")
    drink = (ROOT / "scripts/stations/DrinkStation.gd").read_text(encoding="utf-8")
    order_manager = (ROOT / "scripts/managers/OrderManager.gd").read_text(encoding="utf-8")
    drive_thru = (ROOT / "scripts/stations/DriveThruWindow.gd").read_text(encoding="utf-8")
    customer_car = (ROOT / "scripts/customers/CustomerCar.gd").read_text(encoding="utf-8")
    hud = (ROOT / "scripts/ui/GameHUD.gd").read_text(encoding="utf-8")
    shift_results = (ROOT / "scripts/managers/ShiftResultManager.gd").read_text(encoding="utf-8")
    main = (ROOT / "scripts/Main.gd").read_text(encoding="utf-8")

    if not report.exists():
        raise AssertionError("Missing Phase 23 report: PHASE_23_CORE_GAMEPLAY_DEPTH_REPORT.md")
    if not smoke.exists():
        raise AssertionError("Missing Phase 23 smoke: tools/phase23_core_gameplay_depth_check.gd")

    for fragment in ["add_item", "add_contents", "seal_bag", "get_contents_summary", "food_bag_item_added"]:
        if fragment not in food_bag:
            raise AssertionError(f"Phase 23 bag contract missing: {fragment}")

    for fragment in ["_handle_bagging_table", "_handle_fryer", "Fries added to bag", "Grabbed an empty bag"]:
        if fragment not in store_station:
            raise AssertionError(f"Phase 23 prep station contract missing: {fragment}")

    for fragment in ["Burger added to bag", "Soda added to bag", "DrinkFillStation"]:
        if fragment not in grill + drink + main:
            raise AssertionError(f"Phase 23 station/component contract missing: {fragment}")

    for fragment in ["ORDER_TEMPLATES", "validate_bag_detail", "keep_order_active", "tips_earned", "mistake_count", "Ticket #"]:
        if fragment not in order_manager:
            raise AssertionError(f"Phase 23 order manager contract missing: {fragment}")

    for fragment in ["Ticket stays active", "Missing", "container", "validate_bag_detail"]:
        if fragment not in drive_thru:
            raise AssertionError(f"Phase 23 drive-thru validation contract missing: {fragment}")

    for fragment in ["TRY AGAIN", "Patience", "generate_new_order(customer_type)"]:
        if fragment not in customer_car:
            raise AssertionError(f"Phase 23 customer flow contract missing: {fragment}")

    for fragment in ["TICKET #", "Patience:", "Prep: Bag", "get_last_validation_summary"]:
        if fragment not in hud:
            raise AssertionError(f"Phase 23 HUD ticket contract missing: {fragment}")

    for fragment in ["order_mistakes", "Last Order Feedback", "Mistakes:"]:
        if fragment not in shift_results:
            raise AssertionError(f"Phase 23 recap contract missing: {fragment}")

    smoke_text = smoke.read_text(encoding="utf-8")
    for fragment in [
        "Bagging station gives the player an order bag",
        "Wrong order keeps the active ticket for retry",
        "Fryer adds Fries to carried bag",
        "Drink station adds Soda to carried bag",
        "Recap shows mistakes",
        "Save/load still works after deeper gameplay",
        "Phase 23 core gameplay depth check passed",
    ]:
        if fragment not in smoke_text:
            raise AssertionError(f"Phase 23 smoke contract missing: {fragment}")

def validate_phase_24_career_store_manager_loop_contract():
    report = ROOT / "PHASE_24_CAREER_STORE_MANAGER_LOOP_REPORT.md"
    smoke = ROOT / "tools/phase24_career_multi_shift_loop_check.gd"
    career = (ROOT / "scripts/managers/CareerManager.gd").read_text(encoding="utf-8")
    shift_results = (ROOT / "scripts/managers/ShiftResultManager.gd").read_text(encoding="utf-8")
    save_system = (ROOT / "scripts/managers/SaveSystem.gd").read_text(encoding="utf-8")
    hud = (ROOT / "scripts/ui/GameHUD.gd").read_text(encoding="utf-8")
    menu = (ROOT / "scripts/ui/MainMenuUI.gd").read_text(encoding="utf-8")
    main = (ROOT / "scripts/Main.gd").read_text(encoding="utf-8")

    if not report.exists():
        raise AssertionError("Missing Phase 24 report: PHASE_24_CAREER_STORE_MANAGER_LOOP_REPORT.md")
    if not smoke.exists():
        raise AssertionError("Missing Phase 24 smoke: tools/phase24_career_multi_shift_loop_check.gd")

    for rank in [
        "Trainee",
        "Crew Member",
        "Station Specialist",
        "Shift Lead Candidate",
        "Shift Lead",
        "Assistant Manager Candidate",
        "Assistant Manager",
        "Acting Store Manager",
        "Store Manager",
    ]:
        if rank not in career:
            raise AssertionError(f"Phase 24 career rank missing: {rank}")

    for fragment in [
        "last_career_reasons",
        "last_career_delta",
        "recovery_plan",
        "pre_shift_modifier_history",
        "record_pre_shift_modifier",
        "_build_progression_reasons",
        "_build_recovery_plan",
    ]:
        if fragment not in career:
            raise AssertionError(f"Phase 24 career explanation contract missing: {fragment}")

    for fragment in [
        "Career Path:",
        "Career Gains:",
        "Why It Changed:",
        "Recovery Focus:",
        "pre_shift_modifier",
        "career_recovery_focus",
    ]:
        if fragment not in shift_results:
            raise AssertionError(f"Phase 24 recap/next-shift contract missing: {fragment}")

    for fragment in ["schema_version\": 4", "get_career_save_data", "load_career_save_data"]:
        if fragment not in save_system:
            raise AssertionError(f"Phase 24 save contract missing: {fragment}")

    for fragment in ["->", "Promo", "Trust"]:
        if fragment not in hud:
            raise AssertionError(f"Phase 24 HUD career contract missing: {fragment}")

    for fragment in ["BodyScroll", "body_label.text = report", "Shift Recap"]:
        if fragment not in menu:
            raise AssertionError(f"Phase 24 recap menu contract missing: {fragment}")

    for fragment in ["Phase24CareerPathBoard", "Phase24CareerPathText", "_cartoon_noise_texture", "DIFFUSE_TOON", "SPECULAR_TOON"]:
        if fragment not in main:
            raise AssertionError(f"Phase 24 material/career board contract missing: {fragment}")

    smoke_text = smoke.read_text(encoding="utf-8")
    for fragment in [
        "Phase 24 rank ladder matches requested path",
        "Shift 1 career reasons are visible",
        "Next shift setup carries career focus",
        "Two-shift career history persists after reload",
        "Phase 24 career multi-shift loop check passed",
    ]:
        if fragment not in smoke_text:
            raise AssertionError(f"Phase 24 smoke contract missing: {fragment}")

def validate_phase_25_full_build_audit_contract():
    report = ROOT / "PHASE_25_FULL_BUILD_AUDIT_AND_FIX_REPORT.md"
    smoke = ROOT / "tools/phase25_full_build_audit_check.gd"
    save_system = (ROOT / "scripts/managers/SaveSystem.gd").read_text(encoding="utf-8")
    menu = (ROOT / "scripts/ui/MainMenuUI.gd").read_text(encoding="utf-8")
    source_truth = (ROOT / "PROJECT_SOURCE_OF_TRUTH.md").read_text(encoding="utf-8")
    known_issues = (ROOT / "KNOWN_ISSUES.md").read_text(encoding="utf-8")

    if not report.exists():
        raise AssertionError("Missing Phase 25 report: PHASE_25_FULL_BUILD_AUDIT_AND_FIX_REPORT.md")
    if not smoke.exists():
        raise AssertionError("Missing Phase 25 smoke: tools/phase25_full_build_audit_check.gd")
    report_text = report.read_text(encoding="utf-8")

    for fragment in [
        "_get_previous_save_data",
        "_read_save_data_without_applying",
        'extra_data.get("last_shift", previous_save.get("last_shift", {}))',
        'extra_data.get("next_shift", previous_save.get("next_shift", {}))',
    ]:
        if fragment not in save_system:
            raise AssertionError(f"Phase 25 save preservation contract missing: {fragment}")

    for fragment in ["ScrollContainer", "BodyScroll", "body_label.text = report", "scroll_vertical = 0"]:
        if fragment not in menu:
            raise AssertionError(f"Phase 25 scrollable recap contract missing: {fragment}")

    for fragment in [
        "Phase 25 Full Build Audit",
        "Systems Actually Wired Into Gameplay",
        "Partially Working",
        "Scaffolded Only",
        "Data/Docs Only",
        "Should Be Deferred",
    ]:
        if fragment not in source_truth + report_text:
            raise AssertionError(f"Phase 25 audit classification missing: {fragment}")

    if "GitHub push depends on GitHub CLI authentication" in known_issues:
        raise AssertionError("Known issues still contains stale Phase 19 GitHub auth blocker wording")

    smoke_text = smoke.read_text(encoding="utf-8")
    for fragment in [
        "Shift recap no longer truncates long reports",
        "Menu save preserves completed last shift",
        "Menu save preserves next-shift setup",
        "Phase 25 full build audit smoke check passed",
    ]:
        if fragment not in smoke_text:
            raise AssertionError(f"Phase 25 smoke contract missing: {fragment}")

def validate_all_json() -> int:
    count = 0
    for path in ROOT.rglob("*.json"):
        json.loads(path.read_text(encoding="utf-8"))
        count += 1
    return count

def validate_python_tools() -> int:
    count = 0
    for path in (ROOT / "tools").rglob("*.py"):
        ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
        count += 1
    return count

def validate_required_files():
    for rel in REQUIRED_HANDOFF:
        if not (ROOT / rel).exists():
            raise AssertionError(f"Missing required handoff/phase file: {rel}")

def validate_active_scripts():
    blockers = []
    machine_paths = []
    local_only_hits = []
    disabled_root = ROOT / "disabled_not_in_scope"
    blocker_tokens = ["TODO", "FIXME", "NotImplementedError", "your code here", "queue_//"]
    local_only_tokens = ["multiplayer", "co-op", "remote database", "online backend", "http://", "https://"]
    for path in ROOT.rglob("*.gd"):
        if disabled_root in path.parents:
            continue
        rel = path.relative_to(ROOT).as_posix()
        text = path.read_text(encoding="utf-8")
        for line_number, line in enumerate(text.splitlines(), start=1):
            stripped = line.strip()
            if stripped == "pass":
                blockers.append(f"{rel}:{line_number}: active pass statement")
            for token in blocker_tokens:
                if token in line:
                    blockers.append(f"{rel}:{line_number}: active blocker token {token}")
            if "/home/oai/tools" in line:
                machine_paths.append(f"{rel}:{line_number}: machine-specific validator path")
            lower = line.lower()
            for token in local_only_tokens:
                if token in lower:
                    local_only_hits.append(f"{rel}:{line_number}: local-only scope token {token}")
    if blockers:
        raise AssertionError("Active GDScript blockers found: " + "; ".join(blockers[:10]))
    if machine_paths:
        raise AssertionError("Machine-specific paths found: " + "; ".join(machine_paths[:10]))
    if local_only_hits:
        raise AssertionError("Active online/multiplayer references found: " + "; ".join(local_only_hits[:10]))

def main() -> int:
    errors = []

    try:
        validate_required_files()
        main_scene = validate_project_config()
        scene_resource_count = validate_scene_resource_paths()
        validate_phase_1_player_scene()
        validate_phase_1_input_actions()
        validate_phase_2_interaction_contract()
        validate_phase_3_station_contract()
        validate_phase_4_staff_contract()
        validate_phase_5_store_ops_contract()
        validate_phase_6_daily_tasks_contract()
        validate_phase_7_shift_results_contract()
        validate_phase_8_campaign_progression_contract()
        validate_phase_9_maximum_chaos_contract()
        validate_phase_10_mischief_contract()
        validate_phase_11_fireable_consequence_contract()
        validate_phase_12_emergent_memory_contract()
        validate_phase_13_global_depth_contract()
        validate_phase_14_stabilization_contract()
        validate_phase_15_playability_prep_contract()
        validate_phase_17_demo_contract()
        validate_phase_18_softlock_feel_contract()
        validate_phase_19_github_playtest_prep_contract()
        validate_phase_20_save_load_stress_contract()
        validate_phase_21_art_direction_contract()
        validate_phase_22_manual_playtest_feel_contract()
        validate_phase_23_core_gameplay_depth_contract()
        validate_phase_24_career_store_manager_loop_contract()
        validate_phase_25_full_build_audit_contract()
        json_count = validate_all_json()
        python_count = validate_python_tools()
        validate_active_scripts()

        for rel in REQUIRED_JSON:
            load_json(rel)
        for rel in REQUIRED_SCRIPTS:
            if not (ROOT / rel).exists():
                raise AssertionError(f"Missing required script: {rel}")

        story = load_json("data/mischief/restaurant_story_events.json").get("events", [])
        lock = load_json("V22_RESTAURANT_STORY_EVENT_COUNT_LOCK.json")
        if not (len(story) == lock.get("before_count") == lock.get("after_count")):
            raise AssertionError(
                f"Restaurant story-event count changed: actual={len(story)} lock={lock}"
            )

        bundles = load_json("data/depth/depth_bundles.json").get("bundles", [])
        if len(bundles) < 30:
            raise AssertionError(f"Expected at least 30 depth bundles, found {len(bundles)}")
        for bundle in bundles:
            if len(bundle.get("systems_connected", [])) < 3:
                raise AssertionError(f"Bundle lacks 3+ system links: {bundle.get('id')}")
            if not bundle.get("fallback"):
                raise AssertionError(f"Bundle lacks fallback: {bundle.get('id')}")
            if not bundle.get("required_hooks"):
                raise AssertionError(f"Bundle lacks required hooks: {bundle.get('id')}")

        layers = load_json("data/depth/shift_texture_layers.json").get("layers", [])
        layer_ids = {x.get("id") for x in layers}
        for needed in ["normal_orders", "service_friction", "funny_weird", "wild_spike"]:
            if needed not in layer_ids:
                raise AssertionError(f"Missing shift texture layer: {needed}")

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
            data = load_json(rel).get(key, [])
            if len(data) < minimum:
                raise AssertionError(f"{rel} expected {minimum}+ {key}, found {len(data)}")

    except Exception as exc:
        errors.append(str(exc))

    if errors:
        print("[FAIL] Validation suite failed")
        for err in errors:
            print(f"- {err}")
        return 1

    print("[PASS] Validation suite passed")
    print(f"[PASS] Main scene path exists: {main_scene}")
    print(f"[PASS] Scene resource paths valid: {scene_resource_count}")
    print("[PASS] Phase 1 player scene/input contract valid")
    print("[PASS] Phase 2 interaction/pickup contract valid")
    print("[PASS] Phase 3 station food-state contract valid")
    print("[PASS] Phase 4 staff/coworker contract valid")
    print("[PASS] Phase 5 store operations contract valid")
    print("[PASS] Phase 6 daily tasks contract valid")
    print("[PASS] Phase 7 shift results/save contract valid")
    print("[PASS] Phase 8 campaign progression contract valid")
    print("[PASS] Phase 9 maximum chaos incident contract valid")
    print("[PASS] Phase 10 workplace mischief/pranks contract valid")
    print("[PASS] Phase 11 fireable offense consequence contract valid")
    print("[PASS] Phase 12 emergent restaurant memory contract valid")
    print("[PASS] Phase 13 global depth balance contract valid")
    print("[PASS] Phase 14 stabilization contract valid")
    print("[PASS] Phase 15 playability/Steam prep contract valid")
    print("[PASS] Phase 17 graybox-to-demo contract valid")
    print("[PASS] Phase 18 playtest/softlock/feel contract valid")
    print("[PASS] Phase 19 GitHub/playtest prep contract valid")
    print("[PASS] Phase 20 save/load progression stress contract valid")
    print("[PASS] Phase 21 art direction/prop contract valid")
    print("[PASS] Phase 22 manual playtest/feel contract valid")
    print("[PASS] Phase 23 core gameplay depth contract valid")
    print("[PASS] Phase 24 career/store-manager loop contract valid")
    print("[PASS] Phase 25 full build audit/fix contract valid")
    print(f"[PASS] JSON files valid: {json_count}")
    print(f"[PASS] Python tools compile: {python_count}")
    print(f"[PASS] Restaurant story event count preserved at {len(story)}")
    print(f"[PASS] Depth bundles validated: {len(bundles)}")
    print("[PASS] Active GDScript placeholder/local-only blockers: 0")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
