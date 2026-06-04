extends Node
class_name TutorialManager

## Manages the first-time player experience through physical tasks.

signal tutorial_step_completed(step_id)

var current_step = 0
var steps = [
	{"id": "walk", "goal": "Walk to the Grill", "target": "GrillStation"},
	{"id": "pickup", "goal": "Pick up a Patty", "target": "BurgerPatty"},
	{"id": "cook", "goal": "Cook the Patty to 'Cooked' state", "target": "GrillStation"},
	{"id": "assemble", "goal": "Merge Patty with Bun", "target": "Burger"},
	{"id": "bag", "goal": "Place Burger in Bag", "target": "FoodBag"},
	{"id": "deliver", "goal": "Hand bag to the Customer", "target": "DriveThruWindow"}
]

func _ready():
	start_tutorial()

func start_tutorial():
	print("TUTORIAL START: Welcome to the grind, rookie.")
	update_tutorial_ui()

func update_tutorial_ui():
	if current_step < steps.size():
		var step = steps[current_step]
		print("CURRENT TASK: ", step["goal"])
	else:
		print("TUTORIAL COMPLETE: You are now a certified Fry Rookie.")

func check_progress(action_type: String, target_name: String):
	if current_step >= steps.size(): return
	
	var step = steps[current_step]
	if action_type == "interact" and target_name == step["target"]:
		current_step += 1
		tutorial_step_completed.emit(step["id"])
		update_tutorial_ui()
