extends Node
class_name SuspicionManager

signal suspicion_changed(new_value: int)
signal detection_rolled(result: Dictionary)
signal investigation_started(reason: String)

var player_suspicion: int = 0
var manager_suspicion: int = 0
var corporate_audit_risk: int = 0
var evidence_flags: Array[String] = []
var repeat_behavior: Dictionary = {}
var detection_history: Array[Dictionary] = []
var investigation_history: Array[String] = []

func add_suspicion(amount: int, reason: String = "") -> void:
    player_suspicion = clamp(player_suspicion + amount, 0, 100)
    manager_suspicion = clamp(manager_suspicion + max(0, int(amount / 2)), 0, 100)
    corporate_audit_risk = clamp(corporate_audit_risk + max(0, int(amount / 3)), 0, 100)
    if reason != "":
        evidence_flags.append(reason)
        repeat_behavior[reason] = int(repeat_behavior.get(reason, 0)) + 1
    _log("suspicion_changed", float(player_suspicion), reason)
    emit_signal("suspicion_changed", player_suspicion)
    if player_suspicion >= 75:
        investigation_history.append(reason)
        _log("suspicion_investigation_started", float(player_suspicion), reason)
        emit_signal("investigation_started", reason)

func reduce_suspicion(amount: int, reason: String = "clean_play") -> void:
    player_suspicion = clamp(player_suspicion - amount, 0, 100)
    manager_suspicion = clamp(manager_suspicion - int(amount / 2), 0, 100)
    _log("suspicion_reduced", float(player_suspicion), reason)
    emit_signal("suspicion_changed", player_suspicion)

func roll_detection(action: Dictionary, context: Dictionary = {}) -> Dictionary:
    var base := int(action.get("base_detection_chance", 10))
    var witnesses := int(context.get("witnesses", 0)) * 8
    var camera := int(context.get("camera_coverage", 0))
    var manager := int(context.get("manager_nearby", 0)) * 15
    var chaos_reduction := int(context.get("chaos_level", 0)) * 4
    var loyalty_reduction := int(context.get("staff_loyalty", 0)) / 5
    var chance = clamp(base + witnesses + camera + manager + player_suspicion / 2 - chaos_reduction - loyalty_reduction, 0, 95)
    var caught: bool = bool(context.get("force_caught", false)) or (not bool(context.get("force_clean", false)) and randi_range(1, 100) <= chance)
    var result := {"caught": caught, "chance": chance, "action_id": action.get("offense_id", action.get("id", ""))}
    detection_history.append(result)
    _log("detection_rolled", float(chance), str(result.get("action_id", "")) + " caught=" + str(caught))
    emit_signal("detection_rolled", result)
    return result

func get_summary() -> Dictionary:
    return {
        "player_suspicion": player_suspicion,
        "manager_suspicion": manager_suspicion,
        "corporate_audit_risk": corporate_audit_risk,
        "evidence_flags": evidence_flags.duplicate(),
        "repeat_behavior": repeat_behavior.duplicate(true),
        "detection_history": detection_history.duplicate(true),
        "investigation_history": investigation_history.duplicate()
    }

func _log(event_name: String, value: float, detail: String):
    var event_log = get_tree().root.get_node_or_null("EventLog")
    if event_log and event_log.has_method("log_event"):
        event_log.log_event(event_name, value, detail)
