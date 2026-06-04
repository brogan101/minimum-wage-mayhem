extends Node
class_name LocationManager

## Local business-module framework. Fast food is the only playable module until MVP is stable.

enum LocationType { FAST_FOOD, COFFEE_SHOP, PIZZA_PARLOR, GAS_STATION }
var current_location = LocationType.FAST_FOOD

func load_location(type: LocationType):
	current_location = type
	print("Loading new location: ", LocationType.keys()[type])
	
	# 1. Clear existing world
	var world = get_tree().root.find_child("RestaurantWorld", true, false)
	if world: world.queue_free()
	
	# 2. Spawn new assets based on type
	match type:
		LocationType.FAST_FOOD:
			spawn_fast_food_layout()
		LocationType.COFFEE_SHOP:
			spawn_coffee_shop_layout()
		LocationType.PIZZA_PARLOR:
			spawn_pizza_layout()
	
	# 3. Update the OrderGenerator to use new menu items
	_update_menu_for_location(type)

func spawn_fast_food_layout():
	var world_gen = WorldGenerator.new()
	var restaurant = world_gen.generate_restaurant()
	get_tree().root.add_child(restaurant)

func spawn_coffee_shop_layout():
	print("Generating Coffee Shop layout... [Espresso Machines, Laptop Campers]")
	# Logic to spawn coffee-specific stations

func _update_menu_for_location(type):
	var menu_items: Array[String] = ["Burger", "Fries", "Soda"]
	match type:
		LocationType.COFFEE_SHOP:
			menu_items = ["Coffee", "Iced Coffee", "Pastry"]
		LocationType.PIZZA_PARLOR:
			menu_items = ["Slice", "Whole Pizza", "Soda"]
		LocationType.GAS_STATION:
			menu_items = ["Hot Dog", "Coffee", "Energy Drink"]
		_:
			menu_items = ["Burger", "Fries", "Soda"]
	if typeof(OrderGenerator) != TYPE_NIL and OrderGenerator.has_method("set_menu_items"):
		OrderGenerator.set_menu_items(menu_items)
	if typeof(EventLog) != TYPE_NIL:
		EventLog.log_event("location_menu_loaded", 0.0, ",".join(menu_items))
