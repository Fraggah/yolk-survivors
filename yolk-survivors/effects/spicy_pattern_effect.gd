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
var orbit_previous_center := Vector2.ZERO
var orbit_enemy_positions: Dictionary = {}
var orbit_hit_cooldowns: Dictionary = {}
var detonated := false
var detonation_time := 0.0
var hit_targets: Dictionary = {}
var surface: ColorRect
var effect_material: ShaderMaterial
var mine_sprite: Sprite2D
var mine_visual: Node2D
var wave_visual: Node2D
var cloud_visual: Node2D
var column_visual: Node2D
var column_enemy_positions: Dictionary = {}
var column_hit_cooldowns: Dictionary = {}
var column_trail_distance := 0.0
var column_trail_settings: SpicyPatternSettings
var trail_visual: Node2D
var trail_entries: Array[Dictionary] = []
var trail_lifetime := 0.0
var trail_item_effects: Array[StatusEffect] = []
var trail_contacts: Dictionary = {}
var trail_previous_positions: Dictionary = {}

func configure(weapon: Weapon, config: SpicyPatternSettings, point: Vector2, column_trail: bool = false) -> void:
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
	if settings.mode == SpicyPatternSettings.Mode.TRAIL:
		if column_trail: _configure_column_trail(weapon)
		else: _configure_shared_trail(weapon)
	if settings.mode == SpicyPatternSettings.Mode.SHOCKWAVE: _configure_shared_wave(weapon)
	if settings.mode == SpicyPatternSettings.Mode.ORBIT:
		var sprite := Sprite2D.new()
		sprite.texture = weapon.sprite_2d.texture
		sprite.scale = Vector2.ONE * settings.sprite_scale * Global.GAME_ENTITY_SCALE
		sprite.z_index = 0
		add_child(sprite)
		orbit_previous_center = source.global_position + settings.orbit_center_offset * Global.GAME_ENTITY_SCALE
		global_position = _orbit_point(orbit_previous_center, orbit_angle)
	elif settings.mode == SpicyPatternSettings.Mode.TRAIL:
		trail_visual = load("res://effects/cayenne_trail_visual.gd").new()
		add_child(trail_visual)
		trail_visual.configure(settings,radius,trail_lifetime)
		trail_visual.set_coverage(trail_entries)
	elif settings.mode == SpicyPatternSettings.Mode.TORNADO:
		column_visual = load("res://effects/fire_column_visual.gd").new()
		add_child(column_visual)
		column_visual.configure(settings, radius, settings.lifetime*duration_multiplier if settings.lifetime>0.0 else INF)
	elif settings.mode == SpicyPatternSettings.Mode.CLOUD:
		cloud_visual = load("res://effects/ghost_cloud_visual.gd").new()
		add_child(cloud_visual)
		cloud_visual.configure(settings, radius, settings.lifetime*duration_multiplier)
	elif settings.mode == SpicyPatternSettings.Mode.MINE:
		mine_visual = load("res://effects/scotch_mine_visual.gd").new()
		add_child(mine_visual)
		mine_visual.configure(settings,radius,weapon.sprite_2d.texture)
		mine_sprite = mine_visual.sprite
	elif settings.mode == SpicyPatternSettings.Mode.SHOCKWAVE:
		wave_visual = load("res://effects/rocoto_wave_visual.gd").new()
		add_child(wave_visual)
		wave_visual.configure(settings,radius)
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

func _ready() -> void:
	add_to_group("projectiles")
	if settings.mode == SpicyPatternSettings.Mode.CLOUD: add_to_group("ghost_clouds")
	# Column depth comes from its ground contact, not its height.
	z_index = 0

