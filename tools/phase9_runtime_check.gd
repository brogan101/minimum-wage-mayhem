extends SceneTree

func _initialize():
	call_deferred("_run_check")

func _run_check():
	var main_scene = load("res://scenes/world/Main.tscn")
	_assert(main_scene != null, "Main scene loads")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var chaos = root.find_child("ChaosIncidentRuntime", true, false)
	var career = root.get_node_or_null("CareerManager")
	var shift_results = root.get_node_or_null("ShiftResultManager")
	var event_log = root.get_node_or_null("EventLog")
	var staff = root.find_child("StaffDirector", true, false)
	var store_ops = root.find_child("StoreOpsDirector", true, false)

	_assert(chaos != null, "Phase 9 chaos runtime exists in playable scene")
	_assert(career != null, "CareerManager exists for incident consequences")
	_assert(shift_results != null, "ShiftResultManager exists for incident recap")
	_assert(event_log != null, "EventLog exists for incident logging")
	_assert(staff != null and store_ops != null, "Staff and store systems exist for incident effects")

	for child_name in [
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
		"ManagerTrialManager"
	]:
		_assert(chaos.find_child(child_name, false, false) != null, child_name + " is wired")

	var first_summary = chaos.get_phase9_summary()
	var loaded_paths = first_summary.get("loaded_data_catalogs", [])
	for required_path in [
		"res://data/incidents/unhinged_incidents.json",
		"res://data/incidents/incident_chains.json",
		"res://data/incidents/legendary_shift_chains.json",
		"res://data/fights/brawl_objects.json",
		"res://data/shady/shady_actions.json",
		"res://data/staff/manager_archetypes.json",
		"res://data/hr/hr_report_templates.json",
		"res://data/reviews/viral_clip_events.json",
		"res://data/career/demotion_rules.json",
		"res://data/reputation/player_reputation_labels.json"
	]:
		_assert(required_path in loaded_paths, "Loaded data catalog " + required_path)

	chaos.configure_shift(1)
	var tutorial_incident = chaos.trigger_named_incident("coupon_binder_standoff", {"coupon_customer": true, "register_active": true})
	_assert(tutorial_incident.is_empty(), "Tutorial shift blocks moderate incidents")
	var tutorial_brawl = chaos.consider_slapstick({"beef": 100, "beef_threshold": 70})
	_assert(tutorial_brawl.is_empty(), "Tutorial shift blocks slapstick brawl")

	shift_results.begin_shift_snapshot()
	var starting_morale = staff.staff_morale
	var starting_review_risk = store_ops.review_risk
	var starting_demotion_risk = career.demotion_risk
	chaos.configure_shift(4)
	var incident = chaos.trigger_named_incident("coupon_binder_standoff", {
		"coupon_customer": true,
		"register_active": true,
		"chaos_available": 8,
		"cognitive_load_available": 8
	})
	_assert(not incident.is_empty(), "Gated shift can trigger a non-tutorial incident")
	_assert(bool(incident.get("cartoonish", false)) and bool(incident.get("non_gory", false)), "Incident is cartoonish and non-gory")
	_assert(int(chaos.chaos_budget) < 10, "Incident consumes chaos budget")
	_assert(int(chaos.recovery_window_turns) > 0, "Moderate incident starts recovery window")
	_assert(chaos.incident_cooldowns.has("coupon_binder_standoff"), "Incident cooldown is set")
	_assert(int(staff.staff_morale) < int(starting_morale), "Incident affects staff morale")
	_assert(int(store_ops.review_risk) > int(starting_review_risk), "Incident affects review risk")
	_assert(int(career.demotion_risk) > int(starting_demotion_risk), "Incident affects career demotion risk")
	_assert(event_log.get_events_by_type("max_chaos_incident").size() >= 1, "Incident writes EventLog entries")
	_assert(event_log.get_events_by_type("phase9_hr_report").size() >= 1, "HR report generated and logged")
	_assert(event_log.get_events_by_type("phase9_review").size() >= 1, "Review generated and logged")
	_assert(event_log.get_events_by_type("career_incident_impact").size() >= 1, "Career incident impact logged")

	var blocked_by_recovery = chaos.try_roll_incident({
		"coupon_customer": true,
		"register_active": true,
		"manager_present": true,
		"manager_panic_high": true,
		"rush_active": true,
		"cash_handling_unlocked": true
	})
	_assert(blocked_by_recovery.is_empty(), "Recovery window blocks immediate extra incident")

	chaos.configure_shift(4)
	var brawl = chaos.consider_slapstick({"beef": 100, "beef_threshold": 70})
	_assert(not brawl.is_empty(), "Slapstick brawl can trigger after tutorial")
	_assert(bool(brawl.get("cartoonish", false)) and bool(brawl.get("non_gory", false)), "Slapstick brawl is cartoonish and non-gory")
	_assert(event_log.get_events_by_type("slapstick_brawl_resolved").size() >= 1, "Slapstick brawl writes EventLog")

	var chain = chaos.start_chain("sauce_betrayal_chain")
	_assert(not chain.is_empty(), "Incident chain can start")
	_assert(event_log.get_events_by_type("incident_chain_started").size() >= 1, "Incident chain writes EventLog")

	var report = shift_results.complete_shift({"completed": 1})
	var result = shift_results.get_last_result_data()
	_assert(report.contains("Chaos Incidents:"), "Shift recap includes chaos incident count")
	_assert(result.get("phase9_incidents", []).size() >= 2, "Shift result stores Phase 9 incidents")
	_assert(result.get("phase9_hr_reports", []).size() >= 1, "Shift result stores HR reports")
	_assert(result.get("reviews", []).size() >= 1, "Shift result stores incident reviews")
	_assert(result.get("reputation_labels", []).size() >= 1, "Shift result stores reputation labels")
	_assert(career.get_career_status().get("career_recap_history", []).size() >= 1, "Career history records shift with incidents")

	print("[PASS] Phase 9 runtime maximum chaos incident check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
