extends Node
class_name MischiefRecapManager

signal mischief_recap_generated(recap: Dictionary)

func build_recap(context: Dictionary) -> Dictionary:
	var mischief = get_tree().root.find_child("MischiefDirector", true, false)
	var prank_war = get_tree().root.find_child("PrankWarManager", true, false)
	var damage = get_tree().root.find_child("RestaurantDamageManager", true, false)
	var mischief_summary = mischief.get_mischief_summary() if mischief and mischief.has_method("get_mischief_summary") else {}
	var war_summary = prank_war.get_summary() if prank_war and prank_war.has_method("get_summary") else {}
	var damage_summary = damage.get_damage_summary() if damage and damage.has_method("get_damage_summary") else {}
	var backfire_count = mischief_summary.get("backfires", []).size()
	var recap := {
		"pranks_pulled": mischief_summary.get("pranks", []).size(),
		"coworker_pranks": mischief_summary.get("coworker_pranks", []).size(),
		"prank_backfires": backfire_count,
		"side_quests": mischief_summary.get("side_quests", []),
		"manager_suspicion": mischief_summary.get("manager_suspicion", context.get("manager_suspicion_delta", 0)),
		"staff_morale_delta": context.get("staff_morale_delta", 0),
		"restaurant_stability": damage_summary.get("stability", mischief_summary.get("restaurant_stability", 100)),
		"restaurant_damage_active": damage_summary.get("active_damage", []),
		"restaurant_damage_repaired": damage_summary.get("repaired_damage", []),
		"prank_war_heat": max(int(mischief_summary.get("prank_war_heat", 0)), int(war_summary.get("heat", 0))),
		"prank_war_chain": war_summary.get("active_chain", {}),
		"recap_entries": _combine_entries(mischief_summary, damage_summary),
		"coworker_loyalty": "Playful" if int(mischief_summary.get("coworker_prank_trust", 0)) >= 0 else "Annoyed",
		"hr_risk": "Elevated" if backfire_count > 0 else "Low",
		"most_suspicious_moment": _pick_suspicious_moment(mischief_summary, damage_summary),
		"manager_note": "Mischief stayed optional." if backfire_count == 0 else "The manager has questions about the mop-adjacent evidence."
	}
	emit_signal("mischief_recap_generated", recap)
	_log("mischief_recap_generated", float(recap.get("pranks_pulled", 0)), str(recap.get("manager_note", "")))
	return recap

func _combine_entries(mischief_summary: Dictionary, damage_summary: Dictionary) -> Array[String]:
	var entries: Array[String] = []
	for entry in mischief_summary.get("recap_entries", []):
		entries.append(str(entry))
	for entry in damage_summary.get("recap_entries", []):
		entries.append(str(entry))
	return entries

func _pick_suspicious_moment(mischief_summary: Dictionary, damage_summary: Dictionary) -> String:
	var entries = _combine_entries(mischief_summary, damage_summary)
	if entries.size() > 0:
		return entries[-1]
	return "Nothing suspicious happened, which is suspicious."

func _log(event_name: String, value: float, detail: String):
	var event_log = get_tree().root.get_node_or_null("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event(event_name, value, detail)
