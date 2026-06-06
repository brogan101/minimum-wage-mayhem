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
	await create_timer(2.4, true).timeout

	var player = root.find_child("Player", true, false)
	var interaction = player.get_node_or_null("InteractionHandler") if player else null
	var bagging = root.find_child("BaggingTableStation", true, false)
	var grill = root.find_child("GrillStation", true, false)
	var fryer = root.find_child("FryerCheckStation", true, false)
	var drink = root.find_child("DrinkFillStation", true, false)
	var drive_thru = root.find_child("DriveThruStation", true, false)
	var hud = root.find_child("GameHUD", true, false)
	var order_manager = root.get_node_or_null("OrderManager")
	var beef = root.get_node_or_null("BeefManager")
	var wallet = root.get_node_or_null("WalletManager")
	var career = root.get_node_or_null("CareerManager")
	var shift_results = root.get_node_or_null("ShiftResultManager")
	var save_system = root.get_node_or_null("SaveSystem")
	var event_log = root.get_node_or_null("EventLog")

	_assert(player != null and interaction != null, "Player interaction exists")
	_assert(bagging != null and grill != null and fryer != null and drink != null and drive_thru != null, "Prep, drink, fryer, and drive-thru stations exist")
	_assert(order_manager != null and beef != null and wallet != null and career != null, "Order, Beef, wallet, and career managers exist")
	_assert(hud != null and shift_results != null and save_system != null and event_log != null, "HUD, shift results, save, and event log exist")
	_assert(not order_manager.current_order.is_empty(), "First customer creates an active ticket")
	_assert(order_manager.get_current_order_summary().contains("Ticket #"), "Order ticket summary shows ticket number")
	_assert(hud.order_title_label.text.contains("TICKET #"), "HUD order ticket shows ticket number")
	_assert(hud.customer_status_label.text.contains("Patience"), "HUD shows customer patience")

	bagging.interact(player)
	await process_frame
	var first_bag = interaction.get("carried_item")
	_assert(_is_bag(first_bag), "Bagging station gives the player an order bag")
	grill.interact(player)
	await process_frame
	_assert(first_bag.contained_items.has("Burger"), "Grill adds Burger to carried bag")
	drive_thru.interact(player)
	await process_frame
	await create_timer(0.3, true).timeout
	_assert(order_manager.orders_completed >= 1, "Bagged Burger completes the first ticket")
	_assert(interaction.get("carried_item") == null, "Successful handoff clears carried bag")
	_assert(wallet.balance > 0.0, "Correct handoff pays cash and tips")
	_assert(career.current_xp > 0.0, "Correct handoff grants XP")

	order_manager.generate_new_order("Lunch Driver")
	await process_frame
	bagging.interact(player)
	await process_frame
	var combo_bag = interaction.get("carried_item")
	grill.interact(player)
	await process_frame
	var beef_before = float(beef.get("current_beef"))
	drive_thru.interact(player)
	await process_frame
	await create_timer(0.3, true).timeout
	_assert(order_manager.orders_failed >= 1, "Incomplete combo handoff records a mistake")
	_assert(not order_manager.current_order.is_empty(), "Wrong order keeps the active ticket for retry")
	_assert(float(beef.get("current_beef")) > beef_before, "Wrong handoff raises visible Beef pressure")
	_assert(interaction.get("carried_item") == combo_bag, "Wrong handoff keeps the bag in hand for fixing")
	_assert(hud.station_feedback_label.text.contains("Missing Fries"), "HUD explains the missing item")
	fryer.interact(player)
	await process_frame
	_assert(combo_bag.contained_items.has("Fries"), "Fryer adds Fries to carried bag")
	drive_thru.interact(player)
	await process_frame
	await create_timer(0.3, true).timeout
	_assert(order_manager.orders_completed >= 2, "Fixed fries combo completes after retry")

	order_manager.generate_new_order("Thirsty Commuter")
	await process_frame
	bagging.interact(player)
	await process_frame
	var soda_bag = interaction.get("carried_item")
	grill.interact(player)
	drink.interact(player)
	await process_frame
	_assert(soda_bag.contained_items.has("Soda"), "Drink station adds Soda to carried bag")
	drive_thru.interact(player)
	await process_frame
	await create_timer(0.3, true).timeout
	_assert(order_manager.orders_completed >= 3, "Soda combo completes through the drive-thru")
	_assert(order_manager.get_tips_earned() > 0, "Order tips are tracked")
	_assert(order_manager.get_order_accuracy() < 1.0, "Mistake affects order accuracy")

	var report = shift_results.complete_shift({"completed": order_manager.orders_completed, "cash": wallet.balance})
	var result = shift_results.get_last_result_data()
	var save_data = save_system.get_last_save_data()
	var loaded = save_system.load_game()
	_assert(report.contains("Order Accuracy:"), "Recap shows order accuracy")
	_assert(report.contains("Tips:"), "Recap shows tips")
	_assert(report.contains("XP Earned:"), "Recap shows XP")
	_assert(report.contains("Mistakes:"), "Recap shows mistakes")
	_assert(report.contains("Funniest/Most Notable Moment:"), "Recap keeps notable event")
	_assert(int(result.get("customers_served", 0)) >= 3, "Result tracks multiple served customers")
	_assert(int(result.get("order_mistakes", 0)) >= 1, "Result tracks order mistakes")
	_assert(save_data.get("last_shift", {}).get("customers_served", 0) >= 3, "Save stores deeper shift result")
	_assert(not loaded.is_empty() and loaded.has("last_shift"), "Save/load still works after deeper gameplay")
	_assert(event_log.get_events_by_type("food_bag_item_added").size() >= 3, "Bagging events are logged")

	print("[PASS] Phase 23 core gameplay depth check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _is_bag(item: Object) -> bool:
	return item != null and item.get("contained_items") != null and item.has_method("add_item")

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
