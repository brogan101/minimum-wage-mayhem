extends "res://scripts/stations/Interactable.gd"
class_name StoreOpsStation

@export var duty_id: String = ""
@export var station_label: String = "Store ops station"
@export var repairs_issue: bool = false
@export var issue_id: String = ""

func _ready():
	interact_text = station_label

func interact(player: Node3D):
	super.interact(player)
	var director = get_tree().root.find_child("StoreOpsDirector", true, false)
	if not director:
		print(station_label + ": Store ops director missing.")
		return
	var status: Dictionary
	if repairs_issue:
		status = director.repair_issue(issue_id)
	else:
		status = director.complete_duty(duty_id)
	var feedback = director.get_station_feedback(duty_id) if director.has_method("get_station_feedback") else station_label
	var hud = get_tree().root.find_child("GameHUD", true, false)
	if hud and hud.has_method("set_interaction_prompt"):
		hud.set_interaction_prompt(feedback)
	if hud and hud.has_method("set_station_feedback"):
		hud.set_station_feedback(feedback)
	var audio = get_tree().root.get_node_or_null("AudioManager")
	if audio and audio.has_method("play_sfx"):
		audio.play_sfx("task_complete")
	print(station_label + ": " + str(status))
