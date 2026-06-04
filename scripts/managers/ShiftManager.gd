extends Node
class_name ShiftManager

## The la la: Manages the time and progression of a single shift.

signal shift_started()
signal shift_ended()

@export var shift_duration: float = 360.0 # 6 minutes for first-shift readability
var time_remaining: float = 0.0
var is_active: bool = false

func start_shift():
	time_remaining = shift_duration
	is_active = true
	var shift_results = _autoload("ShiftResultManager")
	if shift_results and shift_results.has_method("begin_shift_snapshot"):
		shift_results.begin_shift_snapshot()
	shift_started.emit()
	print("⏰ SHIFT STARTED: You have ", shift_duration, " seconds to survive.")

func _process(delta):
	if not is_active: return
	
	time_remaining -= delta
	if time_remaining <= 0:
		end_shift()

func end_shift():
	is_active = false
	shift_ended.emit()
	
	# Generate final results based on EventLog
	var shift_results = _autoload("ShiftResultManager")
	var wallet = _autoload("WalletManager")
	var order_manager = _autoload("OrderManager")
	var corporate = _autoload("CorporateManager")
	var stats = {
		"cash": wallet.balance if wallet else 0.0,
		"completed": order_manager.orders_completed if order_manager else 0,
		"corp": corporate.get_approval_rating() if corporate and corporate.has_method("get_approval_rating") else 0
	}
	var report = shift_results.complete_shift(stats) if shift_results and shift_results.has_method("complete_shift") else "--- SHIFT SUMMARY ---"
	
	print(report)
	print("⏰ SHIFT ENDED. Please clock out.")

func _autoload(name: String) -> Node:
	return get_tree().root.get_node_or_null(name)
