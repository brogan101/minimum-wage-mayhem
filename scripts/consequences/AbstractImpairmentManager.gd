extends Node
class_name AbstractImpairmentManager

signal impairment_event_applied(event: Dictionary)
signal crash_warning(event_id: String)

var events: Array = []
var active_event: Dictionary = {}

func _ready() -> void:
    events = _load_json_array("res://data/shady/abstract_impairment_events.json", "events")

func apply_event(event_id: String = "", context: Dictionary = {}) -> Dictionary:
    if event_id != "":
        active_event = _find(event_id)
    elif not events.is_empty():
        active_event = events.pick_random()
    else:
        active_event = {}
    var fireable = get_tree().root.find_child("FireableOffenseManager", true, false)
    var result = {"event": active_event, "abstract_only": true}
    if fireable and fireable.has_method("process_shady_choice") and not active_event.is_empty():
        result["consequence"] = fireable.process_shady_choice("abstract_shift_impairment", context)
    _log("abstract_impairment_event", 1.0, str(active_event.get("id", "")))
    emit_signal("impairment_event_applied", active_event)
    if not active_event.is_empty():
        emit_signal("crash_warning", str(active_event.get("id", "")))
    return result

func _find(event_id: String) -> Dictionary:
    for event in events:
        if str(event.get("id", "")) == event_id:
            return event
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
