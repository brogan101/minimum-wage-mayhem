extends Node
class_name TipJarManager

signal tip_action_taken(action: Dictionary)

var actions: Array = []
var tip_total: float = 0.0

func _ready() -> void:
    actions = _load_json_array("res://data/shady/tip_jar_actions.json", "actions")

func apply_action(action_id: String, context: Dictionary = {}) -> Dictionary:
    var action := _find(action_id)
    if action.is_empty():
        action = {"id": action_id, "risk": "low"}
    var clean = str(action.get("risk", "low")) == "low"
    if clean:
        tip_total = max(0.0, tip_total + 1.0)
    else:
        tip_total = max(0.0, tip_total - 1.0)
    var fireable = get_tree().root.find_child("FireableOffenseManager", true, false)
    var result = {"action": action, "clean_play_valid": clean}
    if fireable:
        if clean and fireable.has_method("record_clean_choice"):
            result["consequence"] = fireable.record_clean_choice(action_id)
        elif fireable.has_method("process_shady_choice"):
            result["consequence"] = fireable.process_shady_choice("tip_jar_pocketing", _merge_context(context, action))
        else:
            result["consequence"] = {}
    _log("tip_jar_action_taken", 1.0, action_id)
    emit_signal("tip_action_taken", action)
    return result

func _find(action_id: String) -> Dictionary:
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

func _merge_context(context: Dictionary, action: Dictionary) -> Dictionary:
    var merged = context.duplicate(true)
    merged["risk"] = action.get("risk", "medium")
    merged["source_action"] = action.get("id", "")
    return merged

func _log(event_name: String, value: float, detail: String):
    var event_log = get_tree().root.get_node_or_null("EventLog")
    if event_log and event_log.has_method("log_event"):
        event_log.log_event(event_name, value, detail)
