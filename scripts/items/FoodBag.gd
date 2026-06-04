extends PickupItem
class_name FoodBag

## A container that can hold multiple food items.

var contained_items: Array[String] = []

func _ready():
	# Set up an Area3D to detect food dropped into the bag
	var area = get_node_or_null("BagArea")
	if area:
		area.body_entered.connect(_on_food_entered)
	else:
		print("FoodBag missing BagArea; bagging will require manual station fallback.")

func _on_food_entered(body):
	if body is FoodItem:
		# 1. Snap the item to the center of the bag for a "clean" look
		body.global_position = self.global_position + Vector3(0, 0.1, 0)
		
		# 2. Add to logic
		var item_name = body.name.get_basename()
		if "Burger" in item_name:
			contained_items.append("Burger")
		elif "Fries" in item_name:
			contained_items.append("Fries")
		elif "Soda" in item_name:
			contained_items.append("Soda")
		
		print("Bagged: ", item_name, " | Current Bag: ", contained_items)
		
		# 3. Remove physical object
		body.queue_free()
