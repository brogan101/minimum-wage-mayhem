extends Node
## BeefBattleManager (Autoload) - Handles the "Conflict" mini-game.

signal battle_started(customer_name, beef_level)
signal battle_ended(winner, consequence)

enum BattleOutcome { CUSTOMER_SATIATED, CUSTOMER_HUMILIATED, EMPLOYEE_FIRED, CORPORATE_PROMOTION }

var active_battle_customer = ""

func start_conflict(customer: Node3D):
	active_battle_customer = customer.name
	battle_started.emit(active_battle_customer, 100.0)
	print("🚨 CONFLICT START: You are now in a verbal standoff with ", active_battle_customer)

## The player chooses a "Move" (Buzzword or Comeback)
func resolve_move(move_type: String, intensity: float):
	# ADVANCED COMBAT LOGIC: Combo system
	var player_streak = 0
	var beef_manager = _autoload("BeefManager")
	var stat_manager = _autoload("StatManager")
	
	if move_type == "BUZZWORD":
		# "The Corporate Shield" - Lowers beef but bores the staff
		if beef_manager and beef_manager.has_method("decrease_beef"):
			beef_manager.decrease_beef(20)
		if stat_manager and stat_manager.has_method("update_stat"):
			stat_manager.update_stat("Mood", -15)
		print("Succeeded in 'Corporate-Speak'. Customer is confused but calm.")
		return handle_outcome(BattleOutcome.CUSTOMER_SATIATED)
		
	elif move_type == "SAVAGE":
		# "The Nuclear Option" - High risk, high reward
		if randf() < 0.4: # 40% chance of "Critical Hit"
			print("CRITICAL HIT! The customer is speechless.")
			if stat_manager and stat_manager.has_method("update_stat"):
				stat_manager.update_stat("Mood", 30)
				stat_manager.update_stat("Reputation", 10)
			return handle_outcome(BattleOutcome.CUSTOMER_HUMILIATED)
		else:
			print("BACKFIRE! The customer is now recording you for TikTok.")
			if beef_manager and beef_manager.has_method("increase_beef"):
				beef_manager.increase_beef(50, "Savage insult failed")
			return handle_outcome(BattleOutcome.EMPLOYEE_FIRED)
	
	return null

func handle_outcome(outcome: BattleOutcome):
	var beef_manager = _autoload("BeefManager")
	var stat_manager = _autoload("StatManager")
	match outcome:
		BattleOutcome.CUSTOMER_SATIATED:
			if beef_manager and beef_manager.has_method("decrease_beef"):
				beef_manager.decrease_beef(50)
			if stat_manager and stat_manager.has_method("update_stat"):
				stat_manager.update_stat("Mood", -10) # Being fake is draining
			battle_ended.emit("Customer", "Job Saved")
		BattleOutcome.CUSTOMER_HUMILIATED:
			if stat_manager and stat_manager.has_method("update_stat"):
				stat_manager.update_stat("Mood", 20) # Feeling like a boss
			battle_ended.emit("Player", "Emotional Victory")
		BattleOutcome.EMPLOYEE_FIRED:
			print("You said too much. You're fired.")
			battle_ended.emit("Corporate", "Termination")
	return outcome

func _autoload(name: String) -> Node:
	return get_tree().root.get_node_or_null(name)
