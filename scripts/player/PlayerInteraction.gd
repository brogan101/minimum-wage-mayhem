extends Node3D
class_name PlayerInteraction

@export var interaction_range: float = 3.2
@export var throw_force: float = 10.0

var raycast: RayCast3D = null
var hold_position: Marker3D = null
var carried_item: RigidBody3D = null
var current_prompt := ""

func _ready():
	var player = get_parent()
	if player:
		raycast = player.get_node_or_null("Head/Camera3D/RayCast3D")
		hold_position = player.get_node_or_null("Head/Camera3D/HoldPosition")
	if raycast:
		raycast.target_position = Vector3(0, 0, -interaction_range)
		call_deferred("_enable_raycast")

func _physics_process(_delta):
	_update_prompt()
	if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("pickup_drop"):
		if carried_item:
			if raycast and raycast.is_colliding():
				var target = raycast.get_collider()
				if _is_pickup_item(target) and target != carried_item:
					print("Item combination is deferred to Phase 2/3 station work.")
			drop_item()
		else:
			attempt_interaction()
	if Input.is_action_just_pressed("throw_item") and carried_item:
		throw_item()
	if carried_item and hold_position:
		carried_item.global_position = carried_item.global_position.lerp(hold_position.global_position, 0.3)
		carried_item.set_collision_mask_value(2, false)
		carried_item.angular_velocity = Vector3.ZERO
		carried_item.linear_velocity = Vector3.ZERO

func attempt_interaction():
	if not raycast or not raycast.is_colliding():
		_set_hud_feedback("Look at a labeled station or item until the prompt appears.")
		return
	var collider = raycast.get_collider()
	if _is_pickup_item(collider):
		grab_item(collider)
	elif collider and collider.has_method("interact"):
		collider.interact(get_parent())
		_log_event("player_interacted", 1.0, collider.name)
		_play_audio_hook("interact")
	else:
		_set_hud_feedback("That is not usable yet. Try a labeled station.")

func grab_item(item: RigidBody3D):
	carried_item = item
	carried_item.freeze = true
	print("Picked up: ", item.name)
	_update_held_hud(_item_label(item))
	_play_audio_hook("pickup")
	_log_event("item_picked_up", 1.0, _item_label(item))

func drop_item():
	if carried_item:
		var item_label = _item_label(carried_item)
		carried_item.freeze = false
		carried_item.set_collision_mask_value(2, true)
		print("Dropped item")
		carried_item = null
		_update_held_hud("")
		_play_audio_hook("drop")
		_log_event("item_dropped", 1.0, item_label)

func throw_item():
	if not carried_item:
		return
	var item_to_throw = carried_item
	drop_item()
	var throw_dir = -global_transform.basis.z
	if raycast:
		throw_dir = -raycast.global_transform.basis.z
		if raycast.is_colliding():
			var target = raycast.get_collider()
			if target and target.has_method("leave_restaurant"):
				print("Bad choice: food thrown at customer. Legal/corporate risk should be applied by later systems.")
				var beef_manager = _autoload("BeefManager")
				if beef_manager and beef_manager.has_method("increase_beef"):
					beef_manager.increase_beef(100, "Food thrown at customer")
				var juice_manager = _autoload("JuiceManager")
				if juice_manager and juice_manager.has_method("trigger_shake"):
					juice_manager.trigger_shake(2.0, 0.5)
				return
	item_to_throw.apply_central_impulse(throw_dir * throw_force)
	print("Threw item!")
	_log_event("item_thrown", 1.0, _item_label(item_to_throw))

func _autoload(name: String) -> Node:
	return get_tree().root.get_node_or_null(name)

func _is_pickup_item(node: Object) -> bool:
	return node is RigidBody3D and node.get("item_name") != null

func _enable_raycast():
	if raycast:
		raycast.enabled = true

func _update_prompt():
	var next_prompt := ""
	if carried_item:
		next_prompt = "E / X: Drop " + _item_label(carried_item) + "    Mouse2 / LB: Throw"
	elif raycast and raycast.is_colliding():
		var target = raycast.get_collider()
		if _is_pickup_item(target):
			next_prompt = "E / A: Pick up " + _item_label(target)
		elif target and target.has_method("interact"):
			var text = target.get("interact_text")
			next_prompt = "E / A: " + str(text if text != null else "Interact")
	if next_prompt != current_prompt:
		current_prompt = next_prompt
		var hud = get_tree().root.find_child("GameHUD", true, false)
		if hud and hud.has_method("set_interaction_prompt"):
			hud.set_interaction_prompt(current_prompt)

func _item_label(item: Object) -> String:
	var label = item.get("item_name") if item else null
	return str(label if label != null else item.name)

func _log_event(event_name: String, value: float, detail: String):
	var event_log = _autoload("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event(event_name, value, detail)

func _update_held_hud(text: String):
	var hud = get_tree().root.find_child("GameHUD", true, false)
	if hud and hud.has_method("set_held_item"):
		hud.set_held_item(text)

func _set_hud_feedback(text: String):
	var hud = get_tree().root.find_child("GameHUD", true, false)
	if hud and hud.has_method("set_station_feedback"):
		hud.set_station_feedback(text)

func _play_audio_hook(hook_name: String):
	var audio = _autoload("AudioManager")
	if audio and audio.has_method("play_sfx"):
		audio.play_sfx(hook_name)
