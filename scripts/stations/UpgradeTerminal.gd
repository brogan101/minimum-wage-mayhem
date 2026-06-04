extends Interactable
class_name UpgradeTerminal

## A physical terminal in the Manager's Office for store upgrades.

func interact(player: Node3D):
	print("Opening Upgrade Terminal...")
	# Trigger the Upgrade UI
	var upgrade_ui = get_tree().root.find_child("UpgradeUI", true, false)
	if upgrade_ui:
		upgrade_ui.open_menu()
	else:
		# Fallback: Just buy a random upgrade for the prototype
		var upgrades = StoreUpgradeManager.available_upgrades.keys()
		var random_upgrade = upgrades.pick_random()
		StoreUpgradeManager.buy_upgrade(random_upgrade)
