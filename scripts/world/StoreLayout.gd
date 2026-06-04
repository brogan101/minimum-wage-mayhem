extends Node
class_name StoreLayout

## The Physical Architecture: Precise 3D coordinates for the restaurant.
## This ensures the game is a physical space, not a menu.

var zones = {
	"DriveThruWindow": Vector3(10, 0, 0),
	"GrillStation": Vector3(-5, 0, -2),
	"FryerStation": Vector3(-3, 0, -2),
	"DrinkStation": Vector3(-1, 0, -2),
	"BaggingTable": Vector3(2, 0, -2),
	"ManagerOffice": Vector3(-8, 0, -8),
	"BreakRoom": Vector3(8, 0, -8),
	"Freezer": Vector3(-10, 0, -2),
	"ParkingLot": Vector3(0, 0, 10)
}

func get_zone_position(zone_name: String) -> Vector3:
	if zones.has(zone_name):
		return zones[zone_name]
	return Vector3.ZERO

func spawn_physical_boundary(world: Node3D):
	# Logic to actually place the CSG walls at these coordinates
	for zone in zones:
		print("Defining Physical Zone: ", zone, " at ", zones[zone])
