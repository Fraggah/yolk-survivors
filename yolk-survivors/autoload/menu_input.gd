extends Node

const FIRST_REPEAT_DELAY := 0.35
const REPEAT_INTERVAL := 0.12
var menus: Array[Control] = []
var active_menu: Control
var held_direction := Vector2.ZERO
var repeat_left := 0.0
var styled_focus: Button
var connected_gamepads: Array[int] = []
var gamepad_active := false
var remembered_focus: Dictionary = {}

func _set_gamepad_active(value: bool) -> void:
	if value and connected_gamepads.is_empty(): return
	if gamepad_active == value: return
	var menu := _visible_menu()
	var focused := get_viewport().gui_get_focus_owner()
	if menu and focused and menu.is_ancestor_of(focused):
		remembered_focus[menu.get_instance_id()] = weakref(focused)
	gamepad_active = value
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN if value else Input.MOUSE_MODE_VISIBLE
	if focused: focused.release_focus()
	var controls := _controls(menu)
	if value: _initial_focus(controls)
	held_direction = Vector2.ZERO
	repeat_left = 0.0
	_sync_focus_visual()


func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if connected and not connected_gamepads.has(device):
		connected_gamepads.append(device)
	elif not connected:
		connected_gamepads.erase(device)
	if connected:
		_set_gamepad_active(true)
	elif connected_gamepads.is_empty():
		_set_gamepad_active(false)
	held_direction = Vector2.ZERO
	repeat_left = 0.0
	if connected_gamepads.is_empty():
		var focused_control := get_viewport().gui_get_focus_owner()
		if focused_control: focused_control.release_focus()
	_sync_focus_visual()


func _sync_focus_visual() -> void:
	var focused_control := get_viewport().gui_get_focus_owner()
	if is_instance_valid(styled_focus) and styled_focus != focused_control:
		UITheme._clear_button_focus(styled_focus)
	styled_focus = focused_control as Button
	if is_instance_valid(styled_focus):
		# Synchronize the real viewport focus, including stick/D-pad repeats and
		# focus assigned before deferred theme setup or after a menu rebuild.
		UITheme._bind_button_focus(styled_focus)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	connected_gamepads = Input.get_connected_joypads()
	gamepad_active = not connected_gamepads.is_empty()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN if gamepad_active else Input.MOUSE_MODE_VISIBLE
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	for binding in [["move_left", JOY_BUTTON_DPAD_LEFT], ["move_right", JOY_BUTTON_DPAD_RIGHT], ["move_up", JOY_BUTTON_DPAD_UP], ["move_down", JOY_BUTTON_DPAD_DOWN], ["dash", JOY_BUTTON_A], ["pause", JOY_BUTTON_START], ["ui_accept", JOY_BUTTON_A], ["ui_cancel", JOY_BUTTON_B], ["ui_left", JOY_BUTTON_DPAD_LEFT], ["ui_right", JOY_BUTTON_DPAD_RIGHT], ["ui_up", JOY_BUTTON_DPAD_UP], ["ui_down", JOY_BUTTON_DPAD_DOWN]]:
		var event := InputEventJoypadButton.new()
		event.button_index = binding[1]
		if not InputMap.action_has_event(binding[0], event): InputMap.action_add_event(binding[0], event)
	for binding in [["ui_left", JOY_AXIS_LEFT_X, -1.0], ["ui_right", JOY_AXIS_LEFT_X, 1.0], ["ui_up", JOY_AXIS_LEFT_Y, -1.0], ["ui_down", JOY_AXIS_LEFT_Y, 1.0]]:
		var event := InputEventJoypadMotion.new()
		event.axis = binding[1]
		event.axis_value = binding[2]
		if not InputMap.action_has_event(binding[0], event): InputMap.action_add_event(binding[0], event)
		InputMap.action_set_deadzone(binding[0], 0.45)

func register_menus(panels: Array[Control]) -> void:
	menus = panels
	active_menu = null

func _visible_menu() -> Control:
	for menu in menus:
		if is_instance_valid(menu) and menu.is_visible_in_tree(): return menu
	return null

