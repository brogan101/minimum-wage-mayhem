extends Node
## Converts a finished shift into results, save data, and replay hooks.

var shift_number: int = 0
var last_report: String = ""
var last_result_data: Dictionary = {}
var next_shift_setup: Dictionary = {}
var shift_start_snapshot := {
	"wallet": 0.0,
	"xp": 0.0,
	"staff_morale": 0,
	"manager_trust": 0,
	"corporate_approval": 0
}

func begin_shift_snapshot():
	shift_number += 1
	var wallet = _autoload("WalletManager")
	var career = _autoload("CareerManager")
	var staff = get_tree().root.find_child("StaffDirector", true, false)
	var corporate = _autoload("CorporateManager")
	var staff_effects = staff.get_shift_effects() if staff and staff.has_method("get_shift_effects") else {}
	shift_start_snapshot = {
		"wallet": wallet.balance if wallet else 0.0,
		"xp": career.current_xp if career else 0.0,
		"staff_morale": int(staff_effects.get("staff_morale", 0)),
		"manager_trust": int(staff_effects.get("manager_trust", 0)),
		"corporate_approval": corporate.get_approval_rating() if corporate and corporate.has_method("get_approval_rating") else 0
	}

func complete_shift(player_stats: Dictionary = {}) -> String:
	last_result_data = build_shift_result_data(player_stats)
	var career = _autoload("CareerManager")
	if career and career.has_method("apply_shift_result"):
		last_result_data["career_status"] = career.apply_shift_result(last_result_data)
	last_report = format_shift_report(last_result_data)
	next_shift_setup = prepare_next_shift(last_result_data)
	last_result_data["next_shift"] = next_shift_setup
	_save_progress(last_result_data, next_shift_setup)
	_log("shift_results_generated", 1.0, "Shift " + str(shift_number) + " recap generated")
	return last_report

func generate_end_of_shift_screen(player_stats: Dictionary):
	return complete_shift(player_stats)

