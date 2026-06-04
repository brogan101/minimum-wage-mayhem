extends Node
class_name MischiefDirector

signal prank_started(prank: Dictionary)
signal prank_backfired(prank: Dictionary, backfire: Dictionary)
signal prank_resolved(result: Dictionary)
signal mischief_stat_changed(stat_name: String, value: int)

var pranks: Array = []
var backfires: Array = []
var side_quests: Array = []
var story_events: Array = []
var consequence_matrix := {}
var stats_catalog := {}
var player_mischief_level: int = 0
var coworker_prank_trust: int = 0
var manager_suspicion: int = 0
var prank_war_heat: int = 0
var restaurant_stability: int = 100
var prank_budget: int = 2
var shift_number: int = 1
var pranks_this_shift: Array[Dictionary] = []
var coworker_pranks_this_shift: Array[Dictionary] = []
var backfires_this_shift: Array[Dictionary] = []
var side_quests_this_shift: Array[Dictionary] = []
var recap_entries: Array[String] = []

func _ready() -> void:
	pranks = _load_json_array("res://data/mischief/pranks.json", "pranks")
	backfires = _load_json_array("res://data/mischief/prank_backfires.json", "backfire_types")
	side_quests = _load_json_array("res://data/mischief/prank_side_quests.json", "side_quests")
	story_events = _load_json_array("res://data/mischief/restaurant_story_events.json", "events")
	consequence_matrix = _load_json_dictionary("res://data/mischief/prank_consequence_matrix.json")
	stats_catalog = _load_json_dictionary("res://data/mischief/mischief_stats.json")
	configure_shift(1)

func configure_shift(number: int) -> void:
	shift_number = max(1, number)
	prank_budget = 1 if shift_number <= 1 else min(4, 1 + int(shift_number / 2))
	pranks_this_shift.clear()
	coworker_pranks_this_shift.clear()
	backfires_this_shift.clear()
	side_quests_this_shift.clear()
	recap_entries.clear()
	_log("mischief_shift_configured", float(prank_budget), "shift=" + str(shift_number))

func choose_prank(max_severity: int = 2) -> Dictionary:
	var candidates: Array = []
	for prank in pranks:
		if int(prank.get("severity_level", 1)) <= max_severity:
			candidates.append(prank)
	if candidates.is_empty():
		return {}
	candidates.shuffle()
	return candidates[0]

func start_prank(prank_id: String = "", max_severity: int = 2, context: Dictionary = {}) -> Dictionary:
	var prank := _find_prank(prank_id) if prank_id != "" else choose_prank(max_severity)
	if prank.is_empty() or not _can_start_prank(prank, context):
		_log("mischief_prank_blocked", 0.0, prank_id if prank_id != "" else "no_prank")
		return {}
	prank_budget = max(0, prank_budget - 1)
	emit_signal("prank_started", prank)
	_change_stat("player_mischief_level", int(prank.get("severity_level", 1)))
	_log("mischief_prank_started", float(prank.get("severity_level", 1)), str(prank.get("id", "")))
	return prank

func pull_optional_prank(prank_id: String = "", context: Dictionary = {}) -> Dictionary:
	var prank = start_prank(prank_id, int(context.get("max_severity", 2)), context)
	if prank.is_empty():
		return {}
	return resolve_prank(prank, context)

func coworker_prank_player(coworker_id: String = "casey", context: Dictionary = {}) -> Dictionary:
	if shift_number <= 1 and not bool(context.get("force", false)):
		_log("coworker_prank_blocked", 0.0, "tutorial")
		return {}
	if prank_war_heat >= 6 and not bool(context.get("force", false)):
		_log("coworker_prank_blocked", 0.0, "heat_too_high")
		return {}
	var prank = choose_prank(1 if prank_war_heat < 3 else 2)
	if prank.is_empty():
		return {}
	var result = resolve_prank(prank, {"coworker_prank": true, "coworker_id": coworker_id, "force_no_backfire": true})
	coworker_pranks_this_shift.append(result)
	_change_stat("coworker_prank_trust", 2)
	_log("coworker_pranked_player", 1.0, coworker_id + ":" + str(prank.get("id", "")))
	return result

func roll_backfire(prank: Dictionary, context: Dictionary = {}) -> Dictionary:
	if bool(context.get("force_no_backfire", false)):
		return {}
	var severity := int(prank.get("severity_level", 1))
	var chance := severity * 10 + int(context.get("manager_suspicion", manager_suspicion)) / 4 + int(context.get("prank_war_heat", prank_war_heat)) * 3
	var rolled := 1 if bool(context.get("force_backfire", false)) else randi_range(1, 100)
	if rolled > chance:
		return {}
	var selected := _select_backfire(severity)
	emit_signal("prank_backfired", prank, selected)
	_log("mischief_prank_backfired", float(severity), str(selected.get("id", "backfire")))
	return selected

