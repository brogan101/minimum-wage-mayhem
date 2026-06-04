extends CharacterBody3D
class_name EmployeeAI

## Depth: NPCs are no longer static. They have "Work-Life" AI.

@export var employee_name: String = "NPC"
@export var job_role: String = "Cook"
@export var mood: float = 1.0 # 0 (Angry/Lazy) to 1 (Productive)

var target_position: Vector3
var is_working: bool = true

func _physics_process(delta):
	if not is_working:
		wander_randomly(delta)
		return
	
	move_to_station(delta)

func move_to_station(delta):
	# AI logic: Move toward station
	var direction = (target_position - global_position).normalized()
	
	# DEPTH: If the player is in the way, the NPC might stop and complain
	var player = get_tree().root.find_child("Player", true, false)
	if player and global_position.distance_to(player.global_position) < 1.5:
		velocity = Vector3.ZERO
		if randf() < 0.01:
			print(employee_name, ": 'Move it, rookie!'")
		return

	velocity = direction * 2.0
	move_and_slide()
	
	if global_position.distance_to(target_position) < 1.0:
		perform_work_task()

func perform_work_task():
	# Depth: NPCs can fail based on their mood
	if randf() > mood:
		print(employee_name, " got distracted by their phone.")
		is_working = false
		await get_tree().create_timer(5.0).timeout
		is_working = true
	else:
		print(employee_name, " is efficiently working.")

func wander_randomly(delta):
	# The "Ghost Employee" behavior: they walk around and get in the player's way
	var random_dir = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	velocity = random_dir * 1.0
	move_and_slide()
