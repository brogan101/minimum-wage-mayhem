extends Node
class_name FoodAssembler

## Handles physical merging of food items into composed food objects.

static func attempt_merge(item_a: PickupItem, item_b: PickupItem) -> PickupItem:
	if not (item_a is FoodItem and item_b is FoodItem):
		return null
	var name_a := item_a.name.to_lower()
	var name_b := item_b.name.to_lower()
	if ("bun" in name_a and "patty" in name_b) or ("patty" in name_a and "bun" in name_b):
		return create_burger(item_a, item_b)
	if (("burger" in name_a) and "cheese" in name_b) or (("burger" in name_b) and "cheese" in name_a):
		return add_cheese(item_a, item_b)
	return null

static func create_burger(a: PickupItem, b: PickupItem) -> PickupItem:
	var burger := CustomizableFood.new()
	burger.name = "Burger"
	burger.item_name = "Burger"
	burger.global_position = (a.global_position + b.global_position) / 2.0
	var parent := a.get_parent()
	if parent:
		parent.add_child(burger)
	burger.add_component("Bun")
	burger.add_component("Patty")
	if typeof(JuiceManager) != TYPE_NIL:
		JuiceManager.trigger_pop(burger)
	if typeof(AudioManager) != TYPE_NIL:
		AudioManager.play_sfx("merge_pop")
	a.queue_free()
	b.queue_free()
	return burger

static func add_cheese(a: PickupItem, b: PickupItem) -> PickupItem:
	var burger: PickupItem = a if a is CustomizableFood else b
	var cheese: PickupItem = b if a is CustomizableFood else a
	if burger is CustomizableFood:
		(burger as CustomizableFood).add_component("Cheese")
		cheese.queue_free()
		return burger
	return null
