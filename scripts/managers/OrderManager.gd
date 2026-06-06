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

const ORDER_TEMPLATES := [
	{
		"customer_type": "Regular",
		"items": [{"item": "Burger", "modifiers": []}],
		"patience": 0.92,
		"target_time": 35.0,
		"customer_note": "First order: keep it simple and bag the burger."
	},
	{
		"customer_type": "Lunch Driver",
		"items": [{"item": "Burger", "modifiers": []}, {"item": "Fries", "modifiers": []}],
		"patience": 0.82,
		"target_time": 42.0,
		"customer_note": "Normal combo. No chaos, just fries."
	},
	{
		"customer_type": "Thirsty Commuter",
		"items": [{"item": "Burger", "modifiers": []}, {"item": "Soda", "modifiers": []}],
		"patience": 0.78,
		"target_time": 44.0,
		"customer_note": "Wants the drink filled, not spiritually implied."
	}
]

var current_order = {} 
var total_earned: int = 0
var tips_earned: int = 0
var orders_completed: int = 0
var orders_attempted: int = 0
var orders_failed: int = 0
var mistake_count: int = 0
var total_wait_seconds: float = 0.0
var total_patience_score: float = 0.0
var ticket_counter: int = 0
var last_validation: Dictionary = {}
var last_payout: Dictionary = {}

func _ready():
	current_order = {}
	total_earned = 0
	tips_earned = 0
	orders_completed = 0
	orders_attempted = 0
	orders_failed = 0
	mistake_count = 0
	total_wait_seconds = 0.0
	total_patience_score = 0.0
	ticket_counter = 0
	last_validation = {}
	last_payout = {}

func set_current_order(order_data):
	current_order = order_data.duplicate(true)
	if not current_order.has("ticket_id"):
		ticket_counter += 1
		current_order["ticket_id"] = ticket_counter
	if not current_order.has("patience"):
		current_order["patience"] = 0.85
	order_changed.emit(current_order)
	_play_audio_hook("order_received")

func generate_new_order(customer_hint: String = "") -> Dictionary:
	var template = _select_order_template(customer_hint)
	set_current_order(template)
	return current_order.duplicate(true)

func validate_bag(bag_contents: Array[String]) -> bool:
	var detail = validate_bag_detail(bag_contents)
	return bool(detail.get("success", false))

func validate_bag_detail(bag_contents: Array[String]) -> Dictionary:
	var provided: Array[String] = []
	for item in bag_contents:
		var normalized = _normalize_item(str(item))
		if normalized != "":
			provided.append(normalized)
	var required: Array[String] = []
	if not current_order.is_empty() and current_order.has("items"):
		for item_obj in current_order["items"]:
			required.append(_normalize_item(str(item_obj.get("item", "Item"))))
	var missing: Array[String] = []
	for item in required:
		if not provided.has(item):
			missing.append(item)
	var extra: Array[String] = []
	for item in provided:
		if not required.has(item):
			extra.append(item)
	var detail = {
		"success": not current_order.is_empty() and missing.is_empty() and extra.is_empty(),
		"required": required,
		"provided": provided,
		"missing": missing,
		"extra": extra,
		"expected_summary": _items_summary(required),
		"provided_summary": _items_summary(provided)
	}
	if current_order.is_empty():
		detail["issue"] = "No active ticket"
	elif not missing.is_empty():
		detail["issue"] = "Missing " + _items_summary(missing)
	elif not extra.is_empty():
		detail["issue"] = "Extra " + _items_summary(extra)
	else:
		detail["issue"] = "Correct"
	last_validation = detail.duplicate(true)
	return detail

func fulfill_order(success: bool, validation: Dictionary = {}, keep_order_active: bool = false) -> Dictionary:
	orders_attempted += 1
	var active_order = current_order.duplicate(true)
	var item_count = active_order.get("items", []).size() if active_order.has("items") else 1
	var patience = float(active_order.get("patience", 0.85))
	var target_time = float(active_order.get("target_time", 35.0))
	total_wait_seconds += target_time if success else target_time + 18.0
	total_patience_score += patience if success else max(0.15, patience - 0.35)
	var payout := {"cash": 0, "tips": 0, "xp": 0, "summary": ""}
	if success:
		var tip = int(round(2.0 + (patience * 4.0)))
		if str(validation.get("container", "")) == "bag":
			tip += 1
		var reward = 8 + (item_count * 4) + tip
		var xp = 6 + (item_count * 4)
		total_earned += reward
		tips_earned += tip
		orders_completed += 1
		var wallet = get_tree().root.get_node_or_null("WalletManager")
		if wallet and wallet.has_method("add_money"):
			wallet.add_money(float(reward))
		var career = get_tree().root.get_node_or_null("CareerManager")
		if career and career.has_method("add_xp"):
			career.add_xp(float(xp))
		var daily = get_tree().root.find_child("DailyTaskManager", true, false)
		if daily and daily.has_method("record_progress"):
			daily.record_progress("customer_served", "order_fulfilled")
		payout = {"cash": reward, "tips": tip, "xp": xp, "summary": "Paid $" + str(reward) + " including $" + str(tip) + " tips"}
		order_fulfilled.emit(true, reward)
		_play_audio_hook("correct_handoff")
	else:
		orders_failed += 1
		mistake_count += 1
		payout = {"cash": 0, "tips": 0, "xp": 0, "summary": str(validation.get("issue", "Wrong order"))}
		order_fulfilled.emit(false, 0)
		_play_audio_hook("wrong_handoff")
	if success or not keep_order_active:
		current_order = {}
	last_payout = payout.duplicate(true)
	return payout

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
	return "Ticket #" + str(current_order.get("ticket_id", "?")) + ": " + " + ".join(parts)

func get_tips_earned() -> int:
	return tips_earned

func get_mistake_count() -> int:
	return mistake_count

func get_last_validation_summary() -> String:
	if last_validation.is_empty():
		return "No validation yet"
	return str(last_validation.get("issue", "No validation yet"))

func get_customer_feedback_line() -> String:
	if current_order.is_empty():
		return "Window clear"
	return str(current_order.get("customer_type", "Customer")) + " patience " + str(int(float(current_order.get("patience", 0.85)) * 100.0)) + "%"

func _select_order_template(customer_hint: String) -> Dictionary:
	if ticket_counter <= 0:
		return ORDER_TEMPLATES[0].duplicate(true)
	var hint = customer_hint.to_lower()
	for template in ORDER_TEMPLATES:
		var customer_type = str(template.get("customer_type", "")).to_lower()
		if hint != "" and (hint.contains(customer_type) or customer_type.contains(hint)):
			return template.duplicate(true)
	var index = ticket_counter % ORDER_TEMPLATES.size()
	return ORDER_TEMPLATES[index].duplicate(true)

func _normalize_item(item_name: String) -> String:
	var lower = item_name.to_lower()
	if lower.contains("burger") or lower.contains("patty"):
		return "Burger"
	if lower.contains("fries") or lower.contains("fry"):
		return "Fries"
	if lower.contains("soda") or lower.contains("drink") or lower.contains("cup"):
		return "Soda"
	return item_name.strip_edges()

func _items_summary(items: Array) -> String:
	if items.is_empty():
		return "nothing"
	var parts: Array[String] = []
	for item in items:
		parts.append(str(item))
	return " + ".join(parts)

func _play_audio_hook(hook_name: String):
	var audio = get_tree().root.get_node_or_null("AudioManager")
	if audio and audio.has_method("play_sfx"):
		audio.play_sfx(hook_name)
