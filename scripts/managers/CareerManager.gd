extends Node
class_name CareerManager
## Career/campaign spine from Trainee to Store Manager.

signal rank_up(new_rank_name)
signal career_progress_changed(status: Dictionary)
signal manager_trial_ready(trial: Dictionary)

const RANKS := [
	{"id": "trainee", "name": "Trainee", "xp_required": 0, "promotion_required": 0, "trust_required": 0, "approval_required": 0, "milestone": "Clock in without becoming a cautionary tale"},
	{"id": "crew_member", "name": "Crew Member", "xp_required": 60, "promotion_required": 2, "trust_required": 35, "approval_required": 30, "milestone": "Prove basic shift survival"},
	{"id": "register_specialist", "name": "Register Specialist", "xp_required": 140, "promotion_required": 5, "trust_required": 40, "approval_required": 35, "milestone": "Handle cash and complaints"},
	{"id": "fryer_specialist", "name": "Fryer Specialist", "xp_required": 240, "promotion_required": 9, "trust_required": 45, "approval_required": 40, "milestone": "Keep hot food boring in the best way"},
	{"id": "window_specialist", "name": "Window Specialist", "xp_required": 360, "promotion_required": 14, "trust_required": 50, "approval_required": 45, "milestone": "Keep the drive-thru moving"},
	{"id": "shift_lead_candidate", "name": "Shift Lead Candidate", "xp_required": 520, "promotion_required": 20, "trust_required": 55, "approval_required": 50, "milestone": "Show leadership under rush pressure"},
	{"id": "shift_lead", "name": "Shift Lead", "xp_required": 700, "promotion_required": 28, "trust_required": 60, "approval_required": 52, "milestone": "Run the floor without losing the room"},
	{"id": "assistant_manager_candidate", "name": "Assistant Manager Candidate", "xp_required": 920, "promotion_required": 38, "trust_required": 65, "approval_required": 55, "milestone": "Own results and coach staff"},
	{"id": "assistant_manager", "name": "Assistant Manager", "xp_required": 1180, "promotion_required": 50, "trust_required": 70, "approval_required": 60, "milestone": "Manage shifts with corporate watching"},
	{"id": "acting_store_manager", "name": "Acting Store Manager", "xp_required": 1500, "promotion_required": 66, "trust_required": 76, "approval_required": 66, "milestone": "Prepare for manager trial"},
	{"id": "store_manager", "name": "Store Manager", "xp_required": 1900, "promotion_required": 85, "trust_required": 82, "approval_required": 72, "milestone": "Pass the manager trial"}
]

var current_rank: int = 0
var current_xp: float = 0.0
var xp_to_next_rank: float = 60.0
var cash_earned_total: float = 0.0
var tips_earned_total: float = 0.0
var promotion_progress: int = 0
var manager_trust: int = 50
var staff_morale: int = 70
var corporate_approval: int = 50
var writeups: int = 0
var warnings: int = 0
var demotion_risk: int = 0
var fired_risk: int = 0
var shift_performance_history: Array = []
var campaign_milestones: Array[String] = []
var career_recap_history: Array[String] = []
var manager_trial_unlocked: bool = false
var manager_trial_passed: bool = false
var manager_trial_setup: Dictionary = {}
var future_expansion_hooks := {
	"district_manager_path": false,
	"regional_review_board": false,
	"multi_store_expansion": false
}

func _ready():
	_recalculate_next_xp()
	_emit_progress()

func add_xp(amount: float):
	current_xp += max(0.0, amount)
	print("Gained ", amount, " XP. Total: ", current_xp, "/", xp_to_next_rank)
	_try_promote()
	_emit_progress()

