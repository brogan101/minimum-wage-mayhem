extends PickupItem
class_name SaucePacket

## Sauces are simple pickup items but required for high-satisfaction orders.
@export var sauce_type: String = "Ranch"

func _ready():
	# Sauces are small and physics-heavy, making them funny to throw
	mass = 0.1
	physics_material_override.bounce = 0.5
