extends RefCounted

static func apply(control: Control, tier: int, compact: bool = false) -> void:
	var band := control.get_node_or_null("RarityMarker") as Panel
	if not band:
		band=load("res://scenes/ui/rarity_compact.tscn" if compact else "res://scenes/ui/rarity_band.tscn").instantiate()
		control.add_child(band)
	var style := band.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	style.bg_color = UITheme.palette.rarity(tier)
	if compact: style.bg_color=Color.TRANSPARENT
	band.add_theme_stylebox_override("panel", style)
	var label := band.get_node("Text") as Label
	label.text = ["I", "II", "III", "IV"][clampi(tier, 0, 3)] if compact else ["COMMON", "RARE", "EPIC", "LEGENDARY"][clampi(tier, 0, 3)]
	label.add_theme_color_override("font_color", UITheme.palette.rarity(tier) if compact else UITheme.palette.hud_text)
