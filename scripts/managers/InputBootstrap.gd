extends Node
class_name InputBootstrap

## Ensures keyboard/mouse and controller-compatible Input Map actions exist at runtime.

func _ready():
	ensure_default_actions()

func ensure_default_actions():
	_add_key_action("move_forward", [KEY_W, KEY_UP])
	_add_key_action("move_back", [KEY_S, KEY_DOWN])
	_add_key_action("move_backward", [KEY_S, KEY_DOWN])
	_add_key_action("move_left", [KEY_A, KEY_LEFT])
	_add_key_action("move_right", [KEY_D, KEY_RIGHT])
	_add_key_action("sprint", [KEY_SHIFT])
	_add_key_action("interact", [KEY_E])
	_add_key_action("pickup_drop", [KEY_Q])
	_add_key_action("use_item", [MOUSE_BUTTON_LEFT])
	_add_key_action("throw_item", [MOUSE_BUTTON_RIGHT])
	_add_key_action("throw", [MOUSE_BUTTON_RIGHT])
	_add_key_action("jump", [KEY_SPACE])
	_add_key_action("pause", [KEY_ESCAPE])
	_add_key_action("open_phone", [KEY_TAB, KEY_P])
	_add_key_action("open_order_screen", [KEY_O])
	_add_key_action("open_manager_clipboard", [KEY_M])
	_add_key_action("toggle_debug_overlay", [KEY_F3])
	_add_key_action("toggle_perspective", [KEY_V])
	_add_key_action("toggle_view", [KEY_V])
	_add_key_action("confirm", [KEY_ENTER])
	_add_key_action("cancel", [KEY_ESCAPE])
	_add_joy_motion("move_left", JOY_AXIS_LEFT_X, -1.0)
	_add_joy_motion("move_right", JOY_AXIS_LEFT_X, 1.0)
	_add_joy_motion("move_forward", JOY_AXIS_LEFT_Y, -1.0)
	_add_joy_motion("move_back", JOY_AXIS_LEFT_Y, 1.0)
	_add_joy_motion("move_backward", JOY_AXIS_LEFT_Y, 1.0)
	_add_joy_motion("look_left", JOY_AXIS_RIGHT_X, -1.0)
	_add_joy_motion("look_right", JOY_AXIS_RIGHT_X, 1.0)
	_add_joy_motion("look_up", JOY_AXIS_RIGHT_Y, -1.0)
	_add_joy_motion("look_down", JOY_AXIS_RIGHT_Y, 1.0)
	_add_joy_button("interact", JOY_BUTTON_A)
	_add_joy_button("pickup_drop", JOY_BUTTON_X)
	_add_joy_button("use_item", JOY_BUTTON_RIGHT_SHOULDER)
	_add_joy_button("throw_item", JOY_BUTTON_LEFT_SHOULDER)
	_add_joy_button("sprint", JOY_BUTTON_LEFT_STICK)
	_add_joy_button("toggle_perspective", JOY_BUTTON_Y)
	_add_joy_button("pause", JOY_BUTTON_START)
	_add_joy_button("open_phone", JOY_BUTTON_BACK)

func _ensure_action(action_name: String):
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name, 0.2)

func _add_key_action(action_name: String, keycodes: Array):
	_ensure_action(action_name)
	for code in keycodes:
		var ev
		if code == MOUSE_BUTTON_LEFT or code == MOUSE_BUTTON_RIGHT or code == MOUSE_BUTTON_MIDDLE:
			ev = InputEventMouseButton.new()
			ev.button_index = code
		else:
			ev = InputEventKey.new()
			ev.keycode = code
		_add_event_if_missing(action_name, ev)

func _add_joy_button(action_name: String, button_index: int):
	_ensure_action(action_name)
	var ev = InputEventJoypadButton.new()
	ev.button_index = button_index
	_add_event_if_missing(action_name, ev)

func _add_joy_motion(action_name: String, axis: int, value: float):
	_ensure_action(action_name)
	var ev = InputEventJoypadMotion.new()
	ev.axis = axis
	ev.axis_value = value
	_add_event_if_missing(action_name, ev)

func _add_event_if_missing(action_name: String, new_event: InputEvent):
	for existing in InputMap.action_get_events(action_name):
		if existing.as_text() == new_event.as_text():
			return
	InputMap.action_add_event(action_name, new_event)
