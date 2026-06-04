extends EmployeeArchetype
class_name TheAlwaysCallingOutGuy

func _ready():
	employee_name = "Kyle"
	reliability = 0.2
	drama_level = 0.8
	speed_modifier = 0.5

func get_excuse() -> String:
	var excuses = [
		"My grandpa died again.",
		"My car started, but emotionally it did not.",
		"I thought I was off because I wanted to be.",
		"My dog looked sad."
	]
	return excuses.pick_random()
