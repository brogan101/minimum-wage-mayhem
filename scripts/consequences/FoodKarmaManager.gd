extends Node
class_name FoodKarmaManager

signal food_karma_changed(value: int)
signal guilt_event_unlocked(event_id: String)

var actions: Array = []
var food_karma: int = 0

func _ready() -> void:
    actions = _load_json_array("res://data/shady/food_karma_actions.json", "actions")

func apply_action(action_id: String, context: Dictionary = {}) -> Dictionary:
    var action := _find(action_id)
    food_karma = clamp(food_karma + int(action.get("karma_delta", 0)), -100, 100)
    var fireable = get_tree().root.find_child("FireableOffenseManager", true, false)
    var result = {"action": action, "food_karma": food_karma}
    if fireable:
        if int(action.get("karma_delta", 0)) >= 0 and fireable.has_method("record_clean_choice"):
            result["consequence"] = fireable.record_clean_choice(action_id)
        elif fireable.has_method("process_shady_choice"):
            result["consequence"] = fireable.process_shady_choice("questionable_order", _merge_context(context, action))
        else:
            result["consequence"] = {}
    _log("food_karma_action", float(food_karma), action_id)
    emit_signal("food_karma_changed", food_karma)
    if food_karma <= -25:
        _log("food_karma_guilt_event", float(food_karma), "nugget_tribunal")
        emit_signal("guilt_event_unlocked", "nugget_tribunal")
    return result

func _find(action_id: String) -> Dictionary:
    for action in actions:
        if str(action.get("id", "")) == action_id:
            return action
    return {"id": action_id, "karma_delta": 0}

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
