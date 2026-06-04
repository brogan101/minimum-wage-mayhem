extends Node
## The Apartment Hub: Turning the room into a lifestyle sim.

var furniture_upgrades = {
	"CheapBed": {"cost": 0, "energy_gain": 20, "stress_reduction": 5},
	"MemoryFoamBed": {"cost": 500, "energy_gain": 50, "stress_reduction": 20},
	"GamingPC": {"cost": 1000, "energy_gain": -10, "stress_reduction": 50},
	"FancyCoffeeMaker": {"cost": 200, "energy_gain": 30, "stress_reduction": 0},
	"JudgmentalFish": {"cost": 50, "energy_gain": 0, "stress_reduction": 10}
}

func interact_with_item(item_id: String):
	if not furniture_upgrades.has(item_id): return
	
	var effect = furniture_upgrades[item_id]
	StatManager.update_stat("Energy", effect["energy_gain"])
	StatManager.update_stat("Stress", -effect["stress_reduction"])
	
	print("You used the ", item_id, ". Your stats have been updated.")

func purchase_furniture(item_id: String):
	if furniture_upgrades.has(item_id):
		var cost = furniture_upgrades[item_id]["cost"]
		if WalletManager.spend_money(cost):
			print("Upgraded to ", item_id, "!")
			# Logic to physically spawn the new model in the 3D room
			return true
	return false
