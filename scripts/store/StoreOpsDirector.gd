extends Node
class_name StoreOpsDirector

signal store_ops_status_changed(status: Dictionary)

var sauce_stock: int = 3
var bagging_table_ready: bool = false
var fryer_health: int = 72
var register_balanced: bool = false
var trash_level: int = 62
var cleanliness: int = 58
var manager_trust: int = 50
var corporate_approval: int = 50
var review_risk: int = 12
var equipment_issue_active: String = ""

var speed_modifier: float = 0.94
var accuracy_modifier: float = 0.92
var customer_patience_modifier: float = 0.95

var completed_duties := {}
var recap_entries: Array[String] = []

var duty_defs := {
	"open_register": {
		"label": "Count register",
		"station": "Register check",
		"phase": "opening",
		"feedback": "Register counted. Drawer anxiety reduced.",
		"effects": {"register_balanced": true, "accuracy": 0.04, "manager_trust": 3, "corporate_approval": 1}
	},
	"restock_sauce": {
		"label": "Restock sauce",
		"station": "Sauce stock",
		"phase": "mid_shift",
		"feedback": "Sauce stocked. Dry-bun complaints retreat for now.",
		"effects": {"sauce_stock": 5, "accuracy": 0.03, "customer_patience": 0.03, "review_risk": -2}
	},
	"clear_bagging_table": {
		"label": "Clear bagging table",
		"station": "Bagging table",
		"phase": "mid_shift",
		"feedback": "Bagging table cleared. Orders stop becoming abstract sculpture.",
		"effects": {"bagging_table_ready": true, "speed": 0.05, "accuracy": 0.03}
	},
	"check_fryer": {
		"label": "Check fryer",
		"station": "Fryer check",
		"phase": "mid_shift",
		"feedback": "Fryer skimmed and timer checked.",
		"effects": {"fryer_health": 16, "speed": 0.03, "customer_patience": 0.02, "review_risk": -1}
	},
	"take_out_trash": {
		"label": "Take out trash",
		"station": "Trash run",
		"phase": "closing",
		"feedback": "Trash handled. The dining room no longer has opinions.",
		"effects": {"trash_level": -45, "cleanliness": 10, "review_risk": -3, "manager_trust": 2}
	},
	"clean_spill": {
		"label": "Clean station",
		"station": "Cleaning",
		"phase": "recovery",
		"feedback": "Station cleaned. Shoes regain legal traction.",
		"effects": {"cleanliness": 14, "customer_patience": 0.02, "review_risk": -3, "manager_trust": 2}
	},
	"repair_minor_issue": {
		"label": "Fix minor issue",
		"station": "Recovery",
		"phase": "recovery",
		"feedback": "Minor issue recovered before it became a meeting.",
		"effects": {"fryer_health": 12, "speed": 0.04, "manager_trust": 3, "corporate_approval": 2, "clear_issue": true}
	}
}

func _ready():
	_recalculate_modifiers()
	_log("store_ops_ready", 1.0, "Store operations director online")
	_emit_status("store_ops_ready")

func complete_duty(duty_id: String) -> Dictionary:
	if not duty_defs.has(duty_id):
		_log("store_duty_missing", 0.0, duty_id)
		return get_shift_effects()
	var duty: Dictionary = duty_defs[duty_id]
	completed_duties[duty_id] = true
	_apply_effects(duty.get("effects", {}))
	var feedback = str(duty.get("feedback", duty_id))
	recap_entries.append(str(duty.get("label", duty_id)) + ": completed")
	_log("store_duty_completed", 1.0, feedback)
	_record_daily_progress("store_duty", duty_id)
	_recalculate_modifiers()
	_emit_status(duty_id)
	return get_shift_effects()

func trigger_minor_issue(issue_id: String = "fryer_timer_drift") -> Dictionary:
	equipment_issue_active = issue_id
	fryer_health = clamp(fryer_health - 24, 0, 100)
	cleanliness = clamp(cleanliness - 6, 0, 100)
	manager_trust = clamp(manager_trust - 4, 0, 100)
	corporate_approval = clamp(corporate_approval - 3, 0, 100)
	review_risk = clamp(review_risk + 7, 0, 100)
	recap_entries.append("Issue: " + issue_id + " recovered=" + str(false))
	_adjust_corporate(-3)
	_log("store_issue_triggered", 1.0, issue_id)
	_recalculate_modifiers()
	_emit_status("minor_issue")
	return get_shift_effects()

