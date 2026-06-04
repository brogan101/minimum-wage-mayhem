extends Node
class_name MissionManager
## MissionManager manages active story missions and lightweight success/failure checks.

signal mission_started(title: String, objective: String)
signal mission_completed(success: bool, mission_id: String, result: Dictionary)
signal mission_progress_changed(mission_id: String, progress: Dictionary)

var active_mission: Dictionary = {}
var completed_missions: Array[String] = []

var legendary_shifts := {
	"coupon_binder_standoff": {
		"title": "Coupon Binder Standoff",
		"objective": "Resolve a coupon argument without maxing Beef or losing the line.",
		"success_keys": {"beef_below": 80, "orders_completed_min": 1},
		"failure_keys": {"beef_at_or_above": 100},
		"reward": 250,
		"safety_note": "Customer conflict is handled through de-escalation and abstract consequence systems."
	},
	"forty_burger_rush_safe": {
		"title": "The 40-Burger Rush",
		"objective": "Handle a huge order rush with quality, teamwork, and no station collapse.",
		"success_keys": {"orders_completed_min": 3, "burnt_items_max": 2},
		"failure_keys": {"store_stability_below": 20},
		"reward": 500,
		"safety_note": "Volume challenge only; no unsafe content."
	},
	"manager_left_building": {
		"title": "Manager Has Left The Building",
		"objective": "Keep the store functioning while the manager disappears during chaos.",
		"success_keys": {"shift_completed": true, "staff_morale_min": 25},
		"failure_keys": {"store_stability_below": 15},
		"reward": 400,
		"safety_note": "Workplace comedy incident."
	},
	"sauce_economy_collapse": {
		"title": "Sauce Economy Collapse",
		"objective": "Stabilize sauce stock, customer Beef, and coworker drama before the shift ends.",
		"success_keys": {"sauce_stock_min": 1, "beef_below": 90},
		"failure_keys": {"beef_at_or_above": 100},
		"reward": 350,
		"safety_note": "Fictional sauce economy gag."
	}
}

func start_mission(mission_id: String) -> bool:
	if not legendary_shifts.has(mission_id):
		return false
	active_mission = legendary_shifts[mission_id].duplicate(true)
	active_mission["mission_id"] = mission_id
	active_mission["started_at"] = Time.get_ticks_msec()
	emit_signal("mission_started", active_mission["title"], active_mission["objective"])
	if typeof(EventLog) != TYPE_NIL:
		EventLog.log_event("mission_started", 0.0, mission_id)
	return true

func check_mission_status(current_state: Dictionary) -> Dictionary:
	if active_mission.is_empty():
		return {"active": false}
	var mission_id := str(active_mission.get("mission_id", ""))
	var failed := _matches_failure(active_mission.get("failure_keys", {}), current_state)
	var succeeded := _matches_success(active_mission.get("success_keys", {}), current_state)
	var result := {"active": true, "mission_id": mission_id, "success": succeeded, "failed": failed}
	emit_signal("mission_progress_changed", mission_id, result)
	if failed or succeeded:
		_finish_mission(not failed, result)
	return result

func _matches_success(requirements: Dictionary, state: Dictionary) -> bool:
	for key in requirements.keys():
		var target = requirements[key]
		match key:
			"beef_below":
				if int(state.get("beef", 0)) >= int(target): return false
			"orders_completed_min":
				if int(state.get("orders_completed", 0)) < int(target): return false
			"burnt_items_max":
				if int(state.get("burnt_items", 0)) > int(target): return false
			"shift_completed":
				if bool(state.get("shift_completed", false)) != bool(target): return false
			"staff_morale_min":
				if int(state.get("staff_morale", 100)) < int(target): return false
			"sauce_stock_min":
				if int(state.get("sauce_stock", 0)) < int(target): return false
	return true

func _matches_failure(requirements: Dictionary, state: Dictionary) -> bool:
	for key in requirements.keys():
		var target = requirements[key]
		match key:
			"beef_at_or_above":
				if int(state.get("beef", 0)) >= int(target): return true
			"store_stability_below":
				if int(state.get("store_stability", 100)) < int(target): return true
	return false

func _finish_mission(success: bool, result: Dictionary) -> void:
	var mission_id := str(active_mission.get("mission_id", ""))
	if success:
		completed_missions.append(mission_id)
		if typeof(WalletManager) != TYPE_NIL and WalletManager.has_method("add_money"):
			WalletManager.add_money(int(active_mission.get("reward", 0)))
	if typeof(EventLog) != TYPE_NIL:
		EventLog.log_event("mission_completed" if success else "mission_failed", float(active_mission.get("reward", 0)), mission_id)
	emit_signal("mission_completed", success, mission_id, result)
	active_mission = {}
