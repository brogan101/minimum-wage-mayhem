extends Node
class_name PrankWarManager

signal prank_war_escalated(chain: Dictionary)
signal prank_war_deescalated(reason: String)

var chains: Array = []
var active_chain: Dictionary = {}
var chain_history: Array[Dictionary] = []
var heat: int = 0
var cooldown_turns: int = 0

func _ready() -> void:
	chains = _load_json_array("res://data/mischief/prank_war_chains.json", "chains")

func configure_shift() -> void:
	cooldown_turns = max(0, cooldown_turns - 1)
	if heat > 0:
		heat -= 1

func consider_escalation(prank_result: Dictionary, context: Dictionary = {}) -> Dictionary:
	heat = clamp(max(heat, int(context.get("heat", heat))) + int(prank_result.get("prank_war_heat_delta", 0)), 0, 8)
	if cooldown_turns > 0 and not bool(context.get("force", false)):
		_log("prank_war_blocked", float(heat), "cooldown")
		return {}
	if heat < 3 and not bool(context.get("force", false)):
		_log("prank_war_blocked", float(heat), "low_heat")
		return {}
	return start_chain("", context)

func start_chain(chain_id: String = "", context: Dictionary = {}) -> Dictionary:
	var chain = _find_chain(chain_id)
	if chain.is_empty() and not chains.is_empty():
		chain = chains[min(chain_history.size(), chains.size() - 1)]
	if chain.is_empty():
		return {}
	active_chain = chain.duplicate(true)
	active_chain["current_step"] = 0
	active_chain["optional"] = true
	chain_history.append(active_chain)
	cooldown_turns = 2
	_log("prank_war_escalated", float(heat), str(active_chain.get("id", "")))
	prank_war_escalated.emit(active_chain)
	return active_chain

func deescalate(reason: String = "player_cooled_it_down") -> Dictionary:
	heat = max(0, heat - 2)
	active_chain.clear()
	_log("prank_war_deescalated", float(heat), reason)
	prank_war_deescalated.emit(reason)
	return get_summary()

func get_summary() -> Dictionary:
	return {
		"heat": heat,
		"cooldown_turns": cooldown_turns,
		"active_chain": active_chain.duplicate(true),
		"chain_history": chain_history.duplicate(true)
	}

func _find_chain(chain_id: String) -> Dictionary:
	for chain in chains:
		if str(chain.get("id", "")) == chain_id:
			return chain
	return {}

func _load_json_array(path: String, key: String) -> Array:
	if not FileAccess.file_exists(path):
		push_warning("Missing data file: " + path)
		return []
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Invalid JSON dictionary: " + path)
		return []
	return parsed.get(key, [])

func _log(event_name: String, value: float, detail: String):
	var event_log = get_tree().root.get_node_or_null("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event(event_name, value, detail)
