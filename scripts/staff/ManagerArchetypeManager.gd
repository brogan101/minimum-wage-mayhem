extends Node
class_name ManagerArchetypeManager

var managers: Array = []
var current_manager: Dictionary = {}

func _ready() -> void:
    managers = _load_json_array("res://data/staff/manager_archetypes.json", "managers")
    if not managers.is_empty():
        current_manager = managers[0]

func choose_manager(seed_offset: int = 0) -> Dictionary:
    if managers.is_empty():
        current_manager = {"id": "fallback_manager", "name": "Fallback Manager", "competence": 50}
    else:
        current_manager = managers[abs(seed_offset) % managers.size()]
    return current_manager

func get_modifier(key: String, fallback: int = 0) -> int:
    return int(current_manager.get(key, fallback))

func _load_json_array(path: String, key: String) -> Array:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: " + path)
        return []
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(parsed) != TYPE_DICTIONARY:
        push_warning("Invalid JSON dictionary: " + path)
        return []
    return parsed.get(key, [])
