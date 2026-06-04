extends Node
class_name AssetFactory

## This class generates 3D meshes programmatically so no external files are needed.

func create_burger_mesh() -> Node3D:
	var root = Node3D.new()
	
	# Bottom Bun
	var bun_bottom = CSGBox3D.new()
	bun_bottom.size = Vector3(0.3, 0.08, 0.3)
	bun_bottom.position = Vector3(0, 0.04, 0)
	var bun_mat = StandardMaterial3D.new()
	bun_mat.albedo_color = Color(0.8, 0.6, 0.4)
	bun_bottom.material = bun_mat
	
	# Patty
	var patty = CSGBox3D.new()
	patty.size = Vector3(0.32, 0.06, 0.32)
	patty.position = Vector3(0, 0.1, 0)
	var patty_mat = StandardMaterial3D.new()
	patty_mat.albedo_color = Color(0.3, 0.2, 0.1)
	patty.material = patty_mat
	
	# Top Bun
	var bun_top = CSGBox3D.new()
	bun_top.size = Vector3(0.3, 0.12, 0.3)
	bun_top.position = Vector3(0, 0.20, 0) # Adjusted for height
	bun_top.material = bun_mat
	
	root.add_child(bun_bottom)
	root.add_child(patty)
	root.add_child(bun_top)
	
	return root

func create_cup_mesh() -> Node3D:
	var root = Node3D.new()
	var cup = CSGCylinder3D.new()
	cup.radius = 0.1
	cup.height = 0.3
	cup.position = Vector3(0, 0.15, 0)
	root.add_child(cup)
	return root

func create_car_mesh() -> Node3D:
	var root = Node3D.new()
	
	# Car Body
	var body = CSGBox3D.new()
	body.size = Vector3(2.0, 1.0, 4.0)
	body.position = Vector3(0, 0.5, 0)
	
	# Car Top
	var top = CSGBox3D.new()
	top.size = Vector3(1.8, 0.8, 2.0)
	top.position = Vector3(0, 1.2, -0.5)
	
	# Wheels
	for x in [-1, 1]:
		for z in [-1, 1]:
			var wheel = CSGCylinder3D.new()
			wheel.radius = 0.3
			wheel.height = 0.2
			wheel.rotation_degrees = Vector3(0, 0, 90)
			wheel.position = Vector3(x, 0.3, z)
			root.add_child(wheel)
			
	root.add_child(body)
	root.add_child(top)
	return root
