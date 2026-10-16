extends Projectile

var settings: RangedSettings
var arena_environment: ArenaEnvironment
var carried: Array[Enemy] = []
var planted := false
var hold_left := 0.0
var hold_duration := 0.0
var query := PhysicsShapeQueryParameters2D.new()
var sweep_shape := CircleShape2D.new()

func _ready() -> void:
	super._ready()
	tree_exiting.connect(_release_all)
	query.shape = sweep_shape
	query.collision_mask = 8
	query.collide_with_areas = true
	query.collide_with_bodies = false

func setup_projectile(projectile_velocity: Vector2, damage: float, critical: bool, _knockback: float, unit: Node2D, travel_range: float = INF) -> void:
	super.setup_projectile(projectile_velocity, damage, critical, 0.0, unit, travel_range)
	if unit is Player: arena_environment = unit.arena_environment

func configure_effects(config: RangedSettings) -> void:
	settings = config
	sweep_shape.radius = maxf(1.0, settings.harpoon_capture_radius * Global.GAME_ENTITY_SCALE)

func _process(delta: float) -> void:
	if Global.game_paused or is_queued_for_deletion() or not settings: return
	if planted:
		hold_left -= delta
		var t := clampf((hold_duration - hold_left) / maxf(0.001, settings.harpoon_embed_duration), 0.0, 1.0)
		$Sprite2D.rotation = settings.harpoon_embed_angle * sin(t * PI * 0.5)
		if hold_left <= 0.0: finish()
		return
	var start := global_position
	var remaining := maxf(0.0, max_distance - distance_travelled)
	var end := start + (velocity * delta).limit_length(remaining)
	var edge := false
	if arena_environment and not arena_environment.clamp_position(end).is_equal_approx(end):
		# Find the first boundary intersection; never slide along a curved rim.
		var inside := start
		var outside := end
		for i in 20:
			var middle := (inside + outside) * 0.5
			if arena_environment.clamp_position(middle).is_equal_approx(middle): inside = middle
			else: outside = middle
		end = arena_environment.clamp_position(inside)
		edge = true
	var steps := maxi(1, ceili(start.distance_to(end) / sweep_shape.radius))
	for i in range(steps + 1):
		query.transform = Transform2D(0.0, start.lerp(end, float(i) / steps))
		for result in get_world_2d().direct_space_state.intersect_shape(query, 4096):
			var hurtbox = result.collider
			if hurtbox is HurtboxComponent: hurtbox._on_area_entered(hitbox)
	global_position = end
	distance_travelled += start.distance_to(end)
	_move_carried()
	if edge or distance_travelled >= max_distance - 0.001: _plant()

func _on_hitbox_component_on_hit_hurtbox(hurtbox: HurtboxComponent) -> void:
	if planted or Global.game_paused or is_queued_for_deletion(): return
	var enemy := hurtbox.owner as Enemy
	if not is_instance_valid(enemy) or enemy.is_retiring or enemy.health_component.current_health <= 0.0: return
	var id := hurtbox.get_instance_id()
	if hit_targets.has(id): return
	hit_targets[id] = true
	enemy.pin_for(self)
	carried.append(enemy)

func _move_carried() -> void:
	for enemy in carried:
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.is_retiring or enemy.health_component.current_health <= 0.0: continue
		enemy.pinned_position = global_position
		enemy.global_position = global_position

func _plant() -> void:
	planted = true
	velocity = Vector2.ZERO
	hitbox.disable()
	z_index = 0
	hold_duration = settings.harpoon_pin_duration
	if hitbox.source is Unit:
		hold_duration *= hitbox.source.stats.get_effect_multiplier() * hitbox.source.stats.effect_duration_multiplier()
	hold_left = hold_duration
	if hold_left <= 0.0: finish()

func _release_all() -> void:
	for enemy in carried:
		if is_instance_valid(enemy): enemy.release_pin(self)
	carried.clear()

func finish() -> void:
	_release_all()
	super.finish()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	pass
