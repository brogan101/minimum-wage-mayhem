extends Node
## AudioManager handles sound hooks without crashing when final audio files are missing.

var sfx_paths = {
	"sizzle": "res://assets/audio/sizzle.wav",
	"ding": "res://assets/audio/order_ding.wav",
	"crash": "res://assets/audio/item_drop.wav",
	"angry_customer": "res://assets/audio/customer_yell.wav",
	"customer_yell": "res://assets/audio/customer_yell.wav",
	"cash_register": "res://assets/audio/cha_ching.wav",
	"interact": "res://assets/audio/interact.wav",
	"pickup": "res://assets/audio/pickup.wav",
	"drop": "res://assets/audio/item_drop.wav",
	"order_received": "res://assets/audio/order_ding.wav",
	"correct_handoff": "res://assets/audio/cha_ching.wav",
	"wrong_handoff": "res://assets/audio/customer_yell.wav",
	"task_complete": "res://assets/audio/task_complete.wav",
	"shift_start": "res://assets/audio/shift_start.wav",
	"shift_end": "res://assets/audio/shift_end.wav"
}

func play_sfx(sound_name: String, position: Vector3 = Vector3.ZERO):
	if not sfx_paths.has(sound_name):
		print("Sound hook missing: ", sound_name)
		return
	var path = sfx_paths[sound_name]
	if not ResourceLoader.exists(path):
		print("Audio fallback: missing file for hook '", sound_name, "': ", path)
		return
	var stream = load(path)
	if stream == null:
		print("Audio failed to load: ", path)
		return
	var player = AudioStreamPlayer3D.new()
	player.stream = stream
	player.global_position = position
	get_tree().root.add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
