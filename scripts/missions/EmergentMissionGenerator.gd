extends Node
class_name EmergentMissionGenerator

signal mission_generated(mission: Dictionary)

var archetypes: Array = []
var routes: Array = []
var components: Dictionary = {}
var generated_missions: Array[Dictionary] = []

func _ready() -> void:
    archetypes = _load_json_array("res://data/missions/generated_mission_archetypes.json", "archetypes")
    routes = _load_json_dict("res://data/missions/mission_routes.json").get("routes", [])
    components = _load_json_dict("res://data/missions/mission_components.json")

func generate_from_event(event: Dictionary, context: Dictionary = {}) -> Dictionary:
    var tags: Array = event.get("tags", [])
    var candidates: Array = []
    for archetype in archetypes:
        for tag in archetype.get("component_tags", []):
            if tag in tags:
                candidates.append(archetype)
                break
    if candidates.is_empty():
        return {}
    var archetype: Dictionary = candidates.pick_random()
    var mission := {
        "mission_id": "%s_generated_%d" % [archetype.get("id", "mission"), randi_range(1000, 9999)],
        "archetype": archetype.get("id", ""),
        "trigger_event": event.get("event_id", ""),
        "context": context,
        "routes": archetype.get("routes", routes),
        "success": [],
        "failure": [],
        "future_consequence": event.get("delayed_consequence", {})
    }
    generated_missions.append(mission)
    _log("generated_mission_from_state", 1.0, str(mission.get("mission_id", "")))
    emit_signal("mission_generated", mission)
    return mission

func get_summary() -> Dictionary:
    return {"generated_missions": generated_missions.duplicate(true), "archetypes": archetypes.duplicate(true)}

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
