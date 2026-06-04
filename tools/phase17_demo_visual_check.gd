extends SceneTree

const SCREENSHOT_PATH := "res://artifacts/phase17_demo_screenshot.png"

func _initialize():
	call_deferred("_run_check")

func _run_check():
	var main_scene = load("res://scenes/world/Main.tscn")
	_assert(main_scene != null, "Main scene loads")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var dressing = root.find_child("Phase17DemoDressing", true, false)
	_assert(dressing != null, "Phase 17 demo dressing exists")
	for node_name in [
		"KitchenColorZone",
		"FrontCounterZone",
		"DriveThruLane",
		"DriveThruHandoffMat",
		"BackWall",
		"MenuBoard",
	]:
		_assert(dressing.get_node_or_null(node_name) != null, "Demo dressing node exists: " + node_name)

	for station_name in [
		"RegisterStation",
		"DriveThruStation",
		"GrillStation",
		"FryerCheckStation",
		"BaggingTableStation",
		"SauceStockStation",
		"RecoveryStation",
		"TrashRunStation",
		"CleaningStation",
		"RegisterCheckStation",
		"ClockOutStation",
	]:
		var station = root.find_child(station_name, true, false)
		_assert(station != null, "Station exists: " + station_name)
		_assert(station.get_node_or_null("Phase17Sign") != null, "Station has readable sign: " + station_name)

	var customer_scene = load("res://scenes/customers/CustomerCar.tscn")
	_assert(customer_scene != null, "CustomerCar scene loads")

	var hud = root.find_child("GameHUD", true, false)
	_assert(hud != null, "HUD exists")
	_assert(hud.get_node_or_null("Control/OrderPanel") != null, "HUD order panel exists")
	_assert(hud.get_node_or_null("Control/ObjectivePanel") != null, "HUD objective panel exists")
	_assert(hud.get_node_or_null("Control/TaskPanel") != null, "HUD task panel exists")
	_assert(hud.get_node_or_null("Control/CustomerStatusLabel") != null, "HUD customer status exists")
	_assert(hud.get_node_or_null("Control/HeldItemLabel") != null, "HUD held item label exists")
	_assert(hud.get_node_or_null("Control/GuidanceLabel") != null, "HUD first-shift guidance exists")
	_assert(hud.get_node_or_null("Control/EventFeedLabel") != null, "HUD event feed exists")

	main.start_new_game()
	await process_frame
	await create_timer(2.3).timeout
	var customer_car = root.find_child("CustomerCar", true, false)
	var order_manager = root.get_node_or_null("OrderManager")
	var player = root.find_child("Player", true, false)
	_assert(customer_car != null, "Visible CustomerCar spawns")
	_assert(str(customer_car.get("active_color_name")).length() > 0, "CustomerCar selects a color variant")
	var visible_body_count := 0
	for body_name in ["BodyRed", "BodyBlue", "BodyYellow", "BodyGreen"]:
		var body = customer_car.get_node_or_null(body_name)
		if body and body.visible:
			visible_body_count += 1
	_assert(visible_body_count == 1, "CustomerCar shows exactly one color body")
	_assert(order_manager != null and not order_manager.current_order.is_empty(), "Customer car creates active order")
	_assert(hud.customer_status_label != null and hud.customer_status_label.text.contains("DRIVE-THRU"), "HUD shows customer drive-thru status")
	_assert(hud.order_title_label != null and hud.order_title_label.text.contains("ORDER TICKET"), "HUD shows readable order ticket")

	var audio = root.get_node_or_null("AudioManager")
	for hook_name in [
		"interact",
		"pickup",
		"drop",
		"order_received",
		"correct_handoff",
		"wrong_handoff",
		"task_complete",
		"shift_start",
		"shift_end",
	]:
		_assert(audio != null and audio.sfx_paths.has(hook_name), "Audio hook exists: " + hook_name)

	var clock_out = root.find_child("ClockOutStation", true, false)
	var menu = root.find_child("MainMenuUI", true, false)
	_assert(clock_out != null and clock_out.has_method("interact"), "Physical clock-out station is interactable")
	clock_out.interact(player)
	await process_frame
	_assert(menu != null and menu.visible and menu.mode == "results", "Physical clock-out opens shift recap")

	await _save_screenshot_if_possible()
	print("[PASS] Phase 17 demo visual smoke check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _save_screenshot_if_possible():
	if DisplayServer.get_name().to_lower().contains("headless"):
		print("[WARN] Phase 17 screenshot skipped: headless renderer")
		return
	var dir = DirAccess.open("res://")
	if dir and not dir.dir_exists("artifacts"):
		dir.make_dir("artifacts")
	await process_frame
	var image = root.get_texture().get_image()
	if image and image.get_width() > 0 and image.get_height() > 0:
		var err = image.save_png(SCREENSHOT_PATH)
		if err == OK:
			print("[PASS] Phase 17 screenshot saved: " + SCREENSHOT_PATH)
		else:
			print("[WARN] Phase 17 screenshot save failed: " + str(err))
	else:
		print("[WARN] Phase 17 screenshot unavailable from headless renderer")

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
