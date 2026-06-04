extends Node
class_name ChaosIncidentRuntime

signal chaos_incident_applied(incident: Dictionary)
signal chaos_recovery_window_started(reason: String)

const UnhingedScript = preload("res://scripts/drama/UnhingedIncidentDirector.gd")
const BrawlScript = preload("res://scripts/drama/SlapstickBrawlManager.gd")
const SuspicionScript = preload("res://scripts/drama/ShadySuspicionManager.gd")
const ChainScript = preload("res://scripts/drama/IncidentChainManager.gd")
const HRScript = preload("res://scripts/drama/HRIncidentReporter.gd")
const ViralScript = preload("res://scripts/drama/ViralClipManager.gd")
const CalloutScript = preload("res://scripts/staff/CalloutManager.gd")
const ManagerArchetypeScript = preload("res://scripts/staff/ManagerArchetypeManager.gd")
const ReputationScript = preload("res://scripts/reputation/PlayerReputationManager.gd")
const DemotionScript = preload("res://scripts/career/DemotionManager.gd")
const ManagerTrialScript = preload("res://scripts/career/ManagerTrialManager.gd")

var incident_director: Node
var brawl_manager: Node
var suspicion_manager: Node
var chain_manager: Node
var hr_reporter: Node
var viral_manager: Node
var callout_manager: Node
var manager_archetypes: Node
var reputation_manager: Node
var demotion_manager: Node
var manager_trial_manager: Node

var chaos_budget: int = 8
var cognitive_budget: int = 8
var shift_number: int = 1
var tutorial_shift: bool = true
var recovery_window_turns: int = 0
var incident_cooldowns := {}
var incident_history: Array[Dictionary] = []
var hr_reports: Array[Dictionary] = []
var viral_clips: Array[Dictionary] = []
var reviews: Array[String] = []
var loaded_data_catalogs := {}

func _ready():
	_add_systems()
	_load_phase9_data_catalogs()
	configure_shift(1)

func configure_shift(number: int):
	shift_number = max(1, number)
	tutorial_shift = shift_number <= 1
	chaos_budget = 4 if tutorial_shift else min(12, 6 + shift_number)
	cognitive_budget = 4 if tutorial_shift else 8
	recovery_window_turns = 0
	incident_director.tutorial_mode = tutorial_shift
	brawl_manager.tutorial_mode = tutorial_shift
	manager_archetypes.choose_manager(shift_number)
	_log("phase9_shift_configured", float(chaos_budget), "tutorial=" + str(tutorial_shift))

func build_context(extra: Dictionary = {}) -> Dictionary:
	var store_ops = get_tree().root.find_child("StoreOpsDirector", true, false)
	var staff = get_tree().root.find_child("StaffDirector", true, false)
	var career = get_tree().root.get_node_or_null("CareerManager")
	var store = store_ops.get_shift_effects() if store_ops and store_ops.has_method("get_shift_effects") else {}
	var staff_effects = staff.get_shift_effects() if staff and staff.has_method("get_shift_effects") else {}
	var context = {
		"tutorial_shift": tutorial_shift,
		"recovery_window": recovery_window_turns > 0,
		"chaos_available": chaos_budget,
		"cognitive_load_available": cognitive_budget,
		"register_active": true,
		"coupon_customer": true,
		"manager_present": true,
		"manager_panic_high": not tutorial_shift,
		"rush_active": not tutorial_shift,
		"cash_handling_unlocked": not tutorial_shift,
		"beef": 80 if not tutorial_shift else 20,
		"beef_threshold": 70,
		"career_rank": career.get_current_rank_name() if career and career.has_method("get_current_rank_name") else "Trainee",
		"manager_trust": int(staff_effects.get("manager_trust", store.get("manager_trust", 50))),
		"staff_morale": int(staff_effects.get("staff_morale", 70)),
		"corporate_approval": int(store.get("corporate_approval", 50))
	}
	for key in extra:
		context[key] = extra[key]
	return context

