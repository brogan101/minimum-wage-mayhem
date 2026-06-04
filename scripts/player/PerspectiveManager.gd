extends Node3D
class_name PerspectiveManager

## This script physically controls the 3D camera and player visibility.

enum ViewMode { FIRST_PERSON, THIRD_PERSON }
var current_mode = ViewMode.FIRST_PERSON

var fp_camera: Camera3D = null
var tp_camera: Camera3D = null

func _ready():
	var player = get_parent()
	if not player:
		return
	fp_camera = player.get_node_or_null("Head/Camera3D")
	tp_camera = player.get_node_or_null("ThirdPersonRig/ThirdPersonCamera")
	_apply_view_mode()

func _input(event):
	if event.is_action_pressed("toggle_view") or event.is_action_pressed("toggle_perspective"):
		switch_view()

func switch_view():
	if current_mode == ViewMode.FIRST_PERSON:
		current_mode = ViewMode.THIRD_PERSON
	else:
		current_mode = ViewMode.FIRST_PERSON
	_apply_view_mode()
	print("View switched to: ", ViewMode.keys()[current_mode])

func _apply_view_mode():
	if fp_camera:
		fp_camera.current = current_mode == ViewMode.FIRST_PERSON
	if tp_camera:
		tp_camera.current = current_mode == ViewMode.THIRD_PERSON
