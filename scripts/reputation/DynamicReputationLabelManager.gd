extends Node
class_name DynamicReputationLabelManager

signal reputation_rule_matched(rule: Dictionary)
signal dynamic_label_added(label_id: String)

var rules: Array = []
var active_labels: Array[String] = []
var evaluation_history: Array[Dictionary] = []

func _ready() -> void:
    rules = _load_json_array("res://data/reputation/dynamic_reputation_rules.json", "rules")

func evaluate(context: Dictionary) -> Array:
    var added: Array = []
    for rule in rules:
        if _conditions_met(rule.get("conditions", []), context):
            var label := str(rule.get("label", ""))
            if label != "" and label not in active_labels:
                active_labels.append(label)
                added.append(label)
                _log("dynamic_reputation_label_added", 1.0, label)
                emit_signal("dynamic_label_added", label)
                emit_signal("reputation_rule_matched", rule)
    evaluation_history.append({"context": context.duplicate(true), "added": added.duplicate()})
    return added

func get_summary() -> Dictionary:
    return {"active_labels": active_labels.duplicate(), "evaluation_history": evaluation_history.duplicate(true)}

func _conditions_met(conditions: Array, context: Dictionary) -> bool:
    for condition in conditions:
        if not bool(context.get(str(condition), false)):
            return false
    return true

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
