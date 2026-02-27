extends Panel
class_name LevelPanel

@export var buttons: Array[Button] = []

func enable_buttons(level: int) -> void:
	for i in buttons.size():
		buttons[i].disabled = i > level

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