func try_roll_incident(extra: Dictionary = {}) -> Dictionary:
	_tick_cooldowns()
	if recovery_window_turns > 0:
		recovery_window_turns -= 1
		_log("phase9_incident_blocked", 0.0, "recovery_window")
		return {}
	var context = build_context(extra)
	var incident = incident_director.try_start_incident(context)
	if incident.is_empty():
		_log("phase9_incident_blocked", 0.0, "no_candidate_or_budget")
		return {}
	if not _rarity_allows(incident, context):
		_log("phase9_incident_blocked", 0.0, "rarity_or_tutorial")
		return {}
	return apply_incident(incident, context)

func trigger_named_incident(incident_id: String, extra: Dictionary = {}) -> Dictionary:
	var context = build_context(extra)
	for incident in incident_director.incidents:
		if str(incident.get("id", "")) == incident_id:
			if not incident_director._incident_allowed(incident, context):
				_log("phase9_incident_blocked", 0.0, incident_id)
				return {}
			return apply_incident(incident, context)
	return {}

func apply_incident(incident: Dictionary, context: Dictionary) -> Dictionary:
	var incident_id = str(incident.get("id", "unknown_incident"))
	var severity = str(incident.get("severity", "minor"))
	var cost = int(incident.get("chaos_cost", 1))
	chaos_budget = max(0, chaos_budget - cost)
	cognitive_budget = max(0, cognitive_budget - int(incident.get("cognitive_load", 1)))
	incident_cooldowns[incident_id] = 2 + _severity_weight(severity)
	recovery_window_turns = 1 if severity in ["moderate", "major", "legendary"] else 0
	var entry = {
		"id": incident_id,
		"name": incident.get("name", incident_id),
		"severity": severity,
		"chaos_cost": cost,
		"choices": incident.get("player_choices", []),
		"cartoonish": true,
		"non_gory": true,
		"recovery_window": recovery_window_turns
	}
	incident_history.append(entry)
	_apply_gameplay_effects(incident, entry, context)
	_log("max_chaos_incident", float(cost), incident_id)
	_log("phase9_incident_effect", float(_severity_weight(severity)), severity)
	chaos_incident_applied.emit(entry)
	if recovery_window_turns > 0:
		chaos_recovery_window_started.emit(incident_id)
	return entry

func consider_slapstick(extra: Dictionary = {}) -> Dictionary:
	var context = build_context(extra)
	var brawl = brawl_manager.start_brawl(context)
	if brawl.is_empty():
		_log("slapstick_brawl_blocked", 0.0, "blocked_by_budget_or_tutorial")
		return {}
	var outcome = brawl_manager.resolve_brawl("deescalate_with_mop_bucket")
	outcome["cartoonish"] = true
	outcome["non_gory"] = true
	_apply_brawl_effects(outcome)
	_log("slapstick_brawl_resolved", 1.0, str(outcome.get("id", "brawl_outcome")))
	return outcome

func start_chain(chain_id: String) -> Dictionary:
	var chain = chain_manager.start_chain(chain_id)
	if not chain.is_empty():
		_log("incident_chain_started", 1.0, chain_id)
		incident_history.append({"id": chain_id, "name": chain.get("name", chain_id), "severity": "chain", "cartoonish": true})
	return chain

func get_phase9_summary() -> Dictionary:
	return {
		"incidents": incident_history.duplicate(true),
		"hr_reports": hr_reports.duplicate(true),
		"viral_clips": viral_clips.duplicate(true),
		"reviews": reviews.duplicate(),
		"chaos_budget_remaining": chaos_budget,
		"cooldowns": incident_cooldowns.duplicate(true),
		"recovery_window_turns": recovery_window_turns,
		"reputation_labels": reputation_manager.active_labels.duplicate(),
		"loaded_data_catalogs": loaded_data_catalogs.keys()
	}

