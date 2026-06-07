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
		"customer_note": "First order: keep it simple and bag the burger.",
		"customer_moment": {
			"id": "regular_first_timer",
			"label": "Normal first-timer",
			"success_line": "The first customer nods like this place might be legally food.",
			"fail_line": "The first customer rereads the ticket out loud.",
			"review_line": "A normal customer appreciated a clean start."
		}
	},
	{
		"customer_type": "Lunch Driver",
		"items": [{"item": "Burger", "modifiers": []}, {"item": "Fries", "modifiers": []}],
		"patience": 0.82,
		"target_time": 42.0,
		"customer_note": "Normal combo. No chaos, just fries.",
		"customer_moment": {
			"id": "work_van_combo",
			"label": "Work-van lunch rush",
			"success_line": "Lunch Driver keeps the lane moving and tips for speed.",
			"fail_line": "Lunch Driver taps the steering wheel in dotted-eighth notes.",
			"review_line": "Lunch Driver says the combo hit the deadline."
		}
	},
	{
		"customer_type": "Thirsty Commuter",
		"items": [{"item": "Burger", "modifiers": []}, {"item": "Soda", "modifiers": []}],
		"patience": 0.78,
		"target_time": 44.0,
		"customer_note": "Wants the drink filled, not spiritually implied.",
		"customer_moment": {
			"id": "commuter_needs_soda",
			"label": "Drink-check commuter",
			"success_line": "Thirsty Commuter spots the soda and visibly unclenches.",
			"fail_line": "Thirsty Commuter points at the cup-shaped absence.",
			"review_line": "A commuter praised the drink accuracy."
		}
	},
	{
		"customer_type": "Coupon Skeptic",
		"items": [{"item": "Burger", "modifiers": []}, {"item": "Fries", "modifiers": []}],
		"patience": 0.74,
		"target_time": 46.0,
		"customer_note": "Checks the bag like the coupon is personally on trial.",
		"customer_moment": {
			"id": "coupon_skeptic",
			"label": "Coupon scrutiny",
			"success_line": "Coupon Skeptic accepts the combo and files no spiritual paperwork.",
			"fail_line": "Coupon Skeptic begins a courtroom reenactment at the speaker.",
			"review_line": "Coupon customer confirms the bag matched the ticket."
		}
	},
	{
		"customer_type": "Night Nurse",
		"items": [{"item": "Burger", "modifiers": []}, {"item": "Soda", "modifiers": []}],
		"patience": 0.88,
		"target_time": 48.0,
		"customer_note": "Tired but kind. Soda matters more than poetry.",
		"customer_moment": {
			"id": "night_nurse",
			"label": "Kind tired regular",
			"success_line": "Night Nurse gives a tiny salute and an extra tip.",
			"fail_line": "Night Nurse is too tired to yell, which somehow hurts more.",
			"review_line": "A tired regular called the shift gentle and competent."
		}
	},
	{
		"customer_type": "Parent Van",
		"items": [{"item": "Burger", "modifiers": []}, {"item": "Fries", "modifiers": []}, {"item": "Soda", "modifiers": []}],
		"patience": 0.7,
		"target_time": 52.0,
		"customer_note": "Full combo. Normal family pressure, not apocalypse.",
		"customer_moment": {
			"id": "parent_van_combo",
			"label": "Full-combo patience test",
			"success_line": "Parent Van survives the lane with a complete bag.",
			"fail_line": "Parent Van performs the ancient missing-side sigh.",
			"review_line": "Family combo landed complete despite the rush."
		}
	},
	{
		"customer_type": "Off-Duty Cook",
		"items": [{"item": "Burger", "modifiers": []}, {"item": "Fries", "modifiers": []}],
		"patience": 0.76,
		"target_time": 45.0,
		"customer_note": "Knows the station rhythm. Do the basics clean.",
		"customer_moment": {
			"id": "off_duty_cook",
			"label": "Quiet quality check",
			"success_line": "Off-Duty Cook notices the bag was built in the right order.",
			"fail_line": "Off-Duty Cook looks at the bag with professional sadness.",
			"review_line": "Off-duty cook respected the clean prep flow."
		}
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
var order_history: Array = []
var customer_moment_entries: Array[String] = []
var customer_review_lines: Array[String] = []

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
	order_history.clear()
	customer_moment_entries.clear()
	customer_review_lines.clear()

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
	_apply_customer_moment(success, active_order, validation, payout)
	_record_order_history(success, active_order, validation, payout)
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

func get_order_variety_summary() -> Dictionary:
	var customer_types: Array[String] = []
	var combo_count = 0
	for entry in order_history:
		var customer_type = str(entry.get("customer_type", "Customer"))
		if not customer_types.has(customer_type):
			customer_types.append(customer_type)
		if int(entry.get("item_count", 0)) >= 2:
			combo_count += 1
	return {
		"order_history": order_history.duplicate(true),
		"customer_types": customer_types,
		"combo_count": combo_count,
		"customer_moments": customer_moment_entries.duplicate(),
		"review_lines": customer_review_lines.duplicate()
	}

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

func _record_order_history(success: bool, active_order: Dictionary, validation: Dictionary, payout: Dictionary) -> void:
	var items: Array = active_order.get("items", [])
	var required: Array[String] = []
	for item_obj in items:
		required.append(_normalize_item(str(item_obj.get("item", "Item"))))
	order_history.append({
		"ticket_id": active_order.get("ticket_id", ticket_counter),
		"customer_type": active_order.get("customer_type", "Customer"),
		"items": required,
		"item_count": required.size(),
		"success": success,
		"issue": validation.get("issue", "Correct"),
		"cash": payout.get("cash", 0),
		"tips": payout.get("tips", 0)
	})
	var daily = get_tree().root.find_child("DailyTaskManager", true, false)
	if daily and daily.has_method("record_progress"):
		if success and required.size() >= 2:
			daily.record_progress("order_type", "combo")
		if success and required.has("Soda"):
			daily.record_progress("order_type", "soda")
		if success and required.has("Fries"):
			daily.record_progress("order_type", "fries")

func _apply_customer_moment(success: bool, active_order: Dictionary, validation: Dictionary, payout: Dictionary) -> void:
	var moment: Dictionary = active_order.get("customer_moment", {})
	if moment.is_empty():
		return
	var line = str(moment.get("success_line", "")) if success else str(moment.get("fail_line", ""))
	if line.is_empty():
		line = str(active_order.get("customer_type", "Customer")) + " reacted to the handoff."
	customer_moment_entries.append(line)
	var review = str(moment.get("review_line", ""))
	if success and not review.is_empty():
		customer_review_lines.append(review)
	var event_log = get_tree().root.get_node_or_null("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event("customer_moment", 1.0 if success else 0.0, line)
	var daily = get_tree().root.find_child("DailyTaskManager", true, false)
	if daily and daily.has_method("record_progress"):
		daily.record_progress("customer_moment", str(moment.get("id", "")))
	if success and str(moment.get("id", "")) == "night_nurse":
		_apply_tip_bonus(1, payout)
	elif not success and str(moment.get("id", "")) == "coupon_skeptic":
		var staff = get_tree().root.find_child("StaffDirector", true, false)
		if staff:
			staff.review_risk = clamp(int(staff.review_risk) + 1, 0, 100)

func _apply_tip_bonus(amount: int, payout: Dictionary) -> void:
	if amount <= 0:
		return
	var wallet = get_tree().root.get_node_or_null("WalletManager")
	if wallet and wallet.has_method("add_money"):
		wallet.add_money(float(amount))
	tips_earned += amount
	total_earned += amount
	payout["cash"] = int(payout.get("cash", 0)) + amount
	payout["tips"] = int(payout.get("tips", 0)) + amount
	payout["summary"] = str(payout.get("summary", "Order paid.")) + " +$" + str(amount) + " moment tip"

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
