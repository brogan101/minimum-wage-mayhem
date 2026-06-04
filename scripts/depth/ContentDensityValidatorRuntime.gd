extends Node
class_name ContentDensityValidatorRuntime

signal density_warning(message: String)

var budgets: Dictionary = {}
var fallback_rules: Dictionary = {}
var validation_history: Array[Dictionary] = []

func _ready() -> void:
    budgets = _load_json_dict("res://data/depth/performance_budgets.json").get("budgets", {})
    fallback_rules = _load_json_dict("res://data/depth/bug_fallback_requirements.json")

func check_runtime_counts(counts: Dictionary) -> bool:
    var ok := true
    for key in budgets.keys():
        if int(counts.get(key, 0)) > int(budgets[key]):
            ok = false
            emit_signal("density_warning", "%s over budget" % key)
    validation_history.append({"counts": counts.duplicate(true), "ok": ok})
    _log("content_density_checked", 1.0 if ok else 0.0, str(counts))
    return ok

func get_summary() -> Dictionary:
    return {"budgets": budgets.duplicate(true), "fallback_rules": fallback_rules.duplicate(true), "validation_history": validation_history.duplicate(true)}

func _load_json_dict(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: " + path)
        return {}
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _log(event_name: String, value: float, detail: String):
    var event_log = get_tree().root.get_node_or_null("EventLog")
    if event_log and event_log.has_method("log_event"):
        event_log.log_event(event_name, value, detail)
