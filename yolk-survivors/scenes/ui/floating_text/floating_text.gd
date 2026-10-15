extends Node2D
class_name FloatingText

@onready var label: Label = $Label

func setup_text(value: String, color: Color, duration: float = 1.3) -> void:
	label.text = value
	modulate = color
	scale = Vector2.ZERO
	
	rotation = deg_to_rad(randf_range(-10, 10))
	var random_scale := randf_range(.8, 1.6)
	
	var tween := create_tween()
	var timing := maxf(0.01, duration) / 1.3
	
	tween.parallel().tween_property(self, "scale", Vector2.ONE * random_scale, .4 * timing)
	tween.parallel().tween_property(self, "global_position", global_position + Vector2.UP * 15, .4 * timing)
	
	tween.tween_interval(.5 * timing)
	
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, .4 * timing)
	tween.parallel().tween_property(self, "modulate:a", .0, .4 * timing)
	
	await tween.finished
	queue_free()
