extends Node
class_name EmergentEventDirector

signal generated_event_created(event: Dictionary)
signal generated_event_resolved(event_id: String, result: Dictionary)

const IncidentComposerScript = preload("res://scripts/emergent/IncidentComposer.gd")

var composer: Node
var recent_generated_events: Array = []
var generated_missions: Array = []
var generated_hr_reports: Array[String] = []
var generated_reviews: Array[String] = []
var generated_recaps: Array[Dictionary] = []
var generated_evidence: Array[Dictionary] = []
var future_chains: Array = []
var dynamic_labels: Array = []
var loaded_emergent_catalogs := {}

func _ready() -> void:
    composer = IncidentComposerScript.new()
    add_child(composer)
    _load_emergent_catalogs()

func generate_event(context: Dictionary = {}) -> Dictionary:
    var state_context = _build_state_context(context)
    var event: Dictionary = composer.compose_event(state_context)
    event["shift_index"] = state_context.get("shift_index", 0)
    recent_generated_events.append(event)
    _process_event(event, state_context)
    _log("emergent_event_generated", 1.0, str(event.get("event_id", "")))
    emit_signal("generated_event_created", event)
    return event

func resolve_event(event_id: String, result: Dictionary) -> void:
    var memory = get_tree().root.find_child("RestaurantMemoryManager", true, false)
    if memory and memory.has_method("record_event"):
        memory.record_event({"event_id": event_id, "resolved": true, "tags": result.get("tags", [])}, "career")
    _log("emergent_event_resolved", 1.0, event_id)
    emit_signal("generated_event_resolved", event_id, result)

func get_emergent_summary() -> Dictionary:
    var memory = get_tree().root.find_child("RestaurantMemoryManager", true, false)
    var evidence = get_tree().root.find_child("EvidenceManager", true, false)
    var object_memory = get_tree().root.find_child("StoreObjectMemoryManager", true, false)
    var karma = get_tree().root.find_child("MultiKarmaManager", true, false)
    return {
        "events": recent_generated_events.duplicate(true),
        "missions": generated_missions.duplicate(true),
        "hr_reports": generated_hr_reports.duplicate(),
        "reviews": generated_reviews.duplicate(),
        "recaps": generated_recaps.duplicate(true),
        "evidence": generated_evidence.duplicate(true),
        "future_chains": future_chains.duplicate(true),
        "dynamic_labels": dynamic_labels.duplicate(),
        "loaded_emergent_catalogs": loaded_emergent_catalogs.keys(),
        "memory": memory.get_summary() if memory and memory.has_method("get_summary") else {},
        "object_memory": object_memory.get_summary() if object_memory and object_memory.has_method("get_summary") else {},
        "karma": karma.get_summary() if karma and karma.has_method("get_summary") else {},
        "evidence_summary": evidence.get_summary() if evidence and evidence.has_method("get_summary") else {}
    }

func _process_event(event: Dictionary, context: Dictionary):
    var memory = get_tree().root.find_child("RestaurantMemoryManager", true, false)
    var evidence = get_tree().root.find_child("EvidenceManager", true, false)
    var object_memory = get_tree().root.find_child("StoreObjectMemoryManager", true, false)
    var matrix = get_tree().root.find_child("ConsequenceMatrixManager", true, false)
    var mission_generator = get_tree().root.find_child("EmergentMissionGenerator", true, false)
    var karma = get_tree().root.find_child("MultiKarmaManager", true, false)
    var reputation = get_tree().root.find_child("DynamicReputationLabelManager", true, false)
    var recap = get_tree().root.find_child("GeneratedRecapManager", true, false)
    var future = get_tree().root.find_child("FutureChainTriggerManager", true, false)
    if memory and memory.has_method("record_event"):
        memory.record_event(event, "career")
        for tag in event.get("tags", []):
            memory.add_flag(str(tag))
    if evidence and evidence.has_method("create_evidence") and ("evidence" in event.get("tags", []) or bool(context.get("force_evidence", false))):
        var evidence_entry = evidence.create_evidence("shift_note", event, 1)
        generated_evidence.append(evidence_entry)
    var object_id = str(event.get("object", {}).get("id", ""))
    if object_memory and object_memory.has_method("record_object_incident") and object_id != "":
        object_memory.record_object_incident(object_id, event)
    var consequence_result = matrix.calculate(event, context) if matrix and matrix.has_method("calculate") else {}
    _apply_consequence_result(consequence_result, event)
    if karma and karma.has_method("apply_event"):
        karma.apply_event(event, consequence_result)
    if reputation and reputation.has_method("evaluate"):
        var labels = reputation.evaluate(_build_reputation_context(event, consequence_result))
        for label in labels:
            dynamic_labels.append(str(label))
    var mission = mission_generator.generate_from_event(event, context) if mission_generator and mission_generator.has_method("generate_from_event") else {}
    if not mission.is_empty():
        generated_missions.append(mission)
        _log("emergent_mission_generated", 1.0, str(mission.get("mission_id", "")))
    if future and future.has_method("evaluate"):
        var chains = future.evaluate(_build_reputation_context(event, consequence_result))
        for chain in chains:
            future_chains.append(chain)
    _generate_interpretations(event, consequence_result)
    if recap and recap.has_method("build_recap"):
        generated_recaps.append(recap.build_recap(_build_recap_context(event, consequence_result)))

