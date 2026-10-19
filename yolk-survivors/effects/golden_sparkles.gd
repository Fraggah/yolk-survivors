extends Node2D
## Four quiet orbiting star glints reserved for a perfect enhancement.
var radius := 40.0
var elapsed := 0.0

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	for index in 4:
		var phase := elapsed * 0.7 + index * TAU / 4.0
		var point := Vector2(cos(phase), sin(phase) * 0.65) * radius
		var length := 2.0 + 2.0 * pow(0.5 + 0.5 * sin(elapsed * 3.0 + index * 1.8), 3.0)
		var points := PackedVector2Array([point + Vector2(0, -length), point + Vector2(1, -1), point + Vector2(length, 0), point + Vector2(1, 1), point + Vector2(0, length), point + Vector2(-1, 1), point + Vector2(-length, 0), point + Vector2(-1, -1)])
		draw_colored_polygon(points, Color(1.0, 0.86, 0.4, 0.85))
