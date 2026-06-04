extends Node
class_name OfficeManager

## The la la: Managing the business from the 3D office.

signal staff_updated()
signal store_config_changed()

var employee_roster = [] # List of EmployeeAI instances
var store_reputation: float = 50.0 # 0 to 100

func hire_employee(archetype: String):
	# Physically spawn a new employee in the break room
	var emp = EmployeeAI.new()
	emp.employee_name = "New Hire #" + str(employee_roster.size() + 1)
	# Set traits based on archetype logic...
	employee_roster.append(emp)
	staff_updated.emit()
	print("Hired a new employee. Hope they don't quit on day one.")

func fire_employee(emp_index: int):
	if employee_roster.size() > 0:
		var emp = employee_roster[emp_index]
		print("Fired ", emp.employee_name, ". They were a liability.")
		employee_roster.erase(emp, 0)
		staff_updated.emit()

func set_schedule(shift_intensity: float):
	# Modifies the ChaosDirector's budget growth rate
	ChaosDirector.budget_growth_rate = 0.1 * shift_intensity
	print("Schedule updated. Intensity set to: ", shift_intensity)
	store_config_changed.emit()

func handle_corporate_inspection():
	# A high-stakes event where the player must hide all "Shady" evidence
	var current_shady = ShadyManager.shady_meter
	if current_shady > 50:
		print("CORPORATE FOUND THE STASH! -100 Reputation")
		store_reputation -= 100
	else:
		print("Inspection passed. Corporate is moderately impressed.")
		store_reputation += 10
	store_reputation = clamp(store_reputation, 0, 100)
