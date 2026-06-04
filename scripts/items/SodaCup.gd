extends FoodItem
class_name SodaCup

## Sodas are filled at the DrinkStation, not cooked.
@export var is_filled: bool = false

func fill():
	is_filled = true
	update_visuals()
	print(name, " is now filled with sugary syrup!")

func update_visuals():
	var mesh = $MeshInstance3D if has_node("MeshInstance3D") else null
	if mesh:
		# Change color to represent liquid (e.g., Brown for Cola)
		mesh.set_instance_shader_parameter("albedo_color", Color.SADDLE_BROWN)
