extends Control
class_name BeefBattleUI

## The la la: The actual interface for the Verbal Duel.

@onready var dialogue_label = $Panel/DialogueLabel
@onready var buzzword_btn = $Panel/Options/BuzzwordButton
@onready var savage_btn = $Panel/Options/SavageButton

func _ready():
	buzzword_btn.pressed.connect(_on_buzzword_pressed)
	savage_btn.pressed.connect(_on_savage_pressed)

func start_battle(customer_name: String, beef: float):
	visible = true
	dialogue_label.text = customer_name + ": 'I want to speak to your manager NOW!'"
	# Disable player movement
	var player = get_tree().root.find_child("Player", true, false)
	if player:
		player.set_physics_process(false)

func _on_buzzword_pressed():
	var dialogue = _autoload("DialogueDatabase")
	var line = dialogue.get_random_buzzword() if dialogue and dialogue.has_method("get_random_buzzword") else "Let us de-escalate this receipt situation."
	dialogue_label.text = "You: '" + line + "'"
	await get_tree().create_timer(2.0).timeout
	var battle = _autoload("BeefBattleManager")
	if battle and battle.has_method("resolve_move"):
		battle.resolve_move("BUZZWORD", 1.0)
	end_battle()

func _on_savage_pressed():
	var dialogue = _autoload("DialogueDatabase")
	var line = dialogue.get_random_comeback() if dialogue and dialogue.has_method("get_random_comeback") else "The manager is currently a concept."
	dialogue_label.text = "You: '" + line + "'"
	await get_tree().create_timer(2.0).timeout
	var battle = _autoload("BeefBattleManager")
	if battle and battle.has_method("resolve_move"):
		battle.resolve_move("SAVAGE", 1.0)
	end_battle()

func end_battle():
	visible = false
	var player = get_tree().root.find_child("Player", true, false)
	if player:
		player.set_physics_process(true)

func _autoload(name: String) -> Node:
	return get_tree().root.get_node_or_null(name)
