extends Node
class_name ShadyChoiceManager

signal choices_opened(template: Dictionary)
signal choice_selected(choice_id: String, result: Dictionary)

var templates: Array = []

func _ready() -> void:
    templates = _load_json_array("res://data/fireable/ui_choice_templates.json", "templates")

func get_choices_for(interactable: String) -> Dictionary:
    for template in templates:
        if str(template.get("interactable", "")) == interactable:
            emit_signal("choices_opened", template)
            return template
    var fallback := {"id": "generic", "interactable": interactable, "choices": ["leave_it", "do_right_thing", "make_it_worse"]}
    emit_signal("choices_opened", fallback)
    return fallback

func select_choice(choice_id: String, context: Dictionary = {}) -> Dictionary:
    var result := {"choice_id": choice_id, "context": context, "abstract_ui_choice": true}
    if not bool(context.get("clean_choice", false)):
        var fireable = get_tree().root.find_child("FireableOffenseManager", true, false)
        if fireable and fireable.has_method("process_shady_choice"):
            result["consequence"] = fireable.process_shady_choice(str(context.get("offense_id", choice_id)), context)
    else:
        var fireable = get_tree().root.find_child("FireableOffenseManager", true, false)
        if fireable and fireable.has_method("record_clean_choice"):
            result["consequence"] = fireable.record_clean_choice(choice_id)
    _log("shady_ui_choice_selected", 1.0, choice_id)
    emit_signal("choice_selected", choice_id, result)
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