func repair_issue(issue_id: String = "") -> Dictionary:
	var target = issue_id if issue_id != "" else equipment_issue_active
	complete_duty("repair_minor_issue")
	if target != "":
		_log("store_issue_repaired", 1.0, target)
		_record_daily_progress("store_issue_repaired", target)
		recap_entries.append("Issue repaired: " + target)
	return get_shift_effects()

func get_shift_effects() -> Dictionary:
	return {
		"speed": speed_modifier,
		"accuracy": accuracy_modifier,
		"customer_patience": customer_patience_modifier,
		"cleanliness": cleanliness,
		"sauce_stock": sauce_stock,
		"bagging_table_ready": bagging_table_ready,
		"fryer_health": fryer_health,
		"register_balanced": register_balanced,
		"trash_level": trash_level,
		"review_risk": review_risk,
		"manager_trust": manager_trust,
		"corporate_approval": corporate_approval,
		"equipment_issue_active": equipment_issue_active,
		"completed_duties": completed_duties.duplicate(true)
	}

func get_recap_entries() -> Array[String]:
	return recap_entries.duplicate()

func get_station_feedback(duty_id: String) -> String:
	if not duty_defs.has(duty_id):
		return "No duty assigned."
	var duty: Dictionary = duty_defs[duty_id]
	if completed_duties.has(duty_id):
		return str(duty.get("label", duty_id)) + " already handled."
	return str(duty.get("feedback", duty_id))

func _apply_effects(effects: Dictionary):
	if effects.has("sauce_stock"):
		sauce_stock = clamp(sauce_stock + int(effects["sauce_stock"]), 0, 10)
	if effects.has("bagging_table_ready"):
		bagging_table_ready = bool(effects["bagging_table_ready"])
	if effects.has("fryer_health"):
		fryer_health = clamp(fryer_health + int(effects["fryer_health"]), 0, 100)
	if effects.has("register_balanced"):
		register_balanced = bool(effects["register_balanced"])
	if effects.has("trash_level"):
		trash_level = clamp(trash_level + int(effects["trash_level"]), 0, 100)
	if effects.has("cleanliness"):
		cleanliness = clamp(cleanliness + int(effects["cleanliness"]), 0, 100)
	if effects.has("review_risk"):
		review_risk = clamp(review_risk + int(effects["review_risk"]), 0, 100)
	if effects.has("manager_trust"):
		manager_trust = clamp(manager_trust + int(effects["manager_trust"]), 0, 100)
	if effects.has("corporate_approval"):
		var delta = int(effects["corporate_approval"])
		corporate_approval = clamp(corporate_approval + delta, 0, 100)
		_adjust_corporate(delta)
	if effects.get("clear_issue", false):
		equipment_issue_active = ""

func _recalculate_modifiers():
	var clean_penalty = float(max(0, 70 - cleanliness)) * 0.002
	var trash_penalty = float(max(0, trash_level - 50)) * 0.0015
	var fryer_penalty = float(max(0, 80 - fryer_health)) * 0.002
	var sauce_penalty = 0.04 if sauce_stock <= 2 else 0.0
	var bagging_bonus = 0.05 if bagging_table_ready else 0.0
	var register_bonus = 0.03 if register_balanced else 0.0
	speed_modifier = clamp(0.94 + bagging_bonus - fryer_penalty - trash_penalty, 0.55, 1.15)
	accuracy_modifier = clamp(0.92 + register_bonus + bagging_bonus - sauce_penalty - clean_penalty, 0.55, 1.15)
	customer_patience_modifier = clamp(0.95 + min(0.05, float(sauce_stock) * 0.01) - clean_penalty - trash_penalty, 0.55, 1.15)

func _emit_status(reason: String):
	var status = get_shift_effects()
	status["reason"] = reason
	store_ops_status_changed.emit(status)

func _adjust_corporate(delta: int):
	var corporate = get_tree().root.get_node_or_null("CorporateManager")
	if corporate and corporate.has_method("adjust_approval"):
		corporate.adjust_approval(delta)

func _log(event_name: String, value: float, detail: String):
	var event_log = get_tree().root.get_node_or_null("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event(event_name, value, detail)

func _record_daily_progress(event_name: String, detail: String):
	var daily = get_tree().root.find_child("DailyTaskManager", true, false)
	if daily and daily.has_method("record_progress"):
		daily.record_progress(event_name, detail)
