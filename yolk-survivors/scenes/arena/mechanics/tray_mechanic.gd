extends StageMechanic

enum State { WAITING, TRACKING, LOCKED, FALLING, HOLDING, RETRACTING }
@export var initial_delay := 1.5
@export var minimum_interval := 2.0
@export var maximum_interval := 3.0
@export var tracking_duration := 2.5
@export var tracking_speed := 320.0
@export_range(0.1, 10.0) var tracking_smoothing := 1.8
@export var lock_duration := 1.0
@export var fall_duration := 0.046666667
@export var shadow_anticipation_duration := 0.50
@export_range(0.5, 1.0) var shadow_raised_scale := 0.80
@export var hold_duration := 0.18
@export var retract_duration := 0.5
@export var impact_size := Vector2(360, 450)
@export var fall_height := 140.0
@export var peek_height := 100.0
@export var push_speed := 750.0
@export var push_duration := 0.45
@export_range(0.0, 100.0) var player_damage_percent := 40.0
@export var shake_strength := 10.0
@export var shake_duration := 0.22
const TEXTURE = preload("res://assets/sprites/arena/giant_spatula.png")
const HEAD_PIXELS = Rect2(260, 84, 500, 620)
var state := State.WAITING
var next_event := 0.0
var phase_time := 0.0
var impact := Rect2()
var pushes: Array[Dictionary] = []
var spatula: Sprite2D
var shadow: Sprite2D
var texture_image: Image
var camera: Camera2D
var peek_position := Vector2.ZERO
var retreat_start := Vector2.ZERO
var damage_hitbox: HitboxComponent
var impact_applied := false

func start(context: Spawner, geometry: ArenaEnvironment) -> void:
	super.start(context, geometry)
	next_event = maxf(0.05, initial_delay)
	camera = context.get_parent().get_node("Camera2D")
	texture_image = TEXTURE.get_image()
	damage_hitbox = HitboxComponent.new()
	damage_hitbox.collision_layer = 0
	damage_hitbox.collision_mask = 0
	damage_hitbox.monitoring = false
	damage_hitbox.monitorable = false
	damage_hitbox.grants_enemy_rewards = false
	add_child(damage_hitbox)
	spatula = Sprite2D.new()
	spatula.texture = TEXTURE
	spatula.centered = false
	spatula.z_as_relative = false
	spatula.z_index = 6
	spatula.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	add_child(spatula)
	shadow = Sprite2D.new()
	shadow.texture = TEXTURE
	shadow.centered = false
	shadow.z_as_relative = false
	shadow.z_index = -1
	shadow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var shadow_material := ShaderMaterial.new()
	shadow_material.shader = preload("res://shaders/spatula_shadow.gdshader")
	shadow.material = shadow_material
	add_child(shadow)
	update_visuals()

func target_position() -> Vector2:
	var bounds := area.movement_bounds
	var size := impact_size.min(bounds.size - Vector2.ONE * (area.corner_radius * 2 + 20)).max(Vector2.ONE * 10)
	var center := Global.player.global_position if is_live(Global.player) else bounds.get_center()
	var margin := Vector2.ONE * (area.corner_radius + 10)
	# Aim a solid strip at the player, rather than the transparent central slot.
	return Vector2(clampf(center.x - size.x * 0.37, bounds.position.x + margin.x, bounds.end.x - margin.x - size.x), clampf(center.y - size.y * 0.5, bounds.position.y + margin.y, bounds.end.y - margin.y - size.y))

func bottom_y() -> float:
	return camera.get_screen_center_position().y + camera.get_viewport_rect().size.y / camera.zoom.y * 0.5

func begin_strike() -> void:
	if not active or Global.game_paused: return
	impact.size = impact_size.min(area.movement_bounds.size - Vector2.ONE * (area.corner_radius * 2 + 20)).max(Vector2.ONE * 10)
	impact.position = target_position()
	phase_time = 0
	state = State.TRACKING
	impact_applied = false
	update_visuals()

func _process(delta: float) -> void:
	if not active or Global.game_paused: return
	_apply_pushes(delta)
	if state == State.WAITING:
		next_event -= delta
		if next_event <= 0: begin_strike()
		return
	phase_time += delta
	match state:
		State.TRACKING:
			var smooth_target := impact.position.lerp(target_position(), 1.0 - exp(-tracking_smoothing * delta))
			impact.position = impact.position.move_toward(smooth_target, maxf(0, tracking_speed) * delta)
			if phase_time >= maxf(0.05, tracking_duration):
				peek_position = Vector2(impact.position.x, bottom_y() - peek_height)
				state = State.LOCKED
				phase_time = 0
		State.LOCKED:
			if phase_time >= maxf(0.05, lock_duration): state = State.FALLING; phase_time = 0
		State.FALLING:
			if phase_time >= maxf(0.01, fall_duration):
				strike()
				if not active: return
				state = State.HOLDING
				phase_time = 0
		State.HOLDING:
			if phase_time >= maxf(0.05, hold_duration):
				retreat_start = impact.position
				state = State.RETRACTING
				phase_time = 0
		State.RETRACTING:
			if phase_time >= maxf(0.05, retract_duration):
				state = State.WAITING
				next_event = random_interval(minimum_interval, maximum_interval)
	update_visuals()

