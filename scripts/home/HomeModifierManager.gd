extends Node
class_name HomeModifierManager

signal modifier_applied(modifier: Dictionary)

var modifiers: Array = []
var active_modifiers: Array = []

func _ready() -> void:
    modifiers = _load_json_array("res://data/home/home_modifiers.json", "modifiers")

func apply_modifier(modifier_id: String) -> Dictionary:
    for modifier in modifiers:
        if str(modifier.get("id", "")) == modifier_id:
            active_modifiers.append(modifier)
            emit_signal("modifier_applied", modifier)
            return modifier
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
