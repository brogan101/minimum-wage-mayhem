extends CookingStation
class_name FryerStation

## Fryers have a higher risk of "Overheating" (Drama Event).

@export var overheat_chance: float = 0.05

func process_cooking(item: FoodItem, delta: float):
	# Roll for overheat event every second
	if randf() < overheat_chance:
		trigger_overheat()
	
	super.process_cooking(item, delta)

func trigger_overheat():
	print("🚨 CRITICAL FAILURE: The Fryer is overheating!")
	# Trigger gameplay consequence and burn food currently in the fryer
	for item in items_on_station:
		item.set_state(FoodItem.State.BURNT)
	
	if typeof(EventLog) != TYPE_NIL:
		EventLog.log_event("fryer_overheat", 1.0, name)
	var shift_manager = get_tree().root.find_child("ShiftManager", true, false)
	if shift_manager and shift_manager.has_method("report_incident"):
		shift_manager.report_incident("Fryer Overheat")
