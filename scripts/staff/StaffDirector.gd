extends Node
class_name StaffDirector

signal staff_status_changed(status: Dictionary)

var staff_morale: int = 70
var manager_trust: int = 55
var corporate_approval: int = 50
var review_risk: int = 0

var coworkers := {}
var station_coverage := {
	"grill": "covered",
	"register": "covered",
	"drive_thru": "covered",
	"bagging": "thin"
}
var shift_modifiers := {
	"speed": 1.0,
	"accuracy": 1.0,
	"customer_patience": 1.0,
	"cleanliness": 1.0
}

func _ready():
	setup_default_roster()
	_emit_status("staff_ready")

func setup_default_roster():
	coworkers = {
		"riley": {
			"display_name": "Riley",
			"station": "grill",
			"style": "helpful",
			"loyalty": 65,
			"annoyance": 15,
			"trust": 70,
			"rivalry": 0,
			"willingness_to_help": 80,
			"present": true
		},
		"casey": {
			"display_name": "Casey",
			"station": "register",
			"style": "lazy",
			"loyalty": 35,
			"annoyance": 45,
			"trust": 40,
			"rivalry": 10,
			"willingness_to_help": 35,
			"present": true
		},
		"morgan": {
			"display_name": "Morgan",
			"station": "drive_thru",
			"style": "weird_helpful",
			"loyalty": 55,
			"annoyance": 20,
			"trust": 60,
			"rivalry": 5,
			"willingness_to_help": 65,
			"present": true
		}
	}
	_recalculate_coverage()

func request_help(coworker_id: String, station: String = "") -> Dictionary:
	if not coworkers.has(coworker_id):
		return {}
	var coworker: Dictionary = coworkers[coworker_id]
	var target_station = station if station != "" else str(coworker.get("station", "bagging"))
	var helped = coworker.get("present", true) and int(coworker.get("willingness_to_help", 0)) >= 50
	if helped:
		coworker["trust"] = clamp(int(coworker.get("trust", 0)) + 5, 0, 100)
		coworker["loyalty"] = clamp(int(coworker.get("loyalty", 0)) + 3, 0, 100)
		staff_morale = clamp(staff_morale + 3, 0, 100)
		manager_trust = clamp(manager_trust + 2, 0, 100)
		station_coverage[target_station] = "helped"
		_log("coworker_helped", 1.0, coworker.get("display_name", coworker_id) + " helped at " + target_station)
	else:
		coworker["annoyance"] = clamp(int(coworker.get("annoyance", 0)) + 5, 0, 100)
		staff_morale = clamp(staff_morale - 2, 0, 100)
		review_risk = clamp(review_risk + 2, 0, 100)
		station_coverage[target_station] = "delayed"
		_log("coworker_refused_help", 1.0, coworker.get("display_name", coworker_id) + " delayed " + target_station)
	coworkers[coworker_id] = coworker
	_recalculate_modifiers()
	_emit_status("coworker_help")
	return coworker

func record_mistake(coworker_id: String, station: String, severity: int = 1) -> Dictionary:
	if not coworkers.has(coworker_id):
		return {}
	var coworker: Dictionary = coworkers[coworker_id]
	coworker["annoyance"] = clamp(int(coworker.get("annoyance", 0)) + (severity * 4), 0, 100)
	coworker["trust"] = clamp(int(coworker.get("trust", 0)) - (severity * 3), 0, 100)
	staff_morale = clamp(staff_morale - severity, 0, 100)
	manager_trust = clamp(manager_trust - severity, 0, 100)
	review_risk = clamp(review_risk + (severity * 3), 0, 100)
	station_coverage[station] = "mistake"
	coworkers[coworker_id] = coworker
	_recalculate_modifiers()
	_log("coworker_mistake", float(severity), coworker.get("display_name", coworker_id) + " caused a delay at " + station)
	_emit_status("coworker_mistake")
	return coworker

func swap_station(coworker_id: String, new_station: String) -> Dictionary:
	if not coworkers.has(coworker_id):
		return {}
	var coworker: Dictionary = coworkers[coworker_id]
	var old_station = str(coworker.get("station", ""))
	coworker["station"] = new_station
	coworker["trust"] = clamp(int(coworker.get("trust", 0)) + 2, 0, 100)
	coworkers[coworker_id] = coworker
	_recalculate_coverage()
	_log("coworker_station_swap", 1.0, coworker.get("display_name", coworker_id) + ": " + old_station + " -> " + new_station)
	_emit_status("station_swap")
	return coworker

