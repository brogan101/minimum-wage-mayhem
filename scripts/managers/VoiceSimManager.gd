extends Node
## The "Voice-Sim" System: Simulates the drive-thru microphone interaction.

signal mic_input_received(text, tone)

func process_voice_input(input_text: String, volume: float, pitch: float):
	var tone = "Neutral"
	
	# Heuristic for tone detection based on volume/pitch
	if volume > 0.8:
		tone = "Screaming"
	elif pitch > 0.7:
		tone = "Panic/Sarcasm"
	elif volume < 0.3:
		tone = "Tired/Bored"
	
	print("MIC INPUT: [", tone, "] ", input_text)
	mic_input_received.emit(input_text, tone)
	
	# Trigger Beef based on tone
	if tone == "Screaming" or tone == "Tired/Bored":
		BeefManager.increase_beef(15, "Poor customer service tone")
	elif tone == "Neutral":
		BeefManager.decrease_beef(5)
