extends RangeBehaviour

var owned: Array[WeakRef] = []
var last_trail_position := Vector2.ZERO
var trail_initialized := false
var spiral_angle := 0.0

func can_execute_attack() -> bool:
	var settings := weapon.data.stats.spicy_pattern
	if settings.mode == SpicyPatternSettings.Mode.TORNADO:
		var active := 0
		for reference in owned:
			var effect = reference.get_ref()
			if is_instance_valid(effect) and not effect.is_queued_for_deletion(): active += 1
		return active < settings.count
	if settings.mode == SpicyPatternSettings.Mode.TRAIL and trail_contributors()[0] != weapon: return false
	if settings.mode == SpicyPatternSettings.Mode.SHOCKWAVE and shockwave_contributors()[0] != weapon: return false
	if settings.mode == SpicyPatternSettings.Mode.ORBIT:
		for reference in owned:
			if is_instance_valid(reference.get_ref()) and not reference.get_ref().is_queued_for_deletion(): return false
	if settings.mode == SpicyPatternSettings.Mode.TRAIL and trail_initialized:
		return weapon.get_parent().global_position.distance_to(last_trail_position) >= settings.trail_spacing*Global.GAME_ENTITY_SCALE
	return true

func execute_attack() -> void:
	var source := weapon.get_parent() as Player
	if not is_instance_valid(source): return
	var settings := weapon.data.stats.spicy_pattern
	if settings.mode == SpicyPatternSettings.Mode.TRAIL and trail_contributors()[0] != weapon: return
	if settings.mode == SpicyPatternSettings.Mode.SHOCKWAVE and shockwave_contributors()[0] != weapon: return
	if settings.mode == SpicyPatternSettings.Mode.SPIRAL:
		var contributors := spiral_contributors()
		var direction_offset := TAU*contributors.find(weapon)/maxi(1,contributors.size())
		for index in settings.count:
			_spawn_projectile(spiral_angle + direction_offset + deg_to_rad(settings.spiral_seed_gap_degrees) * index)
		spiral_angle = fmod(spiral_angle + deg_to_rad(settings.spiral_step_degrees), TAU)
		return
	owned = owned.filter(func(reference): return is_instance_valid(reference.get_ref()) and not reference.get_ref().is_queued_for_deletion())
	if settings.mode == SpicyPatternSettings.Mode.ORBIT and not owned.is_empty(): return
	if settings.mode == SpicyPatternSettings.Mode.TRAIL:
		if not trail_initialized:
			last_trail_position = source.global_position
			trail_initialized = true
			return
		if source.global_position.distance_to(last_trail_position) < settings.trail_spacing * Global.GAME_ENTITY_SCALE: return
		last_trail_position = source.global_position
	var maximum_active := settings.maximum_active
	if settings.mode == SpicyPatternSettings.Mode.TRAIL:
		for equipped in trail_contributors():
			maximum_active = maxi(maximum_active, equipped.data.stats.spicy_pattern.maximum_active)
	var spawn_count := maxi(0,settings.count-owned.size()) if settings.mode == SpicyPatternSettings.Mode.TORNADO else settings.count
	for index in spawn_count:
		if owned.size() >= maximum_active:
			var oldest = owned.pop_front().get_ref()
			if is_instance_valid(oldest): oldest.queue_free()
		var point := source.global_position
		if settings.mode == SpicyPatternSettings.Mode.CLOUD:
			point = _cloud_spawn_point(source, settings)
			if point == Vector2.INF: continue
		elif settings.mode == SpicyPatternSettings.Mode.MINE:
			point = _mine_spawn_point(source, settings)
		elif settings.mode == SpicyPatternSettings.Mode.TORNADO:
			point += Vector2.from_angle(randf()*TAU) * weapon.get_effective_range() * Global.GAME_ENTITY_SCALE * 0.35
			if source.arena_environment: point = source.arena_environment.clamp_position(point)
		var effect = load("res://effects/spicy_pattern_effect.gd").new()
		effect.configure(weapon, settings, point)
		get_tree().current_scene.add_child(effect)
		owned.append(weakref(effect))
	if settings.mode == SpicyPatternSettings.Mode.ORBIT: weapon.sprite_2d.hide()

func reset_attack() -> void:
	super.reset_attack()
	for reference in owned:
		var effect = reference.get_ref()
		if is_instance_valid(effect): effect.queue_free()
	owned.clear()
	trail_initialized = false
	spiral_angle = 0.0
	weapon.sprite_2d.show()

func trail_contributors() -> Array[Weapon]:
	var result: Array[Weapon] = []
	var player := weapon.get_parent() as Player
	if is_instance_valid(player):
		for equipped in player.current_weapons:
			if not is_instance_valid(equipped) or equipped.is_queued_for_deletion(): continue
			if equipped.data.scene == weapon.data.scene and equipped.data.stats.spicy_pattern and equipped.data.stats.spicy_pattern.mode == SpicyPatternSettings.Mode.TRAIL:
				result.append(equipped)
	# Support manually instantiated weapons used by previews and isolated tests.
	if not result.has(weapon): result.append(weapon)
	return result

