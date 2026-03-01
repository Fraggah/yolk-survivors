extends Panel
class_name StartPanel

signal on_play_pressed
signal on_options_pressed
signal on_credits_pressed


func _on_play_button_pressed() -> void:
	on_play_pressed.emit()


func _on_options_button_pressed() -> void:
	on_options_pressed.emit()


func _on_credits_button_pressed() -> void:
	on_credits_pressed.emit()
