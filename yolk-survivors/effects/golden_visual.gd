extends RefCounted

static func material_for(item: ItemBase, overlay := false) -> ShaderMaterial:
	var effect := ShaderMaterial.new()
	effect.shader = load("res://effects/golden_item.gdshader")
	effect.set_shader_parameter("strength", clampf(0.2 + (item.golden_multiplier - 1.0) * 0.65, 0.2, 0.95))
	effect.set_shader_parameter("perfect", item.golden_perfect)
	effect.set_shader_parameter("overlay", overlay)
	return effect

static func apply_weapon(weapon: Weapon) -> void:
	var sprite := weapon.sprite_2d
	for child in sprite.get_children():
		if child.name in ["GoldenOverlay", "GoldenSparkles"]:
			sprite.remove_child(child)
			child.queue_free()
	if weapon.data.golden_multiplier <= 1.0: return
	var overlay := Sprite2D.new()
	overlay.name = "GoldenOverlay"
	overlay.texture = sprite.texture
	overlay.hframes = sprite.hframes
	overlay.vframes = sprite.vframes
	overlay.frame = sprite.frame
	overlay.offset = sprite.offset
	overlay.centered = sprite.centered
	overlay.flip_h = sprite.flip_h
	overlay.flip_v = sprite.flip_v
	overlay.region_enabled = sprite.region_enabled
	overlay.region_rect = sprite.region_rect
	overlay.material = material_for(weapon.data, true)
	sprite.add_child(overlay)
	if weapon.data.golden_perfect:
		var stars = load("res://effects/golden_sparkles.gd").new()
		stars.name = "GoldenSparkles"
		stars.radius = minf(sprite.get_rect().size.x, sprite.get_rect().size.y) * 0.6
		sprite.add_child(stars)
