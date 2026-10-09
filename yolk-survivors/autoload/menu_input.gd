extends Node

const FIRST_REPEAT_DELAY := 0.35
const REPEAT_INTERVAL := 0.12
var menus: Array[Control] = []
var active_menu: Control
var held_direction := Vector2.ZERO
var repeat_left := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
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
			child.focus_mode = Control.FOCUS_ALL
			if not child is BaseButton or not child.disabled: result.append(child)
		_collect_controls(child, result)

func _controls(menu: Control) -> Array[Control]:
	var result: Array[Control] = []
	if is_instance_valid(menu): _collect_controls(menu, result)
	return result

func _initial_focus(controls: Array[Control]) -> void:
	if controls.is_empty(): return
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
	if not menu: return
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
	if best: best.grab_focus()

func _input(event: InputEvent) -> void:
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
