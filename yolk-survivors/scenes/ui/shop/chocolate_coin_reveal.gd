extends Control
## Sprite-based reveal; gameplay rolls exactly once before presentation starts.
signal finished
const SHEET := "res://assets/sprites/UI/chocolate_coin/coin-turn.png"
const REGIONS := [Rect2(52,81,526,533), Rect2(699,77,310,536), Rect2(1265,77,123,537), Rect2(1592,80,525,534)]
const TURN := [0, 1, 2, 4, 3, 4, 2, 1]
var frames: Array[Texture2D] = []
var coin: TextureRect
var veil: ColorRect
var card_style: StyleBoxFlat
var card: Panel
var continue_button: Button
var result_label: Label
var particle_layer: Node2D
var elapsed := 0.0
var won := false
var balance := 0
var displayed_balance := 0
var revealed := false
var spin_announced := false
var particles: Array[Dictionary] = []
var pending_results: Array[Dictionary] = []

func _ready() -> void:
	name = "ChocolateCoinReveal"
	add_to_group("coin_balance_reveal")
	z_index = 200
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	var sheet := load(SHEET) as Texture2D
	for region in REGIONS:
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = region
		atlas.filter_clip = true
		frames.append(atlas)
	veil = ColorRect.new()
	veil.color = Color(0.035, 0.025, 0.02, 0.76)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card = Panel.new()
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_style = UITheme.box(Color("342b25"), Color("b88a46"), 24, 2)
	card.add_theme_stylebox_override("panel", card_style)
	add_child(card)
	coin = TextureRect.new()
	coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coin.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	card.add_child(coin)
	result_label = Label.new()
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.add_theme_color_override("font_color", Color("fff1ce"))
	result_label.add_theme_font_size_override("font_size", 54)
	card.add_child(result_label)
	continue_button = Button.new()
	continue_button.text = "CONTINUE"
	continue_button.add_theme_font_size_override("font_size", 30)
	continue_button.pressed.connect(close)
	card.add_child(continue_button)
	particle_layer = Node2D.new()
	add_child(particle_layer)
	particle_layer.draw.connect(_draw_particles)
	hide()
	set_process(false)

func play(success: bool, final_balance: int, starting_balance: int = -1) -> void:
	if visible:
		pending_results.append({"success":success, "balance":final_balance, "starting_balance":starting_balance})
		return
	won = success
	balance = final_balance
	displayed_balance = Global.coins if starting_balance < 0 else starting_balance
	elapsed = 0.0
	revealed = false
	spin_announced = false
	particles.clear()
	card_style.bg_color = Color("342b25")
	card_style.border_color = Color("b88a46")
	veil.color = Color(0.035, 0.025, 0.02, 0.76)
	continue_button.hide()
	result_label.hide()
	_set_frame(0)
	coin.scale = Vector2.ZERO
	_layout()
	show()
	set_process(true)

func _layout() -> void:
	card.size = size * Vector2(0.82, 0.76)
	card.position = (size - card.size) * 0.5
	coin.size = Vector2(300, 300)
	coin.pivot_offset = coin.size * 0.5
	coin.position = card.size * 0.5 - coin.size * 0.5 - Vector2(0, 35)
	result_label.position = Vector2(0, card.size.y * 0.5 + 185)
	result_label.size = Vector2(card.size.x, 72)
	continue_button.size = Vector2(240, 52)
	continue_button.position = Vector2((card.size.x - 240) * 0.5, card.size.y - 78)

func _set_frame(index: int) -> void:
	coin.texture = frames[1 if index == 4 else index]
	coin.flip_h = index == 4

