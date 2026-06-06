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

	var menu = root.find_child("MainMenuUI", true, false)
	var hud = root.find_child("GameHUD", true, false)
	var save_system = root.get_node_or_null("SaveSystem")
	var shift_results = root.get_node_or_null("ShiftResultManager")
	var order_manager = root.get_node_or_null("OrderManager")
	var career = root.get_node_or_null("CareerManager")
	var wallet = root.get_node_or_null("WalletManager")
	_assert(menu != null and hud != null, "Menu and HUD exist")
	_assert(save_system != null and shift_results != null and order_manager != null, "Save, shift, and order managers exist")
	_assert(menu.find_child("BodyScroll", true, false) != null, "Shift recap body is scrollable")

	var long_report = "--- SHIFT SUMMARY ---\nCustomers Served: 1\n"
	for i in range(180):
		long_report += "Career detail stays visible.\n"
	menu.show_results(long_report)
	await process_frame
	_assert(menu.body_label.text.length() == long_report.length(), "Shift recap no longer truncates long reports")

	_reset_runtime_state(wallet, career, order_manager, shift_results)
	main.start_new_game()
	await process_frame
	await create_timer(2.4, true).timeout
	await _complete_service_loop()
	shift_results.complete_shift({"completed": order_manager.orders_completed, "cash": wallet.balance})
	var completed_save = save_system.get_last_save_data()
	_assert(completed_save.get("last_shift", {}).get("customers_served", 0) >= 1, "Completed shift save records served customer")
	_assert(completed_save.get("next_shift", {}).get("shift_number", 0) >= 2, "Completed shift save records next shift")

	save_system.save_game({})
	var menu_save = save_system.get_last_save_data()
	_assert(menu_save.get("last_shift", {}).get("customers_served", 0) >= 1, "Menu save preserves completed last shift")
	_assert(menu_save.get("next_shift", {}).get("shift_number", 0) >= 2, "Menu save preserves next-shift setup")
	_assert(menu_save.get("career", {}).has("shift_performance_history"), "Menu save keeps career continuity")

	print("[PASS] Phase 25 full build audit smoke check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _complete_service_loop() -> void:
	var player = root.find_child("Player", true, false)
	var interaction = player.get_node_or_null("InteractionHandler") if player else null
	var bagging = root.find_child("BaggingTableStation", true, false)
	var grill = root.find_child("GrillStation", true, false)
	var drive_thru = root.find_child("DriveThruStation", true, false)
	_assert(player != null and interaction != null, "Player interaction exists")
	_assert(bagging != null and grill != null and drive_thru != null, "Core service stations exist")
	bagging.interact(player)
	await process_frame
	_assert(interaction.get("carried_item") != null, "Player can pick up an order bag")
	grill.interact(player)
	await process_frame
	drive_thru.interact(player)
	await process_frame
	await create_timer(0.3, true).timeout
	_assert(interaction.get("carried_item") == null, "Order handoff clears the bag")

func _reset_runtime_state(wallet: Node, career: Node, order_manager: Node, shift_results: Node) -> void:
	if wallet:
		wallet.balance = 0.0
	if career and career.has_method("load_career_save_data"):
		career.load_career_save_data({})
	if shift_results:
		shift_results.shift_number = 0
	if order_manager:
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
