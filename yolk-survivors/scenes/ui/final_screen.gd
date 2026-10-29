extends Control
signal replay_requested
func _ready() -> void:
	$Panel/FinalButton.pressed.connect(func(): replay_requested.emit())
	$Defeat/Replay.pressed.connect(func(): replay_requested.emit())
func set_defeat(value: bool) -> void:
	$Panel.visible=not value
	$Defeat.visible=value