func _process(delta: float) -> void:
	if Global.game_paused or is_queued_for_deletion(): return
	var weapon = weapon_ref.get_ref()
	if not is_instance_valid(source) or source.health_component.current_health <= 0.0 or not is_instance_valid(weapon) or weapon.is_queued_for_deletion():
		queue_free()
		return
	var previous := elapsed
	var previous_position := global_position
	elapsed += delta
	if settings.mode == SpicyPatternSettings.Mode.ORBIT:
		_process_orbit(delta, weapon)
	elif settings.mode == SpicyPatternSettings.Mode.TORNADO:
		var next := global_position + velocity*delta
		if source.arena_environment:
			var bounded := source.arena_environment.clamp_position(next)
			if not bounded.is_equal_approx(next): velocity = bounded.direction_to(source.arena_environment.movement_bounds.get_center())*velocity.length()
			next = bounded
		global_position = next
		_leave_column_trail(previous_position, weapon)
	if settings.mode == SpicyPatternSettings.Mode.SHOCKWAVE:
		var current_radius := radius*clampf(elapsed/settings.wave_duration,0,1)
		var inner := maxf(0.0,radius*clampf(previous/settings.wave_duration,0,1)-settings.wave_band*Global.GAME_ENTITY_SCALE)
		if previous < settings.wave_duration: _damage(current_radius,inner,true)
		if elapsed >= settings.wave_duration+settings.shockwave_visual_tail: queue_free()
	elif settings.mode == SpicyPatternSettings.Mode.MINE:
		if not detonated and elapsed >= settings.arming_time and _enemy_in_trigger():
			detonated = true
			detonation_time = elapsed
			_damage(radius)
		if detonated and elapsed-detonation_time >= settings.wave_duration: queue_free()
	elif settings.mode == SpicyPatternSettings.Mode.TORNADO:
		_update_column_contacts(previous_position)
	elif settings.mode != SpicyPatternSettings.Mode.ORBIT:
		if settings.mode == SpicyPatternSettings.Mode.TRAIL: _update_trail_contacts()
		tick_left -= delta
		if tick_left <= 0.0:
			tick_left = source.stats.get_fire_interval(settings.tick_interval) if settings.fire_ticks else settings.tick_interval
			_damage(radius)
	var lifetime := trail_lifetime if settings.mode == SpicyPatternSettings.Mode.TRAIL else settings.lifetime * duration_multiplier
	if lifetime > 0.0 and elapsed >= lifetime: queue_free()
	_update_visual()

func _enemy_in_trigger() -> bool:
	for enemy in get_tree().get_nodes_in_group("combat_enemies"):
		if not _valid_enemy(enemy): continue
		if _distance(enemy.global_position) <= settings.trigger_radius*Global.GAME_ENTITY_SCALE: return true
	return false

func _leave_column_trail(previous_position: Vector2, weapon: Weapon) -> void:
	var distance := previous_position.distance_to(global_position)
	if distance <= 0.001 or settings.column_trail_damage_multiplier <= 0.0: return
	var spacing := settings.column_trail_spacing * Global.GAME_ENTITY_SCALE
	var cursor := spacing - column_trail_distance
	while cursor <= distance:
		if not column_trail_settings:
			column_trail_settings = settings.duplicate()
			column_trail_settings.mode = SpicyPatternSettings.Mode.TRAIL
			column_trail_settings.lifetime = settings.column_trail_lifetime
			column_trail_settings.radius = settings.radius * settings.column_fill_width * 0.5 * settings.column_trail_radius_multiplier
			var config: Resource = settings.trail_fire_visuals
			if not config: config = load("res://resources/statuses/fire_visual_default.tres")
			column_trail_settings.trail_fire_visuals = config.duplicate()
			column_trail_settings.trail_fire_visuals.flame_count = 10
			column_trail_settings.trail_fire_visuals.ember_count = 4
		var patch = load("res://effects/spicy_pattern_effect.gd").new()
		patch.configure(weapon, column_trail_settings, previous_position.lerp(global_position, cursor / distance), true)
		get_parent().add_child(patch)
		patch.add_to_group("reaper_trails")
		# Ground fire remains below actors and the column, regardless of their Y.
		for child in patch.trail_visual.get_children():
			if child is CanvasItem:
				child.z_as_relative = false
				child.z_index = -1
		cursor += spacing
	column_trail_distance = fposmod(column_trail_distance + distance, spacing)