func _collect_controls(node: Node, result: Array[Control]) -> void:
	for child in node.get_children():
		if child is Control and not child.is_visible_in_tree(): continue
		if child is BaseButton or child is Slider:
			child.focus_mode = Control.FOCUS_ALL if gamepad_active else Control.FOCUS_NONE
			if not child.has_meta("menu_mouse_filter"):
				child.set_meta("menu_mouse_filter", child.mouse_filter)
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE if gamepad_active else child.get_meta("menu_mouse_filter")
			if not child is BaseButton or not child.disabled: result.append(child)
		_collect_controls(child, result)

func _controls(menu: Control) -> Array[Control]:
	var result: Array[Control] = []
	if is_instance_valid(menu): _collect_controls(menu, result)
	return result

func _initial_focus(controls: Array[Control]) -> void:
	if controls.is_empty() or not gamepad_active: return
	var menu := _visible_menu()
	if menu and remembered_focus.has(menu.get_instance_id()):
		var previous = remembered_focus[menu.get_instance_id()].get_ref()
		if is_instance_valid(previous) and controls.has(previous):
			previous.grab_focus()
			return
	# Begin at content rather than Back/Continue on the selection screens.
	for control in controls:
		if control is BaseButton and control.toggle_mode and control.button_pressed:
			control.grab_focus()
			return
	for control in controls:
		if control.get_parent().name in ["PlayersContainer", "WeaponsContainer"]:
			control.grab_focus()
			return
	controls[0].grab_focus()

func _process(delta: float) -> void:
	var menu := _visible_menu()
	var controls := _controls(menu)
	var focused := get_viewport().gui_get_focus_owner()
	if menu != active_menu:
		active_menu = menu
		held_direction = Vector2.ZERO
		repeat_left = 0.0
		if focused: focused.release_focus()
		_initial_focus(controls)
	elif menu and not controls.has(focused):
		_initial_focus(controls)
	_sync_focus_visual()
	if not menu or not gamepad_active: return
	var direction := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	if direction.length() < 0.2:
		held_direction = Vector2.ZERO
		repeat_left = 0.0
		return
	direction = Vector2(signf(direction.x), 0.0) if absf(direction.x) > absf(direction.y) else Vector2(0.0, signf(direction.y))
	repeat_left -= delta
	if direction != held_direction:
		held_direction = direction
		repeat_left = FIRST_REPEAT_DELAY
		move_focus(direction)
	elif repeat_left <= 0.0:
		repeat_left = REPEAT_INTERVAL
		move_focus(direction)

func move_focus(direction: Vector2) -> void:
	if not gamepad_active: return
	var controls := _controls(_visible_menu())
	var focused := get_viewport().gui_get_focus_owner()
	if not controls.has(focused):
		_initial_focus(controls)
		return
	if focused is HSlider and direction.x != 0.0:
		focused.value += direction.x * focused.step
		return
	var origin := focused.get_global_rect().get_center()
	var best: Control
	var best_score := INF
	for candidate in controls:
		if candidate == focused: continue
		var offset := candidate.get_global_rect().get_center() - origin
		var forward := offset.dot(direction)
		if forward <= 1.0: continue
		var sideways := absf(offset.cross(direction))
		var score := offset.length() + sideways * 2.0
		if score < best_score:
			best = candidate
			best_score = score
	if best:
		best.grab_focus()
		_sync_focus_visual()

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.pressed:
		_set_gamepad_active(true)
	elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.45:
		_set_gamepad_active(true)
	elif event is InputEventMouseButton and event.pressed:
		_set_gamepad_active(false)
	elif event is InputEventMouseMotion and event.relative.length_squared() >= 4.0:
		_set_gamepad_active(false)
	var menu := _visible_menu()
	if not menu: return
	# Escape/Start belong to Arena's pause toggle; do not also resume through Back.
	if menu.name == "PausePanel" and event.is_action("pause"): return
	# Navigation is scoped to the active panel and repeats at a controlled rate.
	for action in ["ui_left", "ui_right", "ui_up", "ui_down"]:
		if event.is_action(action):
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("ui_cancel"):
		match menu.name:
			"SelectionPanel", "WeaponSelectionPanel": menu._on_custom_button_exit_pressed()
			"LevelPanel": menu._on_custom_button_pressed()
			"OptionsPanel", "CreditsPanel": menu._on_custom_button_pressed()
			"PausePanel": menu._on_return_button_pressed()
		get_viewport().set_input_as_handled()
