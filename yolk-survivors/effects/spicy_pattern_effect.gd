extends Node2D

var settings: SpicyPatternSettings
var hit: HitboxComponent
var weapon_ref: WeakRef
var source: Player
var radius := 0.0
var elapsed := 0.0
var duration_multiplier := 1.0
var tick_left := 0.0
var velocity := Vector2.ZERO
var orbit_angle := 0.0
var orbit_radius := 0.0
var detonated := false
var detonation_time := 0.0
var hit_targets: Dictionary = {}
var surface: ColorRect
var effect_material: ShaderMaterial
var mine_sprite: Sprite2D

func configure(weapon: Weapon, config: SpicyPatternSettings, point: Vector2) -> void:
	settings = config
	weapon_ref = weakref(weapon)
	source = weapon.get_parent() as Player
	duration_multiplier = source.stats.effect_duration_multiplier()
	position = point
	radius = settings.radius * Global.GAME_ENTITY_SCALE * source.stats.get_area_radius_multiplier()
	orbit_radius = weapon.data.stats.max_range * Global.GAME_ENTITY_SCALE
	orbit_angle = randf()*TAU
	velocity = Vector2.from_angle(randf()*TAU) * settings.movement_speed * Global.GAME_ENTITY_SCALE
	hit = HitboxComponent.new()
	hit.collision_layer = 0
	hit.collision_mask = 0
	hit.monitoring = false
	add_child(hit)
	hit.setup(weapon.data.get_effective_damage(source.stats),false,weapon.data.stats.knockback,source)
	weapon.weapon_behaviour.configure_hit_criticals(hit)
	hit.life_steal_chance = weapon.data.get_effective_life_steal(source.stats)
	hit.weapon_damage_record = weapon.damage_record
	if settings.mode == SpicyPatternSettings.Mode.ORBIT:
		var sprite := Sprite2D.new()
		sprite.texture = weapon.sprite_2d.texture
		sprite.scale = Vector2.ONE * settings.sprite_scale * Global.GAME_ENTITY_SCALE
		sprite.z_index = 2
		add_child(sprite)
	else:
		surface = ColorRect.new()
		surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(surface)
		effect_material = ShaderMaterial.new()
		effect_material.shader = preload("res://shaders/spicy_pattern.gdshader")
		surface.material = effect_material
		var extent := Vector2(radius,radius*settings.area_y_ratio)
		surface.position = -extent
		surface.size = extent*2.0
		if settings.mode == SpicyPatternSettings.Mode.TORNADO:
			surface.size.y += settings.column_height*Global.GAME_ENTITY_SCALE
			surface.position.y -= settings.column_height*Global.GAME_ENTITY_SCALE
		effect_material.set_shader_parameter("mode",settings.mode)
		effect_material.set_shader_parameter("tint",settings.color)
		effect_material.set_shader_parameter("opacity",settings.opacity)
		_update_visual()
		if settings.mode == SpicyPatternSettings.Mode.MINE:
			mine_sprite = Sprite2D.new()
			mine_sprite.texture = weapon.sprite_2d.texture
			mine_sprite.scale = Vector2.ONE*settings.sprite_scale*Global.GAME_ENTITY_SCALE
			mine_sprite.z_index = 1
			add_child(mine_sprite)

func _ready() -> void:
	add_to_group("projectiles")
	z_index = 1

func _process(delta: float) -> void:
	if Global.game_paused or is_queued_for_deletion(): return
	var weapon = weapon_ref.get_ref()
	if not is_instance_valid(source) or source.health_component.current_health <= 0.0 or not is_instance_valid(weapon) or weapon.is_queued_for_deletion():
		queue_free()
		return
	var previous := elapsed
	elapsed += delta
	if settings.mode == SpicyPatternSettings.Mode.ORBIT:
		orbit_angle += settings.orbit_speed*delta
		global_position = source.global_position + Vector2(cos(orbit_angle),sin(orbit_angle)*settings.area_y_ratio)*orbit_radius
	elif settings.mode == SpicyPatternSettings.Mode.TORNADO:
		var next := global_position + velocity*delta
		if source.arena_environment:
			var bounded := source.arena_environment.clamp_position(next)
			if not bounded.is_equal_approx(next): velocity = bounded.direction_to(source.arena_environment.movement_bounds.get_center())*velocity.length()
			next = bounded
		global_position = next
	if settings.mode == SpicyPatternSettings.Mode.SHOCKWAVE:
		var current_radius := radius*clampf(elapsed/settings.wave_duration,0,1)
		var inner := maxf(0.0,radius*clampf(previous/settings.wave_duration,0,1)-settings.wave_band*Global.GAME_ENTITY_SCALE)
		_damage(current_radius,inner,true)
		if elapsed >= settings.wave_duration: queue_free()
	elif settings.mode == SpicyPatternSettings.Mode.MINE:
		if not detonated and elapsed >= settings.arming_time and _enemy_in_trigger():
			detonated = true
			detonation_time = elapsed
			_damage(radius)
		if detonated and elapsed-detonation_time >= settings.wave_duration: queue_free()
	else:
		tick_left -= delta
		if tick_left <= 0.0:
			tick_left = source.stats.get_fire_interval(settings.tick_interval) if settings.fire_ticks else settings.tick_interval
			_damage(radius)
	if settings.lifetime > 0.0 and elapsed >= settings.lifetime * duration_multiplier: queue_free()
	_update_visual()

func _enemy_in_trigger() -> bool:
	for enemy in get_tree().get_nodes_in_group("combat_enemies"):
		if not _valid_enemy(enemy): continue
		if _distance(enemy.global_position) <= settings.trigger_radius*Global.GAME_ENTITY_SCALE: return true
	return false

func _distance(point: Vector2) -> float:
	var offset := point-global_position
	offset.y /= settings.area_y_ratio
	return offset.length()

func _valid_enemy(enemy: Enemy) -> bool:
	return is_instance_valid(enemy) and not enemy.is_queued_for_deletion() and not enemy.is_retiring and enemy.health_component.current_health > 0.0

func _damage(outer: float, inner: float = 0.0, once: bool = false) -> void:
	for enemy in get_tree().get_nodes_in_group("combat_enemies"):
		if not _valid_enemy(enemy): continue
		var distance := _distance(enemy.global_position)
		if distance > outer or distance < inner: continue
		var id := enemy.get_instance_id()
		if once and hit_targets.has(id): continue
		if once: hit_targets[id] = true
		enemy._on_hurtbox_component_on_damage(hit)

func _update_visual() -> void:
	if not effect_material: return
	if mine_sprite: mine_sprite.visible = not detonated
	var progress := clampf(elapsed/settings.wave_duration,0,1) if settings.mode == SpicyPatternSettings.Mode.SHOCKWAVE else clampf((elapsed-detonation_time)/settings.wave_duration,0,1) if detonated else 0.0
	effect_material.set_shader_parameter("elapsed",elapsed)
	effect_material.set_shader_parameter("progress",progress)
	effect_material.set_shader_parameter("detonated",detonated)
