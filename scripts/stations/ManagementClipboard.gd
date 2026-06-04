extends Interactable
class_name ManagementClipboard

## A physical object the manager carries to assign tasks.

func interact(player: Node3D):
	# Trigger a UI menu for "Staff Management"
	print("Opening Staff Clipboard... [Hiring/Firing/Scheduling]")
	# In a full game, this opens a stylized clipboard UI
