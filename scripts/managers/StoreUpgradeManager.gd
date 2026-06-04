extends Node
## StoreUpgradeManager (Autoload) handles purchasing and applying store improvements.

var purchased_upgrades = []

var available_upgrades = {
	"FasterFryer": {"cost": 500, "description": "Reduces fry cook time by 50%", "type": "functional"},
	"GiantBurgerInflatable": {"cost": 200, "description": "A huge inflatable burger for the parking lot", "type": "cosmetic"},
	"GoldenMop": {"cost": 100, "description": "Mop faster and look fancy", "type": "functional"},
	"SassySpeaker": {"cost": 300, "description": "Drive-thru speaker that insults customers", "type": "cosmetic"}
}

func buy_upgrade(upgrade_id: String) -> bool:
	if available_upgrades.has(upgrade_id):
		var cost = available_upgrades[upgrade_id]["cost"]
		if WalletManager.spend_money(cost):
			purchased_upgrades.append(upgrade_id)
			apply_upgrade(upgrade_id)
			return true
	return false

func apply_upgrade(upgrade_id: String):
	print("Applied Upgrade: ", upgrade_id)
	match upgrade_id:
		"FasterFryer":
			# Find all fryers in the scene and double their speed
			var fryers = get_tree().get_nodes_in_group("fryers")
			for f in fryers:
				f.cooking_temperature *= 2.0
		"GiantBurgerInflatable":
			_spawn_cosmetic_marker("GiantBurgerInflatable", Vector3(4, 1.5, 6), Color(1.0, 0.45, 0.1))


func _spawn_cosmetic_marker(marker_name: String, pos: Vector3, color: Color) -> Node3D:
	var marker = Node3D.new()
	marker.name = marker_name
	var mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 2.0
	mesh.mesh = sphere
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material_override = mat
	marker.add_child(mesh)
	marker.global_position = pos
	get_tree().root.add_child(marker)
	if typeof(EventLog) != TYPE_NIL:
		EventLog.log_event("upgrade_visual_spawned", 0.0, marker_name)
	return marker
