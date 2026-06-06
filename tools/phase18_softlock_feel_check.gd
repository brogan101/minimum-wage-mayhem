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
	_assert(menu != null and menu.visible and menu.mode == "main", "New player starts at main menu")
	_assert(hud != null and not hud.visible, "HUD stays hidden before shift")

	main.start_new_game()
	await process_frame
	await create_timer(2.4).timeout

	var player = root.find_child("Player", true, false)
	var interaction = player.get_node_or_null("InteractionHandler") if player else null
	var controller = player if player and player is CharacterBody3D else null
	var drive_thru = root.find_child("DriveThruStation", true, false)
	var burger = root.find_child("TrainingBurger", true, false)
	var clock_out = root.find_child("ClockOutStation", true, false)
	var order_manager = root.get_node_or_null("OrderManager")
	var shift_manager = main.current_shift_manager
	var save_system = root.get_node_or_null("SaveSystem")
	var event_log = root.get_node_or_null("EventLog")

	_assert(player != null, "Player spawns in the 3D restaurant")
	var spawn_is_readable = abs(player.global_position.x) < 0.35 and player.global_position.z < -4.8 and player.global_position.y > 0.5
	_assert(spawn_is_readable, "Player spawn is stable and predictable")
	_assert(controller != null and float(controller.get("walk_speed")) <= 4.2, "Walk speed is tuned for first-time control")
	_assert(controller != null and float(controller.get("sprint_speed")) <= 6.5, "Sprint speed is restrained for the demo layout")
	_assert(controller != null and float(controller.get("mouse_sensitivity")) >= 0.0022, "Mouse look is responsive for first shift")
	_assert(controller != null and float(controller.get("controller_look_sensitivity")) >= 2.7, "Controller look default is responsive")
	_assert(interaction != null and float(interaction.get("interaction_range")) >= 3.0, "Interaction range is forgiving")
	_assert(shift_manager != null and bool(shift_manager.get("is_active")), "Shift starts from New Game")
	_assert(float(shift_manager.get("time_remaining")) > 300.0, "Shift timer gives a first-time player breathing room")
	_assert(hud.objective_label.text.contains("DRIVE-THRU") and hud.objective_label.text.contains("Clock Out"), "Objective names delivery and clock-out")
	_assert(hud.guidance_label.text.contains("floor arrows") and hud.guidance_label.text.contains("clock-out"), "First-shift guidance is understandable without docs")
	_assert(hud.daily_tasks_label.text.contains("Daily Tasks"), "Task list is visible during the shift")
	_assert(order_manager != null and not order_manager.current_order.is_empty(), "Customer/order flow creates an active order")
	_assert(order_manager.get_current_order_summary().contains("Burger"), "Active order has a known fallback item")

	interaction.carried_item = burger
	burger.freeze = true
	drive_thru.interact(player)
	await process_frame
	await create_timer(0.3).timeout

	_assert(order_manager.orders_attempted >= 1, "Drive-thru handoff attempts the current order")
	_assert(order_manager.orders_completed >= 1, "Drive-thru handoff can complete successfully")
	_assert(event_log.get_events_by_type("drive_thru_order_delivered").size() >= 1, "Successful handoff is logged")

	var customer_car = root.find_child("CustomerCar", true, false)
	if customer_car:
		_assert(not bool(customer_car.get("waiting_for_order")), "Customer car is not stuck waiting forever after fulfillment")
	else:
		_assert(true, "Fallback customer path has no stuck customer node")

	player.global_position = Vector3(0, -12, 4)
	await physics_frame
	await process_frame
	_assert(player.global_position.y > 0.5, "Out-of-bounds fall resets player to spawn")

	main.pause_game()
	await process_frame
	_assert(menu.visible and menu.mode == "pause" and paused, "Pause menu opens and pauses")
	main.resume_game()
	await process_frame
	_assert(not menu.visible and not paused, "Pause menu returns to gameplay")

	clock_out.interact(player)
	await process_frame
	_assert(menu.visible and menu.mode == "results", "Physical clock-out ends shift and opens recap")
	var save_data = save_system.get_last_save_data()
	var loaded = save_system.load_game()
	_assert(save_data.get("last_shift", {}).get("customers_served", 0) >= 1, "End shift saves completed customer result")
	_assert(not loaded.is_empty() and loaded.has("last_shift") and loaded.has("career"), "Local save/load roundtrip remains valid")
	_assert(not bool(shift_manager.get("is_active")), "End-shift flow leaves no active-shift softlock")

	main.return_to_main_menu()
	await process_frame
	_assert(menu.visible and menu.mode == "main" and not hud.visible, "Return-to-menu works after results")

	_assert(InputMap.action_get_events("interact").size() > 0, "Keyboard interact input is mapped")
	_assert(InputMap.action_get_events("move_forward").size() > 0 and InputMap.action_get_events("move_back").size() > 0, "Keyboard movement inputs are mapped")
	_assert(InputMap.action_get_events("pause").size() > 0, "Pause input is mapped")
	if Input.get_connected_joypads().is_empty():
		print("[WARN] No physical controller detected; controller InputMap only was checked")
	else:
		print("[PASS] Physical controller detected: " + str(Input.get_connected_joypads()))
	_assert(_action_has_joy_event("interact") and _action_has_joy_event("move_forward") and _action_has_joy_event("pause"), "Controller-compatible InputMap events exist")

	print("[PASS] Phase 18 softlock/feel smoke check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _action_has_joy_event(action_name: String) -> bool:
	for event in InputMap.action_get_events(action_name):
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			return true
	return false

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