func _build_state_context(extra: Dictionary) -> Dictionary:
    var shift_results = get_tree().root.get_node_or_null("ShiftResultManager")
    var fireable = get_tree().root.find_child("FireableOffenseManager", true, false)
    var mischief = get_tree().root.find_child("MischiefDirector", true, false)
    var chaos = get_tree().root.find_child("ChaosIncidentRuntime", true, false)
    var context = extra.duplicate(true)
    context["shift_index"] = shift_results.shift_number if shift_results else 0
    context["has_fireable_history"] = fireable and fireable.has_method("get_consequence_summary") and fireable.get_consequence_summary().get("offenses", []).size() > 0
    context["has_mischief_history"] = mischief and mischief.has_method("get_mischief_summary") and mischief.get_mischief_summary().get("pranks", []).size() > 0
    context["has_chaos_history"] = chaos and chaos.has_method("get_phase9_summary") and chaos.get_phase9_summary().get("incidents", []).size() > 0
    context["force_evidence"] = bool(context.get("force_evidence", false)) or context["has_fireable_history"]
    return context

func _apply_consequence_result(result: Dictionary, event: Dictionary):
    var wallet = get_tree().root.get_node_or_null("WalletManager")
    var career = get_tree().root.get_node_or_null("CareerManager")
    var staff = get_tree().root.find_child("StaffDirector", true, false)
    var store_ops = get_tree().root.find_child("StoreOpsDirector", true, false)
    if wallet and wallet.has_method("add_money") and int(result.get("cash_delta", 0)) != 0:
        wallet.add_money(float(result.get("cash_delta", 0)))
    if career:
        if career.has_method("add_xp"):
            career.add_xp(float(result.get("xp_delta", 0)))
        career.promotion_progress = clamp(int(career.promotion_progress) + int(result.get("promotion_progress", 0)), 0, 100)
        if career.has_method("apply_incident_impact"):
            career.apply_incident_impact({
                "id": event.get("event_id", "emergent_event"),
                "severity": str(event.get("problem", {}).get("severity", "minor")),
                "warning": int(result.get("hr_report_chance", 0)) > 0,
                "demotion_risk": int(result.get("demotion_risk", 0)),
                "fired_risk": int(result.get("fired_risk", 0)),
                "promotion_progress": int(result.get("promotion_progress", 0)),
                "reputation_label": "restaurant_remembers"
            })
    if staff:
        staff.staff_morale = clamp(int(staff.staff_morale) + int(result.get("staff_morale", 0)), 0, 100)
        staff.manager_trust = clamp(int(staff.manager_trust) + int(result.get("manager_trust", 0)), 0, 100)
        if staff.has_method("_emit_status"):
            staff._emit_status("emergent_event")
    if store_ops:
        store_ops.review_risk = clamp(int(store_ops.review_risk) + int(result.get("review_chance", 0)) / 10, 0, 100)
        store_ops.corporate_approval = clamp(int(store_ops.corporate_approval) + int(result.get("corporate_approval", 0)), 0, 100)
        if store_ops.has_method("_recalculate_modifiers"):
            store_ops._recalculate_modifiers()
        if store_ops.has_method("_emit_status"):
            store_ops._emit_status("emergent_event")

