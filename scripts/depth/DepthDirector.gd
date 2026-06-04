extends Node
class_name DepthDirector

signal depth_bundle_selected(bundle: Dictionary)
signal depth_bundle_skipped(bundle_id: String, reason: String)

var bundles: Array = []
var active_bundles: Array = []
var loaded_depth_catalogs := {}
var balanced_sequence: Array[String] = []
var linked_entries: Array[Dictionary] = []
var generated_depth_events: Array[Dictionary] = []
var recovery_routes: Array = []
var promotion_detours: Array = []
var store_mutations: Array = []
var runtime_validation := {}

func _ready() -> void:
    bundles = _load_json_array("res://data/depth/depth_bundles.json", "bundles")
    _load_depth_catalogs()

func select_bundles(context: Dictionary = {}, max_count: int = 3) -> Array:
    var selected: Array = []
    var shuffled := bundles.duplicate()
    shuffled.shuffle()
    for bundle in shuffled:
        if selected.size() >= max_count:
            break
        if _bundle_allowed(bundle, context):
            selected.append(bundle)
            emit_signal("depth_bundle_selected", bundle)
    active_bundles = selected
    return selected

func generate_shift_depth(context: Dictionary = {}) -> Dictionary:
    var normalcy = get_tree().root.find_child("NormalcyBalanceDirector", true, false)
    var linker = get_tree().root.find_child("DepthEventLinker", true, false)
    var texture = get_tree().root.find_child("WorldTextureManager", true, false)
    var flavor_manager = get_tree().root.find_child("ShiftFlavorManager", true, false)
    var density = get_tree().root.find_child("ContentDensityValidatorRuntime", true, false)
    var memory = get_tree().root.find_child("RestaurantMemoryManager", true, false)
    balanced_sequence = normalcy.build_balanced_sequence(context) if normalcy and normalcy.has_method("build_balanced_sequence") else ["normal_orders", "service_friction", "funny_weird", "wild_spike"]
    active_bundles = select_bundles(context, 5)
    linked_entries.clear()
    generated_depth_events.clear()
    for bundle in active_bundles:
        var linked = linker.link_depth_entry(bundle, {"source": "depth_bundle", "systems": bundle.get("systems_connected", [])}) if linker and linker.has_method("link_depth_entry") else bundle
        linked_entries.append(linked)
        generated_depth_events.append(_depth_event_from_bundle(bundle, linked))
    var quiet_event = texture.generate_quiet_event() if texture and texture.has_method("generate_quiet_event") else {}
    var rumor = texture.generate_rumor() if texture and texture.has_method("generate_rumor") else {}
    var flavor = flavor_manager.build_shift_flavor(context) if flavor_manager and flavor_manager.has_method("build_shift_flavor") else {}
    recovery_routes = loaded_depth_catalogs.get("res://data/depth/recovery_routes.json", {}).get("routes", [])
    promotion_detours = loaded_depth_catalogs.get("res://data/depth/promotion_detours.json", {}).get("detours", [])
    store_mutations = loaded_depth_catalogs.get("res://data/depth/store_identity_mutations.json", {}).get("mutations", [])
    _apply_depth_to_gameplay(flavor, quiet_event, rumor)
    if memory and memory.has_method("record_event"):
        memory.record_event({"event_id": "phase13_depth_shift", "tags": ["depth", "normal_play", "balance"], "resolved": false}, "career")
    var counts = {
        "depth_bundles": active_bundles.size(),
        "linked_entries": linked_entries.size(),
        "quiet_events": 1 if not quiet_event.is_empty() else 0,
        "rumors": 1 if not rumor.is_empty() else 0,
        "generated_events": generated_depth_events.size()
    }
    runtime_validation = {"ok": density.check_runtime_counts(counts) if density and density.has_method("check_runtime_counts") else true, "counts": counts}
    _log("phase13_depth_generated", float(active_bundles.size()), "balance=" + str(get_balance_summary().get("ratio", {})))
    return get_depth_summary()

func get_depth_summary() -> Dictionary:
    var normalcy = get_tree().root.find_child("NormalcyBalanceDirector", true, false)
    var texture = get_tree().root.find_child("WorldTextureManager", true, false)
    var flavor = get_tree().root.find_child("ShiftFlavorManager", true, false)
    var density = get_tree().root.find_child("ContentDensityValidatorRuntime", true, false)
    return {
        "active_bundles": active_bundles.duplicate(true),
        "balanced_sequence": balanced_sequence.duplicate(),
        "balance": get_balance_summary(),
        "linked_entries": linked_entries.duplicate(true),
        "generated_depth_events": generated_depth_events.duplicate(true),
        "recovery_routes": recovery_routes.duplicate(true),
        "promotion_detours": promotion_detours.duplicate(true),
        "store_mutations": store_mutations.duplicate(true),
        "loaded_depth_catalogs": loaded_depth_catalogs.keys(),
        "world_texture": texture.get_summary() if texture and texture.has_method("get_summary") else {},
        "shift_flavor": flavor.get_summary() if flavor and flavor.has_method("get_summary") else {},
        "density": density.get_summary() if density and density.has_method("get_summary") else {},
        "runtime_validation": runtime_validation.duplicate(true)
    }

