extends StaticBody3D
class_name TrashBin

## A physical bin where ruined food or trash can be dropped.

func _ready():
	var area = Area3D.new()
	area.name = "TrashArea"
	var shape = CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.size = Vector3(1, 1, 1)
	area.add_child(shape)
	add_child(area)
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is PickupItem:
		print("Trashed: ", body.name)
		EventLog.log_event("WasteDisposal", 1, body.name)
		body.queue_free()