func _configure_column_trail(weapon: Weapon) -> void:
	trail_lifetime = settings.lifetime * duration_multiplier
	var effects: Array[StatusEffect] = []
	for effect in weapon.data.on_hit_effects:
		if not effect: continue
		var copy: StatusEffect = effect.duplicate()
		copy.damage *= settings.column_trail_damage_multiplier
		# All patches from this weapon refresh the same burn contribution.
		copy.set_meta("stack_id", "ReaperTrail_%s_%s" % [weapon.get_instance_id(), effect.get_instance_id()])
		effects.append(copy)
	trail_entries.append({"id": weapon.get_instance_id(), "record": weapon.damage_record,
		"radius": radius, "ratio": settings.area_y_ratio, "lifetime": trail_lifetime,
		"damage": hit.damage * settings.column_trail_damage_multiplier, "effects": effects})
	_set_trail_hit(trail_entries)

func _update_column_contacts(previous_position: Vector2) -> void:
	# Check every frame, sweeping BOTH bodies between samples. Damage cadence is
	# per enemy, so walking through between global ticks can no longer miss a hit.
	var positions: Dictionary = {}
	var cooldowns: Dictionary = {}
	var reach := radius * settings.column_hit_radius_multiplier
	for enemy in get_tree().get_nodes_in_group("combat_enemies"):
		if not _valid_enemy(enemy): continue
		var id := enemy.get_instance_id()
		var shape := enemy.get_node_or_null("HurtboxComponent/CollisionShape2D") as CollisionShape2D
		var point: Vector2 = shape.global_position if shape else enemy.global_position
		var padding := 0.0
		if shape and shape.shape is CircleShape2D and not shape.disabled:
			padding = shape.shape.radius * maxf(absf(shape.global_scale.x), absf(shape.global_scale.y))
		var extent := Vector2(reach + padding, reach * settings.area_y_ratio + padding)
		var start: Vector2 = (column_enemy_positions.get(id, point) - previous_position) / extent
		var end := (point - global_position) / extent
		positions[id] = point
		var next_hit: float = column_hit_cooldowns.get(id, 0.0)
		if elapsed >= next_hit and Geometry2D.get_closest_point_to_segment(Vector2.ZERO, start, end).length_squared() <= 1.0:
			enemy._on_hurtbox_component_on_damage(hit)
			var interval := source.stats.get_fire_interval(settings.tick_interval) if settings.fire_ticks else settings.tick_interval
			next_hit = elapsed + maxf(0.001, interval)
		if next_hit > elapsed: cooldowns[id] = next_hit
	column_enemy_positions = positions
	column_hit_cooldowns = cooldowns

func _distance(point: Vector2) -> float:
	var offset := point-global_position
	offset.y /= settings.area_y_ratio
	return offset.length()

func _valid_enemy(enemy: Enemy) -> bool:
	return is_instance_valid(enemy) and not enemy.is_queued_for_deletion() and not enemy.is_retiring and enemy.health_component.current_health > 0.0

func _damage(outer: float, inner: float = 0.0, once: bool = false) -> void:
	for enemy in get_tree().get_nodes_in_group("combat_enemies"):
		if not _valid_enemy(enemy): continue
		if settings.mode == SpicyPatternSettings.Mode.TRAIL:
			var entries := _trail_at(enemy.global_position)
			if entries.is_empty(): continue
			_set_trail_hit(entries)
			enemy._on_hurtbox_component_on_damage(hit)
			continue
		var distance := _distance(enemy.global_position)
		if distance > outer or distance < inner: continue
		var id := enemy.get_instance_id()
		if once and hit_targets.has(id): continue
		if once: hit_targets[id] = true
		enemy._on_hurtbox_component_on_damage(hit)

