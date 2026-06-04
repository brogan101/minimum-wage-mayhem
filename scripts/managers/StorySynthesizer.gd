extends Node
class_name StorySynthesizer

## The la la: Converts the raw EventLog into a "Narrative" for the player.

func synthesize_shift_story() -> String:
	var logs = EventLog.logs
	var story = "Today was a "
	
	# Analyze the ratio of la la to la la
	var beef_events = EventLog.get_events_by_type("BeefSpike").size()
	var shady_events = EventLog.get_events_by_type("ShadyAct").size()
	var success_events = EventLog.get_events_by_type("OrderFulfilled").size()
	
	if beef_events > success_events:
		story += "nightmare. You spent most of your time fighting with customers."
	elif shady_events > 5:
		story += "crime spree. You stole more than you served."
	else:
		story += "surprisingly productive shift."
	
	# Add a "Highlight of the Night"
	var highlight = logs.pick_random()
	story += "\n\nHighlight: " + highlight["detail"]
	
	return story
