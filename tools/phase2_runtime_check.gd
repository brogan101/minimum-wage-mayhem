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
	_assert(player != null, "Player spawned")
	var interaction = player.get_node_or_null("InteractionHandler")
	_assert(interaction != null, "Interaction handler exists")
	var burger = root.find_child("TrainingBurger", true, false)
	_assert(burger != null, "Training burger exists")
	var register_station = root.find_child("RegisterStation", true, false)
	_assert(register_station != null, "Register station exists")
	var event_log = root.get_node_or_null("EventLog")
	_assert(event_log != null, "EventLog autoload exists")

	interaction.grab_item(burger)
	_assert(interaction.carried_item == burger, "Pickup assigns carried item")
	interaction.drop_item()
	_assert(interaction.carried_item == null, "Drop clears carried item")
	register_station.interact(player)

	_assert(event_log.get_events_by_type("item_picked_up").size() >= 1, "Pickup event logged")
	_assert(event_log.get_events_by_type("item_dropped").size() >= 1, "Drop event logged")
	_assert(event_log.get_events_by_type("station_interacted").size() >= 1, "Station interaction event logged")

	burger.global_position = Vector3(0, -10, 0)
	burger.reset_to_spawn()
	_assert(burger.global_position.y > -1.0, "Lost item resets to spawn")
	_assert(event_log.get_events_by_type("pickup_item_reset").size() >= 1, "Lost item reset event logged")

	print("[PASS] Phase 2 runtime interaction check passed")
	quit(0)

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