func resolve_prank(prank: Dictionary, context: Dictionary = {}) -> Dictionary:
	var backfire := roll_backfire(prank, context)
	var severity = int(prank.get("severity_level", 1))
	var result := {
		"prank": prank,
		"backfire": backfire,
		"staff_morale_delta": 2 if backfire.is_empty() and severity <= 2 else -severity,
		"manager_suspicion_delta": severity,
		"prank_war_heat_delta": 1 if severity >= 2 else 0,
		"cash_reward": 1 if backfire.is_empty() else 0,
		"xp_reward": 4 + severity,
		"promotion_progress_delta": 1 if backfire.is_empty() and severity <= 2 else -1
	}
	_apply_prank_result(result, context)
	pranks_this_shift.append(result)
	if not backfire.is_empty():
		backfires_this_shift.append(backfire)
	emit_signal("prank_resolved", result)
	return result

func generate_side_quest(context: Dictionary = {}) -> Dictionary:
	if side_quests.is_empty():
		return {}
	var quest = side_quests[int(context.get("index", side_quests_this_shift.size())) % side_quests.size()].duplicate(true)
	quest["completed"] = false
	side_quests_this_shift.append(quest)
	recap_entries.append("Side quest offered: " + str(quest.get("name", quest.get("id", ""))))
	_log("mischief_side_quest_generated", 1.0, str(quest.get("id", "")))
	return quest

func complete_side_quest(quest_id: String) -> Dictionary:
	for i in range(side_quests_this_shift.size()):
		var quest: Dictionary = side_quests_this_shift[i]
		if str(quest.get("id", "")) == quest_id:
			quest["completed"] = true
			side_quests_this_shift[i] = quest
			_apply_side_quest_rewards(quest)
			recap_entries.append("Side quest completed: " + str(quest.get("name", quest_id)))
			_log("mischief_side_quest_completed", 1.0, quest_id)
			return quest
	return {}

func get_mischief_summary() -> Dictionary:
	return {
		"pranks": pranks_this_shift.duplicate(true),
		"coworker_pranks": coworker_pranks_this_shift.duplicate(true),
		"backfires": backfires_this_shift.duplicate(true),
		"side_quests": side_quests_this_shift.duplicate(true),
		"recap_entries": recap_entries.duplicate(),
		"player_mischief_level": player_mischief_level,
		"coworker_prank_trust": coworker_prank_trust,
		"manager_suspicion": manager_suspicion,
		"prank_war_heat": prank_war_heat,
		"restaurant_stability": restaurant_stability,
		"prank_budget_remaining": prank_budget,
		"story_event_count": story_events.size()
	}

func _select_backfire(severity: int) -> Dictionary:
	if backfires.is_empty():
		return {"id": "generic_backfire", "effects": ["eventlog_joke"]}
	var candidates: Array = []
	for b in backfires:
		if int(b.get("severity", 1)) <= max(severity + 1, 1):
			candidates.append(b)
	if candidates.is_empty():
		return backfires[0]
	candidates.shuffle()
	return candidates[0]

func _change_stat(stat_name: String, delta: int) -> void:
	match stat_name:
		"player_mischief_level":
			player_mischief_level = clamp(player_mischief_level + delta, 0, 100)
			emit_signal("mischief_stat_changed", stat_name, player_mischief_level)
		"coworker_prank_trust":
			coworker_prank_trust = clamp(coworker_prank_trust + delta, -100, 100)
			emit_signal("mischief_stat_changed", stat_name, coworker_prank_trust)
		"manager_suspicion":
			manager_suspicion = clamp(manager_suspicion + delta, 0, 100)
			emit_signal("mischief_stat_changed", stat_name, manager_suspicion)
		"prank_war_heat":
			prank_war_heat = clamp(prank_war_heat + delta, 0, 8)
			emit_signal("mischief_stat_changed", stat_name, prank_war_heat)
		"restaurant_stability":
			restaurant_stability = clamp(restaurant_stability + delta, 0, 100)
			emit_signal("mischief_stat_changed", stat_name, restaurant_stability)

func _find_prank(prank_id: String) -> Dictionary:
	for prank in pranks:
		if str(prank.get("id", "")) == prank_id:
			return prank
	return {}