func get_balance_summary() -> Dictionary:
    var normalcy = get_tree().root.find_child("NormalcyBalanceDirector", true, false)
    var ratio = normalcy.get_balance_ratio(balanced_sequence) if normalcy and normalcy.has_method("get_balance_ratio") else {}
    var within_target = normalcy.within_target(balanced_sequence) if normalcy and normalcy.has_method("within_target") else false
    return {"ratio": ratio, "within_target": within_target}

func _bundle_allowed(bundle: Dictionary, context: Dictionary) -> bool:
    if bool(context.get("tutorial_shift", false)) and str(bundle.get("tone", "")) == "wild":
        emit_signal("depth_bundle_skipped", str(bundle.get("id", "")), "tutorial_blocks_wild")
        return false
    if str(bundle.get("tone", "")) == "wild" and bool(context.get("recovery_window", false)):
        emit_signal("depth_bundle_skipped", str(bundle.get("id", "")), "recovery_window")
        return false
    return true

func _depth_event_from_bundle(bundle: Dictionary, linked: Dictionary) -> Dictionary:
    return {
        "event_id": "depth_" + str(bundle.get("id", "bundle")),
        "bundle_id": bundle.get("id", ""),
        "tone": bundle.get("tone", "normal"),
        "systems": bundle.get("systems_connected", []),
        "fallback": bundle.get("fallback", ""),
        "linked": linked
    }

func _apply_depth_to_gameplay(flavor: Dictionary, quiet_event: Dictionary, rumor: Dictionary):
    var staff = get_tree().root.find_child("StaffDirector", true, false)
    var store_ops = get_tree().root.find_child("StoreOpsDirector", true, false)
    var career = get_tree().root.get_node_or_null("CareerManager")
    if staff:
        staff.staff_morale = clamp(int(staff.staff_morale) + 1, 0, 100)
        if staff.has_method("_emit_status"):
            staff._emit_status("phase13_depth")
    if store_ops:
        store_ops.review_risk = clamp(int(store_ops.review_risk) - (1 if not quiet_event.is_empty() else 0) + (1 if not rumor.is_empty() else 0), 0, 100)
        store_ops.manager_trust = clamp(int(store_ops.manager_trust) + 1, 0, 100)
        if store_ops.has_method("_recalculate_modifiers"):
            store_ops._recalculate_modifiers()
        if store_ops.has_method("_emit_status"):
            store_ops._emit_status("phase13_depth")
    if career:
        career.promotion_progress = clamp(int(career.promotion_progress) + 1, 0, 100)

func _load_depth_catalogs():
    for path in [
        "res://data/depth/depth_bundles.json",
        "res://data/depth/shift_texture_layers.json",
        "res://data/depth/customer_memory_arcs.json",
        "res://data/depth/customer_normalcy_profiles.json",
        "res://data/depth/coworker_social_web.json",
        "res://data/depth/manager_pressure_situations.json",
        "res://data/depth/home_life_depth_events.json",
        "res://data/depth/commute_micro_events.json",
        "res://data/depth/store_ops_depth.json",
        "res://data/depth/equipment_personality.json",
        "res://data/depth/minigames.json",
        "res://data/depth/story_arc_expansion.json",
        "res://data/depth/world_rumors.json",
        "res://data/depth/quiet_normal_events.json",
        "res://data/depth/escalation_ladders.json",
        "res://data/depth/customer_customer_interactions.json",
        "res://data/depth/recovery_routes.json",
        "res://data/depth/promotion_detours.json",
        "res://data/depth/store_identity_mutations.json",
        "res://data/depth/audio_visual_asset_requirements.json",
        "res://data/depth/performance_budgets.json",
        "res://data/depth/bug_fallback_requirements.json",
        "res://data/depth/research_inspired_patterns.json",
        "res://data/depth/phase_13_acceptance_matrix.json"
    ]:
        loaded_depth_catalogs[path] = _load_json_dict(path)

func _load_json_array(path: String, key: String) -> Array:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: " + path)
        return []
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(parsed) != TYPE_DICTIONARY:
        push_warning("Invalid JSON dictionary: " + path)
        return []
    return parsed.get(key, [])

func _load_json_dict(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: " + path)
        return {}
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _log(event_name: String, value: float, detail: String):
    var event_log = get_tree().root.get_node_or_null("EventLog")
    if event_log and event_log.has_method("log_event"):
        event_log.log_event(event_name, value, detail)
