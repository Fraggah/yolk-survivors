extends RangeBehaviour

func create_projectile() -> void:
	var count := weapon.data.stats.ranged_settings.projectile_count
	for index in count:
		_spawn_projectile(randf_range(0.0, TAU))
