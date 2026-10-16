extends RangeBehaviour

var owned: Array[WeakRef] = []
var last_trail_position := Vector2.ZERO
var trail_initialized := false
var spiral_angle := 0.0

func can_execute_attack() -> bool:
	var settings := weapon.data.stats.spicy_pattern
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
	if settings.mode == SpicyPatternSettings.Mode.SPIRAL:
		for index in settings.count:
			_spawn_projectile(spiral_angle + deg_to_rad(settings.spiral_seed_gap_degrees) * index)
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
	for index in settings.count:
		if owned.size() >= settings.maximum_active:
			var oldest = owned.pop_front().get_ref()
			if is_instance_valid(oldest): oldest.queue_free()
		var point := source.global_position
		if settings.mode in [SpicyPatternSettings.Mode.CLOUD, SpicyPatternSettings.Mode.MINE]:
			point = source.arena_environment.random_spawn_position() if source.arena_environment else point + Vector2.from_angle(randf()*TAU)*randf_range(40,400)
		elif settings.mode == SpicyPatternSettings.Mode.TORNADO:
			point += Vector2.from_angle(randf()*TAU) * weapon.data.stats.max_range * Global.GAME_ENTITY_SCALE * 0.35
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
