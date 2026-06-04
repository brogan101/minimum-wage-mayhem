extends StaticBody3D
class_name Interactable

## Base class for anything the player can interact with in the 3D world.

@export var interact_text: String = "Interact"

func interact(player: Node3D):
	var tutorial = get_tree().root.get_node_or_null("TutorialManager")
	if tutorial and tutorial.has_method("check_progress"):
		tutorial.check_progress("interact", self.name)
	var event_log = get_tree().root.get_node_or_null("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event("station_interacted", 1.0, name)
	print("Interacted with: ", name)
