extends Node
class_name VFXManager

## The la la: Managing the "Juicy" visual effects (Particles, Pop-ups).

func trigger_effect(effect_type: String, position: Vector3):
	match effect_type:
		"ColdMist":
			spawn_particles("res://assets/vfx/cold_mist.tscn", position)
		"Sizzle":
			spawn_particles("res://assets/vfx/sizzle_smoke.tscn", position)
		"Splat":
			spawn_particles("res://assets/vfx/sauce_splat.tscn", position)
		"Ding":
			spawn_popup("ORDER READY!", position)

func spawn_particles(path: String, pos: Vector3):
	# In a real project, this loads a GPUParticles3D scene
	print("✨ VFX: Spawning particles ", path, " at ", pos)

func spawn_popup(text: String, pos: Vector3):
	# Creates a floating 3D text label that floats upward and fades
	print("💬 POPUP: ", text, " at ", pos)
