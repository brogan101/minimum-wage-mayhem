extends "res://scripts/stations/Interactable.gd"
class_name CoworkerNPC

@export var coworker_id: String = "riley"
@export var assigned_station: String = "grill"

func _ready():
	interact_text = "Ask " + coworker_id.capitalize() + " for help"

func interact(player: Node3D):
	super.interact(player)
	var director = get_tree().root.find_child("StaffDirector", true, false)
	if director and director.has_method("request_help"):
		director.request_help(coworker_id, assigned_station)
	if director and director.has_method("dialogue_for"):
		print(director.dialogue_for(coworker_id, "player_interaction"))