func apply_shift_result(result: Dictionary) -> Dictionary:
	var score = calculate_shift_score(result)
	var xp_gain = max(0, int(result.get("xp_earned", 0)) + int(score * 0.35))
	var cash_gain = float(result.get("money_earned", 0.0))
	var tips_gain = float(result.get("tips", 0))
	current_xp += xp_gain
	cash_earned_total += max(0.0, cash_gain)
	tips_earned_total += max(0.0, tips_gain)
	promotion_progress = clamp(promotion_progress + _promotion_delta(result, score), 0, 100)
	manager_trust = clamp(manager_trust + int(result.get("manager_trust_change", 0)) + _trust_bonus(result), 0, 100)
	staff_morale = clamp(staff_morale + int(result.get("staff_morale_change", 0)), 0, 100)
	corporate_approval = clamp(corporate_approval + int(result.get("corporate_approval_change", 0)), 0, 100)
	warnings += int(result.get("warnings", []).size())
	writeups += _writeup_delta(result)
	demotion_risk = clamp(demotion_risk + _demotion_delta(result, score), 0, 100)
	fired_risk = clamp(fired_risk + _fired_delta(result), 0, 100)
	var record = _build_shift_record(result, score, xp_gain)
	shift_performance_history.append(record)
	career_recap_history.append(record.get("summary", "Shift recorded"))
	_record_milestones(result, score)
	_try_promote()
	_update_manager_trial_setup()
	_emit_progress()
	_log("career_shift_applied", float(score), get_current_rank_name() + " progress " + str(promotion_progress))
	return get_career_status()

func apply_incident_impact(impact: Dictionary) -> Dictionary:
	var severity = str(impact.get("severity", "minor"))
	var weight = _incident_weight(severity)
	if bool(impact.get("warning", false)):
		warnings += 1
	if bool(impact.get("writeup", false)):
		writeups += 1
	promotion_progress = clamp(promotion_progress + int(impact.get("promotion_progress", -weight)), 0, 100)
	demotion_risk = clamp(demotion_risk + int(impact.get("demotion_risk", weight * 3)), 0, 100)
	fired_risk = clamp(fired_risk + int(impact.get("fired_risk", weight)), 0, 100)
	var label = str(impact.get("reputation_label", ""))
	var record = {
		"type": "phase9_incident",
		"id": impact.get("id", "incident"),
		"severity": severity,
		"rank": get_current_rank_name(),
		"reputation_label": label,
		"summary": "Incident " + str(impact.get("id", "incident")) + " affected career risk"
	}
	shift_performance_history.append(record)
	career_recap_history.append(str(record.get("summary", "")))
	_add_milestone("Survived " + severity + " incident")
	_emit_progress()
	_log("career_incident_impact", float(weight), str(impact.get("id", "incident")))
	return get_career_status()

func calculate_shift_score(result: Dictionary) -> int:
	var score = 50
	score += int(float(result.get("order_accuracy", 1.0)) * 20.0)
	score += int(float(result.get("average_patience", 1.0)) * 10.0)
	score += int(result.get("daily_tasks_completed", 0)) * 4
	score -= int(result.get("daily_tasks_failed", 0)) * 3
	score -= int(result.get("beef_incidents", 0)) * 6
	score -= int(result.get("writeups", []).size()) * 8
	score += min(10, int(result.get("reviews", []).size()) * 3)
	if str(result.get("notable_moment", "")).length() > 0:
		score += 2
	if str(result.get("fail_state", "none")) != "none":
		score -= 8
	return clamp(score, 0, 100)

func get_current_rank_name() -> String:
	return str(RANKS[current_rank].get("name", "Trainee"))

func get_next_rank_requirements() -> Dictionary:
	if current_rank >= RANKS.size() - 1:
		return {"complete": true, "rank": get_current_rank_name()}
	var next_rank: Dictionary = RANKS[current_rank + 1]
	return {
		"rank": next_rank.get("name", ""),
		"xp_required": next_rank.get("xp_required", 0),
		"promotion_required": next_rank.get("promotion_required", 0),
		"trust_required": next_rank.get("trust_required", 0),
		"approval_required": next_rank.get("approval_required", 0),
		"current_xp": current_xp,
		"promotion_progress": promotion_progress,
		"manager_trust": manager_trust,
		"corporate_approval": corporate_approval,
		"writeups_allowed": max(0, 3 - writeups)
	}

