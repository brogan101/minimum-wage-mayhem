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

	var player = root.find_child("Player", true, false)
	var interaction = player.get_node_or_null("InteractionHandler") if player else null
	var grill = root.find_child("GrillStation", true, false)
	var patty = root.find_child("RawPatty", true, false)
	var event_log = root.get_node_or_null("EventLog")

	_assert(player != null, "Player spawned")
	_assert(interaction != null, "Interaction handler exists")
	_assert(grill != null, "Grill station exists")
	_assert(patty != null, "Raw patty exists")
	_assert(event_log != null, "EventLog autoload exists")
	_assert(int(patty.current_state) == 0, "Patty starts RAW")

	interaction.grab_item(patty)
	grill.interact(player)
	_assert(interaction.carried_item == null, "Grill accepts carried food")
	_assert(grill.items_on_station.has(patty), "Patty is on grill station")
	_assert(event_log.get_events_by_type("station_item_placed").size() >= 1, "Station placement logged")

	grill.interact(player)
	_assert(int(patty.current_state) == 1, "Patty changes to COOKED")
	_assert(_has_visual_material(patty), "Patty visual material updates when cooked")

	grill.interact(player)
	_assert(int(patty.current_state) == 2, "Patty changes to BURNT")
	_assert(event_log.get_events_by_type("item_state_changed").size() >= 2, "Food state changes logged")
	_assert(event_log.get_events_by_type("station_item_advanced").size() >= 2, "Station advancement logged")

	print("[PASS] Phase 3 runtime station food-state check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _has_visual_material(food: Node) -> bool:
	for child in food.get_children():
		if child is MeshInstance3D:
			return child.material_override != null
	return false

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
