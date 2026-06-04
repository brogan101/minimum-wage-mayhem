extends Node
class_name ViralReviewSystem

## Reviews that change future customer weighting and store reputation.

signal market_shift(new_archetype_weight)

func process_review(rating: int, text: String, customer_type: String):
	# Logic: Reviews influence which customer archetypes are more likely to spawn.
	if rating <= 2:
		# Bad review for a specific type makes others of that type angry
		print("VIRAL FAIL: ", customer_type, "s are now avoiding the store.")
		adjust_spawn_weight(customer_type, -0.2)
	elif rating >= 4:
		# Good review attracts more of that archetype
		print("VIRAL SUCCESS: ", customer_type, "s are flocking to the store!")
		adjust_spawn_weight(customer_type, 0.2)
	
	# Update the Store Reputation
	OfficeManager.store_reputation += (rating - 3) * 2
	OfficeManager.store_reputation = clamp(OfficeManager.store_reputation, 0, 100)

var customer_spawn_weight_delta: Dictionary = {}

func adjust_spawn_weight(type: String, amount: float):
	customer_spawn_weight_delta[type] = clamp(float(customer_spawn_weight_delta.get(type, 0.0)) + amount, -0.8, 1.5)
	emit_signal("market_shift", customer_spawn_weight_delta.duplicate())
	if typeof(EventLog) != TYPE_NIL:
		EventLog.log_event("review_spawn_weight_changed", amount, type)