func _update_visual() -> void:
	if is_instance_valid(wave_visual): wave_visual.update_visual(elapsed)
	if is_instance_valid(mine_visual): mine_visual.update_visual(elapsed,detonated,elapsed-detonation_time)
	if is_instance_valid(cloud_visual): cloud_visual.update_visual(elapsed)
	if is_instance_valid(column_visual): column_visual.update_visual(elapsed)
	if is_instance_valid(trail_visual): trail_visual.update_visual(elapsed)
	if not effect_material: return
	if mine_sprite: mine_sprite.visible = not detonated
	var progress := clampf(elapsed/settings.wave_duration,0,1) if settings.mode == SpicyPatternSettings.Mode.SHOCKWAVE else clampf((elapsed-detonation_time)/settings.wave_duration,0,1) if detonated else 0.0
	effect_material.set_shader_parameter("elapsed",elapsed)
	effect_material.set_shader_parameter("progress",progress)
	effect_material.set_shader_parameter("detonated",detonated)

func _trail_at(point: Vector2, previous: Vector2 = Vector2.INF) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in trail_entries:
		if elapsed >= entry.lifetime: continue
		var end := point - global_position
		end.y /= entry.ratio
		var start := end
		if previous != Vector2.INF:
			start = previous - global_position
			start.y /= entry.ratio
		if Geometry2D.get_closest_point_to_segment(Vector2.ZERO, start, end).length_squared() <= entry.radius * entry.radius:
			result.append(entry)
	return result

func _update_trail_contacts() -> void:
	var positions: Dictionary = {}
	var contacts: Dictionary = {}
	for enemy in get_tree().get_nodes_in_group("combat_enemies"):
		if not _valid_enemy(enemy): continue
		var id := enemy.get_instance_id()
		var point: Vector2 = enemy.global_position
		positions[id] = point
		var previous: Vector2 = trail_previous_positions.get(id, point)
		var present: Array = []
		for entry in _trail_at(point): present.append(entry.id)
		contacts[id] = present
		var entries: Array[Dictionary] = []
		var old_contacts: Array = trail_contacts.get(id, [])
		for entry in _trail_at(point, previous):
			if not old_contacts.has(entry.id): entries.append(entry)
		if entries.is_empty(): continue
		# Refresh only contributors actually crossed; the shared burn retains its clock.
		_set_trail_hit(entries)
		for effect in hit.status_effects:
			if effect and effect.kind == StatusEffect.Kind.FIRE and Global.get_chance_succes(effect.chance):
				load("res://effects/status_controller.gd").apply_effect(enemy, effect, hit)
	trail_contacts = contacts
	trail_previous_positions = positions

func _configure_shared_trail(weapon: Weapon) -> void:
	for effect in hit.status_effects:
		if not weapon.data.on_hit_effects.has(effect): trail_item_effects.append(effect)
	var contributors: Array[Weapon] = weapon.weapon_behaviour.trail_contributors()
	for equipped in contributors:
		var config := equipped.data.stats.spicy_pattern
		var reach := config.radius * Global.GAME_ENTITY_SCALE * source.stats.get_area_radius_multiplier()
		var lifetime := config.lifetime * duration_multiplier
		trail_entries.append({"id": equipped.get_instance_id(), "record": equipped.damage_record,
			"radius": reach, "ratio": config.area_y_ratio, "lifetime": lifetime,
			"damage": equipped.data.get_effective_damage(source.stats), "effects": equipped.data.on_hit_effects})
		radius = maxf(radius, reach)
		trail_lifetime = maxf(trail_lifetime, lifetime)
	_set_trail_hit(trail_entries)

func _set_trail_hit(entries: Array[Dictionary]) -> void:
	var total := 0.0
	var shares: Array[Dictionary] = []
	for entry in entries:
		total += entry.damage
		shares.append({"record": entry.record, "weight": entry.damage})
	for share in shares: share.weight /= maxf(0.00001, total)
	hit.base_damage = total
	hit.damage = total
	hit.weapon_damage_record = {"wave_damage": 0.0, "total_damage": 0.0, "contributors": shares}
	hit.status_effects.assign(trail_item_effects)
	var fires: Dictionary = {}
	for entry in entries:
		for effect in entry.effects:
			if not effect: continue
			if effect.kind != StatusEffect.Kind.FIRE:
				if not hit.status_effects.has(effect): hit.status_effects.append(effect)
				continue
			var key: String = effect.resource_path if not effect.resource_path.is_empty() else str(effect.get_instance_id())
			key = str(effect.get_meta("stack_id", key))
			if not fires.has(key):
				var merged: StatusEffect = effect.duplicate()
				merged.damage = 0.0
				merged.set_meta("stack_id", "SharedCayenne_" + key)
				merged.set_meta("fire_contributions", [])
				fires[key] = merged
			var merged: StatusEffect = fires[key]
			merged.damage += effect.damage
			merged.get_meta("fire_contributions").append({"id": entry.id, "record": entry.record,
				"damage": effect.damage, "duration": effect.duration})
	for effect in fires.values(): hit.status_effects.append(effect)

