extends Node
## The Rivalry Engine: Managing competition with other chains.

signal rival_event_triggered(rival_name, event_type)

var rivals = {
	"CluckHut": {"market_share": 30, "aggression": 0.6, "specialty": "Sauce"},
	"TacoPlanet": {"market_share": 20, "aggression": 0.8, "specialty": "LateNight"},
	"FancyFrySociety": {"market_share": 10, "aggression": 0.3, "specialty": "Gourmet"}
}

func update_market_shares():
	# Logic: If the player's store reputation is high, rival shares drop
	var player_rep = OfficeManager.store_reputation
	for rival in rivals:
		var r = rivals[rival]
		r["market_share"] -= (player_rep * 0.01)
		r["market_share"] = clamp(r["market_share"], 0, 100)

func trigger_rival_attack():
	var rival_name = rivals.keys().pick_random()
	var rival = rivals[rival_name]
	
	# A "Sauce War" event
	if rival["specialty"] == "Sauce":
		print("🚨 RIVAL ATTACK: ", rival_name, " is undercutting our sauce prices!")
		# This triggers a shift modifier that increases "Coupon Warrior" spawns
		ChaosEngine.roll_for_chaos()
	
	rival_event_triggered.emit(rival_name, "PriceWar")
