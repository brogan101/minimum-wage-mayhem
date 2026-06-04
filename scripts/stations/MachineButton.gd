extends PhysicalObject
class_name MachineButton

## A button that triggers a specific machine action.

@export var action_id: String = "start_fryer"

func interact(player: Node3D):
	# Physical "Press" animation
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector3(0, -0.05, 0), 0.1)
	tween.tween_property(self, "position", position, 0.1)
	
	# Trigger the actual machine logic
	emit_signal("button_pressed", action_id)
	if AudioManager:
		AudioManager.play_sfx("button_press")
