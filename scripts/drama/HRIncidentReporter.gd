extends Node
class_name HRIncidentReporter

signal hr_report_generated(report: Dictionary)

var templates: Array = []
var training_modules: Array = []

func _ready() -> void:
    templates = _load_json_array("res://data/hr/hr_report_templates.json", "templates")
    training_modules = _load_json_array("res://data/hr/fake_training_modules.json", "modules")

func generate_report(context: Dictionary) -> Dictionary:
    var template := str(templates.pick_random()) if not templates.is_empty() else "Incident recorded: [INCIDENT]."
    var report := {
        "template": template,
        "incident": context.get("incident", "unknown incident"),
        "object": context.get("object", "unknown object"),
        "training_module": training_modules.pick_random() if not training_modules.is_empty() else "General Training",
        "severity": context.get("severity", "minor"),
        "evidence_quality": context.get("evidence_quality", "questionable")
    }
    emit_signal("hr_report_generated", report)
    return report

func _load_json_array(path: String, key: String) -> Array:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: " + path)
        return []
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(parsed) != TYPE_DICTIONARY:
        push_warning("Invalid JSON dictionary: " + path)
        return []
    return parsed.get(key, [])
