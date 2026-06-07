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

	main.start_new_game()
	await process_frame
	await create_timer(2.4, true).timeout

	var order_manager = root.get_node_or_null("OrderManager")
	var daily = root.find_child("DailyTaskManager", true, false)
	var staff = root.find_child("StaffDirector", true, false)
	var shift_results = root.get_node_or_null("ShiftResultManager")
	var save_system = root.get_node_or_null("SaveSystem")
	var event_log = root.get_node_or_null("EventLog")
	var wallet = root.get_node_or_null("WalletManager")
	var hud = root.find_child("GameHUD", true, false)
	_assert(order_manager != null and daily != null and shift_results != null, "Core Phase 26 managers exist")
	_assert(save_system != null and event_log != null and wallet != null, "Save, event, and reward systems exist")
	_assert(order_manager.ORDER_TEMPLATES.size() >= 7, "Order template variety expanded")
	_assert(hud != null and hud.order_title_label.text.contains("TICKET #"), "Readable ticket HUD remains active")

	var first_tasks = _task_titles(daily.get_task_status())
	daily.refresh_for_shift(2)
	var rotated_tasks = _task_titles(daily.get_task_status())
	_assert(first_tasks != rotated_tasks, "Daily task board rotates after first shift")
	_assert(_has_task_id(daily.get_task_status(), "serve_combo_order"), "Rotated tasks include combo objective")
	_assert(_has_task_id(daily.get_task_status(), "upsell_soda_calmly"), "Rotated tasks include soda objective")

	order_manager.generate_new_order("Coupon Skeptic")
	await process_frame
	_assert(order_manager.current_order.get("customer_type", "") == "Coupon Skeptic", "Coupon Skeptic order can be requested")
	_assert(order_manager.current_order.has("customer_moment"), "Customer moment data is attached to order")
	_assert(hud.order_title_label.text.contains("COUPON SKEPTIC"), "HUD names varied customer")
	await _complete_current_order(["Burger", "Fries"])

	order_manager.generate_new_order("Night Nurse")
	await process_frame
	_assert(order_manager.current_order.get("customer_type", "") == "Night Nurse", "Night Nurse order can be requested")
	_assert(hud.customer_status_label.text.contains("Patience"), "HUD keeps patience visible for varied order")
	var wallet_before_nurse = float(wallet.balance)
	await _complete_current_order(["Burger", "Soda"])
	_assert(float(wallet.balance) > wallet_before_nurse, "Varied order pays reward and moment tip")

	if staff and staff.has_method("dialogue_for"):
		staff.dialogue_for("morgan", "rush")
	var completed_tasks = _completed_count(daily.get_task_status())
	_assert(completed_tasks >= 3, "Varied orders and coworker moment complete real tasks")
	_assert(event_log.get_events_by_type("customer_moment").size() >= 2, "Customer moments are logged")

	var report = shift_results.complete_shift({"completed": order_manager.orders_completed, "cash": wallet.balance})
	var result = shift_results.get_last_result_data()
	var variety: Dictionary = result.get("order_variety_summary", {})
	_assert(report.contains("Order Variety:"), "Recap includes order variety")
	_assert(report.contains("Customer Moments:"), "Recap includes customer moments")
	_assert(variety.get("customer_types", []).size() >= 2, "Result records multiple customer types")
	_assert(result.get("customer_moment_entries", []).size() >= 2, "Result stores customer moment entries")
	_assert(result.get("daily_tasks_completed", 0) >= 3, "Result reflects optional task progress")
	_assert(_restaurant_story_event_count() == 180, "Restaurant story event count remains 180")

	var save_data = save_system.get_last_save_data()
	var loaded = save_system.load_game()
	_assert(save_data.get("last_shift", {}).get("customer_moment_entries", []).size() >= 2, "Save stores customer moments through last shift")
	_assert(not loaded.is_empty() and loaded.get("last_shift", {}).get("order_variety_summary", {}).get("customer_types", []).size() >= 2, "Save/load preserves order variety")

	print("[PASS] Phase 26 fun content shift variety check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _complete_current_order(items: Array[String]) -> void:
	var player = root.find_child("Player", true, false)
	var interaction = player.get_node_or_null("InteractionHandler") if player else null
	var bagging = root.find_child("BaggingTableStation", true, false)
	var grill = root.find_child("GrillStation", true, false)
	var fryer = root.find_child("FryerCheckStation", true, false)
	var drink = root.find_child("DrinkFillStation", true, false)
	var drive_thru = root.find_child("DriveThruStation", true, false)
	_assert(player != null and interaction != null, "Player interaction exists for varied order")
	_assert(bagging != null and grill != null and fryer != null and drink != null and drive_thru != null, "Prep stations exist for varied order")
	bagging.interact(player)
	await process_frame
	var bag = interaction.get("carried_item")
	_assert(bag != null and bag.has_method("add_item"), "Player carries bag for varied order")
	if items.has("Burger"):
		grill.interact(player)
		await process_frame
	if items.has("Fries"):
		fryer.interact(player)
		await process_frame
	if items.has("Soda"):
		drink.interact(player)
		await process_frame
	drive_thru.interact(player)
	await process_frame
	await create_timer(0.3, true).timeout
	_assert(interaction.get("carried_item") == null, "Varied order handoff clears bag")

func _task_titles(tasks: Array) -> Array[String]:
	var titles: Array[String] = []
	for task in tasks:
		titles.append(str(task.get("title", "")))
	return titles

func _has_task_id(tasks: Array, task_id: String) -> bool:
	for task in tasks:
		if str(task.get("id", "")) == task_id:
			return true
	return false

func _completed_count(tasks: Array) -> int:
	var count = 0
	for task in tasks:
		if bool(task.get("completed", false)):
			count += 1
	return count

func _restaurant_story_event_count() -> int:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/mischief/restaurant_story_events.json"))
	if typeof(parsed) != TYPE_DICTIONARY:
		return -1
	return parsed.get("events", []).size()

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
