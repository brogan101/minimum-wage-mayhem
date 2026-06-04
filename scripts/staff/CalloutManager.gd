extends Node
class_name CalloutManager

signal callout_generated(callout: Dictionary)

var excuses: Array = []

func _ready() -> void:
    excuses = _load_json_array("res://data/staff/callout_excuses.json", "excuses")

func generate_callout(employee_id: String = "") -> Dictionary:
    var excuse: Dictionary = excuses.pick_random() if not excuses.is_empty() else {"id": "generic_callout", "text": "I can only come in emotionally.", "station_coverage_effect": "station_uncovered"}
    excuse["employee_id"] = employee_id
    emit_signal("callout_generated", excuse)
    return excuse

func _load_json_array(path: String, key: String) -> Array:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: " + path)
        return []
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(parsed) != TYPE_DICTIONARY:
        push_warning("Invalid JSON dictionary: " + path)
        return []
    return parsed.get(key, [])
