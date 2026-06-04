extends Node
## ShadyEconomyManager (Autoload) - Logic for stealing and the "Black Market."

signal stash_updated(item_count)

var secret_stash = [] # Items stolen from the restaurant
var black_market_prices = {
	"Patty": 5,
	"SodaSyrup": 20,
	"SecretSauce": 50,
	"MilkshakeMachine": 500
}

## Logic for stealing an item
func steal_item(item: PickupItem):
	# Stealing adds to the Shady Meter
	var risk = 10.0 if item is FoodItem else 50.0
	ShadyManager.commit_shady_act(risk, "Stole " + item.name)
	
	# Add to secret stash (apartment hub)
	secret_stash.append(item.name)
	stash_updated.emit(secret_stash.size())
	print("Snatched: ", item.name, " added to the stash.")
	
	# Physically remove the item from the world
	item.queue_free()

## Selling stolen goods for "Clean Cash" (not taxed by corporate)
func sell_to_black_market(item_name: String) -> float:
	if secret_stash.has(item_name):
		secret_stash.erase(item_name)
		var price = black_market_prices.get(item_name, 1)
		WalletManager.add_money(price)
		print("Sold ", item_name, " to the underground for $", price)
		return price
	return 0.0
