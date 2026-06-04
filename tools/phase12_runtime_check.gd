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

	var emergent = root.find_child("EmergentEventDirector", true, false)
	var memory = root.find_child("RestaurantMemoryManager", true, false)
	var evidence = root.find_child("EvidenceManager", true, false)
	var object_memory = root.find_child("StoreObjectMemoryManager", true, false)
	var matrix = root.find_child("ConsequenceMatrixManager", true, false)
	var mission_generator = root.find_child("EmergentMissionGenerator", true, false)
	var karma = root.find_child("MultiKarmaManager", true, false)
	var reputation = root.find_child("DynamicReputationLabelManager", true, false)
	var recap = root.find_child("GeneratedRecapManager", true, false)
	var future = root.find_child("FutureChainTriggerManager", true, false)
	var fireable = root.find_child("FireableOffenseManager", true, false)
	var shift_results = root.get_node_or_null("ShiftResultManager")
	var save_system = root.get_node_or_null("SaveSystem")
	var career = root.get_node_or_null("CareerManager")
	var event_log = root.get_node_or_null("EventLog")

	for node_pair in [
		[emergent, "EmergentEventDirector"],
		[memory, "RestaurantMemoryManager"],
		[evidence, "EvidenceManager"],
		[object_memory, "StoreObjectMemoryManager"],
		[matrix, "ConsequenceMatrixManager"],
		[mission_generator, "EmergentMissionGenerator"],
		[karma, "MultiKarmaManager"],
		[reputation, "DynamicReputationLabelManager"],
		[recap, "GeneratedRecapManager"],
		[future, "FutureChainTriggerManager"]
	]:
		_assert(node_pair[0] != null, str(node_pair[1]) + " wired into playable scene")
	_assert(fireable != null and shift_results != null and save_system != null and career != null and event_log != null, "Gameplay/save systems exist")
	_assert(emergent.loaded_emergent_catalogs.size() >= 7, "Emergent data catalogs loaded")
	_assert(evidence.evidence_types.size() > 0, "Evidence data loaded")
	_assert(object_memory.object_targets.size() > 0, "Store object memory targets loaded")
	_assert(karma.karma_values.size() > 0, "Karma data loaded")
	_assert(reputation.rules.size() > 0, "Dynamic reputation rules loaded")
	_assert(mission_generator.archetypes.size() > 0 and not mission_generator.components.is_empty(), "Mission composer data loaded")
	_assert(not matrix.consequence_rules.is_empty(), "Consequence rules loaded")
	_assert(recap.fields.size() > 0, "Generated recap fields loaded")

	shift_results.begin_shift_snapshot()
	fireable.process_shady_choice("tip_jar_pocketing", {"force_caught": true, "witnesses": 1, "camera_coverage": 10, "risk": "medium"})
	var event = emergent.generate_event({
		"force_actor_id": "player",
		"force_problem_id": "borrowed_tip_money",
		"force_location_id": "front_counter",
		"force_object_id": "tip_jar",
		"force_witness_id": "camera_witness",
		"force_cover_story_id": "tip_stabilization",
		"force_immediate_consequence_id": "manager_suspicion_up",
		"force_delayed_consequence_id": "cold_case_sidequest",
		"force_evidence": true,
		"future_chain_chance": true
	})
	_assert(not event.is_empty(), "Emergent event composed from components")
	_assert(str(event.get("event_id", "")).contains("player"), "Generated event has deterministic state-derived id")
	_assert(memory.get_summary().get("career_memory", []).size() >= 1, "Restaurant memory records generated event")
	_assert(evidence.get_summary().get("active_evidence", []).size() >= 1, "Evidence persists beyond event creation")
	_assert(object_memory.get_summary().get("object_memory", {}).get("tip_jar", {}).get("incident_count", 0) >= 1, "Store object gains incident history")
	_assert(matrix.get_summary().get("calculation_history", []).size() >= 1, "Consequence matrix calculated from event")
	_assert(mission_generator.get_summary().get("generated_missions", []).size() >= 1, "Mission generated from event tags")
	_assert(karma.get_summary().get("karma_history", []).size() >= 1, "Karma changed from generated event")
	_assert(recap.get_summary().get("recap_history", []).size() >= 1, "Generated recap uses event history")
	_assert(event_log.get_events_by_type("restaurant_memory_recorded").size() >= 1, "Memory event logged")
	_assert(event_log.get_events_by_type("evidence_created").size() >= 1, "Evidence creation logged")
	_assert(event_log.get_events_by_type("emergent_mission_generated").size() >= 1, "Mission generation logged")

	emergent.generate_event({
		"force_actor_id": "coupon_warrior",
		"force_problem_id": "borrowed_tip_money",
		"force_location_id": "front_counter",
		"force_object_id": "tip_jar",
		"force_evidence": true
	})
	emergent.generate_event({
		"force_actor_id": "corporate_climber",
		"force_problem_id": "borrowed_tip_money",
		"force_location_id": "front_counter",
		"force_object_id": "tip_jar",
		"force_evidence": true
	})
	_assert(object_memory.get_summary().get("object_memory", {}).get("tip_jar", {}).get("labels", []).has("legendary"), "Repeated object history creates object label")

	var summary = emergent.get_emergent_summary()
	_assert(summary.get("events", []).size() >= 3, "Emergent summary stores generated event history")
	_assert(summary.get("missions", []).size() >= 1, "Emergent summary stores generated missions")
	_assert(summary.get("evidence", []).size() >= 1, "Emergent summary stores generated evidence")
	_assert(summary.get("dynamic_labels", []).size() >= 1, "Dynamic reputation label generated")

	var report = shift_results.complete_shift({"completed": 1})
	var result = shift_results.get_last_result_data()
	var save_data = save_system.get_last_save_data()
	_assert(report.contains("Restaurant Memory:"), "Shift report includes restaurant memory section")
	_assert(result.get("emergent_events", []).size() >= 3, "Shift result stores emergent events")
	_assert(result.get("emergent_missions", []).size() >= 1, "Shift result stores generated missions")
	_assert(result.get("emergent_evidence", []).size() >= 1, "Shift result stores evidence")
	_assert(result.get("dynamic_reputation_labels", []).size() >= 1, "Shift result stores dynamic labels")
	_assert(result.get("generated_recaps", []).size() >= 1, "Shift result stores generated recap")
	_assert(save_data.get("last_shift", {}).has("emergent_summary"), "Save includes emergent summary through last shift")
	_assert(career.get_career_status().get("career_recap_history", []).size() >= 1, "Career history includes generated consequence shift")

	print("[PASS] Phase 12 runtime emergent memory mission check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
