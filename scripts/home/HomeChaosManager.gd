extends Node
class_name HomeChaosManager

signal home_event_generated(event: Dictionary)

var events: Array = []

func _ready() -> void:
    events = _load_json_array("res://data/home/home_chaos_events.json", "events")

func generate_home_event() -> Dictionary:
    if events.is_empty():
        return {}
    var event: Dictionary = events.pick_random()
    emit_signal("home_event_generated", event)
    return event

func _load_json_array(path: String, key: String) -> Array:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: " + path)
        return []
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(parsed) != TYPE_DICTIONARY:
        push_warning("Invalid JSON dictionary: " + path)
        return []
    return parsed.get(key, [])