func _orbit_point(center: Vector2, angle: float) -> Vector2:
	return center + Vector2(cos(angle), sin(angle) * settings.area_y_ratio) * orbit_radius

func _process_orbit(delta: float, weapon: Weapon) -> void:
	# Use the same effective attack-speed curve (including final modifiers) as weapons.
	var speed_multiplier := weapon.data.stats.cooldown / weapon.data.get_effective_cooldown(source.stats)
	var angle_step := settings.orbit_speed * speed_multiplier * delta
	var center := source.global_position + settings.orbit_center_offset * Global.GAME_ENTITY_SCALE
	var previous_angle := orbit_angle
	orbit_angle += angle_step
	radius = settings.radius * Global.GAME_ENTITY_SCALE * source.stats.get_area_radius_multiplier()
	# Sample curved travel, rather than a chord that would cut through the orbit.
	var travel := orbit_radius * absf(angle_step) + center.distance_to(orbit_previous_center)
	var steps := maxi(1, ceili(travel / maxf(1.0, radius * 0.35)))
	var positions: Dictionary = {}
	var cooldowns: Dictionary = {}
	for enemy in get_tree().get_nodes_in_group("combat_enemies"):
		if not _valid_enemy(enemy): continue
		var id := enemy.get_instance_id()
		var shape := enemy.get_node_or_null("HurtboxComponent/CollisionShape2D") as CollisionShape2D
		var point: Vector2 = shape.global_position if shape else enemy.global_position
		positions[id] = point
		var next_hit: float = orbit_hit_cooldowns.get(id, 0.0)
		cooldowns[id] = next_hit
		if elapsed + 0.00001 < next_hit: continue
		var padding := 0.0
		if shape and shape.shape is CircleShape2D:
			padding = shape.shape.radius * maxf(absf(shape.global_scale.x), absf(shape.global_scale.y))
		var extent := Vector2(radius + padding, radius * settings.area_y_ratio + padding)
		var previous_enemy: Vector2 = orbit_enemy_positions.get(id, point)
		var start := (_orbit_point(orbit_previous_center, previous_angle) - previous_enemy) / extent
		for index in steps:
			var fraction := float(index + 1) / steps
			var end := (_orbit_point(orbit_previous_center.lerp(center, fraction), previous_angle + angle_step * fraction) - previous_enemy.lerp(point, fraction)) / extent
			if Geometry2D.get_closest_point_to_segment(Vector2.ZERO, start, end).length_squared() <= 1.0:
				hit.base_damage = weapon.data.get_effective_damage(source.stats)
				hit.damage = hit.base_damage
				enemy._on_hurtbox_component_on_damage(hit)
				cooldowns[id] = elapsed + settings.tick_interval
				break
			start = end
	orbit_enemy_positions = positions
	orbit_hit_cooldowns = cooldowns
	orbit_previous_center = center
	orbit_angle = fposmod(orbit_angle, TAU)
	global_position = _orbit_point(center, orbit_angle)

func _configure_shared_wave(weapon: Weapon) -> void:
	var contributors: Array[Weapon] = weapon.weapon_behaviour.shockwave_contributors()
	var total := 0.0
	var shares: Array[Dictionary] = []
	for equipped in contributors:
		var amount := equipped.data.get_effective_damage(source.stats)
		total += amount
		shares.append({"record":equipped.damage_record,"weight":amount})
	for share in shares: share.weight /= maxf(0.00001,total)
	hit.base_damage = total
	hit.damage = total
	hit.weapon_damage_record = {"wave_damage":0.0,"total_damage":0.0,"contributors":shares}
