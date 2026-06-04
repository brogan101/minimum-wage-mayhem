extends Node3D
class_name Spill

## A physical hazard on the floor.

@export var size: float = 1.0
@export var slipperiness: float = 0.8

func _ready():
	# In a real game, this would be a decal or a flat mesh on the floor
	var mesh = MeshInstance3D.new()
	mesh.mesh = PlaneMesh.new()
	mesh.scale = Vector3(size, 1, size)
	add_child(mesh)
	
	var area = Area3D.new()
	var shape = CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.size = Vector3(size, 0.1, size)
	area.add_child(shape)
	add_child(area)
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is PlayerController:
		# Physically slow down the player and increase drop chance
		print("⚠️ SLIP! You hit a spill!")
		body.velocity *= 0.5 
		# Trigger a "drop item" check in PlayerInteraction
