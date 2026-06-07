extends Node
class_name DailyTaskManager

signal daily_tasks_generated(tasks: Array)
signal daily_task_updated(tasks: Array)
signal daily_task_completed(task_id: String)

var active_tasks: Array = []
var completed_tasks := {}
var failed_tasks := {}
var recap_entries: Array[String] = []
var rewards_earned := {
	"cash": 0,
	"tips": 0,
	"xp": 0,
	"morale": 0,
	"reputation": 0,
	"promotion_progress": 0
}
var data_task_catalog := {}
var last_rotation_offset: int = 0

var fallback_tasks := [
	{
		"id": "restock_sauce",
		"title": "Restock sauce before the dry-bun complaints start",
		"category": "normal_work",
		"trigger": "store_duty:restock_sauce",
		"reward": {"cash": 3, "xp": 8, "tips": 1}
	},
	{
		"id": "take_out_trash_before_lobby_smells",
		"title": "Take out trash before the lobby develops a personality",
		"category": "normal_work",
		"trigger": "store_duty:take_out_trash",
		"reward": {"cash": 3, "xp": 7, "reputation": 1}
	},
	{
		"id": "clear_bagging_table",
		"title": "Clear the bagging table",
		"category": "station",
		"trigger": "store_duty:clear_bagging_table",
		"reward": {"xp": 10, "cash": 2, "promotion_progress": 1}
	},
	{
		"id": "check_fryer_before_lore",
		"title": "Check fryer before it becomes lore",
		"category": "station",
		"trigger": "store_duty:check_fryer",
		"reward": {"xp": 9, "cash": 2, "promotion_progress": 1}
	},
	{
		"id": "count_register",
		"title": "Count the register without sighing at it",
		"category": "manager_request",
		"trigger": "store_duty:open_register",
		"reward": {"xp": 8, "reputation": 1, "promotion_progress": 1}
	},
	{
		"id": "upsell_soda_calmly",
		"title": "Serve one soda combo without sounding haunted",
		"category": "manager_request",
		"trigger": "order_type:soda",
		"reward": {"tips": 2, "xp": 8, "promotion_progress": 1}
	},
	{
		"id": "clean_station",
		"title": "Clean one station before someone slips dramatically",
		"category": "recovery",
		"trigger": "store_duty:clean_spill",
		"reward": {"xp": 8, "morale": 1, "reputation": 1}
	},
	{
		"id": "fix_minor_issue",
		"title": "Fix a minor equipment issue",
		"category": "recovery",
		"trigger": "store_issue_repaired:fryer_timer_drift",
		"reward": {"cash": 4, "xp": 12, "promotion_progress": 1}
	},
	{
		"id": "help_customer_fast",
		"title": "Keep a normal customer moving",
		"category": "customer_service",
		"trigger": "customer_served",
		"reward": {"cash": 5, "tips": 2, "xp": 10}
	},
	{
		"id": "serve_combo_order",
		"title": "Serve one combo order with all requested items",
		"category": "customer_service",
		"trigger": "order_type:combo",
		"reward": {"cash": 4, "tips": 2, "xp": 11}
	},
	{
		"id": "make_coworker_laugh",
		"title": "Make a coworker laugh during the rush",
		"category": "small_funny",
		"trigger": "coworker_dialogue",
		"reward": {"morale": 2, "xp": 6}
	},
	{
		"id": "answer_morgan_headset_omen",
		"title": "Answer one coworker comment without losing the lane",
		"category": "small_funny",
		"trigger": "coworker_dialogue:rush",
		"reward": {"morale": 2, "xp": 7}
	}
]

func _ready() -> void:
	data_task_catalog = _load_json_dictionary("res://data/mischief/daily_tasks.json")
	generate_daily_tasks()

func generate_daily_tasks(count: int = 6, categories: Array = [], rotation_offset: int = 0) -> Array:
	last_rotation_offset = rotation_offset
	active_tasks.clear()
	completed_tasks.clear()
	failed_tasks.clear()
	recap_entries.clear()
	rewards_earned = {"cash": 0, "tips": 0, "xp": 0, "morale": 0, "reputation": 0, "promotion_progress": 0}
	var selected_categories = categories if not categories.is_empty() else [
		"normal_work",
		"customer_service",
		"station",
		"manager_request",
		"recovery",
		"small_funny"
	]
	for category in selected_categories:
		var task = _task_for_category(str(category), rotation_offset)
		if not task.is_empty():
			active_tasks.append(_with_runtime_state(task))
		if active_tasks.size() >= count:
			break
	if active_tasks.is_empty():
		active_tasks.append(_with_runtime_state(fallback_tasks[0]))
	daily_tasks_generated.emit(get_task_status())
	daily_task_updated.emit(get_task_status())
	_log("daily_tasks_generated", float(active_tasks.size()), "Optional shift tasks generated")
	return get_task_status()

