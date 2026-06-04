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

	var suspicion = root.find_child("SuspicionManager", true, false)
	var fireable = root.find_child("FireableOffenseManager", true, false)
	var shady = root.find_child("ShadyChoiceManager", true, false)
	var tips = root.find_child("TipJarManager", true, false)
	var register = root.find_child("RegisterIntegrityManager", true, false)
	var inventory = root.find_child("InventoryMisconductManager", true, false)
	var food = root.find_child("FoodKarmaManager", true, false)
	var impairment = root.find_child("AbstractImpairmentManager", true, false)
	var coverup = root.find_child("ManagerCoverupManager", true, false)
	var recovery = root.find_child("FiringRecoveryManager", true, false)
	var shift_results = root.get_node_or_null("ShiftResultManager")
	var save_system = root.get_node_or_null("SaveSystem")
	var career = root.get_node_or_null("CareerManager")
	var event_log = root.get_node_or_null("EventLog")
	var staff = root.find_child("StaffDirector", true, false)
	var store_ops = root.find_child("StoreOpsDirector", true, false)

	for node_pair in [
		[suspicion, "SuspicionManager"],
		[fireable, "FireableOffenseManager"],
		[shady, "ShadyChoiceManager"],
		[tips, "TipJarManager"],
		[register, "RegisterIntegrityManager"],
		[inventory, "InventoryMisconductManager"],
		[food, "FoodKarmaManager"],
		[impairment, "AbstractImpairmentManager"],
		[coverup, "ManagerCoverupManager"],
		[recovery, "FiringRecoveryManager"]
	]:
		_assert(node_pair[0] != null, str(node_pair[1]) + " wired into playable scene")
	_assert(shift_results != null and save_system != null and career != null and event_log != null, "Result, save, career, and EventLog systems exist")
	_assert(staff != null and store_ops != null, "Staff and store consequence systems exist")

	_assert(fireable.offenses.size() > 0, "Fireable offense catalog loaded")
	_assert(fireable.caught_levels.size() > 0, "Caught levels loaded")
	_assert(fireable.firing_routes.size() > 0, "Firing recovery routes loaded")
	_assert(shady.templates.size() > 0, "UI choice templates loaded")
	_assert(tips.actions.size() > 0, "Tip jar actions loaded")
	_assert(register.actions.size() > 0, "Register actions loaded")
	_assert(inventory.actions.size() > 0, "Inventory actions loaded")
	_assert(food.actions.size() > 0, "Food karma actions loaded")
	_assert(impairment.events.size() > 0, "Abstract impairment events loaded")

	shift_results.begin_shift_snapshot()
	var start_suspicion = suspicion.player_suspicion
	var start_promotion = career.promotion_progress
	var clean = tips.apply_action("count_tips_honestly", {"force_clean": true})
	_assert(bool(clean.get("clean_play_valid", false)), "Clean play remains valid")
	_assert(int(suspicion.player_suspicion) <= int(start_suspicion), "Clean play does not raise suspicion")
	_assert(int(career.promotion_progress) >= int(start_promotion), "Clean play can preserve promotion progress")

	var template = shady.get_choices_for("tip_jar")
	_assert(not template.is_empty() and template.get("choices", []).size() > 0, "Shady choices are UI-template driven")
	var ui_result = shady.select_choice("take_little", {"offense_id": "tip_jar_pocketing", "risk": "medium", "force_caught": true, "witnesses": 1, "camera_coverage": 10})
	_assert(bool(ui_result.get("abstract_ui_choice", false)), "Shady choice result stays abstract UI-driven")

	var register_result = register.apply_action("hide_small_discrepancy", 2, {"force_caught": true, "witnesses": 1, "manager_nearby": 1})
	var inventory_result = inventory.apply_action("take_sauce_home", 1, {"force_caught": true, "camera_coverage": 15})
	var food_result = food.apply_action("cut_corner", {"force_caught": true, "witnesses": 1})
	var impairment_result = impairment.apply_event("work_no_sleep", {"force_caught": true, "manager_nearby": 1})
	var cover = coverup.start_coverup()
	var cover_result = coverup.choose_response("refuse", cover)

	_assert(not register_result.get("consequence", {}).is_empty(), "Register integrity routes to consequences")
	_assert(not inventory_result.get("consequence", {}).is_empty(), "Inventory misconduct routes to consequences")
	_assert(not food_result.get("consequence", {}).is_empty(), "Food karma routes to consequences")
	_assert(not impairment_result.get("consequence", {}).is_empty(), "Abstract impairment routes to consequences")
	_assert(not cover_result.get("consequence", {}).is_empty(), "Manager coverup response routes to consequences")
	_assert(suspicion.player_suspicion > start_suspicion, "Suspicion changes from shady choices")
	_assert(suspicion.detection_history.size() >= 4, "Detection rolls are recorded")
	_assert(fireable.caught_history.size() >= 4, "Caught levels trigger consequences")
	_assert(fireable.hr_reports.size() >= 1, "HR reports generated")
	_assert(fireable.reviews.size() >= 1, "Reviews generated")
	_assert(career.demotion_risk > 0, "Career demotion risk changes")
	_assert(career.fired_risk > 0, "Career fired risk changes")
	_assert(career.get_career_status().get("career_recap_history", []).size() >= 1, "Career incident history records consequences")
	_assert(event_log.get_events_by_type("shady_choice_processed").size() >= 4, "Shady choices emit EventLog entries")

	var serious = fireable.process_shady_choice("fake_refund", {"force_caught": true, "witnesses": 3, "manager_nearby": 1, "camera_coverage": 25, "risk": "high"})
	_assert(not serious.get("recovery_route", {}).is_empty(), "Getting fired risk creates recovery route")
	_assert(bool(serious.get("recovery_route", {}).get("recoverable", false)), "Firing route is recoverable")
	recovery.complete_step("complete_training")
	_assert(recovery.get_summary().get("completed_steps", []).has("complete_training"), "Recovery step can complete")

	var report = shift_results.complete_shift({"completed": 1})
	var result = shift_results.get_last_result_data()
	var save_data = save_system.get_last_save_data()
	_assert(report.contains("Consequences:"), "Shift report includes consequence section")
	_assert(result.get("fireable_offenses", []).size() >= 5, "Shift result stores fireable choices")
	_assert(result.get("caught_levels", []).size() >= 4, "Shift result stores caught levels")
	_assert(result.get("firing_recovery_routes", []).size() >= 1, "Shift result stores recovery routes")
	_assert(result.get("suspicion_summary", {}).get("player_suspicion", 0) > 0, "Shift result stores suspicion")
	_assert(save_data.get("last_shift", {}).has("fireable_consequence_summary"), "Save includes consequence summary through last shift")
	_assert(bool(serious.get("non_instructional", false)) and bool(serious.get("consequence_heavy", false)), "Shady consequence result is non-instructional and consequence-heavy")

	print("[PASS] Phase 11 runtime fireable/suspicion/consequence check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
