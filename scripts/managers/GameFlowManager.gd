extends Node
class_name GameFlowManager

## The Director: Manages the high-level state of the game.

enum GameState { APARTMENT, CLOCKING_IN, SHIFT_ACTIVE, SHIFT_RESULTS, CLOCKING_OUT }
var current_state = GameState.APARTMENT

signal state_changed(new_state)

func transition_to(new_state: GameState):
	current_state = new_state
	state_changed.emit(new_state)
	
	match new_state:
		GameState.APARTMENT:
			load_apartment()
		GameState.CLOCKING_IN:
			play_clock_in_animation()
		GameState.SHIFT_ACTIVE:
			start_shift_loop()
		GameState.SHIFT_RESULTS:
			show_results_screen()
		GameState.CLOCKING_OUT:
			process_final_payout()

func load_apartment():
	print("Transitioning to Apartment Hub...")
	# Physical scene swap logic
	var main = get_tree().root.get_node_or_null("Main")
	if main and main.has_method("load_apartment_hub"):
		main.load_apartment_hub()

func play_clock_in_animation():
	print("Clock-in animation placeholder: starting shift loop.")
	start_shift_loop()

func start_shift_loop():
	print("Transitioning to Restaurant...")
	var main = get_tree().root.get_node_or_null("Main")
	if main and main.has_method("clock_in"):
		main.clock_in()

func show_results_screen():
	var results_ui = get_tree().root.find_child("ShiftResultsUI", true, false)
	if results_ui:
		results_ui.visible = true
		var wallet = _autoload("WalletManager")
		var order_manager = _autoload("OrderManager")
		var corporate = _autoload("CorporateManager")
		var shift_results = _autoload("ShiftResultManager")
		var stats = {
			"cash": wallet.balance if wallet else 0.0,
			"completed": order_manager.orders_completed if order_manager else 0,
			"corp": corporate.get_approval_rating() if corporate and corporate.has_method("get_approval_rating") else 0
		}
		if shift_results and shift_results.has_method("generate_end_of_shift_screen"):
			shift_results.generate_end_of_shift_screen(stats)

func process_final_payout():
	# Save game state before returning home
	var save_system = _autoload("SaveSystem")
	if save_system and save_system.has_method("save_game"):
		save_system.save_game()
	transition_to(GameState.APARTMENT)

func _autoload(name: String) -> Node:
	return get_tree().root.get_node_or_null(name)
