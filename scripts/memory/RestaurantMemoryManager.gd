extends Node
class_name RestaurantMemoryManager

signal memory_recorded(entry: Dictionary)
signal memory_flag_added(flag_id: String)

var shift_memory: Array = []
var career_memory: Array = []
var active_flags: Array[String] = []
var rumor_history: Array[String] = []

func record_event(event: Dictionary, scope: String = "shift") -> void:
    var entry := {
        "event": event,
        "scope": scope,
        "shift_index": event.get("shift_index", -1),
        "tags": event.get("tags", []),
        "resolved": event.get("resolved", false)
    }
    shift_memory.append(entry)
    if scope == "career":
        career_memory.append(entry)
    _log("restaurant_memory_recorded", 1.0, str(event.get("event_id", "")))
    emit_signal("memory_recorded", entry)

func add_flag(flag_id: String) -> void:
    if flag_id in active_flags:
        return
    active_flags.append(flag_id)
    if "rumor" in flag_id:
        rumor_history.append(flag_id)
    _log("restaurant_memory_flag_added", 1.0, flag_id)
    emit_signal("memory_flag_added", flag_id)

func get_recent_by_tag(tag: String, limit: int = 5) -> Array:
    var results: Array = []
    for entry in shift_memory:
        if tag in entry.get("tags", []):
            results.append(entry)
    return results.slice(max(results.size() - limit, 0), results.size())

func get_summary() -> Dictionary:
    return {
        "shift_memory": shift_memory.duplicate(true),
        "career_memory": career_memory.duplicate(true),
        "active_flags": active_flags.duplicate(),
        "rumor_history": rumor_history.duplicate()
    }

func get_save_data() -> Dictionary:
    return get_summary()

func load_save_data(data: Dictionary) -> void:
    shift_memory = data.get("shift_memory", []).duplicate(true)
    career_memory = data.get("career_memory", []).duplicate(true)
    active_flags.assign(data.get("active_flags", []))
    rumor_history.assign(data.get("rumor_history", []))

func _log(event_name: String, value: float, detail: String):
    var event_log = get_tree().root.get_node_or_null("EventLog")
    if event_log and event_log.has_method("log_event"):
        event_log.log_event(event_name, value, detail)
