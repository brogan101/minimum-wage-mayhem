extends Node
class_name PhysicsMaterialLibrary

## Utility to generate physics materials for different object types.

func get_food_material() -> PhysicsMaterial:
	var mat = PhysicsMaterial.new()
	mat.friction = 0.5
	mat.bounce = 0.2
	return mat

func get_slippery_material() -> PhysicsMaterial:
	var mat = PhysicsMaterial.new()
	mat.friction = 0.05 # Very low friction
	mat.bounce = 0.1
	return mat

func get_bouncy_material() -> PhysicsMaterial:
	var mat = PhysicsMaterial.new()
	mat.friction = 0.3
	mat.bounce = 0.8 # High bounce for sauce packets
	return mat
