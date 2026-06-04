extends Node
class_name RestaurantDamageManager

signal restaurant_damage_triggered(damage: Dictionary)
signal restaurant_damage_repaired(damage_id: String)

var damage_events: Array = []
var active_damage := {}
var repaired_damage: Array[Dictionary] = []
var recap_entries: Array[String] = []
var stability: int = 100

func _ready() -> void:
	damage_events = _load_json_array("res://data/mischief/restaurant_damage_events.json", "damage_events")

func trigger_damage(damage_id: String = "", context: Dictionary = {}) -> Dictionary:
	var damage = _find_damage(damage_id)
	if damage.is_empty() and not damage_events.is_empty():
		damage = damage_events[int(context.get("index", active_damage.size())) % damage_events.size()]
	if damage.is_empty():
		return {}
	var copy = damage.duplicate(true)
	copy["source"] = context.get("source", "mischief")
	copy["repairable"] = bool(copy.get("repairable", true))
	copy["repaired"] = false
	active_damage[str(copy.get("id", ""))] = copy
	stability = clamp(stability - (6 + int(context.get("severity", 1)) * 2), 0, 100)
	recap_entries.append(str(copy.get("description", copy.get("id", ""))) + ": needs repair")
	_apply_damage_effects(copy)
	_log("restaurant_damage_triggered", 1.0, str(copy.get("id", "")))
	restaurant_damage_triggered.emit(copy)
	return copy

func repair_damage(damage_or_task_id: String = "") -> Dictionary:
	var damage_id = _find_active_damage_for_repair(damage_or_task_id)
	if damage_id == "":
		return get_damage_summary()
	var damage: Dictionary = active_damage[damage_id]
	damage["repaired"] = true
	active_damage.erase(damage_id)
	repaired_damage.append(damage)
	stability = clamp(stability + 8, 0, 100)
	recap_entries.append(str(damage.get("description", damage_id)) + ": repaired")
	var store_ops = get_tree().root.find_child("StoreOpsDirector", true, false)
	if store_ops:
		store_ops.cleanliness = clamp(int(store_ops.cleanliness) + 6, 0, 100)
		store_ops.review_risk = clamp(int(store_ops.review_risk) - 3, 0, 100)
		if store_ops.has_method("_recalculate_modifiers"):
			store_ops._recalculate_modifiers()
		if store_ops.has_method("_emit_status"):
			store_ops._emit_status("mischief_damage_repaired")
	var daily = get_tree().root.find_child("DailyTaskManager", true, false)
	if daily and daily.has_method("record_progress"):
		daily.record_progress("restaurant_damage_repaired", damage_id)
	_log("restaurant_damage_repaired", 1.0, damage_id)
	restaurant_damage_repaired.emit(damage_id)
	return get_damage_summary()

func get_recap_entries() -> Array[String]:
	return recap_entries.duplicate()

func get_damage_summary() -> Dictionary:
	return {
		"active_damage": active_damage.values(),
		"repaired_damage": repaired_damage.duplicate(true),
		"stability": stability,
		"recap_entries": recap_entries.duplicate()
	}

func _apply_damage_effects(damage: Dictionary):
	var store_ops = get_tree().root.find_child("StoreOpsDirector", true, false)
	if store_ops:
		store_ops.cleanliness = clamp(int(store_ops.cleanliness) - 7, 0, 100)
		store_ops.review_risk = clamp(int(store_ops.review_risk) + 4, 0, 100)
		store_ops.manager_trust = clamp(int(store_ops.manager_trust) - 2, 0, 100)
		if store_ops.has_method("_recalculate_modifiers"):
			store_ops._recalculate_modifiers()
		if store_ops.has_method("_emit_status"):
			store_ops._emit_status("mischief_damage")

func _find_active_damage_for_repair(value: String) -> String:
	if value == "" and active_damage.size() > 0:
		return str(active_damage.keys()[0])
	if active_damage.has(value):
		return value
	for damage_id in active_damage:
		var damage: Dictionary = active_damage[damage_id]
		if value in damage.get("repair_tasks", []):
			return str(damage_id)
	return ""

func _find_damage(damage_id: String) -> Dictionary:
	for damage in damage_events:
		if str(damage.get("id", "")) == damage_id:
			return damage
	return {}

func _load_json_array(path: String, key: String) -> Array:
	if not FileAccess.file_exists(path):
		push_warning("Missing data file: " + path)
		return []
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Invalid JSON dictionary: " + path)
		return []
	return parsed.get(key, [])

func _log(event_name: String, value: float, detail: String):
	var event_log = get_tree().root.get_node_or_null("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event(event_name, value, detail)
