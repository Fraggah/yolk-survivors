extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	var spawner = arena.spawner
	spawner.wave_index = 1
	spawner.current_wave_data = spawner.find_wave_data().duplicate()
	var player_base = load("res://resources/units/players/player_well_rounded.tres").speed
	var fast_base = load("res://resources/units/enemies/stats_enemy_chaser_fast.tres").speed
	assert(player_base == 300 and fast_base == 240)
	for id in ["chaser_mid","chaser_fast","chaser_slow","charger","shooter","fueguito"]:
		var profile = load("res://resources/wave/enemies/%s.tres" % id)
		for test_mode in [false,true]:
			spawner.temporary_crowd_test = test_mode
			var enemy = profile.scene.instantiate()
			spawner.prepare_enemy(enemy,profile)
			assert(enemy.stats.speed < player_base)
			for path in DirAccess.get_files_at("res://resources/units/players"):
				if path.ends_with(".tres"):
					assert(enemy.stats.speed < load("res://resources/units/players/" + path).speed)
			if id != "chaser_fast": assert(enemy.stats.speed < fast_base)
			enemy.free()
	var profile = load("res://resources/wave/enemies/chaser_fast.tres")
	spawner.current_wave_data.speed_multiplier = 2
	var enemy = profile.scene.instantiate()
	spawner.prepare_enemy(enemy,profile)
	assert(enemy.stats.speed == 480 and enemy.stats.speed > player_base, "Later speed modifiers remain unrestricted")
	enemy.free()
	arena.queue_free()
	await process_frame
	print("PASS six permanent base speeds below all ten characters, Fast 240 fastest, identical with test enabled/disabled, later modifiers not capped")
	quit()
