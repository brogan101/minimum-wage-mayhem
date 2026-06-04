extends CharacterBody3D
class_name PlayerController

## Handles 3D movement, mouse look, and controller-compatible action-based input.

@export var walk_speed: float = 4.2
@export var sprint_speed: float = 6.5
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.0018
@export var controller_look_sensitivity: float = 2.1
@export var fall_reset_y: float = -8.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_speed = 4.2
var spawn_position := Vector3.ZERO

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

func _ready():
	spawn_position = global_position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	current_speed = sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if look_dir.length() > 0.05:
		rotate_y(-look_dir.x * controller_look_sensitivity * delta)
		head.rotate_x(-look_dir.y * controller_look_sensitivity * delta)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	move_and_slide()
	if global_position.y < fall_reset_y:
		_reset_to_spawn()

func _reset_to_spawn():
	global_position = spawn_position
	velocity = Vector3.ZERO
	var hud = get_tree().root.find_child("GameHUD", true, false)
	if hud and hud.has_method("set_station_feedback"):
		hud.set_station_feedback("Reset to start after falling out of bounds.")
