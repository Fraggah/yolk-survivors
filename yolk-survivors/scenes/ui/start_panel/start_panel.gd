extends Panel
class_name StartPanel

signal on_play_pressed
signal on_options_pressed
signal on_credits_pressed
signal on_exit_pressed

var debug_status: Label

func _ready() -> void:
	$DebugProgressTools.visible=OS.is_debug_build()
	debug_status=$DebugProgressTools/Label2
	$DebugProgressTools.get_child(0).pressed.connect(_debug_progress_action.bind(true))
	$DebugProgressTools.get_child(1).pressed.connect(_debug_progress_action.bind(false))

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
