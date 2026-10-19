extends Control
## Geometric offer sticker; stays sharp at every UI scale.
var caption: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption = Label.new()
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.add_theme_font_override("font", UITheme.FONT)
	caption.add_theme_font_size_override("font_size", 28)
	caption.add_theme_color_override("font_color", Color("fff8e5"))
	caption.add_theme_color_override("font_outline_color", Color("9b330d"))
	caption.add_theme_constant_override("outline_size", 3)
	add_child(caption)
	caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
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