func get_career_status() -> Dictionary:
	return {
		"rank_index": current_rank,
		"rank_id": RANKS[current_rank].get("id", "trainee"),
		"rank_name": get_current_rank_name(),
		"current_xp": current_xp,
		"xp_to_next_rank": xp_to_next_rank,
		"cash_earned_total": cash_earned_total,
		"tips_earned_total": tips_earned_total,
		"promotion_progress": promotion_progress,
		"manager_trust": manager_trust,
		"staff_morale": staff_morale,
		"corporate_approval": corporate_approval,
		"writeups": writeups,
		"warnings": warnings,
		"demotion_risk": demotion_risk,
		"fired_risk": fired_risk,
		"shift_performance_history": shift_performance_history.duplicate(true),
		"promotion_requirements": get_next_rank_requirements(),
		"campaign_milestones": campaign_milestones.duplicate(),
		"manager_trial_unlocked": manager_trial_unlocked,
		"manager_trial_passed": manager_trial_passed,
		"manager_trial_setup": manager_trial_setup.duplicate(true),
		"career_recap_history": career_recap_history.duplicate(),
		"future_expansion_hooks": future_expansion_hooks.duplicate(true)
	}

func get_career_save_data() -> Dictionary:
	return get_career_status()

func load_career_save_data(data: Dictionary):
	current_rank = clamp(int(data.get("rank_index", data.get("rank", 0))), 0, RANKS.size() - 1)
	current_xp = float(data.get("current_xp", data.get("xp", 0.0)))
	xp_to_next_rank = float(data.get("xp_to_next_rank", 60.0))
	cash_earned_total = float(data.get("cash_earned_total", 0.0))
	tips_earned_total = float(data.get("tips_earned_total", 0.0))
	promotion_progress = int(data.get("promotion_progress", 0))
	manager_trust = int(data.get("manager_trust", 50))
	staff_morale = int(data.get("staff_morale", 70))
	corporate_approval = int(data.get("corporate_approval", 50))
	writeups = int(data.get("writeups", 0))
	warnings = int(data.get("warnings", 0))
	demotion_risk = int(data.get("demotion_risk", 0))
	fired_risk = int(data.get("fired_risk", 0))
	shift_performance_history = data.get("shift_performance_history", [])
	campaign_milestones.assign(data.get("campaign_milestones", []))
	career_recap_history.assign(data.get("career_recap_history", []))
	manager_trial_unlocked = bool(data.get("manager_trial_unlocked", false))
	manager_trial_passed = bool(data.get("manager_trial_passed", false))
	manager_trial_setup = data.get("manager_trial_setup", {})
	future_expansion_hooks = data.get("future_expansion_hooks", future_expansion_hooks)
	_recalculate_next_xp()
	_emit_progress()

func promote():
	_promote_one_rank()

func complete_manager_trial(passed: bool):
	manager_trial_passed = passed
	if passed:
		_add_milestone("Manager trial passed")
		_try_promote()
	else:
		demotion_risk = clamp(demotion_risk + 10, 0, 100)
		career_recap_history.append("Manager trial needs a retry")
	_emit_progress()

func _try_promote():
	while current_rank < RANKS.size() - 1:
		var next_rank: Dictionary = RANKS[current_rank + 1]
		if str(next_rank.get("id", "")) == "store_manager":
			_update_manager_trial_setup()
			if not manager_trial_passed:
				break
		var meets = current_xp >= float(next_rank.get("xp_required", 0))
		meets = meets and promotion_progress >= int(next_rank.get("promotion_required", 0))
		meets = meets and manager_trust >= int(next_rank.get("trust_required", 0))
		meets = meets and corporate_approval >= int(next_rank.get("approval_required", 0))
		meets = meets and writeups < 3 and fired_risk < 85
		if not meets:
			break
		_promote_one_rank()

func _promote_one_rank():
	if current_rank >= RANKS.size() - 1:
		return
	current_rank += 1
	campaign_milestones.append("Promoted to " + get_current_rank_name())
	career_recap_history.append("Promotion: " + get_current_rank_name())
	_recalculate_next_xp()
	rank_up.emit(get_current_rank_name())
	_log("career_rank_up", float(current_rank), get_current_rank_name())
	print("PROMOTED TO: ", get_current_rank_name())

