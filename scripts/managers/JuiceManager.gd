extends Node
class_name JuiceManager

## The la la: Adding "Feel" to the game through visual and temporal feedback.

signal screen_shake_triggered(intensity, duration)

func trigger_shake(intensity: float, duration: float):
	# This would be connected to the Camera3D
	print("📳 SCREEN SHAKE: ", intensity, " for ", duration, "s")
	screen_shake_triggered.emit(intensity, duration)

func trigger_time_stop(duration: float):
	# Create a "Freeze Frame" effect for big failures or successes
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration, true).timeout
	Engine.time_scale = 1.0
	print("❄️ TIME STOP: Moment of impact!")

func trigger_pop(node: Node3D):
	# A "Juicy" scale animation for items being merged or bagged
	var tween = create_tween()
	var original_scale = node.scale
	tween.tween_property(node, "scale", original_scale * 1.2, 0.1)
	tween.tween_property(node, "scale", original_scale, 0.1)
	print("✨ POP: Item processed!")
