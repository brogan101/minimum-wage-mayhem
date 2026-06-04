extends Node
## The "Corporate Nightmare" Engine: Procedural Rule Generation.

func generate_absurd_rule() -> String:
	var subjects = ["Employees", "Managers", "The Fryer", "Customers", "The Mop"]
	var actions = ["must bow to", "are forbidden from touching", "shall only speak to", "must be rebranded as", "are required to apologize to"]
	var objects = ["the Regional Manager", "the Secret Sauce", "the drive-thru speaker", "the concept of time", "the Golden Sizzler"]
	
	var rule = subjects.pick_random() + " " + actions.pick_random() + " " + objects.pick_random() + "."
	return rule

func trigger_corporate_memo():
	var rule = generate_absurd_rule()
	print("📢 NEW CORPORATE MEMO: ", rule)
	# This rule now becomes a "Goal" in the CorporateManager
	CorporateManager.generate_shift_goal() # Or a custom rule goal
