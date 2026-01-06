extends Camera2D

func _process(delta: float) -> void:
	if is_instance_valid(Global.player):
		global_position = Global.player.global_position
