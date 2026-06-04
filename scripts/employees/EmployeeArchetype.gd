extends Node
class_name EmployeeArchetype

## Base class for NPC coworkers.

@export var employee_name: String = "Employee"
@export var reliability: float = 1.0 # 0 to 1
@export var drama_level: float = 0.0 # 0 to 1
@export var speed_modifier: float = 1.0

func perform_task():
	# Reliability determines if they actually do the task or "hide in the back"
	if randf() > reliability:
		print(employee_name, " is currently 'in the back' (they are not).")
		return false
	
	print(employee_name, " completed the task with speed ", speed_modifier)
	return true
