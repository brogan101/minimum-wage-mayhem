extends Node
## StatManager (Autoload) handles the "Sims" style physical stats.

signal stat_changed(stat_name, new_value)

var stats = {
	"Energy": 100.0,
	"Mood": 100.0,
	"Hunger": 0.0,
	"Stress": 0.0,
	"Composure": 100.0
}

func update_stat(stat_name: String, amount: float):
	if stats.has(stat_name):
		stats[stat_name] = clamp(stats[stat_name] + amount, 0, 100)
		stat_changed.emit(stat_name, stats[stat_name])
		
		if stat_name == "Composure" and stats["Composure"] <= 0:
			trigger_breakdown()

func trigger_breakdown():
	print("🚨 MENTAL BREAKDOWN: You are now bagging invisible food.")
	# This would trigger the "Losing Your Mind" state in the PlayerController
