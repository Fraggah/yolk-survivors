extends Node2D
## Short, harmless flare used exclusively by the pan hazard lifecycle.
var duration := 0.45
var elapsed := 0.0
var sparks: CPUParticles2D

func _ready() -> void:
	# Match the ground depth of the hazard during arrival and departure.
	z_index = 0
	sparks = CPUParticles2D.new()
	sparks.amount = 18
	sparks.lifetime = duration
	sparks.one_shot = true
	sparks.explosiveness = 0.85
	sparks.direction = Vector2.UP
	sparks.spread = 38
	sparks.initial_velocity_min = 70
	sparks.initial_velocity_max = 160
	sparks.gravity = Vector2(0, -80)
	sparks.scale_amount_min = 0.35
	sparks.scale_amount_max = 0.85
	var texture := GradientTexture2D.new()
	texture.width = 24
	texture.height = 24
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	var glow := Gradient.new()
	glow.colors = PackedColorArray([Color.WHITE, Color(1, 1, 1, 0)])
	texture.gradient = glow
	sparks.texture = texture
	var colors := Gradient.new()
	colors.offsets = PackedFloat32Array([0, 0.35, 1])
	colors.colors = PackedColorArray([Color("fff1b3"), Color("ffac39"), Color(0.95, 0.22, 0.05, 0)])
	sparks.color_ramp = colors
	add_child(sparks)

func _process(delta: float) -> void:
	sparks.speed_scale = 0.0 if Global.game_paused else 1.0
	if Global.game_paused: return
	elapsed += delta
	if elapsed >= duration: queue_free()
	queue_redraw()

func _draw() -> void:
	var progress := clampf(elapsed / maxf(0.05, duration), 0, 1)
	var strength := sin(progress * PI)
	var alpha := 1.0 - smoothstep(0.65, 1.0, progress)
	draw_circle(Vector2(0, -10), 55 * strength, Color(1.0, 0.48, 0.10, 0.18 * alpha))
	var points := PackedVector2Array([Vector2(-42, 6), Vector2(-53, -28), Vector2(-30, -75), Vector2(-27, -38), Vector2(0, -145), Vector2(14, -60), Vector2(35, -103), Vector2(48, -40), Vector2(35, 6)])
	for i in points.size(): points[i] *= maxf(0.08, strength)
	draw_colored_polygon(points, Color(0.98, 0.28, 0.06, alpha))
	for i in points.size(): points[i] *= Vector2(0.62, 0.72)
	draw_colored_polygon(points, Color(1.0, 0.70, 0.15, alpha))
	for i in points.size(): points[i] *= Vector2(0.52, 0.52)
	draw_colored_polygon(points, Color(1.0, 0.96, 0.72, alpha))
