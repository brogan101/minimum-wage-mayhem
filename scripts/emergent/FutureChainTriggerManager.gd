extends Node
class_name FutureChainTriggerManager

signal future_chain_triggered(trigger: Dictionary)

var triggers: Array = []
var fired_history: Array[Dictionary] = []

func _ready() -> void:
    triggers = _load_json_array("res://data/emergent/future_chain_triggers.json", "triggers")

func evaluate(context: Dictionary) -> Array:
    var fired: Array = []
    for trigger in triggers:
        if _conditions_met(trigger.get("conditions", []), context):
            fired.append(trigger)
            fired_history.append(trigger)
            _log("future_chain_triggered", 1.0, str(trigger.get("id", "")))
            emit_signal("future_chain_triggered", trigger)
    return fired

func get_summary() -> Dictionary:
    return {"fired_history": fired_history.duplicate(true), "triggers": triggers.duplicate(true)}

func _conditions_met(conditions: Array, context: Dictionary) -> bool:
    for condition in conditions:
        if not bool(context.get(str(condition), false)):
            return false
    return true

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
