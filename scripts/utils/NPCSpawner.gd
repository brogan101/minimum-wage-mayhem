extends Node
class_name NPCSpawner

## Physically populates the restaurant with the drama-inducing coworkers.

func spawn_shift_crew(world: Node3D):
	# Define roles and positions
	var crew_config = [
		{"role": "Cook", "pos": Vector3(-5, 0, -2), "archetype": "KitchenMenace"},
		{"role": "Runner", "pos": Vector3(2, 0, -2), "archetype": "GhostEmployee"},
		{"role": "Window", "pos": Vector3(10, 0, 0), "archetype": "AlwaysCallingOutGuy"}
	]
	
	for config in crew_config:
		var npc = EmployeeAI.new()
		npc.employee_name = config["archetype"]
		npc.job_role = config["role"]
		npc.global_position = config["pos"]
		
		# Assign a specific behavior based on archetype
		if config["archetype"] == "AlwaysCallingOutGuy":
			npc.reliability = 0.2
		elif config["archetype"] == "GhostEmployee":
			npc.reliability = 0.1
			
		world.add_child(npc)
		print("Spawned Coworker: ", npc.employee_name, " as ", npc.job_role)
