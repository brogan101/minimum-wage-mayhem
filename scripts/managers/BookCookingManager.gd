extends Node
class_name BookCookingManager
## BookCookingManager (Autoload) - Manager-only fraud logic.

func cook_the_books(target_stat: String, amount: float):
		print("Editing records... Changing ", target_stat, " by ", amount)
	
	# Risk: If Corporate discovers the books are cooked, the Manager is fired instantly.
	if randf() < 0.1:
		print("🚨 AUDIT FAILURE: Corporate found the fraud!")
		if typeof(EventLog) != TYPE_NIL:
			EventLog.log_event("audit_failure", amount, target_stat)
	else:
		print("Books successfully cooked. You are a corporate genius.")
