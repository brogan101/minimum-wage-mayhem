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
	await create_timer(2.6, true).timeout

	var dressing = root.find_child("Phase17DemoDressing", true, false)
	var player = root.find_child("Player", true, false)
	var interaction = player.get_node_or_null("InteractionHandler") if player else null
	var hud = root.find_child("GameHUD", true, false)
	var order_manager = root.get_node_or_null("OrderManager")
	var drive_thru = root.find_child("DriveThruStation", true, false)
	var bagging = root.find_child("BaggingTableStation", true, false)
	var grill = root.find_child("GrillStation", true, false)
	var fryer = root.find_child("FryerCheckStation", true, false)
	var drink = root.find_child("DrinkFillStation", true, false)
	var clock_out = root.find_child("ClockOutStation", true, false)

	_assert(dressing != null, "Restaurant dressing root exists")
	_assert(player != null and interaction != null, "Player and interaction handler exist")
	_assert(hud != null and order_manager != null, "HUD and order manager exist")
	_assert(drive_thru != null and bagging != null and grill != null and fryer != null and drink != null and clock_out != null, "All required first-shift stations exist")

	for node_name in [
		"Phase29FrontCounterZone",
		"Phase29PrepBaggingZone",
		"Phase29HotLineZone",
		"Phase29DrinkSauceZone",
		"Phase29DriveThruWindowZone",
		"Phase29ClockOutZone",
		"Phase29MainAisleWalkable",
		"Phase29PrepToHotLineWalkable",
		"Phase29PrepToWindowWalkable",
		"Phase29WindowToClockWalkable",
		"Phase29Step1TakeOrder",
		"Phase29Step2GetBag",
		"Phase29Step3AddFood",
		"Phase29Step4FixTicket",
		"Phase29Step5Handoff",
		"Phase29Step6ClockOut",
		"Phase29OverheadWorkflowSign",
		"Phase29WrongItemReminder",
		"Phase29WindowGlowRing",
	]:
		_assert(dressing.get_node_or_null(node_name) != null, "Phase 29 layout node exists: " + node_name)

	for node_name in [
		"Phase29RouteReadabilityLight",
		"Phase29WindowTargetLight",
	]:
		_assert(root.find_child(node_name, true, false) != null, "Phase 29 readability light exists: " + node_name)

	_assert(_near_xz(player, Vector3(0.0, 0.0, -5.45), 0.25), "Player starts facing the organized route")
	_assert(_near(bagging, Vector3(-0.45, 0.9, -0.55), 0.2), "Bagging station is on step 2")
	_assert(_near(grill, Vector3(1.65, 0.9, 2.55), 0.2), "Grill station is on hot line")
	_assert(_near(fryer, Vector3(3.35, 0.9, 2.55), 0.2), "Fryer station is on hot line")
	_assert(_near(drink, Vector3(-1.75, 0.9, 1.45), 0.2), "Drink station is next to bagging route")
	_assert(_near(drive_thru, Vector3(-4.75, 0.9, -2.15), 0.2), "Drive-thru handoff is on green mat")
	_assert(_near(clock_out, Vector3(5.75, 0.85, 3.65), 0.3), "Clock-out is a distinct endpoint")

	_assert(_path_distance(bagging, grill) < 4.0, "Bagging and hot line are close enough to read as one workflow")
	_assert(_path_distance(bagging, drive_thru) < 5.0, "Bagging and drive-thru are reachable without a maze")
	_assert(_path_distance(drive_thru, clock_out) < 12.75, "Window-to-clock route remains reachable")

	_assert(str(bagging.get("station_label")).contains("Get bag"), "Bagging station has player-facing label")
	_assert(str(grill.get("interact_text")).contains("Burger"), "Grill prompt explains Burger")
	_assert(str(fryer.get("station_label")).contains("Fries"), "Fryer prompt explains Fries")
	_assert(str(drink.get("interact_text")).contains("Soda"), "Drink prompt explains Soda")
	_assert(str(drive_thru.get("interact_text")).contains("green"), "Drive-thru prompt points to green mat")
	_assert(str(clock_out.get("interact_text")).contains("Clock out"), "Clock-out prompt explains shift end")
	_assert(hud.objective_label.text.contains("1 Ticket") and hud.objective_label.text.contains("6 Clock"), "HUD objective shows step-by-step route")
	_assert(hud.get_node_or_null("Control/Phase29FlowRibbon") != null, "Phase 29 HUD flow ribbon exists")
	_assert(hud.get_node_or_null("Control/Phase29PromptHintLabel") != null, "Phase 29 HUD prompt hint exists")
	_assert(hud.guidance_label.text.contains("yellow numbers"), "HUD guidance points to floor numbers")

	order_manager.generate_new_order("Lunch Driver")
	await process_frame
	bagging.interact(player)
	await process_frame
	var bag = interaction.get("carried_item")
	_assert(_is_bag(bag), "Bagging creates a carried order bag")
	grill.interact(player)
	await process_frame
	_assert(bag.contained_items.has("Burger"), "Grill adds Burger in the organized layout")
	drive_thru.interact(player)
	await process_frame
	await create_timer(0.25, true).timeout
	_assert(not order_manager.current_order.is_empty(), "Wrong/incomplete handoff keeps the active customer")
	_assert(hud.station_feedback_label.text.contains("Missing Fries"), "Wrong handoff explains missing item")
	fryer.interact(player)
	await process_frame
	_assert(bag.contained_items.has("Fries"), "Fryer fixes the missing item")
	drive_thru.interact(player)
	await process_frame
	await create_timer(0.35, true).timeout
	_assert(order_manager.orders_completed >= 1, "Corrected bag completes at green handoff")
	_assert(interaction.get("carried_item") == null, "Successful handoff clears carried item")

	var story = FileAccess.open("res://data/mischief/restaurant_story_events.json", FileAccess.READ)
	_assert(story != null, "Restaurant story-event catalog exists")
	var data = JSON.parse_string(story.get_as_text())
	_assert(typeof(data) == TYPE_DICTIONARY and data.get("events", []).size() == 180, "Restaurant story event count remains 180")

	print("[PASS] Phase 29 restaurant layout flow overhaul check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _near(node: Node, pos: Vector3, tolerance: float) -> bool:
	var spatial = node as Node3D
	return spatial != null and spatial.global_position.distance_to(pos) <= tolerance

func _near_xz(node: Node, pos: Vector3, tolerance: float) -> bool:
	var spatial = node as Node3D
	if not spatial:
		return false
	var actual = Vector2(spatial.global_position.x, spatial.global_position.z)
	var expected = Vector2(pos.x, pos.z)
	return actual.distance_to(expected) <= tolerance

func _path_distance(a: Node, b: Node) -> float:
	var spatial_a = a as Node3D
	var spatial_b = b as Node3D
	if not spatial_a or not spatial_b:
		return 999.0
	return spatial_a.global_position.distance_to(spatial_b.global_position)

func _is_bag(item: Object) -> bool:
	return item != null and item.get("contained_items") != null and item.has_method("add_item")

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
