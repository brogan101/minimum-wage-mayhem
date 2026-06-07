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
		"Phase28CeilingPlane",
		"Phase28PendantLightShade0",
		"Phase28LobbyFeatureWall",
		"Phase28KitchenBacksplashA",
		"Phase28LobbyCounterRoundedFace",
		"Phase28LobbyBoothSeat0",
		"Phase28DriveThruCurbedLane",
		"Phase28OrderSpeakerRoundedTop",
		"Phase28RegisterCurvedScreenBack",
		"Phase28GrillRoundedHood",
		"Phase28FryerEnamelFace",
		"Phase28PrepTableRoundedFront",
		"Phase28DrinkCupStackRoundA",
		"Phase28TrashCanRoundBody",
		"Phase28BurgerRoundedTopBun",
		"Phase28FriesCartonRoundedFace",
		"Phase28TallFry0",
	]:
		_assert(dressing.get_node_or_null(node_name) != null, "Phase 28 graphics node exists: " + node_name)

	for node_name in [
		"Phase28RoundedHoodPanel",
		"Phase28CabinSideGlassL",
		"Phase28FrontSmileGrille",
		"Phase28WheelArchFL",
		"Phase28HubcapFL",
	]:
		_assert(car.get_node_or_null(node_name) != null, "Phase 28 customer car upgrade exists: " + node_name)

	for node_name in [
		"Phase28HudReadabilityScrimLeft",
		"Phase28HudReadabilityScrimTop",
		"Phase28HudReadabilityScrimRight",
		"Phase28OrderPin",
		"Phase28PromptGlowLine",
		"Phase28HudStyleLockLabel",
	]:
		_assert(hud.get_node_or_null("Control/" + node_name) != null, "Phase 28 HUD support node exists: " + node_name)

	_assert(root.find_child("Phase28WarmLobbyBounce", true, false) != null, "Phase 28 warm lobby light exists")
	_assert(root.find_child("Phase28CoolKitchenBounce", true, false) != null, "Phase 28 cool kitchen light exists")
	_assert(root.find_child("Phase28DriveThruNightGlow", true, false) != null, "Phase 28 drive-thru glow exists")
	_assert(dressing.get_node_or_null("Phase27ExteriorBrandSign") != null, "Phase 27 brand sign preserved")
	_assert(dressing.get_node_or_null("Phase21RedoStep1Ticket") != null, "Phase 21 route guidance preserved")
	_assert(hud.order_title_label.text.contains("TICKET"), "Order ticket remains readable")

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
	_assert(order_manager.orders_completed >= 1, "One order still completes after major graphics upgrade")

	var story = FileAccess.open("res://data/mischief/restaurant_story_events.json", FileAccess.READ)
	_assert(story != null, "Restaurant story-event catalog exists")
	var data = JSON.parse_string(story.get_as_text())
	_assert(typeof(data) == TYPE_DICTIONARY and data.get("events", []).size() == 180, "Restaurant story event count remains 180")

	print("[PASS] Phase 28 major graphics upgrade check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
