extends Node
class_name ViralClipManager

signal viral_clip_generated(clip: Dictionary)

var clips: Array = []

func _ready() -> void:
    clips = _load_json_array("res://data/reviews/viral_clip_events.json", "events")

func maybe_generate_clip(context: Dictionary) -> Dictionary:
    if not bool(context.get("viral_possible", false)):
        return {}
    if clips.is_empty():
        return {}
    var clip: Dictionary = clips.pick_random()
    emit_signal("viral_clip_generated", clip)
    return clip

func _load_json_array(path: String, key: String) -> Array:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: " + path)
        return []
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(parsed) != TYPE_DICTIONARY:
        push_warning("Invalid JSON dictionary: " + path)
        return []
    return parsed.get(key, [])
