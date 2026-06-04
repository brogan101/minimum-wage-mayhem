extends SceneTree

func _initialize():
	call_deferred("_run_check")

func _run_check():
	var main_scene = load("res://scenes/world/Main.tscn")
	_assert(main_scene != null, "Main scene loads")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var mischief = root.find_child("MischiefDirector", true, false)
	var prank_war = root.find_child("PrankWarManager", true, false)
	var daily = root.find_child("DailyTaskManager", true, false)
	var damage = root.find_child("RestaurantDamageManager", true, false)
	var recap = root.find_child("MischiefRecapManager", true, false)
	var shift_results = root.get_node_or_null("ShiftResultManager")
	var event_log = root.get_node_or_null("EventLog")
	var staff = root.find_child("StaffDirector", true, false)
	var store_ops = root.find_child("StoreOpsDirector", true, false)
	var career = root.get_node_or_null("CareerManager")
	var wallet = root.get_node_or_null("WalletManager")

	_assert(mischief != null, "MischiefDirector wired into playable scene")
	_assert(prank_war != null, "PrankWarManager wired into playable scene")
	_assert(daily != null, "DailyTaskManager still wired")
	_assert(damage != null, "RestaurantDamageManager wired into playable scene")
	_assert(recap != null, "MischiefRecapManager wired into playable scene")
	_assert(shift_results != null and event_log != null, "Shift results and EventLog exist")
	_assert(staff != null and store_ops != null and career != null and wallet != null, "Gameplay consequence systems exist")

	_assert(mischief.pranks.size() > 0, "Prank catalog loaded")
	_assert(mischief.backfires.size() > 0, "Prank backfire catalog loaded")
	_assert(prank_war.chains.size() > 0, "Prank war chains loaded")
	_assert(damage.damage_events.size() > 0, "Restaurant damage events loaded")
	_assert(mischief.side_quests.size() > 0, "Prank side quests loaded")
	_assert(mischief.story_events.size() == 180, "Restaurant story event count remains 180")
	_assert(not daily.data_task_catalog.is_empty(), "Mischief daily task data catalog loaded")

	mischief.configure_shift(1)
	var tutorial_heavy = mischief.pull_optional_prank("fake_coupon_live", {"force_backfire": true})
	_assert(tutorial_heavy.is_empty(), "Tutorial shift blocks heavy prank without force")

	shift_results.begin_shift_snapshot()
	mischief.configure_shift(4)
	var starting_morale = staff.staff_morale
	var starting_wallet = wallet.balance
	var harmless = mischief.pull_optional_prank("party_hat_mop", {"max_severity": 1, "force_no_backfire": true})
	_assert(not harmless.is_empty(), "Optional harmless prank resolves")
	_assert(int(staff.staff_morale) > int(starting_morale), "Harmless prank can improve morale")
	_assert(float(wallet.balance) > float(starting_wallet), "Prank can reward cash")
	_assert(event_log.get_events_by_type("mischief_prank_resolved").size() >= 1, "Prank resolution logged")

	var coworker = mischief.coworker_prank_player("casey", {"force": true})
	_assert(not coworker.is_empty(), "Coworker can prank the player")
	_assert(event_log.get_events_by_type("coworker_pranked_player").size() >= 1, "Coworker prank logged")

	var backfire = mischief.pull_optional_prank("fake_coupon_live", {"force": true, "force_backfire": true, "force_chain": true, "force_damage": true, "max_severity": 4})
	_assert(not backfire.is_empty(), "Disruptive prank can resolve with forced backfire")
	_assert(backfire.get("backfire", {}).size() > 0, "Prank backfire data attached")
	_assert(prank_war.get_summary().get("chain_history", []).size() >= 1, "Prank war can escalate but is tracked")
	_assert(damage.get_damage_summary().get("active_damage", []).size() >= 1, "Backfire can create repairable restaurant damage")
	_assert(event_log.get_events_by_type("restaurant_damage_triggered").size() >= 1, "Restaurant damage logged")

	var repaired = damage.repair_damage("clean_spill")
	_assert(repaired.get("repaired_damage", []).size() >= 1, "Restaurant damage can be repaired")
	_assert(event_log.get_events_by_type("restaurant_damage_repaired").size() >= 1, "Restaurant damage repair logged")

	var quest = mischief.generate_side_quest({"index": 0})
	_assert(not quest.is_empty(), "Prank side quest can generate")
	var completed_quest = mischief.complete_side_quest(str(quest.get("id", "")))
	_assert(bool(completed_quest.get("completed", false)), "Prank side quest can complete")

	var task_count = daily.get_task_status().size()
	daily.complete_task("make_coworker_laugh")
	_assert(task_count >= 1, "Daily tasks generate each shift")
	_assert(int(daily.get_reward_totals().get("xp", 0)) > 0, "Daily task rewards XP")

	var mischief_recap = recap.build_recap({})
	_assert(int(mischief_recap.get("pranks_pulled", 0)) >= 3, "Mischief recap counts pranks")
	_assert(int(mischief_recap.get("prank_backfires", 0)) >= 1, "Mischief recap counts backfires")
	_assert(mischief_recap.get("restaurant_damage_repaired", []).size() >= 1, "Mischief recap includes repaired damage")

	var report = shift_results.complete_shift({"completed": 1})
	var result = shift_results.get_last_result_data()
	_assert(report.contains("Mischief:"), "Shift report includes Mischief section")
	_assert(result.get("mischief_pranks", 0) >= 3, "Shift result stores mischief prank count")
	_assert(result.get("restaurant_damage_repaired", []).size() >= 1, "Shift result stores repaired damage")
	_assert(career.get_career_status().get("career_recap_history", []).size() >= 1, "Career history still records the shift")

	print("[PASS] Phase 10 runtime workplace mischief/pranks/damage check passed")
	main.queue_free()
	await process_frame
	quit(0)

func _assert(condition: bool, message: String):
	if condition:
		print("[PASS] " + message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
