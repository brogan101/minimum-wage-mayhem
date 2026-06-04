extends Node
class_name EvidenceManager

signal evidence_created(evidence: Dictionary)
signal evidence_decayed(evidence_id: String)

var evidence_types: Array = []
var active_evidence: Array = []

func _ready() -> void:
    evidence_types = _load_json_array("res://data/memory/evidence_types.json", "evidence_types")

func create_evidence(evidence_type_id: String, source_event: Dictionary, strength_bonus: int = 0) -> Dictionary:
    var template := _find_type(evidence_type_id)
    if template.is_empty():
        template = {"id": evidence_type_id, "strength": 1, "decay_shifts": 1}
    var evidence := {
        "id": "%s_%d" % [evidence_type_id, active_evidence.size()],
        "type": evidence_type_id,
        "strength": int(template.get("strength", 1)) + strength_bonus,
        "decay_shifts": int(template.get("decay_shifts", 1)),
        "source_event_id": source_event.get("event_id", ""),
        "tags": source_event.get("tags", [])
    }
    active_evidence.append(evidence)
    _log("evidence_created", float(evidence.get("strength", 1)), str(evidence.get("id", "")))
    emit_signal("evidence_created", evidence)
    return evidence

func decay_evidence() -> void:
    for evidence in active_evidence:
        evidence["decay_shifts"] = int(evidence.get("decay_shifts", 0)) - 1
    var kept: Array = []
    for evidence in active_evidence:
        if int(evidence.get("decay_shifts", 0)) > 0:
            kept.append(evidence)
        else:
            _log("evidence_decayed", 1.0, str(evidence.get("id", "")))
            emit_signal("evidence_decayed", str(evidence.get("id", "")))
    active_evidence = kept

func get_summary() -> Dictionary:
    return {"active_evidence": active_evidence.duplicate(true), "evidence_types": evidence_types.duplicate(true)}

func _find_type(evidence_type_id: String) -> Dictionary:
    for evidence in evidence_types:
        if str(evidence.get("id", "")) == evidence_type_id:
            return evidence
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
