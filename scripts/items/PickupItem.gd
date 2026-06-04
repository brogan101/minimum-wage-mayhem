extends RigidBody3D
class_name PickupItem

## Enhanced PickupItem with physics material integration.

@export var item_name: String = "Generic Item"
@export var is_food: bool = false
@export var reset_height: float = -5.0

var spawn_transform: Transform3D
var has_spawn_transform := false

func _ready():
	contact_monitor = true
	max_contacts_reported = 1
	spawn_transform = global_transform
	has_spawn_transform = true
	
	# Assign physics material based on item type
	apply_physics_material()

func _physics_process(_delta):
	if has_spawn_transform and global_position.y < reset_height:
		reset_to_spawn()

func apply_physics_material():
	if "Sauce" in name:
		physics_material_override = _make_physics_material(0.3, 0.8)
	elif "Slippery" in name:
		physics_material_override = _make_physics_material(0.05, 0.1)
	else:
		physics_material_override = _make_physics_material(0.5, 0.2)

func reset_to_spawn():
	freeze = true
	global_transform = spawn_transform
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze = false
	var event_log = get_tree().root.get_node_or_null("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event("pickup_item_reset", 0.0, item_name)

func _make_physics_material(friction: float, bounce: float) -> PhysicsMaterial:
	var mat = PhysicsMaterial.new()
	mat.friction = friction
	mat.bounce = bounce
	return mat