func build_shift_result_data(player_stats: Dictionary = {}) -> Dictionary:
	var wallet = _autoload("WalletManager")
	var career = _autoload("CareerManager")
	var order_manager = _autoload("OrderManager")
	var beef = _autoload("BeefManager")
	var corporate = _autoload("CorporateManager")
	var event_log = _autoload("EventLog")
	var staff = get_tree().root.find_child("StaffDirector", true, false)
	var store_ops = get_tree().root.find_child("StoreOpsDirector", true, false)
	var daily = get_tree().root.find_child("DailyTaskManager", true, false)
	var staff_effects = staff.get_shift_effects() if staff and staff.has_method("get_shift_effects") else {}
	var store_effects = store_ops.get_shift_effects() if store_ops and store_ops.has_method("get_shift_effects") else {}
	if daily and daily.has_method("finish_shift"):
		daily.finish_shift()
	var daily_rewards = daily.get_reward_totals() if daily and daily.has_method("get_reward_totals") else {}
	var daily_tasks = daily.get_task_status() if daily and daily.has_method("get_task_status") else []
	var daily_entries = daily.get_recap_entries() if daily and daily.has_method("get_recap_entries") else []
	var store_entries = store_ops.get_recap_entries() if store_ops and store_ops.has_method("get_recap_entries") else []
	var chaos_runtime = get_tree().root.find_child("ChaosIncidentRuntime", true, false)
	var chaos_summary = chaos_runtime.get_phase9_summary() if chaos_runtime and chaos_runtime.has_method("get_phase9_summary") else {}
	var mischief_recap_manager = get_tree().root.find_child("MischiefRecapManager", true, false)
	var mischief_recap = mischief_recap_manager.build_recap({}) if mischief_recap_manager and mischief_recap_manager.has_method("build_recap") else {}
	var fireable_manager = get_tree().root.find_child("FireableOffenseManager", true, false)
	var consequence_summary = fireable_manager.get_consequence_summary() if fireable_manager and fireable_manager.has_method("get_consequence_summary") else {}
	var emergent_director = get_tree().root.find_child("EmergentEventDirector", true, false)
	var emergent_summary = emergent_director.get_emergent_summary() if emergent_director and emergent_director.has_method("get_emergent_summary") else {}
	var depth_director = get_tree().root.find_child("DepthDirector", true, false)
	var depth_summary = depth_director.get_depth_summary() if depth_director and depth_director.has_method("get_depth_summary") else {}
	var beef_incidents = event_log.get_events_by_type("beef_incident") if event_log and event_log.has_method("get_events_by_type") else []
	var writeups = _build_warnings(beef_incidents, store_effects, staff_effects, corporate)
	var reviews = _build_reviews(store_effects, daily_tasks, beef_incidents)
	for review in chaos_summary.get("reviews", []):
		reviews.append(str(review))
	for hr in chaos_summary.get("hr_reports", []):
		writeups.append("HR: " + str(hr.get("incident", "incident")))
	for hr_note in consequence_summary.get("hr_reports", []):
		writeups.append("HR: " + str(hr_note))
	for shady_review in consequence_summary.get("reviews", []):
		reviews.append(str(shady_review))
	for hr_note in emergent_summary.get("hr_reports", []):
		writeups.append("Emergent HR: " + str(hr_note))
	for review_note in emergent_summary.get("reviews", []):
		reviews.append(str(review_note))
	var current_wallet = wallet.balance if wallet else float(player_stats.get("cash", 0.0))
	var current_xp = career.current_xp if career else 0.0
	var completed_tasks = _count_tasks(daily_tasks, "completed")
	var failed_tasks = _count_tasks(daily_tasks, "failed")
	var result = {
		"shift_number": shift_number,
		"money_earned": current_wallet - float(shift_start_snapshot.get("wallet", 0.0)),
		"xp_earned": current_xp - float(shift_start_snapshot.get("xp", 0.0)),
		"tips": int(daily_rewards.get("tips", 0)),
		"customers_served": order_manager.orders_completed if order_manager else int(player_stats.get("completed", 0)),
		"order_accuracy": order_manager.get_order_accuracy() if order_manager and order_manager.has_method("get_order_accuracy") else 1.0,
		"average_wait": order_manager.get_average_wait() if order_manager and order_manager.has_method("get_average_wait") else 0.0,
		"average_patience": order_manager.get_average_patience() if order_manager and order_manager.has_method("get_average_patience") else float(store_effects.get("customer_patience", 1.0)),
		"beef_incidents": beef_incidents.size(),
		"current_beef": beef.current_beef if beef else 0.0,
		"staff_morale_change": int(staff_effects.get("staff_morale", 0)) - int(shift_start_snapshot.get("staff_morale", 0)),
		"manager_trust_change": int(staff_effects.get("manager_trust", store_effects.get("manager_trust", 0))) - int(shift_start_snapshot.get("manager_trust", 0)),
		"corporate_approval_change": (corporate.get_approval_rating() if corporate and corporate.has_method("get_approval_rating") else int(player_stats.get("corp", 0))) - int(shift_start_snapshot.get("corporate_approval", 0)),
		"daily_tasks_completed": completed_tasks,
		"daily_tasks_failed": failed_tasks,
		"daily_task_entries": daily_entries,
		"store_duty_entries": store_entries,
		"reviews": reviews,
		"writeups": writeups,
		"warnings": writeups,
		"phase9_incidents": chaos_summary.get("incidents", []),
		"phase9_hr_reports": chaos_summary.get("hr_reports", []),
		"phase9_viral_clips": chaos_summary.get("viral_clips", []),
		"reputation_labels": chaos_summary.get("reputation_labels", []),
		"mischief_recap": mischief_recap,
		"mischief_pranks": mischief_recap.get("pranks_pulled", 0),
		"mischief_backfires": mischief_recap.get("prank_backfires", 0),
		"prank_war_heat": mischief_recap.get("prank_war_heat", 0),
		"restaurant_damage_active": mischief_recap.get("restaurant_damage_active", []),
		"restaurant_damage_repaired": mischief_recap.get("restaurant_damage_repaired", []),
		"fireable_consequence_summary": consequence_summary,
		"fireable_offenses": consequence_summary.get("offenses", []),
		"caught_levels": consequence_summary.get("caught_history", []),
		"firing_recovery_routes": consequence_summary.get("recovery_routes", []),
		"suspicion_summary": consequence_summary.get("suspicion", {}),
		"emergent_summary": emergent_summary,
		"emergent_events": emergent_summary.get("events", []),
		"emergent_missions": emergent_summary.get("missions", []),
		"emergent_evidence": emergent_summary.get("evidence", []),
		"emergent_future_chains": emergent_summary.get("future_chains", []),
		"dynamic_reputation_labels": emergent_summary.get("dynamic_labels", []),
		"generated_recaps": emergent_summary.get("recaps", []),
		"depth_summary": depth_summary,
		"depth_bundles": depth_summary.get("active_bundles", []),
		"depth_balance": depth_summary.get("balance", {}),
		"depth_recovery_routes": depth_summary.get("recovery_routes", []),
		"depth_promotion_detours": depth_summary.get("promotion_detours", []),
		"depth_store_mutations": depth_summary.get("store_mutations", []),
		"depth_generated_events": depth_summary.get("generated_depth_events", []),
		"notable_moment": _pick_notable_moment(event_log, daily_entries, store_entries),
		"unlock_hooks": _build_unlock_hooks(career, daily_rewards, completed_tasks),
		"fail_state": _build_fail_state(writeups, beef_incidents, corporate),
		"recommendation": _next_shift_recommendation(completed_tasks, failed_tasks, beef_incidents)
	}
	return result

