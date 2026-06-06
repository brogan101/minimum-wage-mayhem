extends CanvasLayer
class_name MainMenuUI

signal new_game_requested
signal continue_requested
signal resume_requested
signal end_shift_requested
signal return_to_menu_requested
signal save_requested
signal load_requested
signal quit_requested
signal settings_changed(settings: Dictionary)

var mode: String = "main"
var settings := {
	"fullscreen": false,
	"reduced_motion": false,
	"high_contrast": false,
	"master_volume": 0.8,
	"performance_mode": "balanced"
}
var root_panel: PanelContainer
var title_label: Label
var body_label: Label
var buttons_box: VBoxContainer
var status_label: Label

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	show_main_menu("Local-only early build. No online services.")

func _build_ui():
	root_panel = PanelContainer.new()
	root_panel.name = "MenuPanel"
	root_panel.set_anchors_preset(Control.PRESET_CENTER)
	root_panel.offset_left = -260
	root_panel.offset_top = -220
	root_panel.offset_right = 260
	root_panel.offset_bottom = 220
	add_child(root_panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	root_panel.add_child(margin)

	var layout = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	margin.add_child(layout)

	title_label = Label.new()
	title_label.text = "Minimum Wage Mayhem"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(title_label)

	body_label = Label.new()
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.text = ""
	layout.add_child(body_label)

	buttons_box = VBoxContainer.new()
	buttons_box.add_theme_constant_override("separation", 6)
	layout.add_child(buttons_box)

	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.text = ""
	layout.add_child(status_label)

func show_main_menu(status: String = ""):
	mode = "main"
	visible = true
	get_tree().paused = false
	title_label.text = "Minimum Wage Mayhem"
	body_label.text = "Clock in, survive the shift, save locally, and try to look promotable."
	_clear_buttons()
	_add_button("New Game", func(): new_game_requested.emit())
	_add_button("Continue", func(): continue_requested.emit())
	_add_button("Settings", show_settings)
	_add_button("Controls", show_controls)
	_add_button("Credits", show_credits)
	_add_button("Quit", func(): quit_requested.emit())
	status_label.text = status

func show_pause_menu(status: String = "Paused"):
	mode = "pause"
	visible = true
	get_tree().paused = true
	title_label.text = "Shift Paused"
	body_label.text = "The headset is off. The fryer is emotionally unsupervised."
	_clear_buttons()
	_add_button("Resume", func(): resume_requested.emit())
	_add_button("Save Game", func(): save_requested.emit())
	_add_button("Load Game", func(): load_requested.emit())
	_add_button("Settings", show_settings)
	_add_button("Controls", show_controls)
	_add_button("End Shift", func(): end_shift_requested.emit())
	_add_button("Quit To Menu", func(): return_to_menu_requested.emit())
	status_label.text = status

func show_settings():
	mode = "settings"
	title_label.text = "Settings"
	body_label.text = "Display, accessibility, audio hooks, and performance options."
	_clear_buttons()
	_add_button("Windowed / Fullscreen: " + ("Fullscreen" if settings["fullscreen"] else "Windowed"), _toggle_fullscreen)
	_add_button("Reduced Motion: " + _on_off(settings["reduced_motion"]), _toggle_reduced_motion)
	_add_button("High Contrast HUD: " + _on_off(settings["high_contrast"]), _toggle_high_contrast)
	_add_button("Performance: " + str(settings["performance_mode"]).capitalize(), _cycle_performance)
	_add_button("Master Volume: " + str(int(float(settings["master_volume"]) * 100.0)) + "%", _cycle_volume)
	_add_button("Back", _back_from_submenu)
	status_label.text = "Settings are local runtime preferences for this build."

func show_controls():
	mode = "controls"
	title_label.text = "Controls"
	body_label.text = "Keyboard: WASD move, mouse look, E interact/use, Q drop, right mouse throw, Space jump, Shift sprint, V camera, Esc pause.\nController: left stick move, right stick look, A interact/use, X drop, shoulders use/throw, Y camera, Start pause."
	_clear_buttons()
	_add_button("Back", _back_from_submenu)
	status_label.text = "Controller mappings are present through Godot InputMap; physical controller validation is pending."

func show_credits():
	mode = "credits"
	title_label.text = "Credits / Attribution"
	body_label.text = "Current build uses project-local scripts, generated data, and placeholder Godot primitives. See ASSET_ATTRIBUTION.md before adding release assets."
	_clear_buttons()
	_add_button("Back", _back_from_submenu)
	status_label.text = "No paid assets are required."

func show_results(report: String):
	mode = "results"
	visible = true
	get_tree().paused = false
	title_label.text = "Shift Recap"
	body_label.text = report.left(2600)
	_clear_buttons()
	_add_button("Next Shift", func(): new_game_requested.emit())
	_add_button("Return To Menu", func(): return_to_menu_requested.emit())
	status_label.text = "Progress saved locally when the shift completed."

func show_status(message: String):
	status_label.text = message

func hide_menu():
	visible = false
	get_tree().paused = false

func _clear_buttons():
	for child in buttons_box.get_children():
		child.queue_free()

func _add_button(label: String, callback: Callable):
	var button = Button.new()
	button.text = label
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(callback)
	buttons_box.add_child(button)
	if buttons_box.get_child_count() == 1:
		button.grab_focus.call_deferred()

func _back_from_submenu():
	if get_tree().paused:
		show_pause_menu(status_label.text)
	else:
		show_main_menu(status_label.text)

func _toggle_fullscreen():
	settings["fullscreen"] = not bool(settings["fullscreen"])
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if settings["fullscreen"] else DisplayServer.WINDOW_MODE_WINDOWED)
	settings_changed.emit(settings.duplicate(true))
	show_settings()

func _toggle_reduced_motion():
	settings["reduced_motion"] = not bool(settings["reduced_motion"])
	settings_changed.emit(settings.duplicate(true))
	show_settings()

func _toggle_high_contrast():
	settings["high_contrast"] = not bool(settings["high_contrast"])
	settings_changed.emit(settings.duplicate(true))
	show_settings()

func _cycle_performance():
	var modes = ["quality", "balanced", "performance"]
	var index = modes.find(str(settings["performance_mode"]))
	settings["performance_mode"] = modes[(index + 1) % modes.size()]
	settings_changed.emit(settings.duplicate(true))
	show_settings()

func _cycle_volume():
	var volume = float(settings["master_volume"])
	volume += 0.1
	if volume > 1.0:
		volume = 0.0
	settings["master_volume"] = volume
	AudioServer.set_bus_volume_db(0, linear_to_db(max(0.001, volume)))
	settings_changed.emit(settings.duplicate(true))
	show_settings()

func _on_off(value: bool) -> String:
	return "On" if value else "Off"
