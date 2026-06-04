extends Node
class_name PlayerReputationManager

signal reputation_label_added(label_id: String)
signal reputation_label_removed(label_id: String)

var labels: Array = []
var active_labels: Array[String] = []

func _ready() -> void:
    labels = _load_json_array("res://data/reputation/player_reputation_labels.json", "labels")

func add_label(label_id: String) -> void:
    if label_id in active_labels:
        return
    active_labels.append(label_id)
    emit_signal("reputation_label_added", label_id)

func remove_label(label_id: String) -> void:
    active_labels.erase(label_id)
    emit_signal("reputation_label_removed", label_id)

func has_label(label_id: String) -> bool:
    return label_id in active_labels

func _load_json_array(path: String, key: String) -> Array:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: " + path)
        return []
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(parsed) != TYPE_DICTIONARY:
        push_warning("Invalid JSON dictionary: " + path)
        return []
    return parsed.get(key, [])
