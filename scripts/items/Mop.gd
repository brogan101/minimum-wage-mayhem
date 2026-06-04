extends PickupItem
class_name Mop

## The Mop: A physical tool used to clean spills.

@export var cleaning_power: float = 0.5

func interact_with_spill(spill: Spill):
	spill.reduce_size(cleaning_power)
	print("Cleaning up the mess...")
	EventLog.log_event("Cleaning", 1, "Spill")
	if spill.size <= 0:
		spill.queue_free()
