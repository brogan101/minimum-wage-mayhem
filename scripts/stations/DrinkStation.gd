extends Interactable
class_name DrinkStation

## Physically filling a cup at the soda fountain.

func interact(player: Node3D):
	# Check if the player is holding a SodaCup
	var interaction = player.get_node_or_null("InteractionHandler") if player else null
	if not interaction:
		print("Drink station missing player interaction handler.")
		return
	if interaction.carried_item is SodaCup:
		var cup = interaction.carried_item as SodaCup
		cup.fill()
		print("Sshhhhhhh... Soda filled!")
	else:
		print("You need a cup to use the drink machine!")
