extends Node
class_name DepthEventLinker

signal depth_event_linked(entry: Dictionary)

func link_depth_entry(entry: Dictionary, context: Dictionary = {}) -> Dictionary:
    var linked := {
        "id": entry.get("id", "unknown_depth_entry"),
        "source": context.get("source", "depth"),
        "eventlog": true,
        "memory": true,
        "consequence_or_modifier": true,
        "systems": context.get("systems", entry.get("systems_connected", [])),
        "context": context
    }
    var memory = get_tree().root.find_child("RestaurantMemoryManager", true, false)
    if memory and memory.has_method("record_event"):
        memory.record_event({
            "event_id": linked["id"],
            "tags": entry.get("tags", entry.get("systems_connected", [])),
            "depth_source": linked.get("source", "depth"),
            "resolved": false
        }, "career")
    var event_log = get_tree().root.get_node_or_null("EventLog")
    if event_log and event_log.has_method("log_event"):
        event_log.log_event("depth_event_linked", 1.0, str(linked.get("id", "")))
    emit_signal("depth_event_linked", linked)
    return linked
