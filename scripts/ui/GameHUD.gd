extends CanvasLayer
class_name GameHUD

## Real-time player feedback for the MVP shift loop.

@onready var order_list = $Control/OrderList
@onready var beef_bar = $Control/BeefBar
@onready var composure_bar = $Control/ComposureBar
@onready var cash_label = $Control/CashLabel
@onready var rank_label = $Control/RankLabel
@onready var current_mandate = $Control/MandateLabel
@onready var shift_timer_label = $Control/ShiftTimerLabel
@onready var objective_label = $Control/ObjectiveLabel
@onready var boot_status_label = $Control/BootStatusLabel
@onready var interaction_prompt_label = $Control/InteractionPromptLabel
@onready var station_feedback_label = $Control/StationFeedbackLabel
@onready var staff_status_label = $Control/StaffStatusLabel
@onready var store_ops_status_label = $Control/StoreOpsStatusLabel
@onready var daily_tasks_label = $Control/DailyTasksLabel

var customer_status_label: Label
var held_item_label: Label
var guidance_label: Label
var event_feed_label: Label
var order_title_label: Label
var event_feed: Array[String] = []

func _ready():
	_apply_demo_layout()
	# Autoloads are referenced by name in Godot; guard each connection so the HUD does not crash in partial builds.
	var order_manager = _autoload("OrderManager")
	if order_manager and order_manager.has_signal("order_changed"):
		order_manager.order_changed.connect(_update_order_display)
	if order_manager and order_manager.has_signal("order_fulfilled"):
		order_manager.order_fulfilled.connect(_on_order_fulfilled)
	var beef_manager = _autoload("BeefManager")
	if beef_manager and beef_manager.has_signal("beef_level_changed"):
		beef_manager.beef_level_changed.connect(_update_beef_bar)
	var stat_manager = _autoload("StatManager")
	if stat_manager and stat_manager.has_signal("stat_changed"):
		stat_manager.stat_changed.connect(_update_stat_bars)
	var wallet = _autoload("WalletManager")
	if wallet and wallet.has_signal("balance_changed"):
		wallet.balance_changed.connect(_update_cash)
	var corporate = _autoload("CorporateManager")
	if corporate and corporate.has_signal("goal_updated"):
		corporate.goal_updated.connect(_update_mandate)
	_update_order_display({})
	set_customer_status("No customer yet. Clock in to start the lane.")
	set_held_item("")
	set_first_shift_guidance("Read ORDER TICKET, grab food, hand it out at DRIVE-THRU, then use CLOCK OUT or pause.")

func _update_order_display(order_data):
	if not order_list:
		return
	for child in order_list.get_children():
		child.queue_free()
	if typeof(order_data) != TYPE_DICTIONARY or not order_data.has("items"):
		if order_title_label:
			order_title_label.text = "ORDER TICKET"
		var empty_label = Label.new()
		empty_label.text = "Waiting for customer..."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		order_list.add_child(empty_label)
		return
	var customer_type = str(order_data.get("customer_type", "Customer"))
	if order_title_label:
		order_title_label.text = "ORDER TICKET - " + customer_type.to_upper()
	for item in order_data["items"]:
		var label = Label.new()
		var mods = item.get("modifiers", [])
		var mod_text = "plain" if mods.is_empty() else ", ".join(PackedStringArray(mods))
		label.text = "[ ] " + str(item.get("item", "Unknown")) + " - " + mod_text
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		order_list.add_child(label)
	set_customer_status(customer_type + " waiting at DRIVE-THRU.")
	add_event_feed_line("Order received: " + customer_type)

func _update_beef_bar(value):
	if not beef_bar:
		return
	beef_bar.value = value
	if value > 80:
		beef_bar.modulate = Color.RED
	else:
		beef_bar.modulate = Color.WHITE

func _update_stat_bars(stat, value):
	if stat == "Composure" and composure_bar:
		composure_bar.value = value

func _update_cash(amount):
	if cash_label:
		cash_label.text = "Wallet: $" + str(amount)

func _update_mandate(text):
	if current_mandate:
		current_mandate.text = "CORPORATE GOAL: " + str(text)

func set_boot_status(text: String):
	if boot_status_label:
		boot_status_label.text = "Status: " + text

func set_interaction_prompt(text: String):
	if interaction_prompt_label:
		interaction_prompt_label.text = text
		interaction_prompt_label.visible = text.length() > 0
	if station_feedback_label and text.length() > 0:
		station_feedback_label.text = "Station: " + text.replace("E / A: ", "").replace("E / X: ", "")

func set_shift_timer(seconds: float, active: bool):
	if not shift_timer_label:
		return
	var safe_seconds = max(0, int(seconds))
	var minutes = safe_seconds / 60
	var remainder = safe_seconds % 60
	if active:
		shift_timer_label.text = "Shift: " + ("%02d:%02d" % [minutes, remainder])
	else:
		shift_timer_label.text = "Shift: paused"

func set_objective_status(text: String):
	if objective_label:
		objective_label.text = text

