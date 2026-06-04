extends Node
class_name SlapstickBrawlManager

signal brawl_considered(context: Dictionary)
signal brawl_started(data: Dictionary)
signal brawl_deescalated(method: String)
signal brawl_resolved(outcome: Dictionary)

var triggers: Array = []
var actions: Array = []
var outcomes: Array = []
var tutorial_mode: bool = false

func _ready() -> void:
    triggers = _load_json_array("res://data/fights/brawl_triggers.json", "triggers")
    actions = _load_json_array("res://data/fights/brawl_actions.json", "actions")
    outcomes = _load_json_array("res://data/fights/brawl_outcomes.json", "outcomes")

func can_consider_brawl(context: Dictionary) -> bool:
    if tutorial_mode:
        return false
    if bool(context.get("recovery_window", false)):
        return false
    if int(context.get("beef", 0)) < int(context.get("beef_threshold", 100)):
        return false
    return true

func start_brawl(context: Dictionary) -> Dictionary:
    emit_signal("brawl_considered", context)
    if not can_consider_brawl(context):
        emit_signal("brawl_deescalated", "blocked_by_rules")
        return {}
    var data := {"stage": "counter_slapstick_scramble", "available_actions": actions, "context": context}
    emit_signal("brawl_started", data)
    return data

func resolve_brawl(action_id: String) -> Dictionary:
    var outcome: Dictionary = outcomes.pick_random() if not outcomes.is_empty() else {"id": "customer_leaves_angry", "effects": ["beef_down"]}
    outcome["player_action"] = action_id
    emit_signal("brawl_resolved", outcome)
    return outcome

func _load_json_array(path: String, key: String) -> Array:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: " + path)
        return []
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(parsed) != TYPE_DICTIONARY:
        push_warning("Invalid JSON dictionary: " + path)
        return []
    return parsed.get(key, [])
