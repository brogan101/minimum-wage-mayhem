extends Node
class_name ExpansionManager
## ExpansionManager preserves future local business-module metadata without loading DLC or online systems.

signal location_unlocked(location_name: String)
signal location_mechanics_requested(location_name: String, mechanic_data: Dictionary)

var unlocked_locations: Array[String] = ["FastFoodDriveThru"]
var location_mechanics := {
	"FastFoodDriveThru": {"stations": ["grill", "fryer", "drink", "bagging", "window"], "status": "playable_base"},
	"CoffeeShop": {"stations": ["espresso", "foam", "pastry_case", "pickup_counter"], "status": "future_local_module_schema"},
	"PizzaShop": {"stations": ["dough", "sauce", "oven", "cut_box"], "status": "future_local_module_schema"}
}

func unlock_location(location_name: String) -> void:
	if not unlocked_locations.has(location_name):
		unlocked_locations.append(location_name)
		emit_signal("location_unlocked", location_name)
		if typeof(EventLog) != TYPE_NIL:
			EventLog.log_event("location_unlocked", 0.0, location_name)

func load_location_mechanics(location_name: String) -> Dictionary:
	var mechanics: Dictionary = location_mechanics.get(location_name, location_mechanics["FastFoodDriveThru"])
	emit_signal("location_mechanics_requested", location_name, mechanics)
	return mechanics