func apply_callout(coworker_id: String, excuse_id: String = "callout_manual") -> Dictionary:
	if not coworkers.has(coworker_id):
		return {}
	var coworker: Dictionary = coworkers[coworker_id]
	coworker["present"] = false
	var station = str(coworker.get("station", "register"))
	station_coverage[station] = "uncovered"
	staff_morale = clamp(staff_morale - 5, 0, 100)
	manager_trust = clamp(manager_trust - 3, 0, 100)
	review_risk = clamp(review_risk + 5, 0, 100)
	coworkers[coworker_id] = coworker
	_recalculate_modifiers()
	_log("coworker_callout", 1.0, coworker.get("display_name", coworker_id) + " called out: " + excuse_id)
	_emit_status("callout")
	return coworker

func generate_callout(coworker_id: String) -> Dictionary:
	var excuse = _pick_callout_excuse()
	apply_callout(coworker_id, str(excuse.get("id", "callout_manual")))
	excuse["employee_id"] = coworker_id
	_log("manager_callout_handled", float(excuse.get("believability", 0)), str(excuse.get("text", "Called out.")))
	return excuse

func dialogue_for(coworker_id: String, event_name: String) -> String:
	if not coworkers.has(coworker_id):
		return "Someone mutters from the break room."
	var coworker: Dictionary = coworkers[coworker_id]
	var style = str(coworker.get("style", "normal"))
	var line = ""
	match style:
		"helpful":
			line = "I can cover " + str(coworker.get("station", "a station")) + " for a minute."
		"lazy":
			line = "I am helping emotionally, which is almost labor."
		"weird_helpful":
			line = "The headset spirits say the window needs backup."
		_:
			line = "I'm here. Mostly."
	_log("coworker_dialogue", 1.0, coworker.get("display_name", coworker_id) + " on " + event_name + ": " + line)
	var daily = get_tree().root.find_child("DailyTaskManager", true, false)
	if daily and daily.has_method("record_progress"):
		daily.record_progress("coworker_dialogue", event_name)
	return line

func get_shift_effects() -> Dictionary:
	return {
		"speed": shift_modifiers["speed"],
		"accuracy": shift_modifiers["accuracy"],
		"customer_patience": shift_modifiers["customer_patience"],
		"cleanliness": shift_modifiers["cleanliness"],
		"review_risk": review_risk,
		"manager_trust": manager_trust,
		"corporate_approval": corporate_approval,
		"staff_morale": staff_morale,
		"station_coverage": station_coverage.duplicate(true)
	}

func _recalculate_coverage():
	station_coverage = {
		"grill": "uncovered",
		"register": "uncovered",
		"drive_thru": "uncovered",
		"bagging": "thin"
	}
	for coworker_id in coworkers:
		var coworker: Dictionary = coworkers[coworker_id]
		if coworker.get("present", true):
			station_coverage[str(coworker.get("station", "bagging"))] = "covered"
	_recalculate_modifiers()

func _recalculate_modifiers():
	var uncovered = 0
	var delayed = 0
	for station in station_coverage:
		var state = str(station_coverage[station])
		if state == "uncovered":
			uncovered += 1
		elif state == "delayed" or state == "mistake":
			delayed += 1
	shift_modifiers["speed"] = max(0.55, 1.0 - (uncovered * 0.12) - (delayed * 0.06))
	shift_modifiers["accuracy"] = max(0.6, 1.0 - (uncovered * 0.08) - (delayed * 0.08))
	shift_modifiers["customer_patience"] = max(0.55, 1.0 - (uncovered * 0.1) - (delayed * 0.05))
	shift_modifiers["cleanliness"] = max(0.6, 1.0 - (uncovered * 0.05) - (delayed * 0.04))
	_adjust_corporate(-uncovered - delayed)

func _adjust_corporate(delta: int):
	corporate_approval = clamp(corporate_approval + delta, 0, 100)
	var corporate = get_tree().root.get_node_or_null("CorporateManager")
	if corporate and corporate.has_method("adjust_approval"):
		corporate.adjust_approval(delta)

func _emit_status(reason: String):
	var status = get_shift_effects()
	status["reason"] = reason
	staff_status_changed.emit(status)

func _log(event_name: String, value: float, detail: String):
	var event_log = get_tree().root.get_node_or_null("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event(event_name, value, detail)

func _pick_callout_excuse() -> Dictionary:
	var path = "res://data/staff/callout_excuses.json"
	if not FileAccess.file_exists(path):
		return {"id": "callout_manual", "text": "I can only come in emotionally.", "believability": 40}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"id": "callout_manual", "text": "The schedule and I have creative differences.", "believability": 35}
	var excuses: Array = parsed.get("excuses", [])
	if excuses.is_empty():
		return {"id": "callout_manual", "text": "My apron has vanished spiritually.", "believability": 30}
	return excuses[0]
