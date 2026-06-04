extends Node
## The Life Cycle: Connecting the Apartment to the Shift.

func prepare_for_shift(player_stats: Dictionary):
	var modifiers = {}
	
	# Energy -> Movement Speed and Drop Rate
	if player_stats["Energy"] < 30:
		modifiers["speed"] = 0.7
		modifiers["drop_chance"] = 0.2
		print("You are exhausted. You'll move slower and drop things.")
	
	# Mood -> Tip Potential and Beef Growth
	if player_stats["Mood"] < 30:
		modifiers["beef_growth"] = 1.5
		modifiers["tip_chance"] = 0.5
		print("You're in a foul mood. Customers can smell it.")
	
	# Composure -> Breakdown Threshold
	if player_stats["Stress"] > 70:
		modifiers["breakdown_threshold"] = 50
		print("You're on the edge. A single rude customer might break you.")
		
	return modifiers