func _recalculate_next_xp():
	if current_rank >= RANKS.size() - 1:
		xp_to_next_rank = current_xp
	else:
		xp_to_next_rank = float(RANKS[current_rank + 1].get("xp_required", 60.0))

func _promotion_delta(result: Dictionary, score: int) -> int:
	var delta = int(score / 12)
	delta += int(result.get("daily_tasks_completed", 0))
	delta += int(result.get("unlock_hooks", []).size())
	if int(result.get("beef_incidents", 0)) == 0:
		delta += 2
	if float(result.get("order_accuracy", 1.0)) >= 0.9:
		delta += 3
	return delta

func _trust_bonus(result: Dictionary) -> int:
	var bonus = 0
	if int(result.get("daily_tasks_completed", 0)) >= 4:
		bonus += 2
	if int(result.get("beef_incidents", 0)) == 0:
		bonus += 2
	return bonus

func _writeup_delta(result: Dictionary) -> int:
	var count = int(result.get("writeups", []).size())
	if str(result.get("fail_state", "none")) == "recoverable_probation":
		count += 1
	return count

func _demotion_delta(result: Dictionary, score: int) -> int:
	var delta = 0
	if score < 45:
		delta += 12
	delta += int(result.get("beef_incidents", 0)) * 4
	delta += int(result.get("writeups", []).size()) * 10
	if int(result.get("daily_tasks_failed", 0)) > int(result.get("daily_tasks_completed", 0)):
		delta += 8
	if score >= 75:
		delta -= 8
	return delta

func _fired_delta(result: Dictionary) -> int:
	var delta = int(result.get("writeups", []).size()) * 8
	if int(result.get("beef_incidents", 0)) >= 3:
		delta += 10
	if corporate_approval < 25:
		delta += 12
	return delta

func _incident_weight(severity: String) -> int:
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

func _build_shift_record(result: Dictionary, score: int, xp_gain: int) -> Dictionary:
	return {
		"shift_number": result.get("shift_number", shift_performance_history.size() + 1),
		"score": score,
		"rank": get_current_rank_name(),
		"xp_gain": xp_gain,
		"money_earned": result.get("money_earned", 0.0),
		"tips": result.get("tips", 0),
		"order_accuracy": result.get("order_accuracy", 1.0),
		"beef_incidents": result.get("beef_incidents", 0),
		"reviews": result.get("reviews", []),
		"writeups": result.get("writeups", []),
		"notable_moment": result.get("notable_moment", ""),
		"summary": "Shift " + str(result.get("shift_number", shift_performance_history.size() + 1)) + ": score " + str(score) + ", " + get_current_rank_name()
	}

func _record_milestones(result: Dictionary, score: int):
	if score >= 85:
		_add_milestone("Excellent shift performance")
	if int(result.get("daily_tasks_completed", 0)) >= 5:
		_add_milestone("Daily task streak started")
	if int(result.get("beef_incidents", 0)) > 0:
		_add_milestone("Survived customer Beef")
	if str(result.get("notable_moment", "")).length() > 0:
		_add_milestone("Notable shift moment recorded")

func _add_milestone(text: String):
	if not campaign_milestones.has(text):
		campaign_milestones.append(text)

func _update_manager_trial_setup():
	manager_trial_unlocked = current_rank >= 9 and promotion_progress >= 75 and manager_trust >= 75 and corporate_approval >= 65
	if manager_trial_unlocked:
		manager_trial_setup = {
			"trial_id": "manager_trial_shift",
			"ready": true,
			"requirements": ["complete_shift", "protect_staff_morale", "contain_major_issue", "hold_corporate_approval"],
			"future_hooks": ["district_manager_path", "regional_review_board"]
		}
		manager_trial_ready.emit(manager_trial_setup)

func _emit_progress():
	career_progress_changed.emit(get_career_status())

func _log(event_name: String, value: float, detail: String):
	var event_log = get_tree().root.get_node_or_null("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event(event_name, value, detail)