func _can_start_prank(prank: Dictionary, context: Dictionary) -> bool:
	if bool(context.get("force", false)):
		return true
	if prank_budget <= 0:
		return false
	var severity = int(prank.get("severity_level", 1))
	if shift_number <= 1 and severity > 1:
		return false
	if prank_war_heat >= 6 and severity > 1:
		return false
	return true

func _apply_prank_result(result: Dictionary, context: Dictionary):
	var prank: Dictionary = result.get("prank", {})
	var severity = int(prank.get("severity_level", 1))
	_change_stat("manager_suspicion", int(result.get("manager_suspicion_delta", 0)))
	_change_stat("prank_war_heat", int(result.get("prank_war_heat_delta", 0)))
	if not result.get("backfire", {}).is_empty():
		_change_stat("restaurant_stability", -severity * 4)
	var staff = get_tree().root.find_child("StaffDirector", true, false)
	if staff:
		staff.staff_morale = clamp(int(staff.staff_morale) + int(result.get("staff_morale_delta", 0)), 0, 100)
		staff.manager_trust = clamp(int(staff.manager_trust) - max(0, severity - 1), 0, 100)
		if staff.has_method("_emit_status"):
			staff._emit_status("mischief_prank")
	var store_ops = get_tree().root.find_child("StoreOpsDirector", true, false)
	if store_ops:
		store_ops.review_risk = clamp(int(store_ops.review_risk) + (severity if not result.get("backfire", {}).is_empty() else severity * 2), 0, 100)
		store_ops.cleanliness = clamp(int(store_ops.cleanliness) - (severity if not result.get("backfire", {}).is_empty() else severity * 2), 0, 100)
		if store_ops.has_method("_recalculate_modifiers"):
			store_ops._recalculate_modifiers()
		if store_ops.has_method("_emit_status"):
			store_ops._emit_status("mischief_prank")
	var wallet = get_tree().root.get_node_or_null("WalletManager")
	if wallet and wallet.has_method("add_money") and int(result.get("cash_reward", 0)) > 0:
		wallet.add_money(float(result.get("cash_reward", 0)))
	var career = get_tree().root.get_node_or_null("CareerManager")
	if career:
		if career.has_method("add_xp"):
			career.add_xp(float(result.get("xp_reward", 0)))
		career.promotion_progress = clamp(int(career.promotion_progress) + int(result.get("promotion_progress_delta", 0)), 0, 100)
		if career.has_method("apply_incident_impact") and not result.get("backfire", {}).is_empty():
			career.apply_incident_impact({"id": prank.get("id", "mischief_prank"), "severity": "minor", "warning": false, "demotion_risk": severity, "fired_risk": 0, "promotion_progress": -severity, "reputation_label": "shift_jester"})
	var daily = get_tree().root.find_child("DailyTaskManager", true, false)
	if daily and daily.has_method("record_progress"):
		daily.record_progress("mischief_prank", str(prank.get("id", "")))
	recap_entries.append(_format_result(result, context))
	_log("mischief_prank_resolved", float(severity), str(prank.get("id", "")))
	var war = get_tree().root.find_child("PrankWarManager", true, false)
	if war and war.has_method("consider_escalation"):
		war.consider_escalation(result, {"heat": prank_war_heat, "force": bool(context.get("force_chain", false))})
	var damage = get_tree().root.find_child("RestaurantDamageManager", true, false)
	if damage and damage.has_method("trigger_damage") and (not result.get("backfire", {}).is_empty() or severity >= 3 or bool(context.get("force_damage", false))):
		damage.trigger_damage("", {"severity": severity, "source": str(prank.get("id", ""))})

func _apply_side_quest_rewards(quest: Dictionary):
	var career = get_tree().root.get_node_or_null("CareerManager")
	var staff = get_tree().root.find_child("StaffDirector", true, false)
	if career and career.has_method("add_xp"):
		career.add_xp(12.0)
		career.promotion_progress = clamp(int(career.promotion_progress) + 1, 0, 100)
	if staff:
		staff.staff_morale = clamp(int(staff.staff_morale) + 2, 0, 100)
	var daily = get_tree().root.find_child("DailyTaskManager", true, false)
	if daily and daily.has_method("record_progress"):
		daily.record_progress("mischief_side_quest", str(quest.get("id", "")))

func _format_result(result: Dictionary, context: Dictionary) -> String:
	var prank: Dictionary = result.get("prank", {})
	if not result.get("backfire", {}).is_empty():
		return str(prank.get("description", prank.get("id", "Prank"))) + ": backfired"
	if bool(context.get("coworker_prank", false)):
		return "Coworker prank: " + str(prank.get("description", prank.get("id", "prank")))
	return str(prank.get("description", prank.get("id", "Prank"))) + ": resolved"

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
