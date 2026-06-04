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

	var daily = root.find_child("DailyTaskManager", true, false)
	var store_ops = root.find_child("StoreOpsDirector", true, false)
	var sauce = root.find_child("SauceStockStation", true, false)
	var bagging = root.find_child("BaggingTableStation", true, false)
	var register_check = root.find_child("RegisterCheckStation", true, false)
	var cleaning = root.find_child("CleaningStation", true, false)
	var recovery = root.find_child("RecoveryStation", true, false)
	var staff = root.find_child("StaffDirector", true, false)
	var player = root.find_child("Player", true, false)
	var hud = root.find_child("GameHUD", true, false)
	var wallet = root.get_node_or_null("WalletManager")
	var career = root.get_node_or_null("CareerManager")
	var event_log = root.get_node_or_null("EventLog")

	_assert(daily != null, "DailyTaskManager exists in main scene")
	_assert(store_ops != null, "StoreOpsDirector exists")
	_assert(staff != null, "StaffDirector exists")
	_assert(player != null, "Player spawned")
	_assert(hud != null and hud.has_method("set_daily_tasks"), "HUD daily task hook exists")
	_assert(wallet != null, "WalletManager autoload exists")
	_assert(career != null, "CareerManager autoload exists")
	_assert(event_log != null, "EventLog autoload exists")
	_assert(sauce != null and bagging != null and register_check != null and cleaning != null and recovery != null, "Daily task stations exist in 3D")

	var tasks: Array = daily.get_task_status()
	_assert(tasks.size() >= 5, "Daily tasks generated for shift")
	_assert(_has_category(tasks, "normal_work"), "Normal work task generated")
	_assert(_has_category(tasks, "customer_service"), "Customer service task generated")
	_assert(_has_category(tasks, "station"), "Station task generated")
	_assert(_has_category(tasks, "manager_request"), "Manager-requested task generated")
	_assert(_has_category(tasks, "recovery"), "Recovery task generated")
	_assert(_has_category(tasks, "small_funny"), "Small funny task generated")

	var starting_cash = float(wallet.balance)
	var starting_xp = float(career.current_xp)
	sauce.interact(player)
	bagging.interact(player)
	register_check.interact(player)
	cleaning.interact(player)
	store_ops.trigger_minor_issue("fryer_timer_drift")
	recovery.interact(player)
	daily.record_progress("customer_served", "order_fulfilled")
	staff.dialogue_for("riley", "rush")

	var after_tasks: Array = daily.get_task_status()
	_assert(_completed_count(after_tasks) >= 6, "Station, customer, and funny tasks complete without blocking shift")
	_assert(float(wallet.balance) > starting_cash, "Daily tasks reward cash or tips")
	_assert(float(career.current_xp) > starting_xp, "Daily tasks reward XP")
	_assert(int(daily.get_reward_totals().get("promotion_progress", 0)) >= 1, "Daily tasks add progression hook")
	_assert(event_log.get_events_by_type("daily_task_completed").size() >= 5, "Daily task completion logged")

	var before_finalize = daily.get_recap_entries().size()
	daily.finish_shift()
	_assert(daily.get_recap_entries().size() >= before_finalize, "Daily task recap entries available")
	_assert(event_log.get_events_by_type("daily_tasks_finalized").size() >= 1, "Daily task finalization logged")

	print("[PASS] Phase 6 runtime daily tasks check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _has_category(tasks: Array, category: String) -> bool:
	for task in tasks:
		if str(task.get("category", "")) == category:
			return true
	return false

func _completed_count(tasks: Array) -> int:
	var count = 0
	for task in tasks:
		if bool(task.get("completed", false)):
			count += 1
	return count

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
