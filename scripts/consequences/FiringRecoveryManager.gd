extends Node
class_name FiringRecoveryManager

signal firing_route_started(route: Dictionary)
signal recovery_step_completed(step_id: String)

var routes: Array = []
var active_routes: Array[Dictionary] = []
var completed_steps: Array[String] = []

func _ready() -> void:
    routes = _load_json_array("res://data/fireable/firing_routes.json", "routes")

func start_recovery_route(route_id: String = "") -> Dictionary:
    var route := {}
    if route_id != "":
        route = _find(route_id)
    elif not routes.is_empty():
        route = routes[active_routes.size() % routes.size()]
    else:
        route = {"id": "forced_retraining_arc", "description": "Forced retraining arc."}
    route["recoverable"] = true
    active_routes.append(route)
    _log("firing_recovery_started", 1.0, str(route.get("id", "")))
    emit_signal("firing_route_started", route)
    return route

func complete_step(step_id: String) -> void:
    completed_steps.append(step_id)
    _log("firing_recovery_step_completed", 1.0, step_id)
    emit_signal("recovery_step_completed", step_id)

func get_summary() -> Dictionary:
    return {"active_routes": active_routes.duplicate(true), "completed_steps": completed_steps.duplicate()}

func _find(route_id: String) -> Dictionary:
    for route in routes:
        if str(route.get("id", "")) == route_id:
            return route
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

func _log(event_name: String, value: float, detail: String):
    var event_log = get_tree().root.get_node_or_null("EventLog")
    if event_log and event_log.has_method("log_event"):
        event_log.log_event(event_name, value, detail)
