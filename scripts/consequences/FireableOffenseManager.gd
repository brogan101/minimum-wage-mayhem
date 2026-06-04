extends Node
class_name FireableOffenseManager

signal offense_recorded(offense: Dictionary)
signal caught_level_applied(level: Dictionary)
signal fired_route_selected(route: Dictionary)

var offenses: Array = []
var caught_levels: Array = []
var firing_routes: Array = []
var active_offense_history: Array = []
var caught_history: Array[Dictionary] = []
var hr_reports: Array[String] = []
var reviews: Array[String] = []
var recovery_routes: Array[Dictionary] = []
var loaded_fireable_catalogs := {}

func _ready() -> void:
    _load_fireable_catalogs()
    offenses = _load_json_array("res://data/fireable/fireable_offenses.json", "offenses")
    caught_levels = _load_json_array("res://data/fireable/caught_levels.json", "levels")
    firing_routes = _load_json_array("res://data/fireable/firing_routes.json", "routes")

func record_offense(offense_id: String, context: Dictionary = {}) -> Dictionary:
    var offense := _find(offenses, "offense_id", offense_id)
    if offense.is_empty():
        offense = {"offense_id": offense_id, "display_name": offense_id, "severity": "minor", "base_detection_chance": 10, "promotion_delta": -1, "demotion_risk_delta": 1, "fired_risk_delta": 1, "safety_note": "Fallback abstract offense."}
    active_offense_history.append(offense)
    _log("fireable_offense_recorded", float(_severity_index(str(offense.get("severity", "minor")))), str(offense.get("offense_id", "")))
    emit_signal("offense_recorded", offense)
    return offense

func apply_caught_level(severity_index: int) -> Dictionary:
    if caught_levels.is_empty():
        return {}
    var index = clamp(severity_index, 0, caught_levels.size() - 1)
    var level: Dictionary = caught_levels[index]
    caught_history.append(level)
    _log("caught_level_applied", float(index), str(level.get("id", "")))
    emit_signal("caught_level_applied", level)
    return level

func select_firing_route(context: Dictionary = {}) -> Dictionary:
    if firing_routes.is_empty():
        return {"id": "forced_retraining_arc"}
    var route: Dictionary = firing_routes[int(context.get("route_index", recovery_routes.size())) % firing_routes.size()]
    recovery_routes.append(route)
    _log("firing_recovery_route_selected", 1.0, str(route.get("id", "")))
    emit_signal("fired_route_selected", route)
    return route

func process_shady_choice(offense_id: String, context: Dictionary = {}) -> Dictionary:
    var offense = record_offense(offense_id, context)
    var suspicion = get_tree().root.find_child("SuspicionManager", true, false)
    var suspicion_delta = _risk_delta(str(context.get("risk", offense.get("risk", "medium")))) + _severity_index(str(offense.get("severity", "minor"))) * 4
    if suspicion and suspicion.has_method("add_suspicion"):
        suspicion.add_suspicion(suspicion_delta, str(offense.get("offense_id", offense_id)))
    var detection = suspicion.roll_detection(offense, context) if suspicion and suspicion.has_method("roll_detection") else {"caught": false, "chance": 0, "action_id": offense_id}
    var caught_level = apply_caught_level(_severity_index(str(offense.get("severity", "minor")))) if bool(detection.get("caught", false)) else {}
    var route = {}
    _apply_consequences(offense, detection, caught_level, context)
    if _should_offer_recovery(offense, detection):
        var recovery = get_tree().root.find_child("FiringRecoveryManager", true, false)
        route = recovery.start_recovery_route() if recovery and recovery.has_method("start_recovery_route") else select_firing_route(context)
        if route.is_empty():
            route = select_firing_route(context)
        if not route.is_empty() and not recovery_routes.has(route):
            recovery_routes.append(route)
    var result = {
        "offense": offense,
        "detection": detection,
        "caught_level": caught_level,
        "recovery_route": route,
        "abstract_ui_choice": true,
        "consequence_heavy": true,
        "non_instructional": true
    }
    _log("shady_choice_processed", float(suspicion_delta), offense_id + " caught=" + str(detection.get("caught", false)))
    return result

func record_clean_choice(reason: String = "clean_play") -> Dictionary:
    var suspicion = get_tree().root.find_child("SuspicionManager", true, false)
    if suspicion and suspicion.has_method("reduce_suspicion"):
        suspicion.reduce_suspicion(8, reason)
    var career = get_tree().root.get_node_or_null("CareerManager")
    if career:
        career.promotion_progress = clamp(int(career.promotion_progress) + 1, 0, 100)
        career.manager_trust = clamp(int(career.manager_trust) + 1, 0, 100)
    _log("clean_choice_recorded", 1.0, reason)
    return {"reason": reason, "clean_play_valid": true}

