extends Node
class_name SaveSystem

## Local persistence layer. Saves the game to a local JSON file only.

const SAVE_PATH = "user://savegame.json"

var last_save_data: Dictionary = {}

func save_game(extra_data: Dictionary = {}) -> bool:
	var wallet = _autoload("WalletManager")
	var career = _autoload("CareerManager")
	var stat_manager = _autoload("StatManager")
	var corporate = _autoload("CorporateManager")
	var event_log = _autoload("EventLog")
	var restaurant_memory = _runtime("RestaurantMemoryManager")
	var object_memory = _runtime("StoreObjectMemoryManager")
	var dynamic_reputation = _runtime("DynamicReputationLabelManager")
	var save_data = {
		"schema_version": 4,
		"wallet": wallet.balance if wallet else 0.0,
		"career": career.get_career_save_data() if career and career.has_method("get_career_save_data") else {
			"rank": career.current_rank if career else 0,
			"xp": career.current_xp if career else 0.0,
			"xp_to_next_rank": career.xp_to_next_rank if career else 100.0
		},
		"stats": stat_manager.stats if stat_manager else {},
		"corporate_approval": corporate.get_approval_rating() if corporate and corporate.has_method("get_approval_rating") else 0,
		"event_log": event_log.get_save_data() if event_log and event_log.has_method("get_save_data") else {},
		"restaurant_memory": restaurant_memory.get_save_data() if restaurant_memory and restaurant_memory.has_method("get_save_data") else {},
		"store_object_memory": object_memory.get_save_data() if object_memory and object_memory.has_method("get_save_data") else {},
		"dynamic_reputation": dynamic_reputation.get_save_data() if dynamic_reputation and dynamic_reputation.has_method("get_save_data") else {},
		"progression": extra_data.get("progression", {}),
		"last_shift": extra_data.get("last_shift", {}),
		"next_shift": extra_data.get("next_shift", {}),
		"saved_at_ticks": Time.get_ticks_msec(),
		"apartment": {
			"furniture": []
		}
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		last_save_data = save_data.duplicate(true)
		print("Game Saved to ", SAVE_PATH)
		return verify_save_roundtrip()
	return false

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found. Starting fresh.")
		return {}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	if json_text.strip_edges().is_empty():
		print("Save file was empty. Starting fresh.")
		return {}
	var parser = JSON.new()
	if parser.parse(json_text) != OK:
		print("Save file was invalid. Starting fresh.")
		return {}
	var save_data = parser.data
	
	if typeof(save_data) == TYPE_DICTIONARY:
		var wallet = _autoload("WalletManager")
		var career = _autoload("CareerManager")
		var stat_manager = _autoload("StatManager")
		var corporate = _autoload("CorporateManager")
		var event_log = _autoload("EventLog")
		var restaurant_memory = _runtime("RestaurantMemoryManager")
		var object_memory = _runtime("StoreObjectMemoryManager")
		var dynamic_reputation = _runtime("DynamicReputationLabelManager")
		if wallet:
			wallet.balance = save_data.get("wallet", 0.0)
		if career:
			var career_data = save_data.get("career", {})
			if career.has_method("load_career_save_data"):
				career.load_career_save_data(career_data)
			else:
				career.current_rank = career_data.get("rank", 0)
				career.current_xp = career_data.get("xp", 0.0)
				career.xp_to_next_rank = career_data.get("xp_to_next_rank", career.xp_to_next_rank)
		if stat_manager:
			stat_manager.stats = save_data.get("stats", stat_manager.stats)
		if corporate:
			corporate.approval_rating = int(save_data.get("corporate_approval", corporate.approval_rating))
		if event_log and event_log.has_method("load_save_data"):
			event_log.load_save_data(save_data.get("event_log", {}))
		if restaurant_memory and restaurant_memory.has_method("load_save_data"):
			restaurant_memory.load_save_data(save_data.get("restaurant_memory", {}))
		if object_memory and object_memory.has_method("load_save_data"):
			object_memory.load_save_data(save_data.get("store_object_memory", {}))
		if dynamic_reputation and dynamic_reputation.has_method("load_save_data"):
			dynamic_reputation.load_save_data(save_data.get("dynamic_reputation", {}))
		last_save_data = save_data.duplicate(true)
		print("Game Loaded Successfully!")
		return save_data
	return {}
	
func verify_save_roundtrip() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var text = file.get_as_text()
	file.close()
	if text.strip_edges().is_empty():
		return false
	var parser = JSON.new()
	if parser.parse(text) != OK:
		return false
	var parsed = parser.data
	return typeof(parsed) == TYPE_DICTIONARY and parsed.has("last_shift") and parsed.has("next_shift")

func get_last_save_data() -> Dictionary:
	if last_save_data.is_empty():
		return load_game()
	return last_save_data.duplicate(true)

func _autoload(name: String) -> Node:
	return get_tree().root.get_node_or_null(name)

func _runtime(name: String) -> Node:
	return get_tree().root.find_child(name, true, false)