func refresh_for_shift(shift_number: int) -> Array:
	var rotation = max(0, shift_number - 1)
	return generate_daily_tasks(6, [], rotation)

func record_progress(event_name: String, detail: String = ""):
	for i in range(active_tasks.size()):
		var task: Dictionary = active_tasks[i]
		if bool(task.get("completed", false)) or bool(task.get("failed", false)):
			continue
		if _matches_task(task, event_name, detail):
			_complete_task_at(i)

func complete_task(task_id: String) -> void:
	for i in range(active_tasks.size()):
		if str(active_tasks[i].get("id", "")) == task_id:
			_complete_task_at(i)
			return

func finish_shift():
	for i in range(active_tasks.size()):
		var task: Dictionary = active_tasks[i]
		if not bool(task.get("completed", false)) and not bool(task.get("failed", false)):
			task["failed"] = true
			active_tasks[i] = task
			failed_tasks[str(task.get("id", ""))] = true
			recap_entries.append(str(task.get("title", task.get("id", ""))) + ": missed")
	_log("daily_tasks_finalized", float(completed_tasks.size()), "Daily tasks complete=" + str(completed_tasks.size()) + " failed=" + str(failed_tasks.size()))
	daily_task_updated.emit(get_task_status())

func get_task_status() -> Array:
	return active_tasks.duplicate(true)

func get_recap_entries() -> Array[String]:
	return recap_entries.duplicate()

func get_reward_totals() -> Dictionary:
	return rewards_earned.duplicate(true)

func _complete_task_at(index: int):
	var task: Dictionary = active_tasks[index]
	var task_id = str(task.get("id", ""))
	if completed_tasks.has(task_id):
		return
	task["completed"] = true
	active_tasks[index] = task
	completed_tasks[task_id] = true
	_apply_rewards(task.get("reward", {}))
	recap_entries.append(str(task.get("title", task_id)) + ": completed")
	_log("daily_task_completed", 1.0, task_id)
	daily_task_completed.emit(task_id)
	daily_task_updated.emit(get_task_status())

func _apply_rewards(reward: Dictionary):
	var wallet = get_tree().root.get_node_or_null("WalletManager")
	var career = get_tree().root.get_node_or_null("CareerManager")
	var staff = get_tree().root.find_child("StaffDirector", true, false)
	var cash = int(reward.get("cash", 0))
	var tips = int(reward.get("tips", 0))
	var xp = int(reward.get("xp", 0))
	if wallet and wallet.has_method("add_money") and cash + tips > 0:
		wallet.add_money(float(cash + tips))
	if career and career.has_method("add_xp") and xp > 0:
		career.add_xp(float(xp))
	if career:
		career.promotion_progress = clamp(int(career.promotion_progress) + int(reward.get("promotion_progress", 0)), 0, 100)
	if staff:
		staff.staff_morale = clamp(int(staff.staff_morale) + int(reward.get("morale", 0)), 0, 100)
		if staff.has_method("_emit_status"):
			staff._emit_status("daily_task_reward")
	var reputation = get_tree().root.find_child("PlayerReputationManager", true, false)
	if reputation and reputation.has_method("add_label") and int(reward.get("reputation", 0)) > 0:
		reputation.add_label("reliable_shift_worker")
	for key in rewards_earned:
		rewards_earned[key] = int(rewards_earned.get(key, 0)) + int(reward.get(key, 0))

func _matches_task(task: Dictionary, event_name: String, detail: String) -> bool:
	var trigger = str(task.get("trigger", ""))
	if ":" in trigger:
		var parts = trigger.split(":", false, 1)
		return event_name == parts[0] and detail == parts[1]
	return event_name == trigger

func _task_for_category(category: String, offset: int = 0) -> Dictionary:
	var matches: Array = []
	for task in fallback_tasks:
		if str(task.get("category", "")) == category:
			matches.append(task)
	if not matches.is_empty():
		return matches[abs(offset) % matches.size()]
	return {}

func _with_runtime_state(task: Dictionary) -> Dictionary:
	var copy = task.duplicate(true)
	copy["completed"] = false
	copy["failed"] = false
	return copy

func _log(event_name: String, value: float, detail: String):
	var event_log = get_tree().root.get_node_or_null("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event(event_name, value, detail)

func _load_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("Missing data file: " + path)
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Invalid JSON dictionary: " + path)
		return {}
	return parsed
