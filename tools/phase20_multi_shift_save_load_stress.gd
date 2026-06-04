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
	var event_log = root.get_node_or_null("EventLog")
	var shift_results = root.get_node_or_null("ShiftResultManager")
	var restaurant_memory = root.find_child("RestaurantMemoryManager", true, false)
	var object_memory = root.find_child("StoreObjectMemoryManager", true, false)
	var dynamic_reputation = root.find_child("DynamicReputationLabelManager", true, false)

	_assert(save_system != null and wallet != null and career != null and corporate != null, "Core save/progression autoloads exist")
	_assert(event_log != null and shift_results != null, "Event log and shift result systems exist")
	_assert(restaurant_memory != null and object_memory != null and dynamic_reputation != null, "Memory/reputation runtime systems are wired")

	_reset_runtime_state(wallet, career, corporate, event_log, shift_results)
	main.start_new_game()
	await process_frame
	await create_timer(2.2).timeout
	_inject_memory("shift_1", restaurant_memory, object_memory, dynamic_reputation)
	_complete_order(main)
	await process_frame
	shift_results.complete_shift({"completed": root.get_node_or_null("OrderManager").orders_completed, "cash": wallet.balance})
	if main.current_shift_manager:
		main.current_shift_manager.set("is_active", false)
	var shift_1_save = save_system.get_last_save_data()
	_assert(shift_1_save.get("last_shift", {}).get("customers_served", 0) >= 1, "Shift 1 completes and saves a served customer")
	_assert(shift_1_save.get("career", {}).get("shift_performance_history", []).size() == 1, "Shift 1 save records career history")
	_assert(shift_1_save.get("restaurant_memory", {}).get("active_flags", []).has("phase20_shift_1_rumor"), "Shift 1 save includes restaurant memory flag")
	_assert(shift_1_save.get("store_object_memory", {}).get("object_memory", {}).has("drive_thru_window"), "Shift 1 save includes object memory")
	_assert(shift_1_save.get("dynamic_reputation", {}).get("active_labels", []).size() >= 1, "Shift 1 save includes dynamic reputation labels")

	_clear_live_continuity(wallet, career, corporate, event_log, restaurant_memory, object_memory, dynamic_reputation)
	var loaded_1 = save_system.load_game()
	_assert(not loaded_1.is_empty(), "Load after shift 1 returns save data")
	_assert(wallet.balance == shift_1_save.get("wallet", -1), "Wallet persists after shift 1 reload")
	_assert(career.get_career_status().get("shift_performance_history", []).size() == 1, "Career history persists after shift 1 reload")
	_assert(corporate.get_approval_rating() == int(shift_1_save.get("corporate_approval", -1)), "Corporate approval persists after shift 1 reload")
	_assert(restaurant_memory.get_summary().get("active_flags", []).has("phase20_shift_1_rumor"), "Restaurant memory persists after shift 1 reload")
	_assert(dynamic_reputation.get_summary().get("active_labels", []).size() >= 1, "Dynamic reputation persists after shift 1 reload")

	main.start_new_shift()
	await process_frame
	await create_timer(2.2).timeout
	_inject_memory("shift_2", restaurant_memory, object_memory, dynamic_reputation)
	_complete_order(main)
	await process_frame
	shift_results.complete_shift({"completed": root.get_node_or_null("OrderManager").orders_completed, "cash": wallet.balance})
	var shift_2_save = save_system.get_last_save_data()
	var career_save = shift_2_save.get("career", {})
	_assert(shift_2_save.get("last_shift", {}).get("shift_number", 0) >= 2, "Shift 2 completes and saves")
	_assert(career_save.get("shift_performance_history", []).size() >= 2, "Two-shift career history persists in save")
	_assert(float(career_save.get("current_xp", 0.0)) > 0.0, "XP/progression persists in save")
	_assert(int(career_save.get("promotion_progress", 0)) > 0, "Promotion progress persists in save")
	_assert(career_save.has("manager_trust") and career_save.has("staff_morale") and career_save.has("corporate_approval"), "Trust/morale/corporate career fields persist in save")
	_assert(shift_2_save.get("last_shift", {}).has("reviews") and shift_2_save.get("last_shift", {}).has("writeups"), "Reviews/writeups are preserved in last shift")
	_assert(shift_2_save.get("last_shift", {}).has("daily_task_entries"), "Daily task recap is preserved in last shift")
	_assert(shift_2_save.get("event_log", {}).get("logs", []).size() > shift_1_save.get("event_log", {}).get("logs", []).size(), "EventLog history carries into shift 2 save")
	_assert(shift_2_save.get("next_shift", {}).get("shift_number", 0) >= 3, "Next shift setup advances after shift 2")

	_clear_live_continuity(wallet, career, corporate, event_log, restaurant_memory, object_memory, dynamic_reputation)
	var loaded_2 = save_system.load_game()
	_assert(not loaded_2.is_empty(), "Load after shift 2 returns save data")
	_assert(wallet.balance == shift_2_save.get("wallet", -1), "Wallet persists after shift 2 reload")
	_assert(career.get_career_status().get("shift_performance_history", []).size() >= 2, "Two-shift career history survives final reload")
	_assert(restaurant_memory.get_summary().get("active_flags", []).has("phase20_shift_2_rumor"), "Shift 2 restaurant memory survives final reload")
	_assert(object_memory.get_summary().get("object_memory", {}).get("drive_thru_window", {}).get("incident_count", 0) >= 2, "Object memory incident count survives final reload")
	_assert(dynamic_reputation.get_summary().get("evaluation_history", []).size() >= 2, "Reputation evaluation history survives final reload")

	FileAccess.open("user://savegame.json", FileAccess.WRITE).store_string("{not valid json")
	var corrupt_load = save_system.load_game()
	_assert(corrupt_load.is_empty(), "Corrupt save falls back safely")
	save_system.save_game({
		"last_shift": shift_2_save.get("last_shift", {}),
		"next_shift": shift_2_save.get("next_shift", {}),
		"progression": shift_2_save.get("progression", {})
	})

	print("[PASS] Phase 20 two-shift save/load progression stress check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _complete_order(main: Node) -> void:
	var player = root.find_child("Player", true, false)
	var drive_thru = root.find_child("DriveThruStation", true, false)
	var burger = root.find_child("TrainingBurger", true, false)
	var order_manager = root.get_node_or_null("OrderManager")
	_assert(player != null and drive_thru != null and order_manager != null, "Order handoff actors exist")
	if order_manager.current_order.is_empty():
		order_manager.generate_new_order()
	var interaction = player.get_node_or_null("InteractionHandler")
	_assert(interaction != null, "Player interaction handler exists")
	if not burger or not burger.is_inside_tree():
		burger = _make_training_burger(main)
	_assert(burger != null, "Training burger available for handoff")
	interaction.carried_item = burger
	burger.freeze = true
	drive_thru.interact(player)

func _make_training_burger(main: Node) -> RigidBody3D:
	var pickup_script = load("res://scripts/items/PickupItem.gd")
	var burger = RigidBody3D.new()
	burger.name = "TrainingBurgerPhase20"
	burger.set_script(pickup_script)
	burger.set("item_name", "Training Burger")
	main.add_child(burger)
	return burger

func _inject_memory(label: String, restaurant_memory: Node, object_memory: Node, dynamic_reputation: Node) -> void:
	var event = {
		"event_id": "phase20_" + label,
		"shift_index": 1 if label == "shift_1" else 2,
		"tags": ["phase20", "save_load"],
		"resolved": false
	}
	restaurant_memory.record_event(event, "career")
	restaurant_memory.add_flag("phase20_" + label + "_rumor")
	object_memory.record_object_incident("drive_thru_window", event)
	dynamic_reputation.evaluate({"promotion_high": true, "suspicion_high": true})

func _reset_runtime_state(wallet: Node, career: Node, corporate: Node, event_log: Node, shift_results: Node) -> void:
	wallet.balance = 0.0
	career.load_career_save_data({})
	corporate.approval_rating = 50
	event_log.clear_log()
	shift_results.shift_number = 0

func _clear_live_continuity(wallet: Node, career: Node, corporate: Node, event_log: Node, restaurant_memory: Node, object_memory: Node, dynamic_reputation: Node) -> void:
	wallet.balance = -99.0
	career.load_career_save_data({})
	corporate.approval_rating = 0
	event_log.clear_log()
	restaurant_memory.load_save_data({})
	object_memory.load_save_data({"object_memory": {}, "object_targets": []})
	dynamic_reputation.load_save_data({})

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
