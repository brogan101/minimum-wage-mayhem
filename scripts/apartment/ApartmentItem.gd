extends StaticBody3D
class_name ApartmentItem

## Base class for objects in the 3D Apartment Hub.

@export var item_name: String = "Furniture"
@export var cost: float = 0.0
@export var stat_impact: Dictionary = {} # e.g., {"Energy": 20.0}

func interact(player: Node3D):
	# When the player interacts with an apartment item (e.g., Bed)
	# it applies the stat impact to the StatManager.
	for stat in stat_impact:
		StatManager.update_stat(stat, stat_impact[stat])
	
	print("Used ", item_name, ". Feeling better!")