func contains_head(point: Vector2) -> bool:
	if not impact.has_point(point): return false
	var pixel := HEAD_PIXELS.position + (point - impact.position) / impact.size * HEAD_PIXELS.size
	return texture_image.get_pixel(int(pixel.x), int(pixel.y)).a >= 0.60

func strike() -> void:
	if not active or Global.game_paused or impact_applied: return
	impact_applied = true
	SoundManager.play_sound(SoundManager.Sound.SPATULA_IMPACT)
	load("res://effects/arena_bursts.gd").emit_at(self, impact.get_center(), true, impact.size)
	for unit in live_units():
		if contains_head(unit.global_position):
			pushes.append({"unit": weakref(unit), "velocity": Vector2.UP * maxf(0, push_speed), "remaining": maxf(0.05, push_duration), "duration": maxf(0.05, push_duration)})
			if unit is Player:
				damage_hitbox.setup(unit.health_component.max_health * player_damage_percent / 100.0, false, 0, self)
				unit._on_hurtbox_component_on_damage(damage_hitbox)
				if not active or Global.game_paused: return
	camera.start_shake(shake_strength, shake_duration)

func _apply_pushes(delta: float) -> void:
	for index in range(pushes.size() - 1, -1, -1):
		var push := pushes[index]
		var unit = push.unit.get_ref()
		if not is_live(unit): pushes.remove_at(index); continue
		var step := minf(delta, push.remaining)
		var strength: float = (push.remaining - step * 0.5) / push.duration
		move_unit(unit, push.velocity * step * strength)
		push.remaining -= step
		if push.remaining <= 0: pushes.remove_at(index)

func place_sprite(sprite: Sprite2D, head_position: Vector2, multiplier: float = 1.0) -> void:
	sprite.scale = impact.size / HEAD_PIXELS.size * multiplier
	sprite.position = head_position - HEAD_PIXELS.position * sprite.scale

func update_visuals() -> void:
	spatula.visible = state != State.WAITING
	shadow.visible = state != State.WAITING
	if state == State.WAITING: return
	place_sprite(shadow, impact.position)
	shadow.modulate.a = 0.65 if state == State.TRACKING else 1.0
	match state:
		State.TRACKING:
			var progress := clampf(phase_time / 0.45, 0, 1)
			place_sprite(spatula, Vector2(impact.position.x, bottom_y() + 40 - (peek_height + 40) * progress))
		State.LOCKED:
			var anticipation_time := minf(maxf(0.01, shadow_anticipation_duration), maxf(0.05, lock_duration))
			var progress := clampf((phase_time - maxf(0.05, lock_duration) + anticipation_time) / anticipation_time, 0, 1)
			place_sprite(spatula, peek_position.lerp(impact.position - Vector2(0, fall_height), progress), lerpf(1, 1.12, progress))
			var anticipation := smoothstep(0.0, 1.0, progress)
			place_shadow(lerpf(1.0, shadow_raised_scale, anticipation))
			shadow.modulate.a = lerpf(1.0, 0.65, anticipation)
		State.FALLING:
			var progress := clampf(phase_time / maxf(0.01, fall_duration), 0, 1)
			place_sprite(spatula, impact.position - Vector2(0, fall_height * (1.0 - progress * progress)), lerpf(1.12, 1, progress))
			place_shadow(lerpf(shadow_raised_scale, 1.0, progress * progress))
			shadow.modulate.a = lerpf(0.65, 1.0, progress)
		State.HOLDING: place_sprite(spatula, impact.position)
		State.RETRACTING:
			var progress := clampf(phase_time / maxf(0.05, retract_duration), 0, 1)
			place_sprite(spatula, retreat_start.lerp(Vector2(retreat_start.x, maxf(bottom_y(), area.movement_bounds.end.y) + 50), progress))
			shadow.modulate.a = 1.0 - progress

func place_shadow(multiplier: float) -> void:
	# Scale around the head's center without moving the locked impact target.
	place_sprite(shadow, impact.get_center() - impact.size * multiplier * 0.5, multiplier)

func stop() -> void:
	pushes.clear()
	if is_instance_valid(camera): camera.clear_shake()
	super.stop()
