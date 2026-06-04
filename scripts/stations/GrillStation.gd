extends "res://scripts/stations/CookingStation.gd"
class_name GrillStation

## Specialized Grill that might require flipping or have specific zones.

func interact(player: Node3D):
	print("Grill is sizzling hot!")
	super.interact(player)
