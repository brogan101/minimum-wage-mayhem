extends "res://scripts/stations/Interactable.gd"
class_name DriveThruWindow

## The final hand-off point for the order.

@export var success_text: String = "Hand off order"
@export var empty_text: String = "Need order item"

func _ready():
	interact_text = success_text
	var area = get_node_or_null("HandOffArea")
	if not area:
		area = _create_handoff_area()
	if area and not area.body_entered.is_connected(_on_body_entered):
		area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	var contents = _contents_from_body(body)
	if not contents.is_empty():
		_deliver_contents(contents, body)

func interact(player: Node3D):
	var interaction = player.get_node_or_null("InteractionHandler") if player else null
	if not interaction or not interaction.get("carried_item"):
		_log("drive_thru_empty_handoff", 0.0, empty_text)
		_set_hud_feedback("Bring the ticket item here first, then press E / A.")
		print(empty_text)
		return
	var carried = interaction.get("carried_item")
	var contents = _contents_from_body(carried)
	if contents.is_empty():
		_log("drive_thru_invalid_item", 0.0, carried.name)
		_set_hud_feedback("That is not part of this order. Check the ticket.")
		print("That is not a valid order item.")
		return
	interaction.drop_item()
	_deliver_contents(contents, carried)

func _contents_from_body(body: Node) -> Array[String]:
	var contents: Array[String] = []
	if not body:
		return contents
	var bag_contents = body.get("contained_items")
	if bag_contents != null:
		for item in bag_contents:
			contents.append(str(item))
		return contents
	var item_name = str(body.get("item_name") if body.get("item_name") != null else body.name)
	if item_name.to_lower().contains("burger") or item_name.to_lower().contains("patty"):
		contents.append("Burger")
	elif item_name.to_lower().contains("fries"):
		contents.append("Fries")
	elif item_name.to_lower().contains("soda"):
		contents.append("Soda")
	return contents

func _deliver_contents(contents: Array[String], body: Node):
	var order_manager = _autoload("OrderManager")
	var beef = _autoload("BeefManager")
	var juice = _autoload("JuiceManager")
	var audio = _autoload("AudioManager")
	if not order_manager or not order_manager.has_method("validate_bag"):
		_log("drive_thru_missing_order_manager", 0.0, "OrderManager unavailable")
		return
	if order_manager.get("current_order") == null or order_manager.current_order.is_empty():
		if order_manager.has_method("generate_new_order"):
			order_manager.generate_new_order()
	var success = order_manager.validate_bag(contents)
	if success:
		if beef and beef.has_method("decrease_beef"):
			beef.decrease_beef(20)
		order_manager.fulfill_order(true)
		_set_hud_feedback("Correct order delivered at the drive-thru.")
		if juice and juice.has_method("trigger_pop"):
			juice.trigger_pop(self)
		if audio and audio.has_method("play_sfx"):
			audio.play_sfx("cash_register")
		_log("drive_thru_order_delivered", 1.0, ",".join(contents))
	else:
		if beef and beef.has_method("increase_beef"):
			beef.increase_beef(30, "Wrong order delivered")
		order_manager.fulfill_order(false)
		_set_hud_feedback("Wrong order. Check the ticket before handoff.")
		if juice and juice.has_method("trigger_shake"):
			juice.trigger_shake(1.0, 0.3)
		if audio and audio.has_method("play_sfx"):
			audio.play_sfx("customer_yell")
		_log("drive_thru_order_failed", 0.0, ",".join(contents))
	if body and body.is_inside_tree():
		_clear_carried_item_if_needed(body)
		body.queue_free()

func _create_handoff_area() -> Area3D:
	var area = Area3D.new()
	area.name = "HandOffArea"
	area.monitoring = true
	area.monitorable = true
	add_child(area)
	var collision = CollisionShape3D.new()
	collision.name = "HandOffAreaCollision"
	var shape = BoxShape3D.new()
	shape.size = Vector3(2.0, 1.5, 1.8)
	collision.shape = shape
	area.add_child(collision)
	return area

func _clear_carried_item_if_needed(body: Node):
	var interaction = get_tree().root.find_child("InteractionHandler", true, false)
	if interaction and interaction.get("carried_item") == body:
		interaction.set("carried_item", null)
		if interaction.has_method("_update_held_hud"):
			interaction._update_held_hud("")

func _autoload(name: String) -> Node:
	return get_tree().root.get_node_or_null(name)

func _log(event_name: String, value: float, detail: String):
	var event_log = _autoload("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event(event_name, value, detail)

func _set_hud_feedback(text: String):
	var hud = get_tree().root.find_child("GameHUD", true, false)
	if hud and hud.has_method("set_station_feedback"):
		hud.set_station_feedback(text)
