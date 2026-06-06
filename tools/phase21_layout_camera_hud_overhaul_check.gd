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
	await create_timer(0.8).timeout

	var dressing = root.find_child("Phase17DemoDressing", true, false)
	var hud = root.find_child("GameHUD", true, false)
	var player = root.find_child("Player", true, false)
	var order_manager = root.get_node_or_null("OrderManager")
	_assert(dressing != null, "Redo dressing root exists")
	_assert(hud != null, "HUD exists")
	_assert(player != null, "Player exists")

	for node_name in [
		"Phase21RedoLobbyZone",
		"Phase21RedoServiceZone",
		"Phase21RedoPrepZone",
		"Phase21RedoKitchenZone",
		"Phase21RedoRestockZone",
		"Phase21RedoClockZone",
		"Phase21RedoCustomerCounter",
		"Phase21RedoKitchenRail",
		"Phase21RedoDriveThruDivider",
		"Phase21RedoStep1Ticket",
		"Phase21RedoStep2Burger",
		"Phase21RedoStep3Window",
		"Phase21RedoStep4ClockOut",
		"Phase21RedoPathArrowTicketToBurger",
		"Phase21RedoPathArrowBurgerToWindowA",
		"Phase21RedoPathArrowWindowToClock",
		"Phase21RedoHandoffSpot",
		"Phase21RedoPlayerStartSign",
		"Phase21RedoDriveThruOverheadSign",
	]:
		_assert(dressing.get_node_or_null(node_name) != null, "Redo layout node exists: " + node_name)

	_assert(abs(player.global_position.x) < 0.35 and player.global_position.z < -4.8 and player.global_position.y > 0.5, "Player starts in readable front aisle")
	_assert(abs(wrapf(player.rotation.y - PI, -PI, PI)) < 0.05, "Player starts facing into restaurant")
	var camera = player.get_node_or_null("Head/Camera3D") as Camera3D
	var third_camera = player.get_node_or_null("ThirdPersonRig/ThirdPersonCamera") as Camera3D
	_assert(camera != null and camera.fov >= 76.0, "First-person FOV widened for room readability")
	_assert(third_camera != null and third_camera.fov >= 70.0, "Third-person camera FOV set")
	_assert(float(player.get("mouse_sensitivity")) >= 0.0022, "Mouse look is more responsive")
	_assert(float(player.get("controller_look_sensitivity")) >= 2.7, "Controller look is more responsive")

	_assert(hud.objective_label.text.contains("Ticket") and hud.objective_label.text.contains("Clock Out"), "Objective is first-shift readable")
	_assert(hud.guidance_label.text.contains("floor arrows"), "Guidance names the in-world route")
	_assert(hud.guidance_label.text.contains("bags") and hud.guidance_label.text.contains("soda") and hud.guidance_label.text.contains("fries"), "Guidance keeps prep affordance clarity")
	_assert(not hud.beef_bar.visible and not hud.composure_bar.visible and not hud.boot_status_label.visible, "Debug-like HUD elements are hidden")
	_assert(hud.event_feed_label.text.begins_with("Recent"), "Event feed is short and game-like")
	for viewport_size in [Vector2i(1280, 720), Vector2i(1366, 768), Vector2i(1920, 1080)]:
		root.size = viewport_size
		await process_frame
		_assert(_control_inside_viewport(hud.objective_label, viewport_size), "Objective fits viewport " + str(viewport_size))
		_assert(_control_inside_viewport(hud.daily_tasks_label, viewport_size), "Task list fits viewport " + str(viewport_size))
		_assert(_control_inside_viewport(hud.interaction_prompt_label, viewport_size), "Prompt fits viewport " + str(viewport_size))

	var burger = root.find_child("TrainingBurger", true, false)
	var drive_thru = root.find_child("DriveThruStation", true, false)
	var interaction = player.get_node_or_null("InteractionHandler")
	_assert(burger != null and drive_thru != null and interaction != null and order_manager != null, "First-shift order actors exist")
	if order_manager.current_order.is_empty():
		order_manager.generate_new_order()
	interaction.carried_item = burger
	burger.freeze = true
	drive_thru.interact(player)
	await process_frame
	await create_timer(0.3).timeout
	_assert(order_manager.orders_completed >= 1, "One order still completes after redo")

	print("[PASS] Phase 21 layout/camera/HUD overhaul check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _control_inside_viewport(control: Control, viewport_size: Vector2i) -> bool:
	if not control:
		return false
	var right = control.position.x + control.size.x
	var bottom = control.position.y + control.size.y
	return control.position.x >= 0 and control.position.y >= 0 and right <= viewport_size.x and bottom <= viewport_size.y

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
