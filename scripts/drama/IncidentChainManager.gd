extends Node
class_name IncidentChainManager

signal chain_started(chain: Dictionary)
signal chain_step_advanced(chain_id: String, step: String)
signal chain_completed(chain_id: String, outcome: Dictionary)

var chains: Array = []
var active_chains: Dictionary = {}

func _ready() -> void:
    chains = _load_json_array("res://data/incidents/incident_chains.json", "chains")

func start_chain(chain_id: String) -> Dictionary:
    for chain in chains:
        if str(chain.get("id", "")) == chain_id:
            active_chains[chain_id] = {"index": 0, "chain": chain}
            emit_signal("chain_started", chain)
            return chain
    return {}

func advance_chain(chain_id: String) -> void:
    if not active_chains.has(chain_id):
        return
    var state: Dictionary = active_chains[chain_id]
    var chain: Dictionary = state["chain"]
    var stages: Array = chain.get("stages", [])
    var idx: int = int(state.get("index", 0))
    if idx < stages.size():
        emit_signal("chain_step_advanced", chain_id, str(stages[idx]))
        state["index"] = idx + 1
        active_chains[chain_id] = state
    else:
        emit_signal("chain_completed", chain_id, {"outcomes": chain.get("outcomes", [])})
        active_chains.erase(chain_id)

func _load_json_array(path: String, key: String) -> Array:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: " + path)
        return []
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(parsed) != TYPE_DICTIONARY:
        push_warning("Invalid JSON dictionary: " + path)
        return []
    return parsed.get(key, [])
