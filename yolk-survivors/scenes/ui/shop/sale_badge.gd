@tool
extends Control
## Geometric offer sticker; stays sharp at every UI scale.
var caption: Label

func _ready() -> void:
	caption=$Caption
	resized.connect(queue_redraw)

func set_caption(value: String) -> void:
	caption.text = value
	queue_redraw()

func _draw() -> void:
	var points := PackedVector2Array()
	var center := size * 0.5
	for index in 32:
		var angle := TAU * index / 32.0 - PI * 0.5
		var radius := 1.0 if index % 2 == 0 else 0.76
		points.append(center + Vector2(cos(angle) * size.x * 0.5, sin(angle) * size.y * 0.5) * radius)
	var shadow := PackedVector2Array()
	for point in points: shadow.append(point + Vector2(0, 3))
	draw_colored_polygon(shadow, Color("ac3c10"))
	draw_colored_polygon(points, Color("f25a0b"))
	points.append(points[0])
	draw_polyline(points, Color("ce4708"), 1.5, true)
