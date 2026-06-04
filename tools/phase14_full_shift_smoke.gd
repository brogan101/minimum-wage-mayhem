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
	_assert(menu != null and menu.visible, "Main menu appears before shift")
	_assert(main.has_method("start_new_game"), "Main exposes new game flow")
	main.start_new_game()
	await process_frame

	var player = root.find_child("Player", true, false)
	var drive_thru = root.find_child("DriveThruStation", true, false)
	var burger = root.find_child("TrainingBurger", true, false)
	var order_manager = root.get_node_or_null("OrderManager")
	var shift_results = root.get_node_or_null("ShiftResultManager")
	var save_system = root.get_node_or_null("SaveSystem")
	var career = root.get_node_or_null("CareerManager")
	var wallet = root.get_node_or_null("WalletManager")
	var event_log = root.get_node_or_null("EventLog")
	var depth = root.find_child("DepthDirector", true, false)

	_assert(player != null, "Player exists for playable shift")
	_assert(drive_thru != null and drive_thru.has_method("interact"), "Drive-thru station has handoff interaction")
	_assert(burger != null, "Training burger exists for fallback order handoff")
	_assert(order_manager != null and shift_results != null and save_system != null and career != null and wallet != null and event_log != null, "Core shift/save/progression autoloads exist")
	_assert(depth != null and depth.has_method("get_depth_summary"), "Phase 13 depth runtime remains wired")

	if order_manager.current_order.is_empty():
		order_manager.generate_new_order()
	var interaction = player.get_node_or_null("InteractionHandler")
	_assert(interaction != null, "Player interaction handler exists")
	interaction.carried_item = burger
	burger.freeze = true
	drive_thru.interact(player)
	await process_frame
	await create_timer(0.3).timeout

	_assert(order_manager.orders_attempted >= 1, "Order handoff attempts an order")
	_assert(order_manager.orders_completed >= 1, "Order handoff can complete successfully")
	_assert(wallet.balance > 0.0 or order_manager.total_earned > 0, "Order handoff pays out or tracks earnings")
	_assert(event_log.get_events_by_type("drive_thru_order_delivered").size() >= 1, "Drive-thru delivery logged")

	var report = shift_results.complete_shift({"completed": order_manager.orders_completed, "cash": wallet.balance})
	var result = shift_results.get_last_result_data()
	var save_data = save_system.get_last_save_data()
	var loaded = save_system.load_game()

	_assert(report.contains("--- SHIFT SUMMARY ---"), "One full shift can complete")
	_assert(report.contains("Global Depth:"), "Full shift recap keeps Phase 13 depth section")
	_assert(result.get("customers_served", 0) >= 1, "Shift result records served customer")
	_assert(result.has("career_status"), "Shift result applies campaign progression")
	_assert(save_data.get("last_shift", {}).get("customers_served", 0) >= 1, "Save contains completed shift")
	_assert(save_data.get("last_shift", {}).has("depth_summary"), "Save preserves depth summary")
	_assert(not loaded.is_empty() and loaded.has("career") and loaded.has("last_shift"), "Save/load roundtrip works")
	_assert(career.get_career_status().get("shift_performance_history", []).size() >= 1, "Progression records shift history")

	print("[PASS] Phase 14 full shift stabilization smoke check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
