extends StageAreaEffect

enum State { WARNING, HOT, COOLING }
var state := State.WARNING
var active_duration := 12.0
var cooling_duration := 1.2
var damage_interval := 0.75
var next_tick := 0.0
var distortion_enabled := true
var distortion_strength_pixels := 5.5
var distortion_vertical_pixels := 1.5
var distortion_height := 180.0
var distortion_speed := 1.0
var ground: ColorRect
var air: ColorRect
var shape_phase := 0.0
var breathing_offset := 0.0
var breathing_period := 2.5
var damage_core_ratio := 0.60

func _ready() -> void:
	super._ready()
	ground = make_visual(preload("res://shaders/hot_zone_ground.gdshader"))
	ground.position = -Vector2.ONE * radius
	ground.size = Vector2.ONE * radius * 2
	ground.material.set_shader_parameter("shape_phase", shape_phase)
	ground.material.set_shader_parameter("damage_core_ratio", damage_core_ratio)
	ground.material.set_shader_parameter("zone_radius", radius)
	var bounds := mechanic.area.movement_bounds
	ground.material.set_shader_parameter("arena_rect", Vector4(bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y))
	ground.material.set_shader_parameter("arena_corner", mechanic.area.corner_radius)
	if distortion_enabled:
		air = make_visual(preload("res://shaders/hot_zone_air.gdshader"))
		air.position = -Vector2(radius, radius + distortion_height)
		air.size = Vector2(radius * 2, radius * 2 + distortion_height)
		air.z_as_relative = false
		air.z_index = 5
		air.material.set_shader_parameter("strength_pixels", distortion_strength_pixels)
		air.material.set_shader_parameter("vertical_strength_pixels", distortion_vertical_pixels)
	update_visuals()

func make_visual(shader: Shader) -> ColorRect:
	var visual := ColorRect.new()
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader
	visual.material = shader_material
	add_child(visual)
	return visual

func _process(delta: float) -> void:
	if not running(): return
	elapsed += delta
	if elapsed < warning_duration:
		state = State.WARNING
	elif elapsed < warning_duration + active_duration:
		state = State.HOT
		next_tick -= delta
		if next_tick <= 0.0:
			damage_units()
			next_tick = maxf(0.05, damage_interval)
	else:
		state = State.COOLING
		if elapsed >= warning_duration + active_duration + cooling_duration: queue_free()
	update_visuals()

func update_visuals() -> void:
	var intensity := 1.0
	if state == State.WARNING:
		intensity = lerpf(0.15, 0.45, clampf(elapsed / warning_duration, 0, 1))
	elif state == State.COOLING:
		intensity = 1.0 - clampf((elapsed - warning_duration - active_duration) / cooling_duration, 0, 1)
	ground.material.set_shader_parameter("phase", elapsed)
	ground.material.set_shader_parameter("intensity", intensity)
	ground.material.set_shader_parameter("zone_center", global_position)
	var breath := 0.5 + 0.5 * sin(elapsed * TAU / breathing_period + breathing_offset)
	ground.material.set_shader_parameter("breath", breath)
	if is_instance_valid(air):
		air.visible = state != State.WARNING and intensity > 0
		air.material.set_shader_parameter("phase", elapsed * distortion_speed)
		air.material.set_shader_parameter("intensity", intensity * lerpf(0.65, 1.0, breath))

func shape_radius(angle: float) -> float:
	return 0.75 + 0.13 * sin(angle * 3.0 + shape_phase) + 0.08 * cos(angle * 2.0 - shape_phase * 0.7)

func contains_point(point: Vector2) -> bool:
	var local := (point - global_position) / radius
	return local.length() <= shape_radius(local.angle()) * damage_core_ratio
