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

	var store_ops = root.find_child("StoreOpsDirector", true, false)
	var sauce = root.find_child("SauceStockStation", true, false)
	var bagging = root.find_child("BaggingTableStation", true, false)
	var fryer = root.find_child("FryerCheckStation", true, false)
	var trash = root.find_child("TrashRunStation", true, false)
	var cleaning = root.find_child("CleaningStation", true, false)
	var register_check = root.find_child("RegisterCheckStation", true, false)
	var recovery = root.find_child("RecoveryStation", true, false)
	var player = root.find_child("Player", true, false)
	var hud = root.find_child("GameHUD", true, false)
	var event_log = root.get_node_or_null("EventLog")

	_assert(store_ops != null, "StoreOpsDirector exists")
	_assert(player != null, "Player spawned")
	_assert(hud != null and hud.has_method("set_store_ops_status"), "HUD store ops status hook exists")
	_assert(event_log != null, "EventLog autoload exists")
	_assert(sauce != null and bagging != null and fryer != null, "Core store ops stations exist in 3D")
	_assert(trash != null and cleaning != null and register_check != null and recovery != null, "Recovery and closing stations exist in 3D")

	var starting = store_ops.get_shift_effects()
	sauce.interact(player)
	var after_sauce = store_ops.get_shift_effects()
	_assert(int(after_sauce.get("sauce_stock", 0)) > int(starting.get("sauce_stock", 0)), "Sauce restock changes station inventory")
	_assert(float(after_sauce.get("customer_patience", 0.0)) >= float(starting.get("customer_patience", 0.0)), "Sauce stock protects customer patience")

	var before_bag_speed = float(after_sauce.get("speed", 0.0))
	bagging.interact(player)
	var after_bagging = store_ops.get_shift_effects()
	_assert(bool(after_bagging.get("bagging_table_ready", false)), "Bagging table becomes ready")
	_assert(float(after_bagging.get("speed", 0.0)) > before_bag_speed, "Bagging table improves shift speed")

	var before_register_accuracy = float(after_bagging.get("accuracy", 0.0))
	register_check.interact(player)
	var after_register = store_ops.get_shift_effects()
	_assert(bool(after_register.get("register_balanced", false)), "Register check balances drawer")
	_assert(float(after_register.get("accuracy", 0.0)) >= before_register_accuracy, "Register check supports accuracy")

	var before_review = int(after_register.get("review_risk", 0))
	trash.interact(player)
	cleaning.interact(player)
	var after_clean = store_ops.get_shift_effects()
	_assert(int(after_clean.get("trash_level", 100)) < int(after_register.get("trash_level", 100)), "Trash run lowers trash level")
	_assert(int(after_clean.get("cleanliness", 0)) > int(after_register.get("cleanliness", 0)), "Cleaning improves cleanliness")
	_assert(int(after_clean.get("review_risk", 100)) < before_review, "Clean duties reduce review risk")

	var before_issue_speed = float(after_clean.get("speed", 0.0))
	store_ops.trigger_minor_issue("fryer_timer_drift")
	var after_issue = store_ops.get_shift_effects()
	_assert(str(after_issue.get("equipment_issue_active", "")) == "fryer_timer_drift", "Minor equipment issue becomes active")
	_assert(float(after_issue.get("speed", 0.0)) < before_issue_speed, "Equipment issue slows shift")
	_assert(int(after_issue.get("manager_trust", 100)) < int(after_clean.get("manager_trust", 100)), "Equipment issue affects manager trust")

	recovery.interact(player)
	var after_repair = store_ops.get_shift_effects()
	_assert(str(after_repair.get("equipment_issue_active", "")) == "", "Recovery station clears minor issue")
	_assert(float(after_repair.get("speed", 0.0)) > float(after_issue.get("speed", 0.0)), "Repair recovers shift speed")

	fryer.interact(player)
	var after_fryer = store_ops.get_shift_effects()
	_assert(int(after_fryer.get("fryer_health", 0)) >= int(after_repair.get("fryer_health", 0)), "Fryer check improves or preserves fryer health")

	_assert(store_ops.get_recap_entries().size() >= 6, "End-of-shift recap entries collect store duties")
	_assert(event_log.get_events_by_type("store_duty_completed").size() >= 6, "Store duty completions logged")
	_assert(event_log.get_events_by_type("store_issue_triggered").size() >= 1, "Store issue trigger logged")
	_assert(event_log.get_events_by_type("store_issue_repaired").size() >= 1, "Store issue repair logged")

	print("[PASS] Phase 5 runtime store operations check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
