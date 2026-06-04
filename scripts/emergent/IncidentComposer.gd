extends Node
class_name IncidentComposer

var components: Dictionary = {}
var forced_keys := {
    "actors": "force_actor_id",
    "problems": "force_problem_id",
    "locations": "force_location_id",
    "objects": "force_object_id",
    "witnesses": "force_witness_id",
    "cover_stories": "force_cover_story_id",
    "immediate_consequences": "force_immediate_consequence_id",
    "delayed_consequences": "force_delayed_consequence_id"
}

func _ready() -> void:
    components = _load_json_dict("res://data/emergent/event_components.json")

func compose_event(context: Dictionary = {}) -> Dictionary:
    var event := {
        "actor": _pick("actors", context),
        "problem": _pick("problems", context),
        "location": _pick("locations", context),
        "object": _pick("objects", context),
        "witness": _pick("witnesses", context),
        "cover_story": _pick("cover_stories", context),
        "immediate_consequence": _pick("immediate_consequences", context),
        "delayed_consequence": _pick("delayed_consequences", context),
        "seed_context": context
    }
    event["event_id"] = _make_event_id(event)
    event["tags"] = _collect_tags(event)
    return event

func _pick(key: String, context: Dictionary) -> Dictionary:
    var pool: Array = components.get(key, [])
    if pool.is_empty():
        return {}
    var forced_key = str(forced_keys.get(key, ""))
    if context.has(forced_key):
        for entry in pool:
            if str(entry.get("id", "")) == str(context.get(forced_key, "")):
                return entry
    pool.shuffle()
    return pool[0]

func _make_event_id(event: Dictionary) -> String:
    return "%s_%s_%s" % [
        str(event.get("actor", {}).get("id", "actor")),
        str(event.get("problem", {}).get("id", "problem")),
        str(event.get("object", {}).get("id", "object"))
    ]

func _collect_tags(event: Dictionary) -> Array:
    var tags: Array = []
    for part_key in event.keys():
        var part = event[part_key]
        if typeof(part) == TYPE_DICTIONARY:
            for tag in part.get("tags", []):
                if not tag in tags:
                    tags.append(tag)
    return tags

func _load_json_dict(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: " + path)
        return {}
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
