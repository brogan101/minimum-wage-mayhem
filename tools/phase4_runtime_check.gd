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

	var staff = root.find_child("StaffDirector", true, false)
	var riley = root.find_child("CoworkerRiley", true, false)
	var casey = root.find_child("CoworkerCasey", true, false)
	var morgan = root.find_child("CoworkerMorgan", true, false)
	var player = root.find_child("Player", true, false)
	var event_log = root.get_node_or_null("EventLog")

	_assert(staff != null, "StaffDirector exists")
	_assert(riley != null and casey != null and morgan != null, "Coworker NPCs exist in 3D")
	_assert(player != null, "Player spawned")
	_assert(event_log != null, "EventLog autoload exists")
	_assert(staff.coworkers.size() >= 3, "Balanced mini-roster exists")
	_assert(staff.station_coverage.get("grill") == "covered", "Grill starts covered")

	riley.interact(player)
	_assert(staff.station_coverage.get("grill") == "helped", "Helpful coworker improves grill coverage")
	_assert(event_log.get_events_by_type("coworker_helped").size() >= 1, "Coworker help logged")

	var before_accuracy = float(staff.get_shift_effects().get("accuracy", 1.0))
	staff.record_mistake("casey", "register", 2)
	var after_mistake = staff.get_shift_effects()
	_assert(float(after_mistake.get("accuracy", 1.0)) < before_accuracy, "Coworker mistake lowers accuracy")
	_assert(event_log.get_events_by_type("coworker_mistake").size() >= 1, "Coworker mistake logged")

	var before_speed = float(after_mistake.get("speed", 1.0))
	var callout = staff.generate_callout("casey")
	var after_callout = staff.get_shift_effects()
	_assert(not callout.is_empty(), "Callout generated from staff data")
	_assert(staff.station_coverage.get("register") == "uncovered", "Callout uncovers register")
	_assert(float(after_callout.get("speed", 1.0)) < before_speed, "Callout lowers shift speed")
	_assert(float(after_callout.get("customer_patience", 1.0)) < 1.0, "Coverage affects customer patience")
	_assert(event_log.get_events_by_type("coworker_callout").size() >= 1, "Coworker callout logged")
	_assert(event_log.get_events_by_type("manager_callout_handled").size() >= 1, "Manager callout handling logged")

	staff.swap_station("morgan", "register")
	_assert(staff.coworkers["morgan"]["station"] == "register", "Station swap updates coworker assignment")
	_assert(event_log.get_events_by_type("coworker_station_swap").size() >= 1, "Station swap logged")

	var line = staff.dialogue_for("morgan", "rush")
	_assert(line.length() > 0, "Coworker dialogue hook returns line")
	_assert(event_log.get_events_by_type("coworker_dialogue").size() >= 1, "Coworker dialogue logged")

	var final_effects = staff.get_shift_effects()
	_assert(int(final_effects.get("staff_morale", 0)) < 75, "Staff morale changes from events")
	_assert(int(final_effects.get("manager_trust", 0)) < 60, "Manager trust changes from events")
	_assert(int(final_effects.get("corporate_approval", 0)) <= 50, "Corporate approval hook changes or holds under pressure")
	_assert(int(final_effects.get("review_risk", 0)) > 0, "Review risk changes from staff coverage")

	print("[PASS] Phase 4 runtime staff/coworker check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
