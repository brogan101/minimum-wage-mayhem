extends Node
## The "Breakdown" Logic: Modifying the 3D experience when composure hits 0.

signal breakdown_started()
signal hallucination_triggered(type)

func trigger_total_collapse(player: PlayerController):
	breakdown_started.emit()
	print("🚨 TOTAL COLLAPSE: You have lost all composure.")
	
	# 1. Modify Movement: The player now walks in random zig-zags
	player.set_meta("state", "BREAKDOWN")
	
	# 2. Visual Distortions: Trigger hallucinations
	var effects = ["DOUBLE_VISION", "FLOATING_BURGERS", "Screaming_Walls"]
	hallucination_triggered.emit(effects.pick_random())
	
	# 3. Gameplay Sabotage: Player begins bagging air
	# (Linked to the BaggingStation logic)
	
	# 4. Recovery: Only a coworker can "snap" the player out of it
	await get_tree().create_timer(10.0).timeout
	player.set_meta("state", "NORMAL")
	print("You've returned to reality. Back to work.")
