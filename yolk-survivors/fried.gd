extends Sprite2D
class_name FriedUnit



func _on_timer_timeout() -> void:
	queue_free()
