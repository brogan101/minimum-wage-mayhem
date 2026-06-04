extends Node
## ChaosEngine (Autoload) - Layers multiple modifiers to create "Unfair" shifts.

signal shift_modifier_active(mod_name, effect)

var active_modifiers = []

## List of potential "World Modifiers" that can stack
var possible_modifiers = {
	"SlipperyFloor": {"chance": 0.1, "effect": "Player movement speed -30%, higher drop rate"},
	"PowerBrownout": {"chance": 0.05, "effect": "Kitchen lights flicker, equipment randomly resets"},
	"CorporateSpy": {"chance": 0.05, "effect": "Shady Meter detection threshold halved"},
	"LunchRush": {"chance": 0.3, "effect": "Customer spawn rate x2, Beef rises faster"},
	"EmployeeStrike": {"chance": 0.02, "effect": "NPC coworkers stop working and stand in your way"}
}

func roll_for_chaos():
	# At the start of each shift, roll for 1-3 stacking modifiers
	var mod_count = randi_range(1, 3)
	active_modifiers.clear()
	
	for i in range(mod_count):
		var mod_id = possible_modifiers.keys().pick_random()
		active_modifiers.append(mod_id)
		shift_modifier_active.emit(mod_id, possible_modifiers[mod_id]["effect"])
		print("SHIFT MODIFIER ACTIVE: ", mod_id)

func get_modifier_multiplier(mod_name: String) -> float:
	if active_modifiers.has(mod_name):
		return 0.5 # Example: 50% speed if SlipperyFloor is active
	return 1.0