func set_station_feedback(text: String):
	if station_feedback_label:
		station_feedback_label.text = "Station: " + text
	add_event_feed_line(text)

func set_customer_status(text: String):
	if customer_status_label:
		customer_status_label.text = "Customer: " + text

func set_held_item(text: String):
	if held_item_label:
		held_item_label.text = "Held: " + (text if text.length() > 0 else "empty hands")

func set_first_shift_guidance(text: String):
	if guidance_label:
		guidance_label.text = "First Shift: " + text + "\nPrep: Burger now; bags, soda, and fries are marked for clarity."

func add_event_feed_line(text: String):
	if text.is_empty() or not event_feed_label:
		return
	event_feed.append(text)
	while event_feed.size() > 5:
		event_feed.pop_front()
	event_feed_label.text = "Feed\n" + "\n".join(event_feed)

func set_staff_status(status: Dictionary):
	if staff_status_label:
		var morale = int(status.get("staff_morale", 0))
		var trust = int(status.get("manager_trust", 0))
		var speed = float(status.get("speed", 1.0))
		staff_status_label.text = "Staff: morale " + str(morale) + " | trust " + str(trust) + " | speed x" + str(snapped(speed, 0.01))

func set_store_ops_status(status: Dictionary):
	if store_ops_status_label:
		var clean = int(status.get("cleanliness", 0))
		var sauce = int(status.get("sauce_stock", 0))
		var fryer = int(status.get("fryer_health", 0))
		var speed = float(status.get("speed", 1.0))
		store_ops_status_label.text = "Store: clean " + str(clean) + " | sauce " + str(sauce) + " | fryer " + str(fryer) + " | speed x" + str(snapped(speed, 0.01))

func set_daily_tasks(tasks: Array):
	if not daily_tasks_label:
		return
	var lines := ["Daily Tasks"]
	for task in tasks:
		var mark = "DONE" if bool(task.get("completed", false)) else ("MISS" if bool(task.get("failed", false)) else "OPEN")
		lines.append(mark + " " + str(task.get("title", task.get("id", "Task"))))
	daily_tasks_label.text = "\n".join(lines)

func apply_accessibility_settings(settings: Dictionary):
	var high_contrast = bool(settings.get("high_contrast", false))
	var alpha = 1.0 if high_contrast else 0.85
	var control = get_node_or_null("Control")
	if control:
		control.modulate = Color(1.0, 1.0, 1.0, alpha)
	if interaction_prompt_label:
		interaction_prompt_label.add_theme_color_override("font_color", Color.YELLOW if high_contrast else Color.WHITE)
	if station_feedback_label:
		station_feedback_label.add_theme_color_override("font_color", Color.CYAN if high_contrast else Color.WHITE)

func set_career_status(status: Dictionary):
	if rank_label:
		var rank = str(status.get("rank_name", "Trainee"))
		var xp = int(status.get("current_xp", 0))
		var needed = int(status.get("xp_to_next_rank", 0))
		var progress = int(status.get("promotion_progress", 0))
		rank_label.text = "Rank: " + rank + " | XP " + str(xp) + "/" + str(needed) + " | Promo " + str(progress) + "%"

func _on_order_fulfilled(success: bool, reward: int):
	if success:
		set_customer_status("served correctly. Window is clear.")
		set_station_feedback("Correct handoff. +$" + str(reward))
	else:
		set_customer_status("wrong order. Try the next ticket.")
		set_station_feedback("Wrong handoff. Check the ticket before serving.")

