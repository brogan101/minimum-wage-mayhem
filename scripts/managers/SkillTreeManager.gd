extends Node
class_name SkillTreeManager

## Permanent upgrades that modify player and shift stats.

var skills = {
	"Saucier": {"level": 0, "max": 5, "bonus": "Sauce-bagging speed +10% per level"},
	"FryMaster": {"level": 0, "max": 5, "bonus": "Reduce burn risk by 5% per level"},
	"ZenWorker": {"level": 0, "max": 5, "bonus": "Composure drain -10% per level"},
	"SprintingChef": {"level": 0, "max": 5, "bonus": "Walk speed +0.2m/s per level"}
}

func upgrade_skill(skill_id: String):
	if skills.has(skill_id):
		var skill = skills[skill_id]
		if skill["level"] < skill["max"]:
			skill["level"] += 1
			apply_skill_bonus(skill_id)
			print("SKILL UP: ", skill_id, " is now level ", skill, "!")
	else:
		print("Skill not found.")

func apply_skill_bonus(skill_id: String):
	match skill_id:
		"SprintingChef":
			var player = get_tree().root.find_child("Player", true, false)
			if player:
				player.walk_speed += 0.2
		"ZenWorker":
			if typeof(StatManager) != TYPE_NIL and StatManager.has_method("update_stat"):
				StatManager.update_stat("Composure", 5.0)
				StatManager.update_stat("Stress", -3.0)
