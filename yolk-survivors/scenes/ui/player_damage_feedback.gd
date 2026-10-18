extends CanvasLayer
## Screen-space feedback remains independent of camera movement and gameplay pause.
signal defeat_finished
@export var impact_duration := 1.1
@export var center_duration := 0.85
@export var darkness := 0.72
var vignette: ColorRect
var dim: ColorRect
var corpse: Sprite2D
var particles: CPUParticles2D
var health_ratio := 1.0
var target_strength := 0.0
var strength := 0.0
var dying := false
var finished := false
var elapsed := 0.0
var death_origin := Vector2.ZERO
var start_size := 90.0

func _ready() -> void:
	layer = 2
	process_mode = Node.PROCESS_MODE_ALWAYS
	vignette = ColorRect.new()
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Separate canvas below GameUI; defeat presentation keeps its higher layer.
	var vignette_layer := CanvasLayer.new()
	vignette_layer.layer = 0
	add_child(vignette_layer)
	vignette_layer.add_child(vignette)
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var material := ShaderMaterial.new()
	material.shader = preload("res://scenes/ui/damage_vignette.gdshader")
	vignette.material = material
	dim = ColorRect.new()
	dim.color = Color(0.06, 0.04, 0.03, 0)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	corpse = Sprite2D.new()
	corpse.texture = load("res://assets/sprites/player_fried_corpse.png")
	corpse.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	corpse.hide()
	add_child(corpse)
	particles = CPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.amount = 22
	particles.lifetime = 0.65
	particles.explosiveness = 1.0
	particles.direction = Vector2.UP
	particles.spread = 180.0
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 250.0
	particles.gravity = Vector2(0, 300)
	particles.scale_amount_min = 4.0
	particles.scale_amount_max = 9.0
	particles.color = Color("fff3d4")
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color("fff3d4"), Color("eeb851"), Color(0.93,0.65,0.3,0)])
	particles.color_ramp = gradient
	var dot := GradientTexture2D.new()
	dot.width = 8
	dot.height = 8
	dot.fill = GradientTexture2D.FILL_RADIAL
	dot.fill_from = Vector2(0.5,0.5)
	dot.fill_to = Vector2(1,0.5)
	var dot_gradient := Gradient.new()
	dot_gradient.colors = PackedColorArray([Color.WHITE,Color(1,1,1,0)])
	dot.gradient = dot_gradient
	particles.texture = dot
	add_child(particles)

func update_health(current: float, maximum: float) -> void:
	health_ratio = clampf(current / maxf(1.0, maximum), 0.0, 1.0)
	target_strength = strength_for_health(health_ratio)

func strength_for_health(ratio: float) -> float:
	if ratio >= 0.5: return 0.0
	if ratio >= 0.35: return 0.16
	if ratio >= 0.20: return 0.28
	if ratio >= 0.10: return 0.42
	return 0.58

func begin_defeat(screen_position: Vector2, display_size: float) -> void:
	if dying or finished: return
	dying = true
	elapsed = 0.0
	death_origin = screen_position
	start_size = maxf(60, display_size)
	corpse.position = death_origin
	# Death can happen after this layer processed: initialize before the first draw.
	corpse.scale = Vector2.ONE * start_size / maxf(1.0, corpse.texture.get_width())
	corpse.show()
	particles.position = death_origin
	particles.restart()
	particles.emitting = true

func _process(delta: float) -> void:
	var real_delta := delta / maxf(0.01, Engine.time_scale)
	if dying:
		elapsed += real_delta
		strength = move_toward(strength, 0.0, real_delta * 2.0)
		dim.color.a = darkness * minf(1, elapsed / 0.35)
		var travel := clampf((elapsed - impact_duration) / maxf(0.01,center_duration), 0, 1)
		var eased := smoothstep(0, 1, travel)
		corpse.position = death_origin.lerp(get_viewport().get_visible_rect().size * 0.5, eased)
		var pop := 1.0 + 0.18 * sin(minf(1,elapsed / 0.22) * PI)
		var pixels := lerpf(start_size, 180.0, eased) * pop
		corpse.scale = Vector2.ONE * pixels / corpse.texture.get_width()
		if travel >= 1:
			dying = false
			finished = true
			defeat_finished.emit()
	elif not finished:
		var active := is_instance_valid(Global.player) and not Global.game_paused
		var desired := target_strength if active else 0.0
		strength = move_toward(strength, desired, real_delta * 0.8)
	vignette.material.set_shader_parameter("strength", strength)

func reset() -> void:
	dying = false
	finished = false
	elapsed = 0.0
	health_ratio = 1.0
	strength = 0.0
	target_strength = 0.0
	dim.color.a = 0.0
	corpse.hide()
	particles.emitting = false
	vignette.material.set_shader_parameter("strength",0.0)
