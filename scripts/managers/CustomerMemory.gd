extends Node
## Customer Memory: Customers who remember your mistakes.

var customer_history = {} # { "CustomerID": { "last_experience": "Bad", "beef_carried": 20 } }

func record_experience(customer_id: String, success: bool, beef: float):
	if not customer_history.has(customer_id):
		customer_history[customer_id] = {}
	
	customer_history[customer_id]["last_experience"] = "Good" if success else "Bad"
	customer_history[customer_id]["beef_carried"] = beef
	print("Customer ", customer_id, " will remember this.")

func get_returning_customer_mood(customer_id: String):
	if customer_history.has(customer_id):
		var history = customer_history[customer_id]
		if history["last_experience"] == "Bad":
			print("Returning Customer: 'I'm still mad about last time!'")
			return history["beef_carried"] * 1.2 # Beef increases on return
	return 0.0
