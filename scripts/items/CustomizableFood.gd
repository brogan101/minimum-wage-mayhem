extends FoodItem
class_name CustomizableFood

## Depth: Food is no longer just "Cooked." It is a collection of physical components.

var current_components = [] # List of ingredients physically added (e.g., ["Bun", "Patty", "Cheese"])
var removed_components = [] # List of ingredients requested to be removed

func add_component(component_name: String):
	current_components.append(component_name)
	print(name, " now has ", component_name)
	update_visuals()

func remove_component(component_name: String):
	if current_components.has(component_name):
		current_components.erase(component_name)
		removed_components.append(component_name)
		update_visuals()

func validate_against_order(requested_item: String, requested_mods: Array):
	# Depth: Check if the physical components match the complex order algorithm
	if requested_item != self.item_name: return false
	
	for mod in requested_mods:
		if "No " in mod:
			var ingredient = mod.replace("No ", "")
			if current_components.has(ingredient):
				return false # Failed: It has an ingredient that should be removed
		if "Extra " in mod:
			var ingredient = mod.replace("Extra ", "")
			if current_components.count(ingredient) < 2:
				return false # Failed: Not enough of the extra ingredient
	
	return true
