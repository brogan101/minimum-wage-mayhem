extends Node
class_name WorldGenerator

## This script builds the entire 3D restaurant from scratch using code.

func generate_restaurant():
	var world = Node3D.new()
	world.name = "RestaurantWorld"
	var polish = VisualPolishManager.new()
	
	# 1. Create the Floor
	var floor = CSGBox3D.new()
	floor.size = Vector3(20, 0.1, 20)
	floor.position = Vector3(0, 0, 0)
	world.add_child(floor)
	polish.apply_cartoon_style(floor, Color(0.7, 0.7, 0.7)) # Concrete gray
	
	# 2. Create the Walls
	var wall_back = CSGBox3D.new()
	wall_back.size = Vector3(20, 5, 0.5)
	wall_back.position = Vector3(0, 2.5, -10)
	world.add_child(wall_back)
	polish.apply_cartoon_style(wall_back, Color(0.9, 0.8, 0.7)) # Beige walls
	
	# 3. Create the Drive-Thru Window Hole
	var window_hole = CSGBox3D.new()
	window_hole.operation = CSGShape3D.OPERATION_SUBTRACTION
	window_hole.size = Vector3(2, 2, 1)
	window_hole.position = Vector3(5, 2, -10)
	world.add_child(window_hole)
	
	# 4. Place Stations
	spawn_grill(world, Vector3(-2, 0, -5))
	spawn_fryer(world, Vector3(0, 0, -5))
	spawn_drink_station(world, Vector3(2, 0, -5))
	
	return world

func spawn_grill(world, pos):
	var grill = CSGBox3D.new()
	grill.size = Vector3(1.5, 1, 1.5)
	grill.position = pos + Vector3(0, 0.5, 0)
	world.add_child(grill)
	VisualPolishManager.new().apply_cartoon_style(grill, Color(0.2, 0.2, 0.2))

func spawn_fryer(world, pos):
	var fryer = CSGBox3D.new()
	fryer.size = Vector3(1, 1, 1)
	fryer.position = pos + Vector3(0, 0.5, 0)
	world.add_child(fryer)
	VisualPolishManager.new().apply_cartoon_style(fryer, Color(0.7, 0.7, 0.8))

func spawn_drink_station(world, pos):
	var station = CSGBox3D.new()
	station.size = Vector3(1, 2, 1)
	station.position = pos + Vector3(0, 1, 0)
	world.add_child(station)
	VisualPolishManager.new().apply_cartoon_style(station, Color(0.1, 0.4, 0.8))
