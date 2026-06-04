extends StaticBody3D
class_name RegisterScreen

## Diegetic UI: A physical screen on the register that shows order data.

@onready var screen_mesh = $ScreenMesh
@onready var label = $Label3D

func _process(_delta):
	# Continuously update the 3D label with the current order
	if OrderManager.current_order:
		var items = []
		for item in OrderManager.current_order["items"]:
			items.append(item["item"])
		label.text = "ORDER:\n" + "\n".join(items)
	else:
		label.text = "WAITING FOR\nCUSTOMER..."