func format_shift_report(result: Dictionary) -> String:
	var report = "--- SHIFT SUMMARY ---\n"
	report += "Shift: " + str(result.get("shift_number", 0)) + "\n"
	report += "Money Earned: $" + str(snapped(float(result.get("money_earned", 0.0)), 0.01)) + "\n"
	report += "XP Earned: " + str(snapped(float(result.get("xp_earned", 0.0)), 0.01)) + "\n"
	report += "Tips: $" + str(result.get("tips", 0)) + "\n"
	report += "Customers Served: " + str(result.get("customers_served", 0)) + "\n"
	report += "Order Accuracy: " + str(int(float(result.get("order_accuracy", 1.0)) * 100.0)) + "%\n"
	report += "Average Wait: " + str(snapped(float(result.get("average_wait", 0.0)), 0.1)) + "s\n"
	report += "Average Patience: " + str(int(float(result.get("average_patience", 1.0)) * 100.0)) + "%\n"
	report += "Beef Incidents: " + str(result.get("beef_incidents", 0)) + "\n"
	report += "Staff Morale Change: " + _signed(result.get("staff_morale_change", 0)) + "\n"
	report += "Manager Trust Change: " + _signed(result.get("manager_trust_change", 0)) + "\n"
	report += "Corporate Approval Change: " + _signed(result.get("corporate_approval_change", 0)) + "\n"
	report += "Daily Tasks: " + str(result.get("daily_tasks_completed", 0)) + " completed / " + str(result.get("daily_tasks_failed", 0)) + " missed\n"
	report += "Reviews: " + "; ".join(result.get("reviews", [])) + "\n"
	if not result.get("writeups", []).is_empty():
		report += "Write-ups or Warnings: " + "; ".join(result.get("writeups", [])) + "\n"
	else:
		report += "Write-ups or Warnings: none\n"
	report += "Chaos Incidents: " + str(result.get("phase9_incidents", []).size()) + "\n"
	if not result.get("reputation_labels", []).is_empty():
		report += "Reputation Labels: " + "; ".join(result.get("reputation_labels", [])) + "\n"
	report += "Mischief: " + str(result.get("mischief_pranks", 0)) + " pranks / " + str(result.get("mischief_backfires", 0)) + " backfires / heat " + str(result.get("prank_war_heat", 0)) + "\n"
	var mischief_recap: Dictionary = result.get("mischief_recap", {})
	if not mischief_recap.get("recap_entries", []).is_empty():
		report += "Mischief Results:"
		for entry in mischief_recap.get("recap_entries", []):
			report += "\n- " + str(entry)
		report += "\n"
	report += "Consequences: " + str(result.get("fireable_offenses", []).size()) + " shady choices / " + str(result.get("caught_levels", []).size()) + " caught outcomes\n"
	var suspicion_summary: Dictionary = result.get("suspicion_summary", {})
	if not suspicion_summary.is_empty():
		report += "Suspicion: " + str(suspicion_summary.get("player_suspicion", 0)) + " player / " + str(suspicion_summary.get("manager_suspicion", 0)) + " manager\n"
	if not result.get("firing_recovery_routes", []).is_empty():
		report += "Recovery Routes: "
		var route_names: Array[String] = []
		for route in result.get("firing_recovery_routes", []):
			route_names.append(str(route.get("id", "")))
		report += "; ".join(route_names) + "\n"
	report += "Restaurant Memory: " + str(result.get("emergent_events", []).size()) + " generated events / " + str(result.get("emergent_evidence", []).size()) + " evidence / " + str(result.get("emergent_missions", []).size()) + " missions\n"
	if not result.get("dynamic_reputation_labels", []).is_empty():
		report += "Dynamic Labels: " + "; ".join(result.get("dynamic_reputation_labels", [])) + "\n"
	if not result.get("generated_recaps", []).is_empty():
		var generated_recap: Dictionary = result.get("generated_recaps", [])[-1]
		report += "Generated Recap: " + str(generated_recap.get("next_shift_warning", "The restaurant remembers.")) + "\n"
	var depth_balance: Dictionary = result.get("depth_balance", {})
	var depth_ratio: Dictionary = depth_balance.get("ratio", {})
	report += "Global Depth: " + str(result.get("depth_bundles", []).size()) + " bundles / " + str(result.get("depth_generated_events", []).size()) + " generated events\n"
	if not depth_ratio.is_empty():
		report += "Depth Balance: normal " + str(int(float(depth_ratio.get("normal_orders", 0.0)) * 100.0)) + "% / friction " + str(int(float(depth_ratio.get("service_friction", 0.0)) * 100.0)) + "% / weird " + str(int(float(depth_ratio.get("funny_weird", 0.0)) * 100.0)) + "% / wild " + str(int(float(depth_ratio.get("wild_spike", 0.0)) * 100.0)) + "%\n"
	if not result.get("depth_recovery_routes", []).is_empty():
		report += "Depth Recovery Hooks: " + str(result.get("depth_recovery_routes", []).size()) + "\n"
	if not result.get("depth_promotion_detours", []).is_empty():
		report += "Promotion Detours: " + str(result.get("depth_promotion_detours", []).size()) + "\n"
	report += "Funniest/Most Notable Moment: " + str(result.get("notable_moment", "Nothing caught fire emotionally.")) + "\n"
	if not result.get("daily_task_entries", []).is_empty():
		report += "\nDaily Tasks:"
		for entry in result.get("daily_task_entries", []):
			report += "\n- " + str(entry)
	if not result.get("store_duty_entries", []).is_empty():
		report += "\n\nStore Duties:"
		for entry in result.get("store_duty_entries", []):
			report += "\n- " + str(entry)
	report += "\n\nUnlock Hooks: " + "; ".join(result.get("unlock_hooks", []))
	report += "\nFail State: " + str(result.get("fail_state", "none"))
	report += "\nNext Shift: " + str(result.get("recommendation", "Clock in and try again."))
	return report

