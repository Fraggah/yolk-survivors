extends Panel
class_name PausePanel

signal on_return_pressed
signal on_exit_pressed

func _on_return_button_pressed() -> void:
	on_return_pressed.emit()

func _on_exit_button_pressed() -> void:
	on_exit_pressed.emit()
