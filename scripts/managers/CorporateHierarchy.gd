extends Node
class_name CorporateHierarchy

## NPC hierarchy used for promotion gates and performance reviews.

var hierarchy = {
	"ShiftLead": {"name": "Brad", "mood": "Passive-Aggressive", "requirement": "Rank 5"},
	"StoreManager": {"name": "Linda", "mood": "Terrifying", "requirement": "Rank 8"},
	"RegionalDirector": {"name": "Mr. Sterling", "mood": "Out of Touch", "requirement": "Rank 10"}
}

func trigger_performance_review(manager_id: String):
	var manager = hierarchy[manager_id]
	print("Performance Review with ", manager["name"], " (", manager["mood"], ")")
	
	# The review is a mini-game: you must answer questions using "Corporate Speak"
	# If you fail, you are demoted. If you succeed, you get a bonus.
	var result = conduct_review_dialogue()
	
	if result == "SUCCESS":
		WalletManager.add_money(500)
		CareerManager.add_xp(1000)
	else:
		CareerManager.demote()

func conduct_review_dialogue() -> String:
	var composure := 100.0
	if typeof(StatManager) != TYPE_NIL and StatManager.stats.has("Composure"):
		composure = float(StatManager.stats.get("Composure", 100.0))
	var approval := 50
	if typeof(CorporateManager) != TYPE_NIL and CorporateManager.has_method("get_approval_rating"):
		approval = int(CorporateManager.get_approval_rating())
	var score := composure + float(approval) + randf_range(-15.0, 15.0)
	if typeof(EventLog) != TYPE_NIL:
		EventLog.log_event("performance_review_score", score, "Corporate dialogue check")
	return "SUCCESS" if score >= 85.0 else "FAIL"