func _apply_demo_layout():
	var control = get_node_or_null("Control")
	if not control:
		return
	_add_panel(control, "OrderPanel", Vector2(14, 14), Vector2(330, 235), Color(0.07, 0.045, 0.035, 0.88))
	_add_panel(control, "OrderPanelHeader", Vector2(14, 14), Vector2(330, 34), Color(0.88, 0.12, 0.08, 0.95))
	_add_panel(control, "ObjectivePanel", Vector2(365, 14), Vector2(540, 125), Color(0.035, 0.08, 0.12, 0.84))
	_add_panel(control, "ObjectivePanelHeader", Vector2(365, 14), Vector2(540, 10), Color(1.0, 0.76, 0.14, 0.95))
	_add_panel(control, "StatusPanel", Vector2(14, 265), Vector2(520, 205), Color(0.08, 0.055, 0.035, 0.84))
	_add_panel(control, "StatusPanelHeader", Vector2(14, 265), Vector2(520, 10), Color(0.18, 0.72, 0.95, 0.95))
	_add_panel(control, "TaskPanel", Vector2(930, 14), Vector2(335, 315), Color(0.035, 0.07, 0.05, 0.86))
	_add_panel(control, "TaskPanelHeader", Vector2(930, 14), Vector2(335, 34), Color(0.22, 0.68, 0.34, 0.95))
	_add_panel(control, "CareerPanel", Vector2(930, 346), Vector2(335, 175), Color(0.045, 0.05, 0.08, 0.84))
	_add_panel(control, "CareerPanelHeader", Vector2(930, 346), Vector2(335, 10), Color(0.95, 0.72, 0.18, 0.95))
	_add_panel(control, "PromptPanel", Vector2(360, 570), Vector2(560, 74), Color(0.015, 0.018, 0.02, 0.92))
	_add_panel(control, "PromptPanelAccent", Vector2(360, 570), Vector2(560, 8), Color(0.18, 1.0, 0.35, 0.95))
	order_title_label = _ensure_label(control, "OrderTitleLabel", Vector2(28, 24), Vector2(300, 28), "ORDER TICKET", 18, Color(1.0, 0.86, 0.42))
	order_title_label.add_theme_color_override("font_shadow_color", Color(0.08, 0.02, 0.01, 1.0))
	order_title_label.add_theme_constant_override("shadow_offset_x", 2)
	order_title_label.add_theme_constant_override("shadow_offset_y", 2)
	order_list.position = Vector2(28, 58)
	order_list.size = Vector2(292, 165)
	shift_timer_label.position = Vector2(380, 24)
	shift_timer_label.size = Vector2(180, 32)
	objective_label.position = Vector2(380, 58)
	objective_label.size = Vector2(500, 48)
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	current_mandate.position = Vector2(380, 106)
	current_mandate.size = Vector2(500, 28)
	customer_status_label = _ensure_label(control, "CustomerStatusLabel", Vector2(28, 278), Vector2(480, 26), "Customer: waiting", 17, Color(1.0, 0.95, 0.78))
	held_item_label = _ensure_label(control, "HeldItemLabel", Vector2(28, 308), Vector2(480, 26), "Held: empty hands", 17, Color(0.8, 1.0, 0.82))
	guidance_label = _ensure_label(control, "GuidanceLabel", Vector2(28, 338), Vector2(480, 72), "First Shift: follow the ticket", 14, Color(0.88, 0.92, 1.0))
	guidance_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_feed_label = _ensure_label(control, "EventFeedLabel", Vector2(28, 414), Vector2(480, 52), "Feed", 13, Color(0.86, 0.9, 0.92))
	event_feed_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cash_label.position = Vector2(946, 356)
	cash_label.size = Vector2(300, 24)
	cash_label.add_theme_font_size_override("font_size", 15)
	rank_label.position = Vector2(946, 382)
	rank_label.size = Vector2(300, 38)
	rank_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rank_label.add_theme_font_size_override("font_size", 15)
	staff_status_label.position = Vector2(946, 422)
	staff_status_label.size = Vector2(300, 30)
	staff_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	staff_status_label.add_theme_font_size_override("font_size", 14)
	store_ops_status_label.position = Vector2(946, 454)
	store_ops_status_label.size = Vector2(300, 58)
	store_ops_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	store_ops_status_label.add_theme_font_size_override("font_size", 14)
	daily_tasks_label.position = Vector2(946, 30)
	daily_tasks_label.size = Vector2(300, 292)
	daily_tasks_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	daily_tasks_label.add_theme_font_size_override("font_size", 15)
	interaction_prompt_label.position = Vector2(382, 592)
	interaction_prompt_label.size = Vector2(520, 28)
	interaction_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	station_feedback_label.position = Vector2(382, 620)
	station_feedback_label.size = Vector2(520, 22)
	station_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boot_status_label.position = Vector2(365, 146)
	boot_status_label.size = Vector2(540, 28)
	beef_bar.position = Vector2(365, 182)
	beef_bar.size = Vector2(250, 18)
	composure_bar.position = Vector2(365, 208)
	composure_bar.size = Vector2(250, 18)
	for label in [cash_label, rank_label, current_mandate, shift_timer_label, objective_label, boot_status_label, interaction_prompt_label, station_feedback_label, staff_status_label, store_ops_status_label, daily_tasks_label]:
		if label:
			label.add_theme_color_override("font_color", Color(0.96, 0.96, 0.92))
			label.add_theme_color_override("font_shadow_color", Color(0.02, 0.02, 0.02, 1.0))
			label.add_theme_constant_override("shadow_offset_x", 1)
			label.add_theme_constant_override("shadow_offset_y", 1)

func _add_panel(parent: Control, panel_name: String, pos: Vector2, size: Vector2, color: Color):
	if parent.get_node_or_null(panel_name):
		return
	var panel = ColorRect.new()
	panel.name = panel_name
	panel.position = pos
	panel.size = size
	panel.color = color
	parent.add_child(panel)
	parent.move_child(panel, 0)

func _ensure_label(parent: Control, node_name: String, pos: Vector2, size: Vector2, text: String, font_size: int, color: Color) -> Label:
	var label = parent.get_node_or_null(node_name) as Label
	if not label:
		label = Label.new()
		label.name = node_name
		parent.add_child(label)
	label.position = pos
	label.size = size
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _autoload(name: String) -> Node:
	return get_tree().root.get_node_or_null(name)
