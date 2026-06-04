extends Node
## CorporateManager (Autoload) pushes useless goals and pressure.

signal goal_updated(goal_text)

var current_goal: String = ""
var goal_progress: int = 0
var goal_target: int = 0
var approval_rating: int = 50

var corporate_memos = [
	"Team, we are seeing a 4% decrease in fry enthusiasm. FIX IT.",
	"The guest experience begins before the guest understands what they want.",
	"Sauce is not a right. Sauce is a privilege. Limit distribution.",
	"Remember: A smile is just a frown turned upside down by corporate mandate."
]

func generate_shift_goal():
	var goals = [
		{"text": "Upsell 3 Sodas", "type": "upsell", "target": 3},
		{"text": "Zero burnt patties", "type": "quality", "target": 0},
		{"text": "Deliver orders under 30 seconds", "type": "speed", "target": 5}
	]
	var selected = goals.pick_random()
	current_goal = selected["text"]
	goal_target = selected["target"]
	goal_progress = 0
	goal_updated.emit(current_goal)
	print("CORPORATE MANDATE: ", current_goal)

func update_progress(amount: int):
	goal_progress += amount
	if goal_progress >= goal_target:
		print("Goal achieved! Corporate is moderately less disappointed.")
		adjust_approval(3)
		generate_shift_goal()

func adjust_approval(amount: int):
	approval_rating = clamp(approval_rating + amount, 0, 100)

func get_approval_rating() -> int:
	return approval_rating
