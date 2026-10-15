extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var global = root.get_node("Global")
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
	arena._on_level_selected(0)
	global.player.health_component.debug_invulnerable = true
	global.player.set_process(false)
	var spawner = arena.spawner
	spawner.spawn_timer.stop()
	for wave in [1,2,3,4,5,10,20]:
		spawner.wave_index = wave
		spawner.start_wave()
		spawner.spawn_timer.stop()
		var factor := mini(wave,5)
		assert(spawner.test_wave_multiplier() == factor)
		assert(spawner.population_limit(0) == mini(spawner.max_alive_enemies, spawner.current_wave_data.common_limit * factor))
		for id in ["chaser_mid","chaser_fast","chaser_slow","charger","shooter"]:
			var profile = load("res://resources/wave/enemies/%s.tres" % id)
			assert(spawner.test_profile_count(profile) == (1 if id == "chaser_slow" else factor))
			var enemy = profile.scene.instantiate()
			var base = enemy.stats
			spawner.temporary_crowd_test = false
			spawner.prepare_enemy(enemy, profile)
			var original_hp: float = enemy.stats.health
			var original_speed: float = enemy.stats.speed
			enemy.stats = base
			spawner.temporary_crowd_test = true
			spawner.prepare_enemy(enemy, profile)
			assert(is_equal_approx(enemy.stats.health, original_hp * (4 if id in ["chaser_slow","charger"] else 1)))
			assert(is_equal_approx(enemy.stats.speed, original_speed))
			enemy.free()
	# Real scheduler reserves five actual arrivals for one mid stream, one for Big.
	spawner.wave_index = 5
	spawner.start_wave()
	spawner.spawn_timer.stop()
	var group = load("res://resources/wave/spawn_group.gd").new()
	group.enemies.append(load("res://resources/wave/enemies/chaser_mid.tres"))
	spawner.active_groups.clear()
	spawner.active_groups.append({"group":group,"next":0.0,"executions":0,"pending":0,"completed":0,"active":true})
	spawner.scheduler_tick(0)
	assert(spawner.pending_spawns == 5)
	await create_timer(1.2).timeout
	assert(spawner.generated_by_type.get(&"chaser_mid",0) == 5)
	spawner.clear_enemies()
	group.enemies.clear()
	group.enemies.append(load("res://resources/wave/enemies/chaser_slow.tres"))
	spawner.active_groups.clear()
	spawner.active_groups.append({"group":group,"next":0.0,"executions":0,"pending":0,"completed":0,"active":true})
	spawner.scheduler_tick(0)
	assert(spawner.pending_spawns == 1)
	await create_timer(1.2).timeout
	assert(spawner.generated_by_type.get(&"chaser_slow",0) == 1)
	spawner.temporary_crowd_test = false
	assert(spawner.test_wave_multiplier() == 1 and spawner.population_limit(0) == spawner.current_wave_data.common_limit)
	spawner.wave_timer.stop()
	spawner.spawn_timer.stop()
	spawner.clear_enemies()
	global.game_paused = true
	arena.queue_free()
	await process_frame
	print("PASS temporary density 1/2/3/4/5 plateau, scaled caps, Big unchanged count, Heavy HP x4, permanent speeds preserved, actual spawn arrivals and reversible baseline")
	quit()
