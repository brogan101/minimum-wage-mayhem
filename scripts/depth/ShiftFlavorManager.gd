extends Node
class_name ShiftFlavorManager

signal shift_flavor_ready(flavor: Dictionary)

var manager_pressure: Array = []
var home_events: Array = []
var commute_events: Array = []
var equipment: Array = []
var store_ops_depth: Array = []
var minigames: Array = []
var flavor_history: Array[Dictionary] = []

func _ready() -> void:
    manager_pressure = _load_json_array("res://data/depth/manager_pressure_situations.json", "situations")
    home_events = _load_json_array("res://data/depth/home_life_depth_events.json", "events")
    commute_events = _load_json_array("res://data/depth/commute_micro_events.json", "events")
    equipment = _load_json_array("res://data/depth/equipment_personality.json", "equipment")
    store_ops_depth = _load_json_array("res://data/depth/store_ops_depth.json", "ops")
    minigames = _load_json_array("res://data/depth/minigames.json", "minigames")

func build_shift_flavor(context: Dictionary = {}) -> Dictionary:
    var flavor := {
        "manager_pressure": manager_pressure.pick_random() if not manager_pressure.is_empty() else {},
        "home_event": home_events.pick_random() if not home_events.is_empty() else {},
        "commute_event": commute_events.pick_random() if not commute_events.is_empty() else {},
        "equipment_quirk": equipment.pick_random() if not equipment.is_empty() else {},
        "store_ops_depth": store_ops_depth.pick_random() if not store_ops_depth.is_empty() else {},
        "minigame": minigames.pick_random() if not minigames.is_empty() else {}
    }
    flavor_history.append(flavor)
    _apply_flavor(flavor)
    _log("shift_flavor_ready", 1.0, str(flavor.get("equipment_quirk", {}).get("id", "flavor")))
    emit_signal("shift_flavor_ready", flavor)
    return flavor

func get_summary() -> Dictionary:
    return {"flavor_history": flavor_history.duplicate(true)}

func _apply_flavor(flavor: Dictionary):
    var store_ops = get_tree().root.find_child("StoreOpsDirector", true, false)
    if store_ops:
        store_ops.review_risk = clamp(int(store_ops.review_risk) + 1, 0, 100)
        store_ops.cleanliness = clamp(int(store_ops.cleanliness) - 1, 0, 100)
        if store_ops.has_method("_recalculate_modifiers"):
            store_ops._recalculate_modifiers()
        if store_ops.has_method("_emit_status"):
            store_ops._emit_status("depth_shift_flavor")

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
