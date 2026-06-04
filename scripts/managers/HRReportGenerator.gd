extends Node
## HRReportGenerator handles the creation of the funny end-of-shift reports.

func generate_report(incidents: Array):
	var report_id = randi() % 1000
	var final_report = "HR Report #" + str(report_id) + "\n"
	final_report += "--------------------------\n"
	
	if incidents.size() == 0:
		final_report += "No major incidents. This is suspicious."
	else:
		for incident in incidents:
			final_report += "- " + incident + "\n"
	
	final_report += "--------------------------\n"
	final_report += "Result: " + get_random_result()
	
	return final_report

func get_random_result() -> String:
	var results = [
		"Mandatory training video assigned.",
		"Employee morale increased, corporate approval dropped.",
		"Employee must wear the 'I Love Accurate Cash Handling' hat for 3 shifts.",
		"Technically effective. Still not allowed.",
		"Sauce budget destroyed. Refund requested."
	]
	return results.pick_random()
