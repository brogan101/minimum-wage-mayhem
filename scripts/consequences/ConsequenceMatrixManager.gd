extends Node
class_name ConsequenceMatrixManager

signal consequences_calculated(result: Dictionary)

var consequence_rules: Dictionary = {}
var modifiers: Array = []
var calculation_history: Array[Dictionary] = []

func _ready() -> void:
    consequence_rules = _load_json_dict("res://data/consequences/consequence_rules.json")
    modifiers = _load_json_array("res://data/consequences/outcome_modifiers.json", "modifiers")

func calculate(event: Dictionary, context: Dictionary = {}) -> Dictionary:
    var result := {
        "cash_delta": 0,
        "tip_delta": 0,
        "xp_delta": 5,
        "time_lost": 0,
        "customer_beef": 0,
        "staff_morale": 0,
        "manager_trust": 0,
        "manager_suspicion": 0,
        "corporate_approval": 0,
        "store_stability": 0,
        "suspicion": 0,
        "hr_report_chance": 0,
        "review_chance": 0,
        "viral_clip_chance": 0,
        "promotion_progress": 0,
        "demotion_risk": 0,
        "fired_risk": 0,
        "future_chain_chance": 0
    }
    var immediate: Dictionary = event.get("immediate_consequence", {}).get("effects", {})
    for key in immediate.keys():
        result[key] = int(result.get(key, 0)) + int(immediate[key])
    _apply_context_modifiers(result, context)
    calculation_history.append({"event_id": event.get("event_id", ""), "result": result.duplicate(true)})
    _log("emergent_consequences_calculated", 1.0, str(event.get("event_id", "")))
    emit_signal("consequences_calculated", result)
    return result

func get_summary() -> Dictionary:
    return {"calculation_history": calculation_history.duplicate(true), "rules": consequence_rules.duplicate(true)}

func _apply_context_modifiers(result: Dictionary, context: Dictionary) -> void:
    if bool(context.get("huge_rush", false)):
        result["customer_beef"] = int(result.get("customer_beef", 0)) + 10
        result["suspicion"] = int(result.get("suspicion", 0)) - 5
    if bool(context.get("corporate_climber_nearby", false)):
        result["hr_report_chance"] = int(result.get("hr_report_chance", 0)) + 20
        result["suspicion"] = int(result.get("suspicion", 0)) + 10
    if bool(context.get("loyal_coworker_nearby", false)):
        result["suspicion"] = int(result.get("suspicion", 0)) - 5

func _load_json_array(path: String, key: String) -> Array:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: " + path)
        return []
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(parsed) != TYPE_DICTIONARY:
        push_warning("Invalid JSON dictionary: " + path)
        return []
    return parsed.get(key, [])

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
