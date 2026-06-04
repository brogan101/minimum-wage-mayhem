extends RigidBody3D
class_name CustomerCar

## A tiny visible customer car for the Phase 17 drive-thru demo loop.

@export var start_position: Vector3 = Vector3(-8.5, 0.45, -5.0)
@export var window_position: Vector3 = Vector3(-6.2, 0.45, -2.2)
@export var customer_type: String = "Standard"

var waiting_for_order := false
var active_color_name := "red"

func _ready():
	freeze = true
	global_position = start_position
	_apply_customer_variant()
	var order_manager = _autoload("OrderManager")
	if order_manager and order_manager.has_signal("order_fulfilled"):
		order_manager.order_fulfilled.connect(_on_order_fulfilled)
	call_deferred("drive_to_window")

func configure_route(start: Vector3, window: Vector3):
	start_position = start
	window_position = window
	if is_inside_tree():
		global_position = start_position
	else:
		position = start_position

func drive_to_window():
	var tween = create_tween()
	tween.tween_property(self, "global_position", window_position, 2.0)
	tween.finished.connect(_on_reached_window)

func _on_reached_window():
	waiting_for_order = true
	print("Customer car waiting at the drive-thru.")
	var order_manager = _autoload("OrderManager")
	if order_manager and order_manager.has_method("generate_new_order"):
		order_manager.generate_new_order()
	var hud = get_tree().root.find_child("GameHUD", true, false)
	if hud and hud.has_method("set_customer_status"):
		hud.set_customer_status(customer_type + " car waiting at the DRIVE-THRU window.")
	var event_log = _autoload("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event("customer_car_waiting", 1.0, customer_type)

func leave_restaurant():
	waiting_for_order = false
	var tween = create_tween()
	tween.tween_property(self, "global_position", start_position + Vector3(20, 0, 0), 3.0)
	tween.finished.connect(queue_free)

func _on_order_fulfilled(_success: bool, _reward: int):
	if waiting_for_order:
		leave_restaurant()

func _apply_customer_variant():
	var variants = [
		{"label": "Red sedan", "node": "BodyRed", "color": "red"},
		{"label": "Blue compact", "node": "BodyBlue", "color": "blue"},
		{"label": "Yellow hatchback", "node": "BodyYellow", "color": "yellow"},
		{"label": "Green coupe", "node": "BodyGreen", "color": "green"}
	]
	var selected = variants.pick_random()
	customer_type = str(selected["label"])
	active_color_name = str(selected["color"])
	var default_body = get_node_or_null("BodyMesh")
	if default_body:
		default_body.visible = false
	for variant in variants:
		var body = get_node_or_null(str(variant["node"]))
		if body:
			body.visible = str(variant["node"]) == str(selected["node"])

func _autoload(name: String) -> Node:
	return get_tree().root.get_node_or_null(name)