func prepare_next_shift(result: Dictionary) -> Dictionary:
	var setup = {
		"shift_number": shift_number + 1,
		"suggested_focus": result.get("recommendation", "Keep orders moving"),
		"starting_patience_modifier": max(0.75, float(result.get("average_patience", 1.0))),
		"carryover_warning_count": result.get("warnings", []).size(),
		"available_unlock_hooks": result.get("unlock_hooks", []),
		"recoverable": str(result.get("fail_state", "none")) != "hard_fail"
	}
	_log("next_shift_prepared", 1.0, str(setup.get("suggested_focus", "")))
	return setup

func get_last_result_data() -> Dictionary:
	return last_result_data.duplicate(true)

func get_last_report() -> String:
	return last_report

func get_next_shift_setup() -> Dictionary:
	return next_shift_setup.duplicate(true)

func _save_progress(result: Dictionary, next_shift: Dictionary):
	var save_system = _autoload("SaveSystem")
	if save_system and save_system.has_method("save_game"):
		save_system.save_game({
			"last_shift": result,
			"next_shift": next_shift,
			"progression": {
				"unlock_hooks": result.get("unlock_hooks", []),
				"shift_number": shift_number,
				"recoverable_fail_state": result.get("fail_state", "none")
			}
		})

func _build_warnings(beef_incidents: Array, store_effects: Dictionary, staff_effects: Dictionary, corporate: Node) -> Array[String]:
	var warnings: Array[String] = []
	if beef_incidents.size() >= 2:
		warnings.append("Customer Beef trend requires coaching")
	if int(store_effects.get("review_risk", 0)) >= 12:
		warnings.append("Review risk elevated by store conditions")
	var approval = corporate.get_approval_rating() if corporate and corporate.has_method("get_approval_rating") else int(store_effects.get("corporate_approval", 50))
	if approval < 35:
		warnings.append("Corporate approval below comfort theater")
	if int(staff_effects.get("staff_morale", 70)) < 35:
		warnings.append("Staff morale needs recovery")
	return warnings