func _add_systems():
	incident_director = _add_child_system("UnhingedIncidentDirector", UnhingedScript)
	brawl_manager = _add_child_system("SlapstickBrawlManager", BrawlScript)
	suspicion_manager = _add_child_system("ShadySuspicionManager", SuspicionScript)
	chain_manager = _add_child_system("IncidentChainManager", ChainScript)
	hr_reporter = _add_child_system("HRIncidentReporter", HRScript)
	viral_manager = _add_child_system("ViralClipManager", ViralScript)
	callout_manager = _add_child_system("CalloutManager", CalloutScript)
	manager_archetypes = _add_child_system("ManagerArchetypeManager", ManagerArchetypeScript)
	reputation_manager = _add_child_system("PlayerReputationManager", ReputationScript)
	demotion_manager = _add_child_system("DemotionManager", DemotionScript)
	manager_trial_manager = _add_child_system("ManagerTrialManager", ManagerTrialScript)

func _add_child_system(node_name: String, script_resource: Script) -> Node:
	var node = script_resource.new()
	node.name = node_name
	add_child(node)
	return node

func _load_phase9_data_catalogs():
	for path in [
		"res://data/incidents/unhinged_incidents.json",
		"res://data/incidents/incident_chains.json",
		"res://data/incidents/legendary_shift_chains.json",
		"res://data/incidents/incident_severity.json",
		"res://data/career/career_history_fields.json",
		"res://data/career/demotion_rules.json",
		"res://data/career/manager_trial_events.json",
		"res://data/career/promotion_setback_events.json",
		"res://data/reputation/dynamic_reputation_rules.json",
		"res://data/reputation/player_reputation_labels.json"
	]:
		loaded_data_catalogs[path] = _load_json_file(path)
	for directory in [
		"res://data/fights",
		"res://data/shady",
		"res://data/staff",
		"res://data/hr",
		"res://data/reviews",
		"res://data/career",
		"res://data/reputation"
	]:
		_load_json_directory(directory)
	_log("phase9_data_catalogs_loaded", float(loaded_data_catalogs.size()), "Phase 9 data families loaded")

func _load_json_directory(directory_path: String):
	var dir = DirAccess.open(directory_path)
	if not dir:
		push_warning("Missing data directory: " + directory_path)
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var path = directory_path + "/" + file_name
			loaded_data_catalogs[path] = _load_json_file(path)
		file_name = dir.get_next()
	dir.list_dir_end()

func _load_json_file(path: String):
	if not FileAccess.file_exists(path):
		push_warning("Missing data file: " + path)
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed == null:
		push_warning("Invalid JSON: " + path)
		return {}
	return parsed

