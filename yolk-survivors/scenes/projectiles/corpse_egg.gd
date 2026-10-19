extends Projectile
## A placed explosive: no contact damage, upright art, fuse starts on landing.
var settings: RangedSettings
var origin := Vector2.ZERO
var landing_point := Vector2.ZERO
var flight_time := 0.0
var flight_elapsed := 0.0
var landed := false
var fuse_left := 0.3
var exploded := false
var falling := false
var fall_elapsed := 0.0
var fall_height := 0.0
var contact_target_id := 0
@onready var egg: Sprite2D = $Sprite2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("projectiles")
	scale *= Global.GAME_ENTITY_SCALE
	hitbox.disable()
	z_index = 0

func setup_projectile(projectile_velocity: Vector2, damage: float, critical: bool, knockback: float, unit: Node2D, travel_range: float = INF) -> void:
	super.setup_projectile(projectile_velocity, damage, critical, knockback, unit, travel_range)
	rotation = 0.0
	origin = global_position

func configure_effects(config: RangedSettings) -> void:
	settings = config
	fuse_left = settings.fuse

func configure_target(point: Vector2) -> void:
	landing_point = point
	flight_time = origin.distance_to(point) / maxf(1.0, velocity.length())

func _process(delta: float) -> void:
	if Global.game_paused or exploded or is_queued_for_deletion() or not settings: return
	rotation = 0.0
	var remaining := delta
	if not landed and not falling:
		var previous := global_position
		var step := minf(remaining, maxf(0.0, flight_time - flight_elapsed))
		flight_elapsed += step
		remaining -= step
		var progress := clampf(flight_elapsed / maxf(0.0001, flight_time), 0.0, 1.0)
		global_position = origin.lerp(landing_point, progress)
		egg.position.y = -sin(progress * PI) * settings.lob_height
		var contact := _find_contact(previous, global_position)
		if not contact.is_empty():
			global_position = contact.point
			var enemy: Enemy = contact.enemy
			contact_target_id = enemy.get_instance_id()
			var push := settings.egg_contact_push
			if hitbox.source is Unit: push = hitbox.source.stats.get_push_force(push)
			enemy.apply_knockback(velocity.normalized(), push)
			landing_point = global_position
			falling = true
			fall_height = egg.position.y
		elif flight_elapsed >= flight_time:
			_land()
	if falling:
		var fall_step := minf(remaining, maxf(0.0, settings.egg_fall_duration - fall_elapsed))
		fall_elapsed += fall_step
		remaining -= fall_step
		egg.position.y = lerpf(fall_height, 0.0, pow(clampf(fall_elapsed / settings.egg_fall_duration, 0.0, 1.0), 2.0))
		if fall_elapsed >= settings.egg_fall_duration: _land()
	if landed:
		fuse_left -= remaining
		# Shake only the artwork: landing point and explosion center remain fixed.
		var shake_window := minf(settings.fuse, settings.pre_explosion_shake_duration)
		var shake_elapsed := shake_window - fuse_left
		if shake_window > 0.0 and shake_elapsed > 0.0:
			var phase := shake_elapsed * settings.pre_explosion_shake_frequency * TAU
			var intensity := lerpf(0.65, 1.0, clampf(shake_elapsed / shake_window, 0.0, 1.0))
			egg.position = Vector2(sin(phase), sin(phase * 1.37) * 0.5) * settings.pre_explosion_shake_amount * intensity
			var pulse := 0.5 + 0.5 * sin(phase)
			egg.modulate = Color(1.0, 1.0 - pulse * 0.18, 1.0 - pulse * 0.3)
		else:
			egg.position = Vector2.ZERO
			egg.modulate = Color.WHITE
		if fuse_left <= 0.0: detonate()

func _land() -> void:
	landed = true
	falling = false
	global_position = landing_point
	egg.position = Vector2.ZERO
	z_index = 0

func _find_contact(start: Vector2, end: Vector2) -> Dictionary:
	# Sweep a small footprint so fast eggs cannot tunnel through tiny hurtboxes.
	var shape := CircleShape2D.new()
	shape.radius = 10.0 * Global.GAME_ENTITY_SCALE
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.collision_mask = 8
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var steps := maxi(1, ceili(start.distance_to(end) / maxf(1.0, shape.radius)))
	for index in range(steps + 1):
		var point := start.lerp(end, float(index) / steps)
		query.transform = Transform2D(0.0, point)
		for result in get_world_2d().direct_space_state.intersect_shape(query, 16):
			var hurtbox = result.collider
			if not hurtbox is HurtboxComponent: continue
			var enemy = hurtbox.owner
			if not enemy is Enemy or not enemy.targetable or enemy.is_retiring or enemy.is_queued_for_deletion() or enemy.health_component.current_health <= 0.0: continue
			return {"point":point, "enemy":enemy}
	return {}

func detonate() -> void:
	if exploded or Global.game_paused or not landed: return
	exploded = true
	var arena := get_tree().current_scene
	var blast = load("res://scenes/projectiles/ranged_area_effect.gd").new()
	arena.add_child(blast)
	blast.global_position = landing_point
	blast.setup(hitbox, settings, false)
	if arena.has_method("spawn_yolk_at"):
		for i in settings.bonus_yolks: arena.spawn_yolk_at(landing_point, 1)
	queue_free()

func _on_hitbox_component_on_hit_hurtbox(_hurtbox: HurtboxComponent) -> void:
	pass

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# It is placed at a world target; camera movement must not cancel the egg.
	pass
