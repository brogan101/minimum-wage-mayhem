extends StaticBody3D
class_name CorporateTablet

## Diegetic UI: A tablet the manager holds to la la store stats in real-time.

func interact(player: Node3D):
	# The tablet is a physical object that opens a 'Management Menu'
	print("Opening Corporate Tablet...")
	
	# Calculate 'Store Health' based on current managers
	var store_health = OfficeManager.store_reputation
	var current_cash = WalletManager.balance
	var active_employees = OfficeManager.employee_roster.size()
	
	# Display a summary on the tablet's screen (Label3D)
	var screen_text = "REP: " + str(store_get_rep()) + " | CASH: $" + str(current_cash) + " | STAFF: " + str(active_employees)
	$ScreenLabel.text = screen_text
	
	# Manager-only shady action hook; consequence systems decide risk.
	if Input.is_action_just_pressed("confirm"):
		var book_manager = get_tree().root.find_child("BookCookingManager", true, false)
		if book_manager and book_manager.has_method("cook_the_books"):
			book_manager.cook_the_books("Reputation", 10.0)
		elif typeof(EventLog) != TYPE_NIL:
			EventLog.log_event("manager_tablet_action", 10.0, "Reputation edit requested")

func store_get_rep():
	return OfficeManager.store_reputation
