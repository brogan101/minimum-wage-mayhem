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
	await create_timer(0.5).timeout

	var dressing = root.find_child("Phase17DemoDressing", true, false)
	var hud = root.find_child("GameHUD", true, false)
	var car = root.find_child("CustomerCar", true, false)
	_assert(dressing != null, "Cartoon dressing root exists")
	_assert(hud != null, "HUD exists")
	_assert(car != null, "CustomerCar spawns")

	for prop_name in [
		"Phase21WallStripeBack",
		"Phase21BaseboardBack",
		"Phase21FloorGroutX0",
		"Phase21FloorGroutZ0",
		"Phase21DriveThruWindowFrame",
		"Phase21DriveThruAwning",
		"Phase21DriveThruLaneBorderA",
		"Phase21HandoffTargetRing",
		"Phase21RegisterScreen",
		"Phase21RegisterGlow",
		"Phase21GrillFlatTop",
		"Phase21GrillLine0",
		"Phase21FryerVat",
		"Phase21FryStick0",
		"Phase21TicketRail",
		"Phase21OrderTicketCard",
		"Phase21SodaCupA",
		"Phase21FryCartonLip",
		"Phase21ClockFace",
		"Phase21BrandWallSign",
		"Phase21WindowCue",
	]:
		_assert(dressing.get_node_or_null(prop_name) != null, "Phase 21 prop exists: " + prop_name)

	for old_prop in [
		"BaggingPaperBags",
		"FriesReadyBin",
		"SodaCupStack",
		"PrepFlowArrowTicket",
		"PrepFlowArrowWindow",
	]:
		_assert(dressing.get_node_or_null(old_prop) != null, "Phase 19 prep affordance preserved: " + old_prop)

	for car_prop in [
		"Phase21Windshield",
		"Phase21FrontBumper",
		"Phase21HeadlightL",
		"Phase21OrderBubbleCard",
		"Phase21OrderBubbleText",
	]:
		_assert(car.get_node_or_null(car_prop) != null, "CustomerCar cartoon detail exists: " + car_prop)

	for panel_name in [
		"OrderPanelHeader",
		"ObjectivePanelHeader",
		"TaskPanelHeader",
		"PromptPanelAccent",
	]:
		_assert(hud.get_node_or_null("Control/" + panel_name) != null, "HUD game-style panel exists: " + panel_name)

	var burger = root.find_child("TrainingBurger", true, false)
	_assert(burger != null and dressing.get_node_or_null("Phase21BurgerBunTop") != null, "Training burger station has readable layered prop")

	var player = root.find_child("Player", true, false)
	var drive_thru = root.find_child("DriveThruStation", true, false)
	var order_manager = root.get_node_or_null("OrderManager")
	_assert(player != null and drive_thru != null and order_manager != null, "Full-shift actors still exist")
	var interaction = player.get_node_or_null("InteractionHandler")
	_assert(interaction != null, "Player interaction handler exists")
	if order_manager.current_order.is_empty():
		order_manager.generate_new_order()
	_assert(not order_manager.current_order.is_empty(), "Art pass preserves active customer order flow")

	print("[PASS] Phase 21 art direction runtime check passed")
	await process_frame
	quit(0)

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
