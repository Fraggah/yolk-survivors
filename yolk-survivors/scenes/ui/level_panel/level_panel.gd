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
	enable_buttons(Global.level_reached)
	_show_difficulty(0)

func _show_difficulty(level: int) -> void:
	%DifficultyDescription.text = DIFFICULTY_RULES.description(level)

func enable_buttons(level: int) -> void:
	for i in buttons.size():
		buttons[i].disabled = i > DIFFICULTY_RULES.normalize_level(level)

func _on_level_0_button_pressed() -> void:
	Global.on_level_selected.emit(0)


func _on_level_1_button_pressed() -> void:
	Global.on_level_selected.emit(1)


func _on_level_2_button_pressed() -> void:
	Global.on_level_selected.emit(2)


func _on_level_3_button_pressed() -> void:
	Global.on_level_selected.emit(3)


func _on_level_4_button_pressed() -> void:
	Global.on_level_selected.emit(4)


func _on_level_5_button_pressed() -> void:
	Global.on_level_selected.emit(5)


func _on_custom_button_pressed() -> void:
	on_level_selection_exited.emit()
