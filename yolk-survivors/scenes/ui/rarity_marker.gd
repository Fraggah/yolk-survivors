extends RefCounted

static func apply(control: Control, tier: int, compact: bool = false) -> void:
	var band := control.get_node_or_null("RarityMarker") as Panel
	if not band:
		band = Panel.new()
		band.name = "RarityMarker"
		band.mouse_filter = Control.MOUSE_FILTER_IGNORE
		control.add_child(band)
		var label := Label.new()
		label.name = "Text"
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		band.add_child(label)
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var style := StyleBoxFlat.new()
	style.bg_color = UITheme.palette.rarity(tier)
	if compact:
		style.bg_color = Color.TRANSPARENT
		band.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
		band.offset_left = -34
		band.offset_top = -25
		band.offset_right = -3
		band.offset_bottom = -3
		style.set_corner_radius_all(5)
	else:
		band.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		band.offset_left = 3
		band.offset_right = -3
		band.offset_top = 3
		band.offset_bottom = 39
		style.corner_radius_top_left = maxi(0, UITheme.palette.radius - 3)
		style.corner_radius_top_right = style.corner_radius_top_left
	band.add_theme_stylebox_override("panel", style)
	var label := band.get_node("Text") as Label
	label.text = ["I", "II", "III", "IV"][clampi(tier, 0, 3)] if compact else ["COMMON", "RARE", "EPIC", "LEGENDARY"][clampi(tier, 0, 3)]
	label.add_theme_font_size_override("font_size", 18 if compact else 22)
	label.add_theme_color_override("font_color", UITheme.palette.rarity(tier) if compact else UITheme.palette.hud_text)