func _build_reviews(store_effects: Dictionary, daily_tasks: Array, beef_incidents: Array) -> Array[String]:
	var reviews: Array[String] = []
	var completed = _count_tasks(daily_tasks, "completed")
	if completed >= 4:
		reviews.append("4 stars: shift looked almost intentional")
	if int(store_effects.get("cleanliness", 0)) >= 70:
		reviews.append("Clean lobby noticed by one normal person")
	if beef_incidents.size() > 0:
		reviews.append("One guest described the vibe as spicy")
	if reviews.is_empty():
		reviews.append("3 stars: edible, local, emotionally complicated")
	return reviews

func _build_unlock_hooks(career: Node, daily_rewards: Dictionary, completed_tasks: int) -> Array[String]:
	var hooks: Array[String] = []
	if completed_tasks >= 4:
		hooks.append("daily_task_bonus_pool")
	if int(daily_rewards.get("promotion_progress", 0)) > 0:
		hooks.append("promotion_progress_tick")
	if career and float(career.current_xp) >= 50.0:
		hooks.append("trainee_growth_checkpoint")
	if hooks.is_empty():
		hooks.append("replay_basics")
	return hooks

func _build_fail_state(warnings: Array, beef_incidents: Array, corporate: Node) -> String:
	var approval = corporate.get_approval_rating() if corporate and corporate.has_method("get_approval_rating") else 50
	if approval <= 20:
		return "recoverable_probation"
	if warnings.size() >= 2 or beef_incidents.size() >= 3:
		return "recoverable_warning"
	return "none"

func _next_shift_recommendation(completed_tasks: int, failed_tasks: int, beef_incidents: Array) -> String:
	if beef_incidents.size() > 0:
		return "Start with patience recovery and cleaner handoffs"
	if failed_tasks > completed_tasks:
		return "Pick two easy daily tasks before the rush"
	return "Ride the momentum into another shift"

func _pick_notable_moment(event_log: Node, daily_entries: Array, store_entries: Array) -> String:
	if event_log and event_log.has_method("get_events_by_type"):
		var funny = event_log.get_events_by_type("coworker_dialogue")
		if funny.size() > 0:
			return str(funny[-1].get("detail", "Coworker said something shift-shaped"))
		var beefs = event_log.get_events_by_type("beef_incident")
		if beefs.size() > 0:
			return "Beef incident: " + str(beefs[-1].get("detail", "customer frustration"))
	if daily_entries.size() > 0:
		return str(daily_entries[0])
	if store_entries.size() > 0:
		return str(store_entries[0])
	return "The shift ended and the building remained technically open."

func _count_tasks(tasks: Array, key: String) -> int:
	var count = 0
	for task in tasks:
		if bool(task.get(key, false)):
			count += 1
	return count

func _signed(value) -> String:
	var number = int(value)
	return "+" + str(number) if number >= 0 else str(number)

func _log(event_name: String, value: float, detail: String):
	var event_log = _autoload("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event(event_name, value, detail)

func _autoload(name: String) -> Node:
	return get_tree().root.get_node_or_null(name)
