extends Node
class_name StoreObjectMemoryManager

signal object_memory_updated(object_id: String, memory: Dictionary)
signal object_label_added(object_id: String, label_id: String)

var object_memory: Dictionary = {}
var object_targets: Array = []
var label_pool: Array = []

func _ready() -> void:
    object_targets = _load_json_array("res://data/memory/store_object_memory_targets.json", "objects")
    label_pool = _load_json_array("res://data/memory/object_reputation_labels.json", "labels")
    for target in object_targets:
        object_memory[str(target.get("id", ""))] = target

func record_object_incident(object_id: String, event: Dictionary) -> Dictionary:
    if not object_memory.has(object_id):
        object_memory[object_id] = {"id": object_id, "incident_count": 0, "labels": [], "legendary_threshold": 3}
    var memory: Dictionary = object_memory[object_id]
    memory["incident_count"] = int(memory.get("incident_count", 0)) + 1
    var incidents: Array = memory.get("incidents", [])
    incidents.append(event.get("event_id", "unknown_event"))
    memory["incidents"] = incidents
    object_memory[object_id] = memory
    _log("store_object_memory_updated", float(memory.get("incident_count", 0)), object_id)
    emit_signal("object_memory_updated", object_id, memory)
    if int(memory.get("incident_count", 0)) >= int(memory.get("legendary_threshold", 3)):
        _add_label(object_id, "legendary")
    return memory

func _add_label(object_id: String, label_id: String) -> void:
    var memory: Dictionary = object_memory.get(object_id, {})
    var labels: Array = memory.get("labels", [])
    if label_id not in labels:
        labels.append(label_id)
        memory["labels"] = labels
        object_memory[object_id] = memory
        _log("store_object_label_added", 1.0, object_id + ":" + label_id)
        emit_signal("object_label_added", object_id, label_id)

func get_summary() -> Dictionary:
    return {"object_memory": object_memory.duplicate(true), "object_targets": object_targets.duplicate(true)}

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
