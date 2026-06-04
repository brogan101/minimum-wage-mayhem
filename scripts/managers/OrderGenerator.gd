extends Node
## Depth: Re-implementing OrderGenerator to use weighted complexity.

signal order_generated(order_data)

var archetypes = {
	"GymBro": {"weights": {"Burger": 10, "Salad": 30, "Soda": 5}, "modifiers": ["No Bun", "Extra Patty"], "patience": 0.7},
	"Influencer": {"weights": {"Burger": 5, "FancyFries": 20, "Sodas": 20}, "modifiers": ["Extra Sauce", "Aesthetic Plating"], "patience": 0.5},
	"CouponWarrior": {"weights": {"ValueMeal": 50, "Soda": 10}, "modifiers": ["Discounted"], "patience": 0.3},
	"Standard": {"weights": {"Burger": 20, "Fries": 20, "Soda": 20}, "modifiers": [], "patience": 1.0}
}

func generate_order():
	var type = archetypes.keys().pick_random()
	var data = archetypes[type]
	
	var order_items = []
	var item_count = randi_range(1, 3)
	
	for i in range(item_count):
		var item = select_weighted_item(data["weights"])
		var mods = []
		if not data["modifiers"].is_empty() and randf() < 0.5:
			mods.append(data["modifiers"].pick_random())
		
		order_items.append({"item": item, "modifiers": mods})
	
	var final_order = {
		"customer_type": type,
		"items": order_items,
		"patience": data["patience"],
		"complexity": order_items.size()
	}
	
	order_generated.emit(final_order)
	return final_order

func select_weighted_item(weights: Dictionary) -> String:
	var total = 0
	for w in weights.values(): total += w
	var roll = randi() % total
	var current = 0
	for item in weights:
		current += weights[item]
		if roll < current: return item
	return "Burger"
