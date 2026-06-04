extends Node
class_name EventManager
## EventManager handles low-frequency shift chaos events and routes them into real game state.

signal chaos_event_triggered(event_type: String, payload: Dictionary)

var active_events: Array[String] = []
var event_history: Array[Dictionary] = []
var chaos_timer: Timer

func _ready():
	chaos_timer = Timer.new()
	chaos_timer.name = "ChaosTimer"
	chaos_timer.wait_time = randf_range(60.0, 180.0)
	chaos_timer.autostart = true
	chaos_timer.timeout.connect(_on_chaos_timer_timeout)
	add_child(chaos_timer)

func _on_chaos_timer_timeout():
	var events = [
		"SODA_SPRAY",
		"FRYER_OVERHEAT",
		"CUSTOMER_MELTDOWN",
		"CORPORATE_INSPECTION"
	]
	trigger_event(events.pick_random())
	chaos_timer.start(randf_range(60.0, 180.0))

func trigger_event(event_type: String) -> Dictionary:
	var payload := {
		"event_type": event_type,
		"time": Time.get_ticks_msec(),
		"systems_affected": [],
		"resolved": false
	}
	active_events.append(event_type)
	match event_type:
		"SODA_SPRAY":
			payload["systems_affected"] = ["cleanliness", "station_delay", "staff_morale"]
			_apply_stat("Stress", 5.0)
			_log("chaos_soda_spray", 5.0, "Drink station sprayed soda and created a cleanup task.")
		"FRYER_OVERHEAT":
			payload["systems_affected"] = ["food_quality", "station_delay", "beef"]
			_apply_beef(15, "Fryer overheated during shift")
			_burn_items_in_group("fryers")
			_log("chaos_fryer_overheat", 15.0, "Fryer overheated and raised Beef risk.")
		"CUSTOMER_MELTDOWN":
			payload["systems_affected"] = ["beef", "review_risk", "manager_trust"]
			_apply_beef(35, "Customer meltdown")
			_log("chaos_customer_meltdown", 35.0, "A customer entered meltdown mode.")
		"CORPORATE_INSPECTION":
			payload["systems_affected"] = ["corporate_approval", "cleanliness", "promotion_progress"]
			_apply_corporate_pressure(-5)
			_log("chaos_corporate_inspection", -5.0, "Corporate inspection pressure increased.")
		_:
			payload["systems_affected"] = ["eventlog"]
			_log("chaos_unknown", 0.0, event_type)
	event_history.append(payload)
	emit_signal("chaos_event_triggered", event_type, payload)
	return payload

func resolve_event(event_type: String, detail: String = "") -> void:
	active_events.erase(event_type)
	_log("chaos_event_resolved", 0.0, event_type + " " + detail)

func _apply_beef(amount: int, reason: String) -> void:
	if typeof(BeefManager) != TYPE_NIL and BeefManager.has_method("increase_beef"):
		BeefManager.increase_beef(amount, reason)

func _apply_stat(stat_name: String, amount: float) -> void:
	if typeof(StatManager) != TYPE_NIL and StatManager.has_method("update_stat"):
		StatManager.update_stat(stat_name, amount)

func _apply_corporate_pressure(amount: int) -> void:
	if typeof(CorporateManager) != TYPE_NIL:
		if CorporateManager.has_method("adjust_approval"):
			CorporateManager.adjust_approval(amount)
		elif "approval_rating" in CorporateManager:
			CorporateManager.approval_rating = clamp(CorporateManager.approval_rating + amount, 0, 100)

func _burn_items_in_group(group_name: String) -> void:
	for node in get_tree().get_nodes_in_group(group_name):
		if node.has_method("trigger_overheat"):
			node.trigger_overheat()

func _log(event_name: String, value: float, detail: String) -> void:
	if typeof(EventLog) != TYPE_NIL and EventLog.has_method("log_event"):
		EventLog.log_event(event_name, value, detail)
