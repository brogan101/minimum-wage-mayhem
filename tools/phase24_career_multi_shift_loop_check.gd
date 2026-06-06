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

	var save_system = root.get_node_or_null("SaveSystem")
	var wallet = root.get_node_or_null("WalletManager")
	var career = root.get_node_or_null("CareerManager")
	var corporate = root.get_node_or_null("CorporateManager")
	var order_manager = root.get_node_or_null("OrderManager")
	var shift_results = root.get_node_or_null("ShiftResultManager")
	var event_log = root.get_node_or_null("EventLog")
	var hud = root.find_child("GameHUD", true, false)
	var dressing = root.find_child("Phase17DemoDressing", true, false)

	_assert(save_system != null and wallet != null and career != null and corporate != null, "Core save/career autoloads exist")
	_assert(order_manager != null and shift_results != null and event_log != null, "Order, result, and event systems exist")
	_assert(hud != null and dressing != null, "HUD and runtime restaurant dressing exist")
	_assert(career.RANKS.size() == 9, "Phase 24 rank ladder matches requested path")
	_assert(career.RANKS[2].get("name") == "Station Specialist", "Station Specialist replaces old split specialist ranks")
	_assert(career.RANKS[8].get("name") == "Store Manager", "Store Manager remains the campaign goal")
	_assert(dressing.get_node_or_null("Phase24CareerPathBoard") != null, "Career path board is visible in the restaurant")
	_assert(dressing.get_node_or_null("Phase24BagFoldFront") != null, "Life-like cartoon bag crease detail exists")
	_assert(dressing.get_node_or_null("Phase24BurgerSesame0") != null, "Life-like cartoon food texture detail exists")

	_reset_runtime_state(wallet, career, corporate, order_manager, event_log, shift_results)
	main.start_new_game()
	await process_frame
	await create_timer(2.4, true).timeout
	await _complete_service_loop("Regular")
	await _complete_station_rewards()
	var report_1 = shift_results.complete_shift({"completed": order_manager.orders_completed, "cash": wallet.balance})
	if main.current_shift_manager:
		main.current_shift_manager.set("is_active", false)
	var save_1 = save_system.get_last_save_data()
	var career_1: Dictionary = save_1.get("career", {})
	var next_1: Dictionary = save_1.get("next_shift", {})
	_assert(report_1.contains("Career Path:"), "Shift 1 recap shows career path")
	_assert(report_1.contains("Why It Changed:"), "Shift 1 recap explains career changes")
	_assert(report_1.contains("Recovery Focus:"), "Shift 1 recap shows recovery or focus route")
	_assert(career_1.get("last_career_reasons", []).size() >= 2, "Shift 1 career reasons are visible")
	_assert(float(career_1.get("cash_earned_total", 0.0)) > 0.0, "Cash progression changes after shift 1")
	_assert(float(career_1.get("tips_earned_total", 0.0)) > 0.0, "Tips progression changes after shift 1")
	_assert(float(career_1.get("current_xp", 0.0)) > 0.0, "XP progression changes after shift 1")
	_assert(int(career_1.get("promotion_progress", 0)) > 0, "Promotion progress changes after shift 1")
	_assert(career_1.has("manager_trust") and career_1.has("staff_morale") and career_1.has("corporate_approval"), "Trust, morale, and corporate fields are saved")
	_assert(next_1.has("career_recovery_focus"), "Next shift setup carries career focus")
	_assert(next_1.get("pre_shift_modifier", {}).has("label"), "Next shift setup carries pre-shift modifier")

	_clear_live_continuity(wallet, career, corporate, order_manager, event_log)
	var loaded_1 = save_system.load_game()
	_assert(not loaded_1.is_empty(), "Load after shift 1 returns save data")
	_assert(career.get_career_status().get("last_career_reasons", []).size() >= 2, "Career reasons persist after shift 1 reload")
	_assert(career.get_career_status().get("pre_shift_modifier_history", []).size() >= 1, "Pre-shift modifier history persists after shift 1 reload")

	main.start_new_shift()
	await process_frame
	await create_timer(2.4, true).timeout
	await _complete_service_loop("Lunch Driver", true)
	await _complete_station_rewards()
	var report_2 = shift_results.complete_shift({"completed": order_manager.orders_completed, "cash": wallet.balance})
	var save_2 = save_system.get_last_save_data()
	var career_2: Dictionary = save_2.get("career", {})
	_assert(report_2.contains("Career Gains:"), "Shift 2 recap shows money, tips, XP, and promotion gains")
	_assert(save_2.get("last_shift", {}).get("shift_number", 0) >= 2, "Shift 2 completes and saves")
	_assert(career_2.get("shift_performance_history", []).size() >= 2, "Two-shift career history persists in save")
	_assert(career_2.get("career_recap_history", []).size() >= 2, "Career recap history persists in save")
	_assert(career_2.get("pre_shift_modifier_history", []).size() >= 2, "Multi-shift pre-shift setup persists")
	_assert(float(career_2.get("current_xp", 0.0)) > float(career_1.get("current_xp", 0.0)), "XP increases between shifts")
	_assert(float(career_2.get("cash_earned_total", 0.0)) >= float(career_1.get("cash_earned_total", 0.0)), "Cash total carries between shifts")
	_assert(career_2.get("last_career_delta", {}).has("promotion_progress"), "Saved career delta explains latest shift")
	_assert(save_2.get("next_shift", {}).get("shift_number", 0) >= 3, "Next shift setup advances after shift 2")

	_clear_live_continuity(wallet, career, corporate, order_manager, event_log)
	var loaded_2 = save_system.load_game()
	_assert(not loaded_2.is_empty(), "Load after shift 2 returns save data")
	_assert(career.get_career_status().get("shift_performance_history", []).size() >= 2, "Two-shift career history persists after reload")
	_assert(career.get_career_status().get("recovery_plan", {}).has("focus"), "Recovery plan persists after reload")
	_assert(wallet.balance == save_2.get("wallet", -1), "Wallet persists after second reload")

	print("[PASS] Phase 24 career multi-shift loop check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _complete_service_loop(customer_type: String, include_fries: bool = false) -> void:
	var player = root.find_child("Player", true, false)
	var interaction = player.get_node_or_null("InteractionHandler") if player else null
	var bagging = root.find_child("BaggingTableStation", true, false)
	var grill = root.find_child("GrillStation", true, false)
	var fryer = root.find_child("FryerCheckStation", true, false)
	var drive_thru = root.find_child("DriveThruStation", true, false)
	var order_manager = root.get_node_or_null("OrderManager")
	_assert(player != null and interaction != null, "Player interaction exists for service loop")
	_assert(bagging != null and grill != null and drive_thru != null, "Bagging, grill, and drive-thru stations exist")
	order_manager.generate_new_order(customer_type)
	await process_frame
	bagging.interact(player)
	await process_frame
	var bag = interaction.get("carried_item")
	_assert(bag != null and bag.has_method("add_item"), "Player carries an order bag")
	grill.interact(player)
	await process_frame
	if include_fries:
		_assert(fryer != null, "Fryer station exists for combo order")
		fryer.interact(player)
		await process_frame
	drive_thru.interact(player)
	await process_frame
	await create_timer(0.3, true).timeout
	_assert(interaction.get("carried_item") == null, "Correct order handoff clears the bag")

func _complete_station_rewards() -> void:
	var player = root.find_child("Player", true, false)
	for station_name in ["SauceStockStation", "CleaningStation", "RegisterCheckStation"]:
		var station = root.find_child(station_name, true, false)
		if station and station.has_method("interact"):
			station.interact(player)
			await process_frame

func _reset_runtime_state(wallet: Node, career: Node, corporate: Node, order_manager: Node, event_log: Node, shift_results: Node) -> void:
	wallet.balance = 0.0
	career.load_career_save_data({})
	corporate.approval_rating = 50
	_reset_orders(order_manager)
	event_log.clear_log()
	shift_results.shift_number = 0

func _clear_live_continuity(wallet: Node, career: Node, corporate: Node, order_manager: Node, event_log: Node) -> void:
	wallet.balance = -99.0
	career.load_career_save_data({})
	corporate.approval_rating = 0
	_reset_orders(order_manager)
	event_log.clear_log()

func _reset_orders(order_manager: Node) -> void:
	order_manager.current_order = {}
	order_manager.total_earned = 0
	order_manager.tips_earned = 0
	order_manager.orders_completed = 0
	order_manager.orders_attempted = 0
	order_manager.orders_failed = 0
	order_manager.mistake_count = 0
	order_manager.total_wait_seconds = 0.0
	order_manager.total_patience_score = 0.0
	order_manager.ticket_counter = 0
	order_manager.last_validation = {}
	order_manager.last_payout = {}

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
