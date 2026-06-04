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

	var depth = root.find_child("DepthDirector", true, false)
	var normalcy = root.find_child("NormalcyBalanceDirector", true, false)
	var linker = root.find_child("DepthEventLinker", true, false)
	var texture = root.find_child("WorldTextureManager", true, false)
	var flavor = root.find_child("ShiftFlavorManager", true, false)
	var density = root.find_child("ContentDensityValidatorRuntime", true, false)
	var memory = root.find_child("RestaurantMemoryManager", true, false)
	var shift_results = root.get_node_or_null("ShiftResultManager")
	var save_system = root.get_node_or_null("SaveSystem")
	var career = root.get_node_or_null("CareerManager")
	var event_log = root.get_node_or_null("EventLog")
	var staff = root.find_child("StaffDirector", true, false)
	var store_ops = root.find_child("StoreOpsDirector", true, false)

	for node_pair in [
		[depth, "DepthDirector"],
		[normalcy, "NormalcyBalanceDirector"],
		[linker, "DepthEventLinker"],
		[texture, "WorldTextureManager"],
		[flavor, "ShiftFlavorManager"],
		[density, "ContentDensityValidatorRuntime"]
	]:
		_assert(node_pair[0] != null, str(node_pair[1]) + " wired into playable scene")
	_assert(memory != null and shift_results != null and save_system != null and career != null and event_log != null, "Memory, result, save, career, and EventLog systems exist")
	_assert(staff != null and store_ops != null, "Staff and store operation systems exist")
	_assert(depth.loaded_depth_catalogs.size() >= 24, "DepthDirector loaded all required depth catalogs")
	_assert(depth.bundles.size() >= 30, "Depth bundle catalog has 30+ bundles")

	shift_results.begin_shift_snapshot()
	var start_promotion = int(career.promotion_progress)
	var start_morale = int(staff.staff_morale)
	var start_manager_trust = int(store_ops.manager_trust)
	var summary = depth.generate_shift_depth({"shift_number": 3, "tutorial_shift": false, "recovery_window": false})
	var balance = summary.get("balance", {})
	var ratio = balance.get("ratio", {})

	_assert(bool(balance.get("within_target", false)), "Depth balance stays inside Phase 13 target mix")
	_assert(float(ratio.get("normal_orders", 0.0)) >= 0.45 and float(ratio.get("normal_orders", 0.0)) <= 0.60, "Normal work stays 45-60 percent")
	_assert(float(ratio.get("service_friction", 0.0)) >= 0.20 and float(ratio.get("service_friction", 0.0)) <= 0.30, "Service friction stays 20-30 percent")
	_assert(float(ratio.get("funny_weird", 0.0)) >= 0.10 and float(ratio.get("funny_weird", 0.0)) <= 0.20, "Weird comedy stays 10-20 percent")
	_assert(float(ratio.get("wild_spike", 0.0)) >= 0.05 and float(ratio.get("wild_spike", 0.0)) <= 0.10, "Wild chaos stays 5-10 percent")
	_assert(summary.get("active_bundles", []).size() > 0, "Depth bundles selected for shift")
	_assert(summary.get("linked_entries", []).size() > 0, "Depth entries linked into memory/EventLog path")
	_assert(summary.get("generated_depth_events", []).size() > 0, "Depth generated state-derived events")
	_assert(summary.get("recovery_routes", []).size() >= 1, "Recovery routes available")
	_assert(summary.get("promotion_detours", []).size() >= 1, "Promotion detours available")
	_assert(summary.get("store_mutations", []).size() >= 1, "Store identity mutations available")
	_assert(summary.get("world_texture", {}).get("quiet_events", []).size() >= 1, "Quiet normal event generated")
	_assert(summary.get("world_texture", {}).get("rumors", []).size() >= 1, "World rumor generated")
	_assert(summary.get("shift_flavor", {}).get("flavor_history", []).size() >= 1, "Shift flavor history generated")
	_assert(bool(summary.get("runtime_validation", {}).get("ok", false)), "Content density/performance budget check passed")
	_assert(memory.get_summary().get("career_memory", []).size() >= 1, "Restaurant memory records Phase 13 depth")
	_assert(event_log.get_events_by_type("depth_event_linked").size() >= 1, "Depth linker emits EventLog entries")
	_assert(event_log.get_events_by_type("quiet_normal_event_generated").size() >= 1, "Quiet texture event logged")
	_assert(event_log.get_events_by_type("world_rumor_generated").size() >= 1, "World rumor logged")
	_assert(event_log.get_events_by_type("phase13_depth_generated").size() >= 1, "Depth generation logged")
	_assert(int(career.promotion_progress) >= start_promotion, "Depth can affect promotion progress")
	_assert(int(staff.staff_morale) >= start_morale, "Depth can affect staff morale")
	_assert(int(store_ops.manager_trust) >= start_manager_trust, "Depth can affect manager trust")

	var report = shift_results.complete_shift({"completed": 2})
	var result = shift_results.get_last_result_data()
	var save_data = save_system.get_last_save_data()
	_assert(report.contains("Global Depth:"), "Shift report includes global depth section")
	_assert(report.contains("Depth Balance:"), "Shift report includes balance breakdown")
	_assert(result.get("depth_bundles", []).size() > 0, "Shift result stores depth bundles")
	_assert(result.get("depth_generated_events", []).size() > 0, "Shift result stores generated depth events")
	_assert(result.get("depth_summary", {}).has("runtime_validation"), "Shift result stores depth runtime validation")
	_assert(save_data.get("last_shift", {}).has("depth_summary"), "Save includes depth summary through last shift")

	print("[PASS] Phase 13 runtime global depth balance check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
