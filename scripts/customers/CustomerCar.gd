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
	_apply_phase21_cartoon_details()
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
	var order_data = {}
	if order_manager and order_manager.has_method("generate_new_order"):
		order_data = order_manager.generate_new_order(customer_type)
		if typeof(order_data) == TYPE_DICTIONARY and order_data.has("customer_type"):
			customer_type = str(order_data.get("customer_type", customer_type))
		_set_order_bubble(order_manager.get_current_order_summary() if order_manager.has_method("get_current_order_summary") else "ORDER READY")
	var hud = get_tree().root.find_child("GameHUD", true, false)
	if hud and hud.has_method("set_customer_status"):
		var patience = int(float(order_data.get("patience", 0.85)) * 100.0) if typeof(order_data) == TYPE_DICTIONARY else 85
		hud.set_customer_status(customer_type + " waiting at DRIVE-THRU. Patience " + str(patience) + "%.")
	var event_log = _autoload("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event("customer_car_waiting", 1.0, customer_type)

func leave_restaurant():
	waiting_for_order = false
	var tween = create_tween()
	tween.tween_property(self, "global_position", start_position + Vector3(20, 0, 0), 3.0)
	tween.finished.connect(queue_free)

func _on_order_fulfilled(success: bool, _reward: int):
	if waiting_for_order and success:
		_set_order_bubble("THANKS")
		leave_restaurant()
	elif waiting_for_order:
		_set_order_bubble("TRY AGAIN\nCHECK TICKET")

func _apply_customer_variant():
	var variants = [
		{"label": "Regular", "node": "BodyRed", "color": "red"},
		{"label": "Lunch Driver", "node": "BodyBlue", "color": "blue"},
		{"label": "Thirsty Commuter", "node": "BodyYellow", "color": "yellow"},
		{"label": "Coupon Skeptic", "node": "BodyGreen", "color": "green"},
		{"label": "Night Nurse", "node": "BodyBlue", "color": "blue"},
		{"label": "Parent Van", "node": "BodyYellow", "color": "yellow"},
		{"label": "Off-Duty Cook", "node": "BodyRed", "color": "red"}
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

func _apply_phase21_cartoon_details():
	var black = _mat("Car cartoon black", Color(0.03, 0.03, 0.035), 0.72)
	var glass = _mat("Car blue glass", Color(0.55, 0.82, 1.0), 0.38)
	var cream = _mat("Car headlight cream", Color(1.0, 0.92, 0.58), 0.45, Color(1.0, 0.85, 0.35, 1.0))
	var red = _mat("Car tail light red", Color(1.0, 0.08, 0.04), 0.55)
	var paper = _mat("Car order bubble paper", Color(1.0, 0.95, 0.8), 0.7)
	_add_detail_box("Phase21Windshield", Vector3(0.0, 0.72, -0.48), Vector3(0.95, 0.25, 0.06), glass)
	_add_detail_box("Phase21RearWindow", Vector3(0.0, 0.7, 0.27), Vector3(0.82, 0.22, 0.06), glass)
	_add_detail_box("Phase21FrontBumper", Vector3(0.0, -0.02, -1.14), Vector3(1.7, 0.14, 0.12), black)
	_add_detail_box("Phase21RearBumper", Vector3(0.0, -0.02, 1.14), Vector3(1.7, 0.14, 0.12), black)
	_add_detail_box("Phase21HeadlightL", Vector3(-0.48, 0.06, -1.22), Vector3(0.28, 0.14, 0.04), cream)
	_add_detail_box("Phase21HeadlightR", Vector3(0.48, 0.06, -1.22), Vector3(0.28, 0.14, 0.04), cream)
	_add_detail_box("Phase21TailLightL", Vector3(-0.5, 0.04, 1.22), Vector3(0.24, 0.12, 0.04), red)
	_add_detail_box("Phase21TailLightR", Vector3(0.5, 0.04, 1.22), Vector3(0.24, 0.12, 0.04), red)
	_add_detail_box("Phase21OrderBubbleCard", Vector3(0.0, 1.2, -0.55), Vector3(1.1, 0.55, 0.04), paper)
	if not get_node_or_null("Phase21OrderBubbleText"):
		var label = Label3D.new()
		label.name = "Phase21OrderBubbleText"
		label.text = "1 BURGER\nPLEASE"
		label.position = Vector3(0.0, 1.2, -0.5)
		label.font_size = 22
		label.pixel_size = 0.008
		label.modulate = Color(0.06, 0.05, 0.04)
		label.outline_size = 2
		label.outline_modulate = Color(1.0, 0.94, 0.76)
		add_child(label)

func _set_order_bubble(text: String):
	var label = get_node_or_null("Phase21OrderBubbleText")
	if label:
		label.text = text.replace("Ticket #", "#")

func _add_detail_box(node_name: String, pos: Vector3, size: Vector3, mat: Material):
	if get_node_or_null(node_name):
		return
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = pos
	var box = BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.set_surface_override_material(0, mat)
	add_child(mesh_instance)

func _mat(resource_name: String, color: Color, roughness: float = 0.75, emission: Color = Color(0, 0, 0, 0)) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.resource_name = resource_name
	mat.albedo_color = color
	mat.roughness = roughness
	if emission.a > 0.0:
		mat.emission_enabled = true
		mat.emission = emission
		mat.emission_energy_multiplier = 0.2
	return mat

func _autoload(name: String) -> Node:
	return get_tree().root.get_node_or_null(name)
