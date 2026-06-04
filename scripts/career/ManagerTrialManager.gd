extends Node
class_name ManagerTrialManager

signal manager_trial_started(trial: Dictionary)
signal manager_trial_completed(result: Dictionary)

var trial_data: Dictionary = {}

func _ready() -> void:
    trial_data = _load_json_dict("res://data/missions/manager_trial_shift.json")

func start_trial() -> Dictionary:
    emit_signal("manager_trial_started", trial_data)
    return trial_data

func complete_trial(passed: bool, context: Dictionary = {}) -> Dictionary:
    var result := {
        "passed": passed,
        "rewards": trial_data.get("rewards", []) if passed else trial_data.get("failure_rewards", []),
        "context": context
    }
    emit_signal("manager_trial_completed", result)
    return result

func _load_json_dict(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
