extends RefCounted
class_name SlotSelectionStyle

static func darkened(style: StyleBoxFlat, amount: float = 0.25) -> StyleBoxFlat:
	var result := style.duplicate() as StyleBoxFlat
	result.bg_color = style.bg_color.darkened(amount)
	return result

static func apply(button: Button, style: StyleBoxFlat) -> void:
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", darkened(style, 0.08))
	button.add_theme_stylebox_override("pressed", darkened(style))
	button.add_theme_stylebox_override("hover_pressed", darkened(style, 0.3))
