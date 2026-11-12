extends Panel
class_name LevelPanel

var spawner: Spawner

signal on_level_selection_exited
signal on_stress_test_selected(population: int)
signal on_boss_test_selected

@export var buttons: Array[Button] = []
@export var display_wave_counts: PackedInt32Array

func _ready() -> void:
	Progression.progress_changed.connect(_refresh_locks)
	for index in buttons.size():
		buttons[index].mouse_entered.connect(_show_difficulty.bind(index))
		buttons[index].focus_entered.connect(_show_difficulty.bind(index))
	UITheme.palette_changed.connect(_refresh_locks)
	visibility_changed.connect(_refresh_locks)
	call_deferred("_refresh_locks")

func setup_difficulties(source: Spawner) -> void:
	spawner = source
	enable_buttons(Global.level_reached)
	_show_difficulty(0)

func _difficulty_description(level: int) -> String:
	if not spawner: return ""
	var count := display_wave_counts[level] if level < display_wave_counts.size() else -1
	return spawner.difficulty_data_for(level).description(count)

func _show_difficulty(level: int) -> void:
	var description := _difficulty_description(level)
	if level > Global.level_reached:
		description = "LOCKED — Win a run on difficulty %d to unlock." % (level - 1)
	%DifficultyDescription.text = description

func enable_buttons(level: int) -> void:
	for i in buttons.size():
		var button := buttons[i]
		var locked := i > level
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
		button.tooltip_text = "Win a run on difficulty %d to unlock." % (i - 1) if locked else _difficulty_description(i)
		UITheme._bind_button_focus(button)

func _refresh_locks() -> void:
	if not is_visible_in_tree(): return
	enable_buttons(Global.level_reached)

func _select_difficulty(level: int) -> void:
	_show_difficulty(level)
	if level > Global.level_reached: return
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

func _on_stress_test_button_pressed() -> void:
	on_stress_test_selected.emit(1000)

func _on_stress_500_button_pressed() -> void:
	on_stress_test_selected.emit(500)

func _on_boss_test_button_pressed() -> void:
	on_boss_test_selected.emit()
