extends "res://scripts/stations/Interactable.gd"
class_name ClockOutStation

@export var clock_out_text: String = "Clock out / end shift"

func _ready():
	interact_text = clock_out_text

func interact(player: Node3D):
	super.interact(player)
	var hud = get_tree().root.find_child("GameHUD", true, false)
	if hud and hud.has_method("set_station_feedback"):
		hud.set_station_feedback("Clocked out. Shift recap opening.")
	var audio = get_tree().root.get_node_or_null("AudioManager")
	if audio and audio.has_method("play_sfx"):
		audio.play_sfx("shift_end")
	var main = get_tree().root.find_child("Main", true, false)
	if main and main.has_method("end_current_shift"):
		main.end_current_shift()
