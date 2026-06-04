extends Node
## ==============================================================================
## CLASS: OrderManager
## PURPOSE: The central authority for order state, validation, and fulfillment.
## DEPENDENCIES: OrderGenerator (for creation), WalletManager (for payouts).
## LOGIC FLOW: 
##   1. Customer arrives -> OrderGenerator creates a complex order.
##   2. OrderManager stores order -> HUD displays it.
##   3. Player delivers bag -> OrderManager validates components.
##   4. Success/Failure -> Triggers WalletManager and BeefManager.
## ==============================================================================

signal order_changed(new_order)
signal order_fulfilled(success: bool, reward: int)

var current_order = {} 
var total_earned: int = 0
var orders_completed: int = 0
var orders_attempted: int = 0
var orders_failed: int = 0
var total_wait_seconds: float = 0.0
var total_patience_score: float = 0.0

func _ready():
	current_order = {}
	total_earned = 0
	orders_completed = 0
	orders_attempted = 0
	orders_failed = 0
	total_wait_seconds = 0.0
	total_patience_score = 0.0

func set_current_order(order_data):
	current_order = order_data
	order_changed.emit(current_order)
	_play_audio_hook("order_received")

func generate_new_order():
	var simple_order = {"items": [{"item": "Burger", "modifiers": []}], "customer_type": "Standard"}
	set_current_order(simple_order)

func validate_bag(bag_contents: Array[String]) -> bool:
	if current_order.is_empty(): return false
	var required_items = []
	for item_obj in current_order["items"]:
		required_items.append(item_obj["item"])
	for item in required_items:
		if not bag_contents.has(item):
			return false
	return true

func fulfill_order(success: bool):
	orders_attempted += 1
	total_wait_seconds += 28.0 if success else 46.0
	total_patience_score += 0.85 if success else 0.35
	if success:
		var reward = 10 * current_order["items"].size()
		total_earned += reward
		orders_completed += 1
		var daily = get_tree().root.find_child("DailyTaskManager", true, false)
		if daily and daily.has_method("record_progress"):
			daily.record_progress("customer_served", "order_fulfilled")
		order_fulfilled.emit(true, reward)
		_play_audio_hook("correct_handoff")
	else:
		orders_failed += 1
		order_fulfilled.emit(false, 0)
		_play_audio_hook("wrong_handoff")
	current_order = {}

func get_order_accuracy() -> float:
	if orders_attempted <= 0:
		return 1.0
	return float(orders_completed) / float(orders_attempted)

func get_average_wait() -> float:
	if orders_attempted <= 0:
		return 0.0
	return total_wait_seconds / float(orders_attempted)

func get_average_patience() -> float:
	if orders_attempted <= 0:
		return 1.0
	return total_patience_score / float(orders_attempted)

func get_current_order_summary() -> String:
	if current_order.is_empty() or not current_order.has("items"):
		return "No active order"
	var parts: Array[String] = []
	for item_obj in current_order["items"]:
		parts.append(str(item_obj.get("item", "Item")))
	return ", ".join(parts)

func _play_audio_hook(hook_name: String):
	var audio = get_tree().root.get_node_or_null("AudioManager")
	if audio and audio.has_method("play_sfx"):
		audio.play_sfx(hook_name)
