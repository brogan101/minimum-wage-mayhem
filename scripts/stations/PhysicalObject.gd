extends Interactable
class_name PhysicalObject

## Base class for objects that have physical states (Doors, Drawers, Buttons).

@export var open_position: Vector3 = Vector3(0, 0, 0)
@export var closed_position: Vector3 = Vector3(0, 0, 0)
@export var is_open: bool = false
@export var interaction_sound: String = "click"

func interact(player: Node3D):
	toggle_state()

func toggle_state():
	is_open = !is_open
	var target_pos = open_position if is_open else closed_position
	
	# Physical movement: Tween the object to the new position
	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, 0.2).set_trans(Tween.TRANS_CUBIC)
	
	if AudioManager:
		AudioManager.play_sfx(interaction_sound)
	
	print(name, " is now ", "OPEN" if is_open else "CLOSED")
