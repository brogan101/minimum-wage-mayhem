extends PhysicalObject
class_name FreezerDoor

## Specialized door that triggers a "Cold" effect on the player.

func toggle_state():
	super.toggle_state()
	if is_open:
		# Trigger "Cold" particles and sound
		VFXManager.trigger_effect("ColdMist", global_position)
		print("Brrr! The freezer is open.")
