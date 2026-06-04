extends Node
class_name InventoryMisconductManager

signal inventory_action_taken(action: Dictionary)
signal inventory_discrepancy_changed(value: int)

var actions: Array = []
var inventory_discrepancy: int = 0

func _ready() -> void:
    actions = _load_json_array("res://data/shady/inventory_misconduct_actions.json", "actions")

func apply_action(action_id: String, discrepancy_delta: int = 1, context: Dictionary = {}) -> Dictionary:
    var action := _find(action_id)
    inventory_discrepancy += discrepancy_delta
    var fireable = get_tree().root.find_child("FireableOffenseManager", true, false)
    var offense_id = "employee_meal_abuse" if "meal" in action_id else "sauce_box_hoarding"
    var result = {"action": action, "inventory_discrepancy": inventory_discrepancy}
    if fireable:
        if str(action.get("risk", "unknown")) == "low" and fireable.has_method("record_clean_choice"):
            result["consequence"] = fireable.record_clean_choice(action_id)
        elif fireable.has_method("process_shady_choice"):
            result["consequence"] = fireable.process_shady_choice(offense_id, _merge_context(context, action))
        else:
            result["consequence"] = {}
    _log("inventory_misconduct_action", float(inventory_discrepancy), action_id)
    emit_signal("inventory_discrepancy_changed", inventory_discrepancy)
    emit_signal("inventory_action_taken", action)
    return result

func _find(action_id: String) -> Dictionary:
    for action in actions:
        if str(action.get("id", "")) == action_id:
            return action
    return {"id": action_id, "risk": "unknown"}

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
