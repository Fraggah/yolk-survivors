extends Panel
class_name StartPanel

signal on_play_pressed
signal on_options_pressed
signal on_credits_pressed
signal on_exit_pressed

var debug_status: Label

func _ready() -> void:
	if not OS.is_debug_build(): return
	var tools := VBoxContainer.new()
	tools.name = "DebugProgressTools"
	add_child(tools)
	tools.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	tools.offset_left = -390
	tools.offset_right = -25
	tools.offset_top = -185
	tools.offset_bottom = -25
	for action in ["Resetear progreso", "Desbloquear todo"]:
		var button := Button.new()
		button.text = "TEST: " + action
		button.custom_minimum_size = Vector2(365,48)
		button.add_theme_font_size_override("font_size",22)
		tools.add_child(button)
		button.pressed.connect(_debug_progress_action.bind(action == "Resetear progreso"))
	debug_status = Label.new()
	debug_status.add_theme_font_size_override("font_size",18)
	tools.add_child(debug_status)

func _debug_progress_action(reset: bool) -> void:
	var saved := Progression.debug_reset_progress() if reset else Progression.debug_unlock_all()
	debug_status.text = ("Progreso reseteado" if reset else "Todo desbloqueado") if saved else "No se pudo guardar el cambio"


func _on_play_button_pressed() -> void:
	on_play_pressed.emit()


func _on_options_button_pressed() -> void:
	on_options_pressed.emit()


func _on_credits_button_pressed() -> void:
	on_credits_pressed.emit()


func _on_exit_button_pressed() -> void:
	on_exit_pressed.emit()
