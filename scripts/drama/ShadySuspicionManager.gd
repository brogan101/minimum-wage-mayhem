extends Node
class_name ShadySuspicionManager

signal shady_action_recorded(action: Dictionary)
signal suspicion_changed(value: int)

var suspicion: int = 0
var repeat_offender_count: int = 0
var actions: Array = []

func _ready() -> void:
    actions = _load_json_array("res://data/shady/shady_actions.json", "actions")

func record_action(action_id: String, context: Dictionary = {}) -> Dictionary:
    var action := _find_action(action_id)
    if action.is_empty():
        action = {"id": action_id, "severity": "minor", "risk": "unknown", "safety_note": "Fallback shady action."}
    repeat_offender_count += 1
    suspicion += _severity_to_suspicion(str(action.get("severity", "minor")))
    emit_signal("shady_action_recorded", action)
    emit_signal("suspicion_changed", suspicion)
    return action

func _severity_to_suspicion(severity: String) -> int:
    match severity:
        "minor": return 5
        "moderate": return 12
        "major": return 25
        _: return 3

func _find_action(action_id: String) -> Dictionary:
    for action in actions:
        if str(action.get("id", "")) == action_id:
            return action
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
