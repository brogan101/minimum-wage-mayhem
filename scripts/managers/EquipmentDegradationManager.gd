extends Node
class_name EquipmentDegradationManager

## The la la: Machines that get 'gunked up' and need cleaning.

var equipment_health = {
	"Fryer": 100.0,
	"Grill": 100.0,
	"SodaMachine": 100.0
}

func degrade_equipment(machine_id: String, amount: float):
	if equipment_health.has(machine_id):
		equipment_health[machine_id] -= amount
		
		if equipment_health[machine_id] < 30:
			trigger_malfunction(machine_id)

func trigger_malfunction(machine_id: String):
	print("⚠️ MALFUNCTION: The ", machine_id, " is gunked up!")
	# Link to ChaosDirector to spawn a 'Slippery' spill or 'Sizzle' fire
	if machine_id == "SodaMachine":
		ChaosEngine.trigger_soda_spray()
	elif machine_id == "Fryer":
		ChaosEngine.trigger_fryer_overheat()
