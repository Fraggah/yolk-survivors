extends WeaponBehaviour

func execute_attack() -> void:
	var source := weapon.get_parent() as Player
	if not is_instance_valid(source): return
	var settings := weapon.data.stats.spicy_explosion_settings
	var scale_factor := Global.GAME_ENTITY_SCALE
	var max_distance := weapon.data.stats.max_range * scale_factor
	var min_distance := minf(settings.minimum_distance * scale_factor, max_distance)
	for index in settings.explosion_count:
		var angle := randf_range(0.0, TAU)
		var distance := sqrt(randf_range(min_distance * min_distance, max_distance * max_distance))
		var offset := Vector2.from_angle(angle) * distance
		offset.y *= settings.area_y_ratio
		var point := source.global_position + offset
		if source.arena_environment: point = source.arena_environment.clamp_position(point)
		var blast = load("res://effects/spicy_explosion.gd").new()
		blast.configure(weapon, point, settings, get_base_damage(), get_life_steal_chance())
		get_tree().current_scene.add_child(blast)
