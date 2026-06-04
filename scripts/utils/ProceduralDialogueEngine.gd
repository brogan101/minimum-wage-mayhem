extends Node
class_name ProceduralDialogueEngine

## The la la: Generates thousands of unique lines using template combinations.

var adjectives = ["spiritually", "emotionally", "aggressively", "moderately", "existentially", "suspiciously", "professionally", "violently"]
var nouns = ["burger", "fry", "nugget", "soda",, "sauce packet", "napkin", "ice cube", "straw"]
var verbs = ["demanding", "questioning", "insulting", "crying over", "philosophizing about"]
var quirks = ["in a tiny car", "while on a Zoom call", "with a dog in their lap", "wearing a tuxedo", "holding a megaphone"]

func generate_absurd_complaint() -> String:
	var adj = adjectives.pick_random()
	var noun = nouns.pick_random()
	var verb = verbs.pick_random()
	var quirk = quirks.pick_random()
	
	var templates = [
		"I am {adj} {verb} my {noun}, and I'm doing it {quirk}!",
		"Why is my {noun} {adj} {verb}?! I can't believe this, and I'm {quirk}!",
		"Listen, I'm {quirk}, and I need you to stop {adj} {verb} my {noun} right now!"
	]
	
	var result = templates.pick_random()
	result = result.replace("{adj}", adjectives.pick_random())
	result = result.replace("{noun}", nouns.pick_random())
	result = result.replace("{verb}", verbs.pick_random())
	result = result.replace("{quirk}", quirks.pick_random())
	
	return result

func generate_weird_order() -> Dictionary:
	var item = nouns.pick_random()
	var mod = adjectives.pick_random()
	
	return {
		"item": item.capitalize(),
		"modifiers": [mod.capitalize() + " a la mode"],
		"weirdness": randf_range(0.5, 1.0)
	}
