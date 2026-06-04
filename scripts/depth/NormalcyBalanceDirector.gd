extends Node
class_name NormalcyBalanceDirector

signal balance_bucket_selected(bucket: String)
signal chaos_blocked(reason: String)

var layers: Array = []
var default_weights := {"normal_orders": 50, "service_friction": 25, "funny_weird": 15, "wild_spike": 10}
var wild_cooldown: int = 0
var balance_history: Array[String] = []

func _ready() -> void:
    layers = _load_json_array("res://data/depth/shift_texture_layers.json", "layers")

func pick_layer(context: Dictionary = {}) -> String:
    if wild_cooldown > 0:
        wild_cooldown -= 1
    var roll := randi_range(1, 100)
    var cumulative := 0
    for layer in layers:
        var id := str(layer.get("id", "normal_orders"))
        var weight := int(layer.get("weight", default_weights.get(id, 10)))
        cumulative += weight
        if roll <= cumulative:
            if id == "wild_spike" and (wild_cooldown > 0 or bool(context.get("tutorial_shift", false)) or bool(context.get("recovery_window", false))):
                emit_signal("chaos_blocked", "wild_blocked_by_budget")
                emit_signal("balance_bucket_selected", "normal_orders")
                return "normal_orders"
            if id == "wild_spike":
                wild_cooldown = 2
            balance_history.append(id)
            emit_signal("balance_bucket_selected", id)
            return id
    balance_history.append("normal_orders")
    emit_signal("balance_bucket_selected", "normal_orders")
    return "normal_orders"

func build_balanced_sequence(context: Dictionary = {}) -> Array[String]:
    var sequence: Array[String] = []
    for i in range(6):
        sequence.append("normal_orders")
    for i in range(3):
        sequence.append("service_friction")
    for i in range(2):
        sequence.append("funny_weird")
    if not bool(context.get("tutorial_shift", false)) and not bool(context.get("recovery_window", false)):
        sequence.append("wild_spike")
    else:
        sequence.append("normal_orders")
    for bucket in sequence:
        balance_history.append(bucket)
        emit_signal("balance_bucket_selected", bucket)
    return sequence

func get_balance_ratio(sequence: Array[String]) -> Dictionary:
    var total = max(1, sequence.size())
    var counts := {"normal_orders": 0, "service_friction": 0, "funny_weird": 0, "wild_spike": 0}
    for bucket in sequence:
        counts[str(bucket)] = int(counts.get(str(bucket), 0)) + 1
    return {
        "normal_orders": float(counts["normal_orders"]) / float(total),
        "service_friction": float(counts["service_friction"]) / float(total),
        "funny_weird": float(counts["funny_weird"]) / float(total),
        "wild_spike": float(counts["wild_spike"]) / float(total)
    }

func within_target(sequence: Array[String]) -> bool:
    var ratio = get_balance_ratio(sequence)
    return ratio["normal_orders"] >= 0.45 and ratio["normal_orders"] <= 0.60 and ratio["service_friction"] >= 0.20 and ratio["service_friction"] <= 0.30 and ratio["funny_weird"] >= 0.10 and ratio["funny_weird"] <= 0.20 and ratio["wild_spike"] >= 0.05 and ratio["wild_spike"] <= 0.10

func _load_json_array(path: String, key: String) -> Array:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: " + path)
        return []
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(parsed) != TYPE_DICTIONARY:
        push_warning("Invalid JSON dictionary: " + path)
        return []
    return parsed.get(key, [])
