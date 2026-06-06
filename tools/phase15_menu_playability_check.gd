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

	var menu = root.find_child("MainMenuUI", true, false)
	var hud = root.find_child("GameHUD", true, false)
	_assert(menu != null and menu.visible and menu.mode == "main", "Main menu is first playable screen")
	_assert(hud != null and not hud.visible, "HUD is hidden at menu")

	menu.show_controls()
	_assert(menu.mode == "controls" and menu.body_label.text.contains("Keyboard") and menu.body_label.text.contains("Controller"), "Controls screen covers keyboard/mouse and controller")
	menu.show_settings()
	_assert(menu.mode == "settings", "Settings screen opens")
	menu._toggle_high_contrast()
	_assert(bool(menu.settings.get("high_contrast", false)), "Accessibility high contrast toggles")
	menu._cycle_performance()
	_assert(str(menu.settings.get("performance_mode", "")) in ["quality", "balanced", "performance"], "Performance setting cycles")
	menu.show_main_menu("checked")

	main.start_new_game()
	await process_frame
	var player = root.find_child("Player", true, false)
	var shift_manager = main.current_shift_manager
	_assert(player != null, "New game keeps player in 3D scene")
	_assert(hud.visible, "HUD appears during shift")
	_assert(shift_manager != null and bool(shift_manager.get("is_active")), "New game starts active shift")
	_assert(hud.objective_label.text.contains("DRIVE-THRU") and hud.objective_label.text.contains("Clock Out"), "HUD objective tracker is populated")
	_assert(hud.shift_timer_label.text.contains("Shift:"), "HUD shift timer is populated")

	main.pause_game()
	await process_frame
	_assert(menu.visible and menu.mode == "pause", "Pause menu opens")
	_assert(paused, "Pause menu pauses tree")
	main.resume_game()
	await process_frame
	_assert(not menu.visible and not paused, "Resume hides menu and unpauses")

	main.pause_game()
	main.save_game_from_menu()
	main.load_game_from_menu()
	_assert(menu.status_label.text.length() > 0, "Save/load UX reports status")
	main.resume_game()

	var drive_thru = root.find_child("DriveThruStation", true, false)
	var burger = root.find_child("TrainingBurger", true, false)
	var interaction = player.get_node_or_null("InteractionHandler")
	_assert(drive_thru != null and burger != null and interaction != null, "Order handoff actors exist")
	interaction.carried_item = burger
	burger.freeze = true
	drive_thru.interact(player)
	await process_frame
	await create_timer(0.3).timeout

	var order_manager = root.get_node_or_null("OrderManager")
	_assert(order_manager.orders_completed >= 1, "Playable order handoff still works after menu flow")
	main.end_current_shift()
	await process_frame
	_assert(menu.visible and menu.mode == "results", "End shift opens recap presentation")
	_assert(menu.body_label.text.contains("Customers Served:"), "Recap presents shift result text")

	var save_system = root.get_node_or_null("SaveSystem")
	var career = root.get_node_or_null("CareerManager")
	var save_data = save_system.get_last_save_data()
	_assert(save_data.get("last_shift", {}).get("customers_served", 0) >= 1, "Save UX keeps completed shift data")
	_assert(career.get_career_status().get("shift_performance_history", []).size() >= 1, "Progression works through menu flow")

	main.return_to_main_menu()
	await process_frame
	_assert(menu.visible and menu.mode == "main" and not hud.visible, "Return to menu works")
	main.continue_game()
	await process_frame
	_assert(hud.visible and main.game_started, "Continue/load starts playable shift")

	_assert(InputMap.action_get_events("pause").size() > 0, "Pause input mapping exists")
	_assert(InputMap.action_get_events("interact").size() > 0, "Interact input mapping exists")
	_assert(InputMap.action_get_events("move_forward").size() > 0, "Keyboard/controller movement mapping exists")

	print("[PASS] Phase 15 menu playability smoke check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
