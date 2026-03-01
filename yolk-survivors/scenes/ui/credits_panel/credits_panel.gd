extends Panel
class_name CreditsPanel

signal on_credits_exited

func _on_custom_button_pressed() -> void:
	on_credits_exited.emit()
