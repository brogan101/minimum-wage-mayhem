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

	var hud = root.find_child("GameHUD", true, false)
	var dressing = root.find_child("Phase17DemoDressing", true, false)
	_assert(hud != null, "HUD exists")
	_assert(dressing != null, "Demo dressing exists")

	for prop_name in [
		"PrepFlowArrowTicket",
		"PrepFlowArrowWindow",
		"BaggingPaperBags",
		"FriesReadyBin",
		"SodaCupStack",
		"PrepFlowLabel",
		"SodaAffordanceLabel",
		"FriesAffordanceLabel",
	]:
		_assert(dressing.get_node_or_null(prop_name) != null, "Prep affordance exists: " + prop_name)

	main.start_new_game()
	await process_frame
	await create_timer(2.4).timeout

	_assert(hud.guidance_label.text.contains("bags") and hud.guidance_label.text.contains("soda") and hud.guidance_label.text.contains("fries"), "HUD guidance names prep affordances")
	_assert(hud.objective_label.text.contains("DRIVE-THRU"), "HUD objective still names handoff target")
	_assert(hud.interaction_prompt_label.size.x >= 500.0, "Interaction prompt has stable width")
	_assert(hud.daily_tasks_label.size.y >= 292.0, "Task list has stable height")

	for viewport_size in [Vector2i(1280, 720), Vector2i(1366, 768), Vector2i(1920, 1080)]:
		root.size = viewport_size
		await process_frame
		_assert(_label_inside_viewport(hud.objective_label, viewport_size), "Objective fits viewport " + str(viewport_size))
		_assert(_label_inside_viewport(hud.interaction_prompt_label, viewport_size), "Prompt fits viewport " + str(viewport_size))
		_assert(_label_inside_viewport(hud.daily_tasks_label, viewport_size), "Task list fits viewport " + str(viewport_size))

	var player = root.find_child("Player", true, false)
	var interaction = player.get_node_or_null("InteractionHandler") if player else null
	var drive_thru = root.find_child("DriveThruStation", true, false)
	var burger = root.find_child("TrainingBurger", true, false)
	var order_manager = root.get_node_or_null("OrderManager")
	_assert(player != null and interaction != null and drive_thru != null and burger != null, "First-shift handoff actors exist")
	if order_manager.current_order.is_empty():
		order_manager.generate_new_order()
	interaction.carried_item = burger
	burger.freeze = true
	drive_thru.interact(player)
	await process_frame
	await create_timer(0.3).timeout
	_assert(order_manager.orders_completed >= 1, "One order still completes after prep affordance pass")

	var connected = Input.get_connected_joypads()
	if connected.is_empty():
		print("[WARN] No physical controller detected; controller hardware playtest still pending")
	else:
		print("[PASS] Physical controller detected: " + str(connected))
	_assert(_action_has_joy_event("move_forward") and _action_has_joy_event("interact") and _action_has_joy_event("pause"), "Controller InputMap remains wired")

	print("[PASS] Phase 19 playtest prep smoke check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _label_inside_viewport(label: Control, viewport_size: Vector2i) -> bool:
	if not label:
		return false
	var right = label.position.x + label.size.x
	var bottom = label.position.y + label.size.y
	return label.position.x >= 0 and label.position.y >= 0 and right <= viewport_size.x and bottom <= viewport_size.y

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
