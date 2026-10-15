extends StageAreaEffect

var burst_duration := 0.05
var exploded := false
var dome: Sprite2D
var splash: Sprite2D
var sprite_scale := 1.0
var red_phase_start := 0.75
var explosion_elapsed := 0.0

func _ready() -> void:
	super._ready()
	dome = Sprite2D.new()
	dome.texture = preload("res://assets/sprites/arena/oil_bubble.png")
	add_child(dome)
	splash = Sprite2D.new()
	splash.texture = preload("res://assets/sprites/arena/oil_splash.png")
	add_child(splash)
	# Asset padding leaves about 90% occupied width; reserve the full burst radius.
	sprite_scale = radius * 2.0 / (dome.texture.get_width() * 0.90 * 1.1)
	dome.position.y = -radius * 0.20
	splash.position.y = -radius * 0.20
	dome.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	splash.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var oil_material := ShaderMaterial.new()
	oil_material.shader = preload("res://shaders/oil_translucency.gdshader")
	dome.material = oil_material
	splash.material = oil_material
	update_visuals()

func _process(delta: float) -> void:
	if not running(): return
	elapsed += delta
	if not exploded:
		var player_near := is_instance_valid(Global.player) and contains_point(Global.player.global_position)
		if elapsed >= warning_duration or (is_red() and player_near): explode()
	else:
		explosion_elapsed += delta
		if explosion_elapsed >= burst_duration: queue_free()
	update_visuals()

func is_red() -> bool:
	return not exploded and elapsed >= warning_duration * red_phase_start

func explode() -> void:
	if exploded or not running(): return
	exploded = true
	SoundManager.play_sound(SoundManager.Sound.BUBBLE_EXPLOSION)
	explosion_elapsed = 0.0
	damage_units()

func update_visuals() -> void:
	dome.visible = not exploded
	splash.visible = exploded
	if not exploded:
		dome.modulate = Color("f05b53") if is_red() else Color.WHITE
		var progress := clampf(elapsed / warning_duration, 0, 1)
		var growth := lerpf(0.1, 1.0, 1.0 - pow(1.0 - minf(progress / 0.75, 1), 2))
		var vibration := Vector2.ONE
		if progress > 0.75:
			var charge := (progress - 0.75) / 0.25
			growth = lerpf(1.0, 1.1, charge)
			var wobble := sin(elapsed * 65.0) * 0.035 * charge
			vibration = Vector2(1.0 + wobble, 1.0 - wobble)
		dome.scale = Vector2.ONE * sprite_scale * growth * vibration
	else:
		var progress := clampf(explosion_elapsed / burst_duration, 0, 1)
		splash.scale = Vector2.ONE * sprite_scale * lerpf(0.8, 1.1, progress)
		splash.modulate.a = 1.0 - progress