func _cloud_spawn_point(source: Player, settings: SpicyPatternSettings) -> Vector2:
	var active: Array[Node2D] = []
	for cloud in get_tree().get_nodes_in_group("ghost_clouds"):
		if cloud.is_queued_for_deletion() or cloud.source != source: continue
		if cloud.elapsed >= cloud.settings.lifetime*cloud.duration_multiplier: continue
		active.append(cloud)
	if active.is_empty(): return _random_cloud_point(source, settings)
	var reach := maxf(0.0,weapon.get_effective_range())*Global.GAME_ENTITY_SCALE
	var own_radius := settings.radius*Global.GAME_ENTITY_SCALE*source.stats.get_area_radius_multiplier()
	var best := Vector2.INF
	var best_score := -1.0
	var best_distance := 0.0
	for attempt in settings.cloud_spawn_attempts:
		var point := _random_cloud_point(source, settings)
		var score := INF
		var nearest := INF
		for cloud in active:
			var offset: Vector2 = point-cloud.global_position
			offset.y /= minf(settings.area_y_ratio,cloud.settings.area_y_ratio)
			var distance := offset.length()
			var separation: float = settings.cloud_min_separation*(own_radius+cloud.radius)*0.5
			score = minf(score,distance/maxf(0.001,separation))
			nearest = minf(nearest,distance)
		if score > best_score:
			best = point
			best_score = score
			best_distance = nearest
		if score >= 1.0 and nearest > 0.01: return point
	# Crowded areas can partially overlap, but never reuse a coincident center.
	if best_distance > maxf(0.01,minf(12.0*Global.GAME_ENTITY_SCALE,reach*0.1)): return best
	return Vector2.INF

func _random_cloud_point(source: Player, settings: SpicyPatternSettings) -> Vector2:
	return _local_spawn_point(source, maxf(0.0,weapon.get_effective_range())*Global.GAME_ENTITY_SCALE,settings.area_y_ratio)

func _local_spawn_point(source: Player, reach: float, y_ratio: float) -> Vector2:
	var offset := Vector2.from_angle(randf()*TAU)*sqrt(randf())*reach
	offset.y *= y_ratio
	var point := source.global_position+offset
	if source.arena_environment: point = source.arena_environment.clamp_position(point)
	# Keep the final point inside the local oval even near rounded arena corners.
	offset = point-source.global_position
	var normalized := Vector2(offset.x,offset.y/y_ratio)
	if normalized.length() > reach and normalized.length() > 0.0:
		point = source.global_position+offset*(reach/normalized.length())
	return point

func spiral_contributors() -> Array[Weapon]:
	var result: Array[Weapon] = []
	var player := weapon.get_parent() as Player
	if is_instance_valid(player):
		for equipped in player.current_weapons:
			if not is_instance_valid(equipped) or equipped.is_queued_for_deletion(): continue
			if equipped.data.scene == weapon.data.scene and equipped.data.stats.spicy_pattern and equipped.data.stats.spicy_pattern.mode == SpicyPatternSettings.Mode.SPIRAL:
				result.append(equipped)
	if not result.has(weapon): result.append(weapon)
	return result

func mine_contributors() -> Array[Weapon]:
	var result: Array[Weapon] = []
	var player := weapon.get_parent() as Player
	if is_instance_valid(player):
		for equipped in player.current_weapons:
			if not is_instance_valid(equipped) or equipped.is_queued_for_deletion(): continue
			if equipped.data.scene == weapon.data.scene and equipped.data.stats.spicy_pattern and equipped.data.stats.spicy_pattern.mode == SpicyPatternSettings.Mode.MINE:
				result.append(equipped)
	if not result.has(weapon): result.append(weapon)
	return result

func get_mine_spawn_radius() -> float:
	var config := weapon.data.stats.spicy_pattern
	var copies := mine_contributors().size()
	return maxf(0.0,weapon.get_effective_range())*Global.GAME_ENTITY_SCALE*(1.0+maxi(0,copies-1)*config.mine_spawn_growth_per_copy)

func _mine_spawn_point(source: Player, settings: SpicyPatternSettings) -> Vector2:
	return _local_spawn_point(source,get_mine_spawn_radius(),settings.area_y_ratio)

func shockwave_contributors() -> Array[Weapon]:
	var result: Array[Weapon] = []
	var player := weapon.get_parent() as Player
	if is_instance_valid(player):
		for equipped in player.current_weapons:
			if not is_instance_valid(equipped) or equipped.is_queued_for_deletion(): continue
			if equipped.data.scene == weapon.data.scene and equipped.data.item_tier == weapon.data.item_tier and equipped.data.stats.spicy_pattern and equipped.data.stats.spicy_pattern.mode == SpicyPatternSettings.Mode.SHOCKWAVE:
				result.append(equipped)
	if not result.has(weapon): result.append(weapon)
	return result
