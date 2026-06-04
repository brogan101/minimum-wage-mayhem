extends Node
class_name DemotionManager

signal demotion_risk_changed(value: int)
signal setback_triggered(setback: Dictionary)

var demotion_risk: int = 0
var rules: Array = []
var setbacks: Array = []

func _ready() -> void:
    rules = _load_json_array("res://data/career/demotion_rules.json", "rules")
    setbacks = _load_json_array("res://data/career/promotion_setback_events.json", "events")

func add_risk(amount: int, reason: String = "") -> void:
    demotion_risk += amount
    emit_signal("demotion_risk_changed", demotion_risk)
    if demotion_risk >= 100:
        var setback: Dictionary = setbacks.pick_random() if not setbacks.is_empty() else {"id": "generic_setback", "reason": reason, "recovery": "complete_retraining"}
        emit_signal("setback_triggered", setback)

func _load_json_array(path: String, key: String) -> Array:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: " + path)
        return []
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(parsed) != TYPE_DICTIONARY:
        push_warning("Invalid JSON dictionary: " + path)
        return []
    return parsed.get(key, [])
