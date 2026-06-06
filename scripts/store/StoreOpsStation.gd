extends "res://scripts/stations/Interactable.gd"
class_name StoreOpsStation

const FoodBagScript = preload("res://scripts/items/FoodBag.gd")

@export var duty_id: String = ""
@export var station_label: String = "Store ops station"
@export var repairs_issue: bool = false
@export var issue_id: String = ""

func _ready():
	interact_text = station_label

func interact(player: Node3D):
	var interaction = player.get_node_or_null("InteractionHandler") if player else null
	if _handle_food_prep(player, interaction):
		return
	super.interact(player)
	var director = get_tree().root.find_child("StoreOpsDirector", true, false)
	if not director:
		print(station_label + ": Store ops director missing.")
		return
	var status: Dictionary
	if repairs_issue:
		status = director.repair_issue(issue_id)
	else:
		status = director.complete_duty(duty_id)
	var feedback = director.get_station_feedback(duty_id) if director.has_method("get_station_feedback") else station_label
	var hud = get_tree().root.find_child("GameHUD", true, false)
	if hud and hud.has_method("set_interaction_prompt"):
		hud.set_interaction_prompt(feedback)
	if hud and hud.has_method("set_station_feedback"):
		hud.set_station_feedback(feedback)
	var audio = get_tree().root.get_node_or_null("AudioManager")
	if audio and audio.has_method("play_sfx"):
		audio.play_sfx("task_complete")
	print(station_label + ": " + str(status))

func _handle_food_prep(player: Node3D, interaction: Node) -> bool:
	if duty_id == "clear_bagging_table":
		return _handle_bagging_table(player, interaction)
	if duty_id == "check_fryer":
		return _handle_fryer(player, interaction)
	return false

func _handle_bagging_table(player: Node3D, interaction: Node) -> bool:
	if not interaction:
		return false
	var carried = interaction.get("carried_item")
	if carried == null:
		var empty_bag = _create_food_bag([])
		_grab_new_item(interaction, empty_bag)
		_complete_store_duty_once()
		_set_hud_feedback("Grabbed an empty bag. Add Burger, Fries, or Soda, then hand it off at DRIVE-THRU.")
		_log("food_bag_started", 1.0, "empty")
		return true
	if _is_food_bag(carried):
		if carried.has_method("seal_bag"):
			carried.seal_bag()
		_set_hud_feedback("Bag ready: " + _bag_summary(carried) + ". Take it to the green DRIVE-THRU mat.")
		_log("food_bag_checked", 1.0, _bag_summary(carried))
		return true
	var contents = _contents_from_item(carried)
	if contents.is_empty():
		return false
	var bag = _create_food_bag(contents)
	_replace_carried_item(interaction, carried, bag)
	_complete_store_duty_once()
	_set_hud_feedback("Bagged " + " + ".join(contents) + ". Add sides if the ticket asks, then DRIVE-THRU.")
	_log("food_item_bagged", 1.0, " + ".join(contents))
	return true

func _handle_fryer(player: Node3D, interaction: Node) -> bool:
	if not interaction:
		return false
	var carried = interaction.get("carried_item")
	if carried != null and _is_food_bag(carried):
		if carried.has_method("add_item") and carried.add_item("Fries"):
			_complete_store_duty_once()
			_set_hud_feedback("Fries added to bag. " + _bag_summary(carried))
			_log("fries_added_to_bag", 1.0, _bag_summary(carried))
		else:
			_set_hud_feedback("Fries are already in that bag. Check the ticket.")
		return true
	return false

func _create_food_bag(contents: Array) -> RigidBody3D:
	var bag = FoodBagScript.new()
	bag.name = "OrderBag"
	bag.item_name = "Order Bag"
	bag.mass = 0.2
	bag.freeze = true
	var mesh = MeshInstance3D.new()
	mesh.name = "MeshInstance3D"
	var box = BoxMesh.new()
	box.size = Vector3(0.42, 0.48, 0.22)
	mesh.mesh = box
	bag.add_child(mesh)
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.42, 0.48, 0.22)
	collision.shape = shape
	bag.add_child(collision)
	get_parent().add_child(bag)
	bag.global_position = global_position + Vector3(0.0, 0.75, 0.0)
	if bag.has_method("add_contents"):
		bag.add_contents(contents)
	if bag.has_method("seal_bag") and not contents.is_empty():
		bag.seal_bag()
	return bag

func _grab_new_item(interaction: Node, item: RigidBody3D):
	if interaction.has_method("grab_item"):
		interaction.grab_item(item)
	else:
		interaction.set("carried_item", item)

func _replace_carried_item(interaction: Node, old_item: Node, new_item: RigidBody3D):
	interaction.set("carried_item", null)
	if old_item and old_item.is_inside_tree():
		old_item.queue_free()
	_grab_new_item(interaction, new_item)

func _contents_from_item(item: Node) -> Array[String]:
	var contents: Array[String] = []
	if not item:
		return contents
	if _is_food_bag(item):
		var bag_contents = item.get("contained_items")
		if bag_contents != null:
			for entry in bag_contents:
				contents.append(str(entry))
		return contents
	var item_name = str(item.get("item_name") if item.get("item_name") != null else item.name)
	var lower = item_name.to_lower()
	if lower.contains("burger") or lower.contains("patty"):
		contents.append("Burger")
	elif lower.contains("fries") or lower.contains("fry"):
		contents.append("Fries")
	elif lower.contains("soda") or lower.contains("drink"):
		contents.append("Soda")
	return contents

func _is_food_bag(item: Object) -> bool:
	return item != null and item.get("contained_items") != null and item.has_method("add_item")

func _bag_summary(item: Object) -> String:
	if item and item.has_method("get_contents_summary"):
		return item.get_contents_summary()
	var bag_contents = item.get("contained_items") if item else []
	if bag_contents == null or bag_contents.is_empty():
		return "empty bag"
	var parts: Array[String] = []
	for entry in bag_contents:
		parts.append(str(entry))
	return " + ".join(parts)

func _complete_store_duty_once():
	var director = get_tree().root.find_child("StoreOpsDirector", true, false)
	if not director or not director.has_method("complete_duty"):
		return
	var status = director.get_shift_effects() if director.has_method("get_shift_effects") else {}
	var completed = status.get("completed_duties", {})
	if typeof(completed) == TYPE_DICTIONARY and completed.has(duty_id):
		return
	director.complete_duty(duty_id)

func _set_hud_feedback(text: String):
	var hud = get_tree().root.find_child("GameHUD", true, false)
	if hud and hud.has_method("set_station_feedback"):
		hud.set_station_feedback(text)
	if hud and hud.has_method("set_interaction_prompt"):
		hud.set_interaction_prompt(text)

func _log(event_name: String, value: float, detail: String):
	var event_log = get_tree().root.get_node_or_null("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event(event_name, value, detail)
