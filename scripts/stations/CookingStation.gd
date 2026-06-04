extends "res://scripts/stations/Interactable.gd"
class_name CookingStation

## Base class for any station that cooks food (Grills, Fryers, Ovens).

@export var cooking_temperature: float = 1.0 # Multiplier for cooking speed

var items_on_station: Array[RigidBody3D] = []

func _ready():
	# Connect the Area3D signals
	var area = get_node_or_null("CookingArea")
	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

func _process(delta):
	# Process all food currently resting on the station
	for item in items_on_station:
		process_cooking(item, delta)

func interact(player: Node3D):
	super.interact(player)
	var interaction = player.get_node_or_null("InteractionHandler") if player else null
	if interaction and interaction.carried_item and _is_food_item(interaction.carried_item):
		var item = interaction.carried_item
		interaction.carried_item = null
		_place_item_on_station(item)
		_log_station_event("station_item_placed", item.name)
		return
	if not items_on_station.is_empty():
		advance_item_state(items_on_station[0])
	else:
		_log_station_event("station_checked_empty", name)

func process_cooking(item: RigidBody3D, delta: float):
	if not _is_food_item(item):
		return
	# This is a simple timer-based approach.
	# We use a custom property on the FoodItem to track progress.
	if not item.has_meta("cook_progress"):
		item.set_meta("cook_progress", 0.0)
	
	var progress = item.get_meta("cook_progress") + (delta * cooking_temperature)
	item.set_meta("cook_progress", progress)
	
	var cook_time = float(item.get("cook_time"))
	var burn_time = float(item.get("burn_time"))
	if progress >= burn_time:
		_set_food_state(item, 2)
	elif progress >= cook_time:
		_set_food_state(item, 1)

func advance_item_state(item: RigidBody3D):
	if not _is_food_item(item):
		return
	var next_state = min(int(item.get("current_state")) + 1, 2)
	_set_food_state(item, next_state)
	item.set_meta("cook_progress", float(item.get("burn_time")) if next_state >= 2 else float(item.get("cook_time")))
	_log_station_event("station_item_advanced", item.name)

func _on_body_entered(body):
	if _is_food_item(body):
		items_on_station.append(body)
		body.set_meta("cook_progress", 0.0) # Reset progress when placed
		print(body.name, " placed on station")

func _on_body_exited(body):
	if _is_food_item(body):
		items_on_station.erase(body)
		print(body.name, " removed from station")

func _place_item_on_station(item: RigidBody3D):
	if not items_on_station.has(item):
		items_on_station.append(item)
	item.freeze = true
	item.global_position = global_position + Vector3(0, 0.85, 0)
	item.linear_velocity = Vector3.ZERO
	item.angular_velocity = Vector3.ZERO

func _is_food_item(item: Object) -> bool:
	return item is RigidBody3D and item.has_method("set_state") and item.get("current_state") != null

func _set_food_state(item: RigidBody3D, state: int):
	if item.has_method("set_state"):
		item.set_state(state)

func _log_station_event(event_name: String, detail: String):
	var event_log = get_tree().root.get_node_or_null("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event(event_name, 1.0, detail)
