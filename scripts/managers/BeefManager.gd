extends Node
## BeefManager (Autoload) tracks the frustration of the current customer.

signal beef_level_changed(new_level)
signal beef_critical()

var current_beef: float = 0.0
var max_beef: float = 100.0

func _ready():
	# Connect the beef critical signal to the UI
	# Since BeefManager is an Autoload, we use call_deferred to wait for the scene tree
	call_deferred("_setup_connections")

func _setup_connections():
	# We use the signal to tell the UI to start a Beef Battle
	beef_critical.connect(_on_beef_critical)

func _on_beef_critical():
	# Trigger the visual Beef Battle UI
	var battle_ui = get_tree().root.find_child("BeefBattleUI", true, false)
	if battle_ui:
		battle_ui.start_battle("Angry Customer", 100.0)
	else:
		print("Beef Battle UI not found in scene!")

func increase_beef(amount: float, reason: String):
	current_beef = clamp(current_beef + amount, 0, max_beef)
	print("Beef increased by ", amount, " due to: ", reason, " | Total Beef: ", current_beef)
	var event_log = get_tree().root.get_node_or_null("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event("beef_incident", amount, reason)
	beef_level_changed.emit(current_beef)
	
	if current_beef >= max_beef:
		beef_critical.emit()
		trigger_beef_event()

func decrease_beef(amount: float):
	current_beef = clamp(current_beef - amount, 0, max_beef)
	beef_level_changed.emit(current_beef)

func trigger_beef_event():
	print("🚨 BEEF CRITICAL: The customer is now screaming!")
	var event_log = get_tree().root.get_node_or_null("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event("beef_critical", current_beef, "Customer reached critical Beef")
