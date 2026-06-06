extends "res://scripts/stations/CookingStation.gd"
class_name GrillStation

## Specialized Grill that might require flipping or have specific zones.

func interact(player: Node3D):
	var interaction = player.get_node_or_null("InteractionHandler") if player else null
	var carried = interaction.get("carried_item") if interaction else null
	if carried != null and _is_food_bag(carried):
		if carried.has_method("add_item") and carried.add_item("Burger"):
			_set_hud_feedback("Burger added to bag. Check the ticket for fries or soda, then DRIVE-THRU.")
			_log("burger_added_to_bag", 1.0, _bag_summary(carried))
		else:
			_set_hud_feedback("Burger is already in that bag. Check the ticket.")
		return
	print("Grill is sizzling hot!")
	super.interact(player)

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
