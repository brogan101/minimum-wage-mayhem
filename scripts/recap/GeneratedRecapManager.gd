extends Node
class_name GeneratedRecapManager

signal generated_recap_ready(recap: Dictionary)

var fields: Array = []
var recap_history: Array[Dictionary] = []

func _ready() -> void:
    fields = _load_json_dict("res://data/recap/generated_recap_fields.json").get("fields", [])

func build_recap(context: Dictionary) -> Dictionary:
    var recap := {}
    for field in fields:
        recap[field] = context.get(field, _default_for(str(field)))
    recap_history.append(recap)
    _log("generated_recap_ready", 1.0, str(recap.get("next_shift_warning", "")))
    emit_signal("generated_recap_ready", recap)
    return recap

func get_summary() -> Dictionary:
    return {"recap_history": recap_history.duplicate(true), "fields": fields.duplicate()}

func _default_for(field: String):
    match field:
        "most_unhinged_moment":
            return "Somehow, nothing was the weirdest thing."
        "funniest_object":
            return "None yet."
        "worst_decision":
            return "Pending investigation."
        "best_recovery":
            return "Still developing."
        "next_shift_warning":
            return "The restaurant remembers."
        _:
            return 0

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
