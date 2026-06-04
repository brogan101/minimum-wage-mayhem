extends Node
class_name ScenarioManager

## The la la: Manages high-intensity, scripted "Boss Shifts."

signal scenario_started(title, goal)

func start_perfect_storm():
	print("🚨 SCENARIO: THE PERFECT STORM")
	# 1. Max out Chaos Budget immediately
	ChaosDirector.chaos_budget = 100.0
	ChaosDirector.budget_growth_rate = 0.5
	
	# 2. Force immediate failures
	ChaosEngine.trigger_event("SODA_SPRAY")
	ChaosEngine.trigger_event("FRYER_FIRE")
	
	# 3. Spawn the "Ultimate Customer" (Influencer + PTA Commander hybrid)
	spawn_boss_customer("The Mega-Karen")
	
	# 4. Set an impossible Corporate Mandate
	CorporateManager.set_manual_goal("Zero Mistakes", 0)
	
	print("Goal: Survive 5 minutes without getting fired.")

func start_hundred_car_challenge():
	print("🚨 SCENARIO: THE 100-CAR CHALLENGE")
	# 1. Massive increase in spawn rate
	CustomerManager.spawn_rate = 2.0 # 1 car every 2 seconds
	
	# 2. Remove the "Patience" buffer
	# All customers now have a Beef multiplier of 2.0
	BeefManager.global_beef_multiplier = 2.0
	
	print("Goal: Serve 100 cars before the timer hits zero.")

func spawn_boss_customer(type: String):
	# Logic to spawn a customer with maxed-out Beef and complex requirements
	var boss_order = {
		"customer_type": type,
		"items": [
			{"item": "Burger", "modifiers": ["No Bun", "Extra Cheese", "Well Done"]},
			{"item": "Soda", "modifiers": ["Light Ice", "Extra Syrup"]},
			{"item": "Fries", "modifiers": ["Double Salt", "Symmetric"]}
		],
		"patience": 0.1,
		"beef_multiplier": 3.0
	}
	OrderManager.set_current_order(boss_order)