func _generate_interpretations(event: Dictionary, result: Dictionary):
    var tags = event.get("tags", [])
    if int(result.get("hr_report_chance", 0)) > 0 or "hr" in tags or "evidence" in tags:
        generated_hr_reports.append("HR generated from " + str(event.get("event_id", "event")))
        _log("emergent_hr_generated", 1.0, str(event.get("event_id", "")))
    if int(result.get("review_chance", 0)) > 0 or "customer" in tags or "customer_visible" in tags:
        generated_reviews.append("Review mutated around " + str(event.get("object", {}).get("id", "the restaurant")))
        _log("emergent_review_generated", 1.0, str(event.get("event_id", "")))

func _build_reputation_context(event: Dictionary, result: Dictionary) -> Dictionary:
    var tags = event.get("tags", [])
    return {
        "sauce_incidents_3": "sauce" in tags,
        "hr_reports_5": generated_hr_reports.size() >= 1,
        "food_karma_low": "food_karma" in tags,
        "coworker_karma_high": "coworker" in tags and int(result.get("staff_morale", 0)) > 0,
        "corporate_karma_high": "corporate" in tags,
        "staff_morale_low": int(result.get("staff_morale", 0)) < 0,
        "mop_incidents_3": str(event.get("object", {}).get("id", "")) == "mop",
        "promotion_high": int(result.get("promotion_progress", 0)) > 0,
        "suspicion_high": int(result.get("suspicion", 0)) > 0,
        "fired_risk_high": int(result.get("fired_risk", 0)) > 0,
        "shifts_survived": true,
        "future_chain_chance": int(result.get("future_chain_chance", 0)) > 0,
        "evidence": generated_evidence.size() > 0
    }

func _build_recap_context(event: Dictionary, result: Dictionary) -> Dictionary:
    return {
        "cash": result.get("cash_delta", 0),
        "tips": result.get("tip_delta", 0),
        "xp": result.get("xp_delta", 0),
        "customer_beef": result.get("customer_beef", 0),
        "staff_morale": result.get("staff_morale", 0),
        "manager_trust": result.get("manager_trust", 0),
        "corporate_approval": result.get("corporate_approval", 0),
        "promotion_progress": result.get("promotion_progress", 0),
        "demotion_risk": result.get("demotion_risk", 0),
        "fired_risk": result.get("fired_risk", 0),
        "suspicion": result.get("suspicion", 0),
        "evidence": generated_evidence.size(),
        "karma": event.get("tags", []),
        "hr_reports": generated_hr_reports.size(),
        "reviews": generated_reviews.size(),
        "missions": generated_missions.size(),
        "most_unhinged_moment": str(event.get("event_id", "event")),
        "funniest_object": str(event.get("object", {}).get("id", "object")),
        "worst_decision": str(event.get("problem", {}).get("id", "problem")),
        "best_recovery": str(event.get("delayed_consequence", {}).get("id", "pending")),
        "rumor_started": "rumor" in event.get("tags", []),
        "next_shift_warning": "The restaurant remembers " + str(event.get("object", {}).get("id", "everything"))
    }

func _load_emergent_catalogs():
    for path in [
        "res://data/emergent/event_components.json",
        "res://data/emergent/event_formula.json",
        "res://data/emergent/generated_event_templates.json",
        "res://data/emergent/hr_interpretations.json",
        "res://data/emergent/review_interpretations.json",
        "res://data/emergent/career_impacts.json",
        "res://data/emergent/future_chain_triggers.json"
    ]:
        loaded_emergent_catalogs[path] = _load_json_dictionary(path)

func _load_json_dictionary(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: " + path)
        return {}
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _log(event_name: String, value: float, detail: String):
    var event_log = get_tree().root.get_node_or_null("EventLog")
    if event_log and event_log.has_method("log_event"):
        event_log.log_event(event_name, value, detail)
