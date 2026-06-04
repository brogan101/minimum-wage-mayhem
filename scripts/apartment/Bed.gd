extends ApartmentItem
class_name Bed

## Specialized Apartment item for sleeping.

func _ready():
	item_name = "Bed"
	stat_impact = {"Energy": 50.0, "Stress": -20.0}

func interact(player: Node3D):
	super.interact(player)
	print("Zzzzz... You slept and recovered energy.")
