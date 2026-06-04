extends Node
class_name ManagerCoverupManager

signal coverup_started(coverup: Dictionary)
signal coverup_response_selected(response_id: String, result: Dictionary)

var coverups: Array = []

func _ready() -> void:
    coverups = _load_json_array("res://data/fireable/manager_coverups.json", "coverups")

func start_coverup() -> Dictionary:
    var coverup: Dictionary = coverups.pick_random() if not coverups.is_empty() else {"id": "generic_coverup", "player_routes": ["refuse", "go_along"]}
    emit_signal("coverup_started", coverup)
    return coverup

func choose_response(response_id: String, coverup: Dictionary = {}) -> Dictionary:
    var result := {"response_id": response_id, "coverup_id": coverup.get("id", "")}
    var fireable = get_tree().root.find_child("FireableOffenseManager", true, false)
    if fireable and fireable.has_method("record_clean_choice") and response_id == "refuse":
        result["consequence"] = fireable.record_clean_choice("refused_manager_coverup")
    elif fireable and fireable.has_method("process_shady_choice"):
        result["consequence"] = fireable.process_shady_choice("fake_corporate_memo", {"risk": "high", "manager_nearby": 1})
    _log("manager_coverup_response", 1.0, response_id)
    emit_signal("coverup_response_selected", response_id, result)
    return result

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
