extends Interactable
class_name DrinkStation

## Physically filling a cup at the soda fountain.

func interact(player: Node3D):
	super.interact(player)
	# Check if the player is holding a SodaCup
	var interaction = player.get_node_or_null("InteractionHandler") if player else null
	if not interaction:
		print("Drink station missing player interaction handler.")
		return
	var carried = interaction.get("carried_item")
	if carried != null and _is_food_bag(carried):
		if carried.has_method("add_item") and carried.add_item("Soda"):
			_set_hud_feedback("Soda added to bag. " + _bag_summary(carried))
			_log("soda_added_to_bag", 1.0, _bag_summary(carried))
		else:
			_set_hud_feedback("Soda is already in that bag. Check the ticket.")
		return
	if carried is SodaCup:
		var cup = carried as SodaCup
		cup.fill()
		_set_hud_feedback("Soda cup filled. Bag it or hand it off if the ticket asks.")
		print("Sshhhhhhh... Soda filled!")
	else:
		_set_hud_feedback("Need an order bag or cup before using the soda machine.")
		print("You need a cup to use the drink machine!")

func _is_food_bag(item: Object) -> bool:
	return item != null and item.get("contained_items") != null and item.has_method("add_item")

func _bag_summary(item: Object) -> String:
	if item and item.has_method("get_contents_summary"):
		return item.get_contents_summary()
	return "order bag"

func _set_hud_feedback(text: String):
	var hud = get_tree().root.find_child("GameHUD", true, false)
	if hud and hud.has_method("set_station_feedback"):
		hud.set_station_feedback(text)

func _log(event_name: String, value: float, detail: String):
	var event_log = get_tree().root.get_node_or_null("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event(event_name, value, detail)
