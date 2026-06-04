extends Node
## ShadyManager (Autoload) tracks dishonest behavior.

signal shady_level_changed(new_level)
signal caught_by_corporate()

var shady_meter: float = 0.0
var detection_threshold: float = 50.0

func commit_shady_act(amount: float, act_description: String):
	shady_meter += amount
	shady_level_changed.emit(shady_meter)
	print("Shady Act: ", act_description, " | Shady Meter: ", shady_meter)
	
	# Chance to be caught increases as the meter rises
	if randf() * 100 < (shady_meter / 2):
		be_caught(act_description)

func be_caught(act: String):
	print("🚨 CAUGHT! Corporate noticed: ", act)
	caught_by_corporate.emit()
	# This would trigger a "Punishment" event (e.g., wearing the Shame Hat)
	shady_meter = 0 # Reset after being caught
