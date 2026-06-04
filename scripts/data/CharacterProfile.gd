extends Resource
class_name CharacterProfile

## Depth: Every character has physical and psychological traits.

@export var char_name: String = "Unknown"
@export var physical_description: String = "Generic Human"
@export var personality_trait: String = "Average"
@export var trigger_phrase: String = "I want a manager!"
@export var behavior_modifier: float = 1.0 # How fast they get angry
@export var dialogue_set: Array[String] = []

# Example profiles can be created as .tres files in Godot
