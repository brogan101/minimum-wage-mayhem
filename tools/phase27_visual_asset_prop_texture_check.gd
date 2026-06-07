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
	var car = root.find_child("CustomerCar", true, false)
	var order_manager = root.get_node_or_null("OrderManager")
	_assert(dressing != null, "Restaurant dressing root exists")
	_assert(hud != null, "HUD exists")
	_assert(car != null, "CustomerCar spawns")
	_assert(order_manager != null, "Order manager exists")

	for node_name in [
		"Phase27ExteriorBrandSign",
		"Phase27BrandNameSign",
		"Phase27MenuBoardLeftPanel",
		"Phase27MenuBurgerText",
		"Phase27LobbyWallWarmPanel",
		"Phase27KitchenTileWallPanel",
		"Phase27DriveThruOrderSpeaker",
		"Phase27DriveThruSpeakerLabel",
		"Phase27WindowPickupShelf",
		"Phase27RegisterDrawer",
		"Phase27GrillGreaseGuard",
		"Phase27GrillSpatulaBlade",
		"Phase27FryerBasketMeshA",
		"Phase27PrepWrapperStack",
		"Phase27DrinkDispenserBody",
		"Phase27SaucePacketRack",
		"Phase27TrashCanLid",
		"Phase27MopBucket",
		"Phase27ClockOutWallPoster",
	]:
		_assert(dressing.get_node_or_null(node_name) != null, "Phase 27 visual node exists: " + node_name)
	_assert(root.find_child("Phase27BrandSignGlow", true, false) != null, "Phase 27 readability light exists: Phase27BrandSignGlow")
	_assert(root.find_child("Phase27KitchenReadabilityLight", true, false) != null, "Phase 27 readability light exists: Phase27KitchenReadabilityLight")

	for node_name in [
		"Phase27SideStripeL",
		"Phase27RoofOrderSign",
		"Phase27WindshieldShine",
		"Phase27FrontPlate",
		"Phase27RoofSignText",
	]:
		_assert(car.get_node_or_null(node_name) != null, "Phase 27 customer car detail exists: " + node_name)

	for node_name in [
		"Phase27OrderTicketPaper",
		"Phase27HudBrandLabel",
		"Phase27ObjectiveBadge",
		"Phase27TimerBadge",
		"Phase27TaskBoardClip",
		"Phase27CareerRibbon",
		"Phase27PromptKeyBadge",
		"Phase27PromptKeyText",
	]:
		_assert(hud.get_node_or_null("Control/" + node_name) != null, "Phase 27 HUD polish node exists: " + node_name)

	_assert(hud.order_title_label.text.contains("TICKET"), "Order ticket remains readable after HUD polish")
	_assert(hud.guidance_label.text.contains("bags") and hud.guidance_label.text.contains("soda"), "HUD guidance still names prep affordances")
	_assert(dressing.get_node_or_null("Phase21RedoStep1Ticket") != null, "Phase 21 route guidance preserved")
	_assert(dressing.get_node_or_null("Phase24CareerPathBoard") != null, "Phase 24 career board preserved")

	var player = root.find_child("Player", true, false)
	var burger = root.find_child("TrainingBurger", true, false)
	var drive_thru = root.find_child("DriveThruStation", true, false)
	var interaction = player.get_node_or_null("InteractionHandler") if player else null
	_assert(player != null and burger != null and drive_thru != null and interaction != null, "Core first-shift actors still exist")
	if order_manager.current_order.is_empty():
		order_manager.generate_new_order()
	interaction.carried_item = burger
	burger.freeze = true
	drive_thru.interact(player)
	await process_frame
	await create_timer(0.3).timeout
	_assert(order_manager.orders_completed >= 1, "One order still completes after visual upgrade")

	var story = FileAccess.open("res://data/mischief/restaurant_story_events.json", FileAccess.READ)
	_assert(story != null, "Restaurant story-event catalog exists")
	var data = JSON.parse_string(story.get_as_text())
	_assert(typeof(data) == TYPE_DICTIONARY and data.get("events", []).size() == 180, "Restaurant story event count remains 180")

	print("[PASS] Phase 27 visual asset prop texture check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