func _process(delta: float) -> void:
	if not is_visible_in_tree(): return
	elapsed += delta
	if elapsed>=0.7 and not spin_announced:
		spin_announced=true
		SoundManager.play_event("coin_spin")
	_layout()
	veil.modulate.a = minf(1, elapsed / 0.16)
	card.modulate.a = minf(1, elapsed / 0.16)
	if elapsed < 0.25:
		coin.scale = Vector2.ZERO
	elif elapsed < 0.48:
		coin.scale = Vector2.ONE * ease(clampf((elapsed - 0.25) / 0.23, 0, 1), 0.4)
	elif elapsed < 0.7:
		coin.scale = Vector2.ONE
	elif elapsed < 1.7:
		var spin_time := elapsed - 0.7
		# Integral of a ramp from 16 to 72 sprite frames per second.
		_set_frame(TURN[int(16.0 * spin_time + 28.0 * spin_time * spin_time) % TURN.size()])
		coin.scale = Vector2.ONE
	elif elapsed < 1.84:
		coin.scale = Vector2.ONE * pow(1.0 - (elapsed - 1.7) / 0.14, 2)
	else:
		_set_frame(0 if won else 3)
		var reveal := clampf((elapsed - 1.84) / 0.18, 0, 1)
		coin.scale = Vector2.ONE * 1.3 * (1.0 - pow(1.0 - reveal, 3))
		card_style.bg_color = Color("342b25").lerp(Color("504025") if won else Color("512a2b"), reveal)
		card_style.border_color = Color("b88a46").lerp(Color("d6a63c") if won else Color("a7564c"), reveal)
		veil.color = Color(0.035, 0.025, 0.02, 0.76).lerp(Color(0.09, 0.06, 0.015, 0.76) if won else Color(0.12, 0.025, 0.025, 0.79), reveal)
		if reveal >= 1.0 and not revealed:
			revealed = true
			SoundManager.play_event("coin_reveal")
			SoundManager.play_event("coin_win" if won else "coin_lose")
			displayed_balance = balance
			result_label.text = "X2" if won else "X0"
			result_label.add_theme_color_override("font_color", Color("ffd344") if won else Color("ee6960"))
			result_label.show()
			if won: _celebrate()
	# Keep the breathing motion through the spin, reveal and held result.
	coin.scale *= 1.0 + 0.025 * sin(elapsed * 4.3)
	if elapsed >= 2.8 and not continue_button.visible:
		continue_button.show()
		if MenuInput.gamepad_active: continue_button.grab_focus()
	for particle in particles:
		particle.age += delta
		particle.point += particle.velocity * delta
		particle.velocity.y += 290.0 * delta
		particle.angle += particle.spin * delta
	particles = particles.filter(func(particle): return particle.age < particle.life)
	particle_layer.queue_redraw()

func _celebrate() -> void:
	var colors := [Color("fff2cb"), Color("ffc536"), Color("ed9131"), Color("e9c388")]
	for index in 220:
		var left := index % 2 == 0
		var point := card.position + Vector2(8 if left else card.size.x - 8, card.size.y * randf_range(0.25, 0.75))
		var velocity := Vector2(randf_range(180, 520) * (1 if left else -1), randf_range(-330, -80))
		particles.append({"point":point, "velocity":velocity, "age":0.0, "life":randf_range(0.9, 1.6), "angle":randf()*TAU, "spin":randf_range(-10,10), "size":Vector2(randf_range(4,9),randf_range(2,6)), "color":colors[index % colors.size()], "spark":false})
	for index in 75:
		particles.append({"point":card.position + coin.position + coin.size*0.5, "velocity":Vector2.from_angle(randf()*TAU)*randf_range(70,260), "age":0.0, "life":randf_range(0.5,1.0), "angle":randf()*TAU, "spin":randf_range(-5,5), "size":Vector2.ONE*randf_range(2,6), "color":colors[index % colors.size()], "spark":true})

func _draw_particles() -> void:
	for particle in particles:
		var color: Color = particle.color
		color.a *= clampf((particle.life - particle.age) / 0.35, 0, 1)
		particle_layer.draw_set_transform(particle.point, particle.angle, particle.size)
		if particle.spark:
			particle_layer.draw_colored_polygon(PackedVector2Array([Vector2(0,-1.5),Vector2(0.4,-0.4),Vector2(1.5,0),Vector2(0.4,0.4),Vector2(0,1.5),Vector2(-0.4,0.4),Vector2(-1.5,0),Vector2(-0.4,-0.4)]), color)
		else: particle_layer.draw_rect(Rect2(-1,-1,2,2),color)
	particle_layer.draw_set_transform(Vector2.ZERO)

func close() -> void:
	if elapsed < 2.8: return
	hide()
	set_process(false)
	particles.clear()
	particle_layer.queue_redraw()
	if not pending_results.is_empty():
		var next: Dictionary = pending_results.pop_front()
		play(next.success, next.balance, next.starting_balance)
	else:
		finished.emit()
