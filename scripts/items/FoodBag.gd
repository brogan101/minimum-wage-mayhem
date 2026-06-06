extends PickupItem
class_name FoodBag

## A container that can hold multiple food items.

var contained_items: Array[String] = []
var is_sealed: bool = false

func _ready():
	super._ready()
	# Set up an Area3D to detect food dropped into the bag
	var area = get_node_or_null("BagArea")
	if area and not area.body_entered.is_connected(_on_food_entered):
		area.body_entered.connect(_on_food_entered)
	_refresh_item_name()

func _on_food_entered(body):
	if body is FoodItem:
		# 1. Snap the item to the center of the bag for a "clean" look
		body.global_position = self.global_position + Vector3(0, 0.1, 0)
		
		# 2. Add to logic
		var item_name = body.name.get_basename()
		add_item(item_name)
		
		print("Bagged: ", item_name, " | Current Bag: ", contained_items)
		
		# 3. Remove physical object
		body.queue_free()

func add_item(raw_item_name: String) -> bool:
	var normalized = _normalize_item(raw_item_name)
	if normalized == "":
		return false
	if contained_items.has(normalized):
		return false
	contained_items.append(normalized)
	is_sealed = false
	_refresh_item_name()
	_update_visuals()
	var event_log = get_tree().root.get_node_or_null("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event("food_bag_item_added", 1.0, normalized)
	return true

func add_contents(items: Array) -> int:
	var added := 0
	for item in items:
		if add_item(str(item)):
			added += 1
	return added

func seal_bag():
	is_sealed = true
	_refresh_item_name()
	_update_visuals()

func get_contents_summary() -> String:
	if contained_items.is_empty():
		return "empty bag"
	return " + ".join(contained_items)

func has_item(item_name_to_check: String) -> bool:
	return contained_items.has(_normalize_item(item_name_to_check))

func _normalize_item(raw_item_name: String) -> String:
	var lower = raw_item_name.to_lower()
	if lower.contains("burger") or lower.contains("patty"):
		return "Burger"
	if lower.contains("fries") or lower.contains("fry"):
		return "Fries"
	if lower.contains("soda") or lower.contains("drink") or lower.contains("cup"):
		return "Soda"
	return ""

func _refresh_item_name():
	item_name = "Order Bag: " + get_contents_summary()

func _update_visuals():
	var mesh = get_node_or_null("MeshInstance3D")
	if not mesh:
		for child in get_children():
			if child is MeshInstance3D:
				mesh = child
				break
	if not mesh:
		return
	var mat = StandardMaterial3D.new()
	if is_sealed:
		mat.albedo_color = Color(0.92, 0.7, 0.38)
	elif contained_items.is_empty():
		mat.albedo_color = Color(0.72, 0.52, 0.3)
	else:
		mat.albedo_color = Color(0.86, 0.64, 0.35)
	mesh.material_override = mat
