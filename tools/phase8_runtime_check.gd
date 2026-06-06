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

	var career = root.get_node_or_null("CareerManager")
	var shift_results = root.get_node_or_null("ShiftResultManager")
	var save_system = root.get_node_or_null("SaveSystem")
	var order_manager = root.get_node_or_null("OrderManager")
	var wallet = root.get_node_or_null("WalletManager")
	var staff = root.find_child("StaffDirector", true, false)
	var store_ops = root.find_child("StoreOpsDirector", true, false)
	var player = root.find_child("Player", true, false)
	var sauce = root.find_child("SauceStockStation", true, false)
	var bagging = root.find_child("BaggingTableStation", true, false)
	var cleaning = root.find_child("CleaningStation", true, false)
	var event_log = root.get_node_or_null("EventLog")

	_assert(career != null, "CareerManager autoload exists")
	_assert(shift_results != null, "ShiftResultManager autoload exists")
	_assert(save_system != null, "SaveSystem autoload exists")
	_assert(order_manager != null, "OrderManager autoload exists")
	_assert(wallet != null, "WalletManager autoload exists")
	_assert(staff != null and store_ops != null, "Gameplay performance directors exist")
	_assert(player != null, "Player spawned")
	_assert(sauce != null and bagging != null and cleaning != null, "3D progression task stations exist")
	_assert(event_log != null, "EventLog autoload exists")

	var start_rank = career.get_current_rank_name()
	_assert(start_rank == "Trainee", "Player starts as low-level Trainee")
	_assert(career.RANKS.size() == 9, "Store Manager rank ladder has Phase 24's 9 ranks")
	_assert(career.RANKS[2].get("name") == "Station Specialist", "Station Specialist rank exists")
	_assert(career.RANKS[8].get("name") == "Store Manager", "Campaign goal rank is Store Manager")

	shift_results.begin_shift_snapshot()
	sauce.interact(player)
	bagging.interact(player)
	cleaning.interact(player)
	order_manager.generate_new_order()
	order_manager.fulfill_order(true)
	var report = shift_results.complete_shift({"cash": wallet.balance, "completed": order_manager.orders_completed})
	var status = career.get_career_status()
	var save_data = save_system.get_last_save_data()

	_assert(report.contains("Unlock Hooks:"), "Shift report includes progression hooks")
	_assert(str(status.get("rank_name", "")) != "Trainee", "Good shift can promote from Trainee")
	_assert(float(status.get("current_xp", 0.0)) > 0.0, "Career XP progresses from gameplay")
	_assert(float(status.get("cash_earned_total", 0.0)) > 0.0, "Career cash progression tracked")
	_assert(float(status.get("tips_earned_total", 0.0)) > 0.0, "Career tips progression tracked")
	_assert(int(status.get("promotion_progress", 0)) > 0, "Promotion progress reacts to shift")
	_assert(int(status.get("manager_trust", 0)) > 0, "Manager trust tracked")
	_assert(int(status.get("staff_morale", 0)) > 0, "Staff morale tracked")
	_assert(int(status.get("corporate_approval", 0)) > 0, "Corporate approval tracked")
	_assert(status.get("promotion_requirements", {}).has("rank"), "Promotion requirements exposed")
	_assert(status.get("shift_performance_history", []).size() >= 1, "Shift performance history recorded")
	_assert(status.get("career_recap_history", []).size() >= 1, "Career recap history recorded")
	_assert(status.get("campaign_milestones", []).size() >= 1, "Campaign milestones recorded")
	_assert(status.has("writeups") and status.has("warnings"), "Warnings and write-ups tracked")
	_assert(status.has("demotion_risk") and status.has("fired_risk"), "Demotion and fired risk tracked")
	_assert(save_data.get("career", {}).has("shift_performance_history"), "Save includes career progress history")

	career.current_rank = 7
	career.current_xp = 1900.0
	career.promotion_progress = 82
	career.manager_trust = 82
	career.corporate_approval = 72
	career.writeups = 0
	career.apply_shift_result({
		"shift_number": 99,
		"money_earned": 25.0,
		"tips": 5,
		"xp_earned": 160,
		"order_accuracy": 1.0,
		"average_patience": 1.0,
		"daily_tasks_completed": 6,
		"daily_tasks_failed": 0,
		"beef_incidents": 0,
		"reviews": ["5 stars: manager material"],
		"writeups": [],
		"staff_morale_change": 5,
		"manager_trust_change": 4,
		"corporate_approval_change": 4,
		"notable_moment": "Ran the floor cleanly",
		"fail_state": "none",
		"unlock_hooks": ["manager_trial_progress"]
	})
	var trial_status = career.get_career_status()
	_assert(bool(trial_status.get("manager_trial_unlocked", false)), "Store manager trial setup unlocks near top of ladder")
	_assert(str(trial_status.get("rank_name", "")) == "Acting Store Manager", "Store Manager rank waits for trial pass")
	_assert(trial_status.get("last_career_reasons", []).size() >= 1, "Career progression reasons are visible")
	_assert(not trial_status.get("manager_trial_setup", {}).is_empty(), "Manager trial setup data exists")
	_assert(trial_status.get("future_expansion_hooks", {}).has("district_manager_path"), "Future district hook exists without implementation")
	_assert(event_log.get_events_by_type("career_shift_applied").size() >= 2, "Career shift applications logged")
	_assert(event_log.get_events_by_type("career_rank_up").size() >= 1, "Career promotion logged")

	save_system.save_game({"last_shift": shift_results.get_last_result_data(), "next_shift": shift_results.get_next_shift_setup(), "progression": {"career": career.get_career_save_data()}})
	var persisted = save_system.get_last_save_data()
	_assert(persisted.get("career", {}).get("manager_trial_unlocked", false), "Save persists manager trial readiness")
	_assert(not persisted.get("career", {}).get("manager_trial_passed", true), "Save preserves pending trial state")

	print("[PASS] Phase 8 runtime career campaign progression check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
