extends Control
class_name NotificationUI

## A simple popup system for game events.

func show_message(text: String, duration: float = 3.0):
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "position:y", -50, duration)
	tween.tween_property(label, "modulate:a", 0.0, duration)
	tween.finished.connect(func(): label.queue_free())
