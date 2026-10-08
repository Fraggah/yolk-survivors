extends Sprite2D
class_name FriedUnit



func _on_timer_timeout() -> void:
	queue_free()

func _ready() -> void:
	scale *= Global.GAME_ENTITY_SCALE
