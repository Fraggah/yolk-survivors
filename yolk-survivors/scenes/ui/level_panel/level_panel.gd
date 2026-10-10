extends Panel
class_name LevelPanel

const DIFFICULTY_RULES = preload("res://resources/difficulty_rules.gd")

signal on_level_selection_exited

@export var buttons: Array[Button] = []

func _ready() -> void:
	for index in buttons.size():
		buttons[index].tooltip_text = DIFFICULTY_RULES.description(index)
		buttons[index].mouse_entered.connect(_show_difficulty.bind(index))
		buttons[index].focus_entered.connect(_show_difficulty.bind(index))
	UITheme.palette_changed.connect(_refresh_locks)
	call_deferred("_refresh_locks")
	enable_buttons(Global.level_reached)
	_show_difficulty(0)

func _show_difficulty(level: int) -> void:
	var description := DIFFICULTY_RULES.description(level)
	if level > DIFFICULTY_RULES.normalize_level(Global.level_reached):
		description = "LOCKED — Win a run on difficulty %d to unlock." % (level - 1)
	%DifficultyDescription.text = description

func enable_buttons(level: int) -> void:
	for i in buttons.size():
		var button := buttons[i]
		var locked := i > DIFFICULTY_RULES.normalize_level(level)
		UITheme._clear_button_focus(button)
		button.disabled = false # Inspectable with mouse, touch or controller.
		button.set_meta("difficulty_locked", locked)
		for state in ["normal", "hover", "pressed", "hover_pressed"]:
			if locked:
				var edge = UITheme.palette.outline if state == "normal" else UITheme.palette.focus
				var width: int = UITheme.palette.border_width if state == "normal" else UITheme.palette.focus_width
				button.add_theme_stylebox_override(state, UITheme.box(UITheme.palette.locked_surface, edge, -1, width))
			else:
				button.remove_theme_stylebox_override(state)
		button.get_node("Label").add_theme_color_override("font_color", UITheme.palette.hud_text if locked else UITheme.palette.text)
		button.tooltip_text = "Win a run on difficulty %d to unlock." % (i - 1) if locked else DIFFICULTY_RULES.description(i)
		UITheme._bind_button_focus(button)

func _refresh_locks() -> void:
	enable_buttons(Global.level_reached)

func _select_difficulty(level: int) -> void:
	_show_difficulty(level)
	if level > DIFFICULTY_RULES.normalize_level(Global.level_reached): return
	Global.on_level_selected.emit(level)

func _on_level_0_button_pressed() -> void:
	_select_difficulty(0)


func _on_level_1_button_pressed() -> void:
	_select_difficulty(1)


func _on_level_2_button_pressed() -> void:
	_select_difficulty(2)


func _on_level_3_button_pressed() -> void:
	_select_difficulty(3)


func _on_level_4_button_pressed() -> void:
	_select_difficulty(4)


func _on_level_5_button_pressed() -> void:
	_select_difficulty(5)


func _on_custom_button_pressed() -> void:
	on_level_selection_exited.emit()