func get_consequence_summary() -> Dictionary:
    var suspicion = get_tree().root.find_child("SuspicionManager", true, false)
    return {
        "offenses": active_offense_history.duplicate(true),
        "caught_history": caught_history.duplicate(true),
        "hr_reports": hr_reports.duplicate(),
        "reviews": reviews.duplicate(),
        "recovery_routes": recovery_routes.duplicate(true),
        "loaded_fireable_catalogs": loaded_fireable_catalogs.keys(),
        "suspicion": suspicion.get_summary() if suspicion and suspicion.has_method("get_summary") else {}
    }

func _apply_consequences(offense: Dictionary, detection: Dictionary, caught_level: Dictionary, context: Dictionary):
    var severity = _severity_index(str(offense.get("severity", "minor")))
    var caught = bool(detection.get("caught", false))
    var career = get_tree().root.get_node_or_null("CareerManager")
    var staff = get_tree().root.find_child("StaffDirector", true, false)
    var store_ops = get_tree().root.find_child("StoreOpsDirector", true, false)
    if staff:
        staff.manager_trust = clamp(int(staff.manager_trust) - severity - (2 if caught else 0), 0, 100)
        staff.staff_morale = clamp(int(staff.staff_morale) - max(1, severity), 0, 100)
        if staff.has_method("_emit_status"):
            staff._emit_status("fireable_consequence")
    if store_ops:
        store_ops.review_risk = clamp(int(store_ops.review_risk) + severity + (3 if caught else 0), 0, 100)
        store_ops.manager_trust = clamp(int(store_ops.manager_trust) - severity, 0, 100)
        if store_ops.has_method("_recalculate_modifiers"):
            store_ops._recalculate_modifiers()
        if store_ops.has_method("_emit_status"):
            store_ops._emit_status("fireable_consequence")
    if caught:
        hr_reports.append("HR noted " + str(offense.get("display_name", offense.get("offense_id", "shady choice"))))
        reviews.append("A customer review mentioned suspicious shift energy.")
    if career and career.has_method("apply_incident_impact"):
        career.apply_incident_impact({
            "id": offense.get("offense_id", ""),
            "severity": str(offense.get("severity", "minor")),
            "writeup": caught and severity >= 2,
            "warning": caught,
            "demotion_risk": int(offense.get("demotion_risk_delta", severity * 3)),
            "fired_risk": int(offense.get("fired_risk_delta", severity * 4)) if caught else max(1, severity),
            "promotion_progress": int(offense.get("promotion_delta", -severity)),
            "reputation_label": "high_risk_employee"
        })

func _should_offer_recovery(offense: Dictionary, detection: Dictionary) -> bool:
    if not bool(detection.get("caught", false)):
        return false
    var severity = _severity_index(str(offense.get("severity", "minor")))
    var career = get_tree().root.get_node_or_null("CareerManager")
    var risk = int(career.fired_risk) if career else 0
    return severity >= 3 or risk >= 25

func _severity_index(severity: String) -> int:
    match severity:
        "minor":
            return 1
        "moderate":
            return 2
        "major":
            return 3
        "legendary":
            return 4
        _:
            return 1

func _risk_delta(risk: String) -> int:
    match risk:
        "low":
            return 0
        "medium":
            return 8
        "high":
            return 16
        _:
            return 6

func _find(list: Array, key: String, value: String) -> Dictionary:
    for item in list:
        if str(item.get(key, "")) == value:
            return item
    return {}

func _load_fireable_catalogs():
    var dir = DirAccess.open("res://data/fireable")
    if not dir:
        return
    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        if not dir.current_is_dir() and file_name.ends_with(".json"):
            var path = "res://data/fireable/" + file_name
            loaded_fireable_catalogs[path] = _load_json_dictionary(path)
        file_name = dir.get_next()
    dir.list_dir_end()

func _load_json_array(path: String, key: String) -> Array:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: " + path)
        return []
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(parsed) != TYPE_DICTIONARY:
        push_warning("Invalid JSON dictionary: " + path)
        return []
    return parsed.get(key, [])

func _load_json_dictionary(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: " + path)
        return {}
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(parsed) != TYPE_DICTIONARY:
        push_warning("Invalid JSON dictionary: " + path)
        return {}
    return parsed

func _log(event_name: String, value: float, detail: String):
    var event_log = get_tree().root.get_node_or_null("EventLog")
    if event_log and event_log.has_method("log_event"):
        event_log.log_event(event_name, value, detail)
