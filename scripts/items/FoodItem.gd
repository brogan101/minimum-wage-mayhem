extends "res://scripts/items/PickupItem.gd"
class_name FoodItem

enum State { RAW, COOKED, BURNT }
@export var current_state: State = State.RAW
@export var cook_time: float = 5.0
@export var burn_time: float = 10.0

func advance_cooking(delta: float):
	# Station-driven timer handles cooking; this method exists for compatibility.
	return

func set_state(new_state: State):
	if current_state == new_state:
		return
	current_state = new_state
	update_visuals()
	print(name, " is now ", State.keys()[new_state])
	var event_log = get_tree().root.get_node_or_null("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event("item_state_changed", float(new_state), name + ":" + State.keys()[new_state])

func update_visuals():
	var mesh = get_node_or_null("MeshInstance3D")
	if not mesh:
		for child in get_children():
			if child is MeshInstance3D:
				mesh = child
				break
	if not mesh:
		return
	var mat = StandardMaterial3D.new()
	match current_state:
		State.RAW:
			mat.albedo_color = Color(1.0, 0.45, 0.55)
		State.COOKED:
			mat.albedo_color = Color(0.45, 0.25, 0.1)
		State.BURNT:
			mat.albedo_color = Color(0.02, 0.02, 0.02)
	mesh.material_override = mat
