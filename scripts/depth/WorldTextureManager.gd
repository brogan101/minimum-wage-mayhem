extends Node
class_name WorldTextureManager

signal rumor_generated(rumor: Dictionary)
signal quiet_event_generated(event: Dictionary)

var rumors: Array = []
var quiet_events: Array = []
var generated_rumors: Array[Dictionary] = []
var generated_quiet_events: Array[Dictionary] = []

func _ready() -> void:
    rumors = _load_json_array("res://data/depth/world_rumors.json", "rumors")
    quiet_events = _load_json_array("res://data/depth/quiet_normal_events.json", "events")

func generate_rumor() -> Dictionary:
    if rumors.is_empty():
        return {}
    var rumor: Dictionary = rumors.pick_random()
    generated_rumors.append(rumor)
    _log("world_rumor_generated", 1.0, str(rumor.get("id", "")))
    emit_signal("rumor_generated", rumor)
    return rumor

func generate_quiet_event() -> Dictionary:
    if quiet_events.is_empty():
        return {}
    var event: Dictionary = quiet_events.pick_random()
    generated_quiet_events.append(event)
    _log("quiet_normal_event_generated", 1.0, str(event.get("id", "")))
    emit_signal("quiet_event_generated", event)
    return event

func get_summary() -> Dictionary:
    return {"rumors": generated_rumors.duplicate(true), "quiet_events": generated_quiet_events.duplicate(true)}

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
