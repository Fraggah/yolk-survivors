extends "res://scenes/ui/shop/chocolate_coin_reveal.gd"
## Reuses the coin modal's panel, input barrier and particle drawing.
var yolk: TextureRect
var flash: ColorRect
var source_item: ItemBase
var improved_item: ItemBase
var improvement := 0.0
var upgrade_queue: Array[Dictionary] = []
var perfect_glints: Node2D

func _ready() -> void:
	super._ready()
	name = "GoldenYolkReveal"
	remove_from_group("coin_balance_reveal")
	yolk = TextureRect.new()
	yolk.texture = load("res://assets/sprites/Items/Catalogue/078.png")
	yolk.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	yolk.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	yolk.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	yolk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(yolk)
	flash = ColorRect.new()
	flash.color = Color.WHITE
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(flash)
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.hide()

var impact_announced := false

func play_upgrade(original: ItemBase, replacement: ItemBase, outcome: float) -> void:
	if visible:
		upgrade_queue.append({"original":original,"replacement":replacement,"outcome":outcome})
		return
	SoundManager.play_event("golden_anticipation")
	impact_announced=false
	source_item = original
	improved_item = replacement
	improvement = outcome
	elapsed = 0.0
	revealed = false
	particles.clear()
	if is_instance_valid(perfect_glints):
		perfect_glints.free()
		perfect_glints = null
	coin.texture = original.item_icon
	coin.flip_h = false
	coin.material = load("res://effects/golden_visual.gd").material_for(original) if original.golden_multiplier > 1.0 else null
	coin.show()
	yolk.show()
	flash.hide()
	result_label.hide()
	continue_button.hide()
	card_style.bg_color = Color("342b25")
	card_style.border_color = Color("b88a46")
	veil.color = Color(0.035,0.025,0.02,0.76)
	_layout()
	coin.scale = Vector2.ZERO
	yolk.scale = Vector2.ZERO
	show()
	set_process(true)

func _process(delta: float) -> void:
	if not visible: return
	elapsed += delta
	if elapsed>=1.12 and not impact_announced:
		impact_announced=true
		SoundManager.play_event("golden_impact")
	_layout()
	yolk.size = coin.size
	yolk.pivot_offset = yolk.size * 0.5
	var center := coin.position
	var distance := minf(280, card.size.x * 0.25)
	veil.modulate.a = minf(1, elapsed / 0.16)
	card.modulate.a = minf(1, elapsed / 0.16)
	flash.visible = elapsed >= 1.12 and elapsed < 1.17
	if elapsed < 0.4:
		var appear := 1.0 - pow(1.0 - clampf(elapsed / 0.3, 0, 1), 3)
		coin.position = center - Vector2(distance,0)
		yolk.position = center + Vector2(distance,0)
		coin.scale = Vector2.ONE * appear * source_item.icon_scale
		yolk.scale = Vector2.ONE * appear
	elif elapsed < 0.9:
		var anticipation := 1.0 - pow(1.0 - (elapsed - 0.4) / 0.5, 3)
		var stretch := Vector2.ONE.lerp(Vector2(0.82,1.15), anticipation)
		coin.position = center - Vector2(distance + 90 * anticipation,0)
		yolk.position = center + Vector2(distance + 90 * anticipation,0)
		coin.scale = stretch * source_item.icon_scale
		yolk.scale = stretch
	elif elapsed < 1.12:
		var strike := pow((elapsed - 0.9) / 0.22, 3)
		var stretch := Vector2(0.82,1.15).lerp(Vector2(1.55,0.65), strike)
		coin.position = center - Vector2((distance + 90) * (1 - strike),0)
		yolk.position = center + Vector2((distance + 90) * (1 - strike),0)
		coin.scale = stretch * source_item.icon_scale
		yolk.scale = stretch
	elif elapsed < 1.3:
		coin.hide()
		yolk.hide()
	else:
		if not revealed: _reveal_upgrade()
		var appear := 1.0 - pow(1.0 - clampf((elapsed - 1.3) / 0.24, 0, 1), 3)
		coin.position = center
		coin.scale = Vector2.ONE * 1.3 * source_item.icon_scale * appear * (1 + 0.02 * sin(elapsed * 4.3))
		result_label.modulate.a = appear
	if elapsed >= 2.8 and not continue_button.visible:
		continue_button.show()
		if MenuInput.gamepad_active: continue_button.grab_focus()
	for particle in particles:
		particle.age += delta
		particle.point += particle.velocity * delta
		particle.velocity *= exp(-1.8 * delta)
		if not particle.spark: particle.velocity.y += 290.0 * delta
		particle.angle += particle.spin * delta
	particles = particles.filter(func(particle): return particle.age < particle.life)
	particle_layer.queue_redraw()

func _reveal_upgrade() -> void:
	revealed = true
	var success := improved_item != null
	SoundManager.play_event("golden_reveal")
	SoundManager.play_event("golden_success" if success else "golden_broken")
	card_style.bg_color = Color("504025") if success else Color("512a2b")
	card_style.border_color = Color("d6a63c") if success else Color("a7564c")
	veil.color = Color(0.09, 0.06, 0.015, 0.76) if success else Color(0.12, 0.025, 0.025, 0.79)
	yolk.hide()
	result_label.show()
	if improved_item:
		coin.texture = improved_item.item_icon
		coin.material = load("res://effects/golden_visual.gd").material_for(improved_item)
		coin.show()
		result_label.text = "+%d%%" % roundi(improvement * 100)
		result_label.add_theme_color_override("font_color", Color("ffd344"))
		if improved_item.golden_perfect:
			perfect_glints = load("res://effects/golden_sparkles.gd").new()
			perfect_glints.position = coin.size * 0.5
			perfect_glints.radius = 110
			coin.add_child(perfect_glints)
		_celebrate()
	else:
		coin.hide()
		result_label.text = "ITEM BROKEN"
		result_label.add_theme_color_override("font_color", Color("ee6960"))
		result_label.position.y = card.size.y * 0.5 - 36

func _layout() -> void:
	super._layout()
	if revealed and not improved_item: result_label.position.y = card.size.y * 0.5 - 36

func close() -> void:
	if elapsed < 2.8: return
	hide()
	set_process(false)
	particles.clear()
	particle_layer.queue_redraw()
	if not upgrade_queue.is_empty():
		var next: Dictionary = upgrade_queue.pop_front()
		play_upgrade(next.original, next.replacement, next.outcome)
	else: finished.emit()
