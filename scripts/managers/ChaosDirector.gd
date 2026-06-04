extends Node
## ==============================================================================
## CLASS: ChaosDirector
## PURPOSE: Manages the "Chaos Budget" to trigger physical hazards and drama.
## LOGIC FLOW:
##   1. Budget grows over time based on player performance.
##   2. When budget hits threshold -> Pick random chaos event.
##   3. Execute physical change in world (e.g., spawn spill, overheat fryer).
## ==============================================================================

signal chaos_event_triggered(event_name)

var chaos_budget: float = 0.0
var budget_growth_rate: float = 0.1 
var player_performance_multiplier: float = 1.0

func _process(delta):
	chaos_budget += budget_growth_rate * delta * player_performance_multiplier
	if chaos_budget >= 10.0:
		trigger_random_chaos()

func trigger_random_chaos():
	var events = [
		{"name": "SODA_SPRAY", "cost": 10.0},
		{"name": "FRYER_OVERHEAT", "cost": 15.0},
		{"name": "EMPLOYEE_HIDING", "cost": 5.0},
		{"name": "BEEF_SPIKE", "cost": 8.0},
		{"name": "CORPORATE_CALL", "cost": 12.0}
	]
	var event = events.pick_random()
	chaos_budget -= event["cost"]
	
	match event["name"]:
		"SODA_SPRAY": trigger_soda_spray()
		"FRYER_OVERHEAT": trigger_fryer_overheat()
		"EMPLOYEE_HIDING": trigger_employee_disappearance()
		"BEEF_SPIKE": BeefManager.increase_beef(40, "Random Customer Outburst")
		"CORPORATE_CALL": CorporateManager.generate_shift_goal()
	
	chaos_event_triggered.emit(event["name"])

func trigger_soda_spray():
	var drink_stations = get_tree().get_nodes_in_group("drink_stations")
	if drink_stations.size() > 0:
		var station = drink_stations.pick_random()
		var spill = preload("res://scenes/world/Spill.tscn").instantiate()
		spill.global_position = station.global_position + Vector3(0, 0, 1)
		get_tree().root.add_child(spill)

func trigger_fryer_overheat():
	var fryers = get_tree().get_nodes_in_group("fryers")
	if fryers.size() > 0:
		var fryer = fryers.pick_random()
		fryer.trigger_overheat()

func trigger_employee_disappearance():
	var employees = get_tree().get_nodes_in_group("employees")
	if employees.size() > 0:
		var emp = employees.pick_random()
		emp.is_working = false
