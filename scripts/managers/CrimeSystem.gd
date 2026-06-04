extends Node
## The "Crime Suite": Detailed logic for every shady act.

func perform_shady_act(act_type: String, player: Node3D):
	match act_type:
		"SKIM_REGISTER":
			# Physically interact with the register to steal small change
			var amount = randf_range(0.10, 2.00)
			WalletManager.add_money(amount)
			ShadyManager.commit_shady_act(15.0, "Skimming pennies from the till")
			print("You pocketed $", amount, " with a quick hand.")
			
		"EAT_ORDER":
			# Eat a fry from a customer's bag before handing it over
			StatManager.update_stat("Hunger", -10)
			ShadyManager.commit_shady_act(10.0, "Eating customer fries")
			BeefManager.increase_beef(5, "Order looks slightly incomplete")
			print("Delicious. Who's going to notice one fry?")
			
		"FAKE_CLEAN":
			# Mop the same spot for 30 seconds to avoid work
			StatManager.update_stat("Stress", -20)
			ShadyManager.commit_shady_act(20.0, "Aggressive slacking")
			print("You are now the Master of the Mop. Productivity is zero.")
			
		"SAUCE_TRAFFICKING":
			# Give a friend extra sauce in exchange for cash
			WalletManager.add_money(5)
			ShadyManager.commit_shady_act(30.0, "Illegal sauce distribution")
			print("The sauce trade is booming tonight.")