func _apply_gameplay_effects(incident: Dictionary, entry: Dictionary, context: Dictionary):
	var severity = str(entry.get("severity", "minor"))
	var weight = _severity_weight(severity)
	var staff = get_tree().root.find_child("StaffDirector", true, false)
	var store_ops = get_tree().root.find_child("StoreOpsDirector", true, false)
	var career = get_tree().root.get_node_or_null("CareerManager")
	if staff:
		staff.staff_morale = clamp(int(staff.staff_morale) - weight, 0, 100)
		staff.manager_trust = clamp(int(staff.manager_trust) - max(1, weight - 1), 0, 100)
		if staff.has_method("_emit_status"):
			staff._emit_status("phase9_incident")
	if store_ops:
		store_ops.review_risk = clamp(int(store_ops.review_risk) + weight, 0, 100)
		store_ops.manager_trust = clamp(int(store_ops.manager_trust) - weight, 0, 100)
		store_ops.corporate_approval = clamp(int(store_ops.corporate_approval) - max(1, weight - 1), 0, 100)
		if store_ops.has_method("_recalculate_modifiers"):
			store_ops._recalculate_modifiers()
		if store_ops.has_method("_emit_status"):
			store_ops._emit_status("phase9_incident")
	var hr = {}
	if bool(incident.get("hr_hook", false)):
		hr = hr_reporter.generate_report({"incident": entry.get("name", entry.get("id", "")), "severity": severity, "object": "shift floor", "evidence_quality": "grainy"})
		hr_reports.append(hr)
		_log("phase9_hr_report", float(weight), str(hr.get("incident", entry.get("id", ""))))
	if bool(incident.get("review_hook", false)):
		var review = _incident_review(entry)
		reviews.append(review)
		_log("phase9_review", float(weight), review)
	var clip = viral_manager.maybe_generate_clip({"viral_possible": severity in ["major", "legendary"], "incident": entry.get("id", "")})
	if not clip.is_empty():
		viral_clips.append(clip)
		_log("phase9_viral_clip", float(weight), str(clip.get("id", "viral_clip")))
	if "shady_suspicion_change" in incident.get("consequences", []):
		suspicion_manager.record_action("register_miscount", context)
	reputation_manager.add_label(_label_for_incident(entry))
	demotion_manager.add_risk(weight * 4, str(entry.get("id", "")))
	if career and career.has_method("apply_incident_impact"):
		career.apply_incident_impact({
			"id": entry.get("id", ""),
			"severity": severity,
			"writeup": bool(incident.get("hr_hook", false)) and severity in ["major", "legendary"],
			"warning": bool(incident.get("hr_hook", false)),
			"demotion_risk": weight * 4,
			"fired_risk": weight * 2,
			"promotion_progress": -weight,
			"reputation_label": _label_for_incident(entry)
		})
	if "callout" in incident.get("eventlog_tags", []):
		callout_manager.generate_callout("casey")

func _apply_brawl_effects(outcome: Dictionary):
	var staff = get_tree().root.find_child("StaffDirector", true, false)
	var career = get_tree().root.get_node_or_null("CareerManager")
	if staff:
		staff.staff_morale = clamp(int(staff.staff_morale) - 3, 0, 100)
		staff.manager_trust = clamp(int(staff.manager_trust) - 2, 0, 100)
	reputation_manager.add_label("somehow_still_employed")
	if career and career.has_method("apply_incident_impact"):
		career.apply_incident_impact({"id": "slapstick_brawl", "severity": "moderate", "warning": true, "demotion_risk": 6, "fired_risk": 4, "promotion_progress": -2, "reputation_label": "somehow_still_employed"})

func _incident_review(entry: Dictionary) -> String:
	return "3 stars: " + str(entry.get("name", "incident")) + " happened, but at least it was local."

func _label_for_incident(entry: Dictionary) -> String:
	var id = str(entry.get("id", ""))
	if "sauce" in id:
		return "sauce_criminal"
	if "manager" in id:
		return "manager_material_somehow"
	if "register" in id:
		return "walking_hr_report"
	return "somehow_still_employed"

func _rarity_allows(incident: Dictionary, context: Dictionary) -> bool:
	var rarity = str(incident.get("rarity", "common"))
	var severity = str(incident.get("severity", "minor"))
	if bool(context.get("tutorial_shift", false)) and severity in ["moderate", "major", "legendary"]:
		return false
	if incident_cooldowns.has(str(incident.get("id", ""))):
		return false
	if rarity == "legendary" and shift_number < 8:
		return false
	if rarity == "rare" and shift_number < 3:
		return false
	return true

func _severity_weight(severity: String) -> int:
	match severity:
		"minor":
			return 1
		"moderate":
			return 3
		"major":
			return 5
		"legendary":
			return 8
		_:
			return 2

func _tick_cooldowns():
	for key in incident_cooldowns.keys():
		incident_cooldowns[key] = int(incident_cooldowns[key]) - 1
		if int(incident_cooldowns[key]) <= 0:
			incident_cooldowns.erase(key)

func _log(event_name: String, value: float, detail: String):
	var event_log = get_tree().root.get_node_or_null("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event(event_name, value, detail)
