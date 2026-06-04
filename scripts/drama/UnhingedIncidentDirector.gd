extends Node
class_name UnhingedIncidentDirector

signal unhinged_incident_started(incident: Dictionary)
signal unhinged_incident_resolved(incident_id: String, outcome: Dictionary)
signal legendary_chain_started(chain: Dictionary)

var incidents: Array = []
var recent_incident_ids: Array[String] = []
var max_recent_memory: int = 8
var tutorial_mode: bool = false
var recovery_window_active: bool = false

func _ready() -> void:
    incidents = _load_json_array("res://data/incidents/unhinged_incidents.json", "incidents")

func choose_incident(context: Dictionary) -> Dictionary:
    var candidates: Array = []
    for incident in incidents:
        if _incident_allowed(incident, context):
            candidates.append(incident)
    if candidates.is_empty():
        return {}
    candidates.shuffle()
    return candidates[0]

func try_start_incident(context: Dictionary) -> Dictionary:
    var incident := choose_incident(context)
    if incident.is_empty():
        return {}
    recent_incident_ids.append(str(incident.get("id", "")))
    while recent_incident_ids.size() > max_recent_memory:
        recent_incident_ids.pop_front()
    emit_signal("unhinged_incident_started", incident)
    return incident

func resolve_incident(incident_id: String, outcome: Dictionary) -> void:
    emit_signal("unhinged_incident_resolved", incident_id, outcome)

func _incident_allowed(incident: Dictionary, context: Dictionary) -> bool:
    var id := str(incident.get("id", ""))
    if id in recent_incident_ids:
        return false
    if tutorial_mode and str(incident.get("severity", "")) in ["moderate", "major", "legendary"]:
        return false
    if recovery_window_active and str(incident.get("severity", "")) in ["major", "legendary"]:
        return false
    if int(incident.get("chaos_cost", 0)) > int(context.get("chaos_available", 10)):
        return false
    if int(incident.get("cognitive_load", 0)) > int(context.get("cognitive_load_available", 10)):
        return false
    for condition in incident.get("blocked_conditions", []):
        if bool(context.get(str(condition), false)):
            return false
    for condition in incident.get("trigger_conditions", []):
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
