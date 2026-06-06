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
	_assert(menu != null and menu.visible, "New player starts at main menu")
	_assert(hud != null and not hud.visible, "HUD is hidden before New Game")

	main.start_new_game()
	await process_frame
	await create_timer(1.0, true).timeout

	var player = root.find_child("Player", true, false)
	var interaction = player.get_node_or_null("InteractionHandler") if player else null
	var drive_thru = root.find_child("DriveThruStation", true, false)
	var burger = root.find_child("TrainingBurger", true, false)
	var order_manager = root.get_node_or_null("OrderManager")
	_assert(player != null and interaction != null, "Player and interaction handler exist")
	_assert(drive_thru != null and drive_thru.get_node_or_null("HandOffArea") != null, "Drive-thru has real handoff area")
	_assert(burger != null and order_manager != null, "First-shift burger/order actors exist")
	_assert(_action_has_key("interact", KEY_E), "Keyboard interact uses E")
	_assert(_action_has_key("pickup_drop", KEY_Q), "Keyboard drop uses Q")
	_assert(not _action_has_key("pickup_drop", KEY_E), "E no longer doubles as drop while holding food")
	_assert(_action_has_joy_button("interact", JOY_BUTTON_A), "Controller interact uses A")
	_assert(_action_has_joy_button("pickup_drop", JOY_BUTTON_X), "Controller drop uses X")

	if order_manager.current_order.is_empty():
		order_manager.generate_new_order()
	interaction.grab_item(burger)
	_assert(interaction.carried_item == burger, "Pickup updates carried item")
	var used = interaction.use_carried_item_on(drive_thru)
	await process_frame
	await create_timer(0.3, true).timeout
	_assert(used, "Held food can be used on the drive-thru station")
	_assert(interaction.carried_item == null, "Successful handoff clears held item")
	_assert(order_manager.orders_completed >= 1, "Drive-thru order completes through player interaction path")
	_assert(hud.station_feedback_label.text.contains("Correct") or hud.station_feedback_label.text.contains("delivered"), "Handoff feedback is visible")

	order_manager.generate_new_order()
	drive_thru.interact(player)
	await process_frame
	_assert(hud.station_feedback_label.text.contains("Bring the ticket item"), "Empty handoff gives recovery feedback")

	var controllers = Input.get_connected_joypads()
	if controllers.is_empty():
		print("[WARN] No physical controller detected; InputMap only was checked")
	else:
		print("[PASS] Physical controller detected: " + str(controllers))

	print("[PASS] Phase 22 manual playtest feel smoke check passed")
	quit(0)

func _action_has_key(action_name: String, keycode: int) -> bool:
	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey and event.keycode == keycode:
			return true
	return false

func _action_has_joy_button(action_name: String, button_index: int) -> bool:
	for event in InputMap.action_get_events(action_name):
		if event is InputEventJoypadButton and event.button_index == button_index:
			return true
	return false

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
