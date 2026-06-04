extends Node
class_name MultiKarmaManager

signal karma_changed(karma_id: String, value: int)
signal karma_triggered(trigger: Dictionary)

var karma_values: Dictionary = {}
var triggers: Array = []
var karma_history: Array[Dictionary] = []
var triggered_history: Array[Dictionary] = []

func _ready() -> void:
    var types := _load_json_array("res://data/karma/karma_types.json", "karma_types")
    for type in types:
        karma_values[str(type.get("id", ""))] = int(type.get("default", 0))
    triggers = _load_json_array("res://data/karma/karma_event_triggers.json", "triggers")

func change_karma(karma_id: String, delta: int) -> void:
    karma_values[karma_id] = clamp(int(karma_values.get(karma_id, 0)) + delta, -100, 100)
    karma_history.append({"karma_id": karma_id, "delta": delta, "value": karma_values[karma_id]})
    _log("multi_karma_changed", float(delta), karma_id)
    emit_signal("karma_changed", karma_id, karma_values[karma_id])
    _check_triggers()

func apply_event(event: Dictionary, consequences: Dictionary = {}) -> void:
    var tags = event.get("tags", [])
    if "customer" in tags or int(consequences.get("customer_beef", 0)) > 0:
        change_karma("customer_karma", -1 if int(consequences.get("customer_beef", 0)) > 0 else 1)
    if "coworker" in tags:
        change_karma("coworker_karma", 1 if int(consequences.get("staff_morale", 0)) >= 0 else -1)
    if "corporate" in tags:
        change_karma("corporate_karma", 1 if int(consequences.get("corporate_approval", 0)) >= 0 else -1)
    if "food_karma" in tags or "food" in tags:
        change_karma("food_karma", -1)
    if "shady" in tags:
        change_karma("shady_karma", -1)

func _check_triggers() -> void:
    for trigger in triggers:
        var karma_id = str(trigger.get("karma_id", ""))
        var threshold = int(trigger.get("threshold", 999))
        if karma_id != "" and abs(int(karma_values.get(karma_id, 0))) >= abs(threshold):
            triggered_history.append(trigger)
            _log("multi_karma_triggered", float(karma_values.get(karma_id, 0)), karma_id)
            emit_signal("karma_triggered", trigger)

func get_summary() -> Dictionary:
    return {"karma_values": karma_values.duplicate(true), "karma_history": karma_history.duplicate(true), "triggered_history": triggered_history.duplicate(true)}

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
