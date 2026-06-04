extends Node
class_name EmployeeGroupChat

## Generates random staff drama in a phone/chat-style interface.

signal new_message(sender, text)

var employees = ["Gary", "Tina", "Kyle", "Megan", "Brad", "Derek"]
var drama_templates = [
	"{name1}: Reminder: nobody is allowed to put fries in their pockets anymore.",
	"{name2}: Why did that need to be said?",
	"{name3}: can someone cover my shift tonight",
	"{name4}: {name3}, you are already here.",
	"{name3}: emotionally no",
	"{name5}: Great communication, team. Let's keep the energy guest-focused.",
	"{name6}: {name5}, you hid in the office during lunch rush.",
	"{name1}: Also who labeled the mop 'assistant manager'?"
]

func _ready():
	var timer = Timer.new()
	timer.wait_time = randf_range(30.0, 120.0)
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func _on_timer_timeout():
	var template = drama_templates.pick_random()
	var message = template
	
	# Fill template tokens with random employee names
	for i in range(1, 7):
		message = message.replace("{" + "name" + str(i) + "}", employees.pick_random())
	
	new_message.emit("System", message)
	print("📱 GROUP CHAT: ", message)
	
	# Randomly trigger a shift modifier based on the drama
	if randf() < 0.2:
		ChaosEngine.roll_for_chaos()
