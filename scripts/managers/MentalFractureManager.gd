extends Node
## MentalFractureManager (Autoload) - Deepening the "Losing Your Mind" system.

signal hallucination_started(type)

enum FractureState { STABLE, STRESSED, FRACTURED, TOTAL_COLLAPSE }
var current_state = FractureState.STABLE

func update_fracture_state(composure: float):
	if composure > 70:
		current_state = FractureState.STABLE
	elif composure > 30:
		current_state = FractureState.STRESSED
	elif composure > 0:
		current_state = FractureState.FRACTURED
	else:
		current_state = FractureState.TOTAL_COLLAPSE
	
	if current_state == FractureState.FRACTURED:
		trigger_hallucination()

func trigger_hallucination():
	# Logic: a "Fractured" player begins to see the world differently.
	var effects = ["DOUBLE_BURGERS", "FLOATING_SODA", "Screaming_Walls"]
	var effect = effects.pick_random()
	hallucination_started.emit(effect)
	print("🚨 MENTAL FRACTURE: You are now seeing ", effect)

## This function would be called by the PlayerController to modify movement
func get_control_modifier() -> float:
	match current_state:
		FractureState.STABLE: return 1.0
		FractureState.STRESSED: return 0.9 # Slight jitter
		FractureState.FRACTURED: return 0.5 # Drunk-like movement
		FractureState.TOTAL_COLLAPSE: return 0.0 # Cannot move
	return 1.0
