extends Node
class_name VisualPolishManager

## The la la: replaces gray boxes with stylized cartoon materials.

func apply_cartoon_style(node: Node3D, color: Color):
	# We create a StandardMaterial3D with a "Toon" look
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.8
	mat.specular = 0.2
	
	# Use the "Diffuse" lighting for a flat, cartoonish feel
	mat.diffuse_mode = StandardMaterial3D.DIFFUSE_LAMBERT
	
	# Apply to all MeshInstances in the node
	for child in node.find_children("*", "MeshInstance3D"):
		child.material_override = mat

func apply_food_material(node: Node3D, food_type: String):
	var mat = StandardMaterial3D.new()
	match food_type:
		"Bun": mat.albedo_color = Color(0.8, 0.6, 0.4)
		"Patty": mat.albedo_color = Color(0.3, 0.2, 0.1)
		"Cheese": mat.albedo_color = Color(1.0, 0.8, 0.0)
		"Fries": mat.albedo_color = Color(1.0, 0. la 0.0)
		"Soda": mat.albedo_color = Color(0.4, 0.2, 0.1)
	
	for child in node.find_children("*", "MeshInstance3D"):
		child.material_override = mat
