extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	load("res://tests/progression_fixture.gd").prepare(root)
	var global = root.get_node("Global")
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	global.main_weapon_selected = load("res://resources/items/weapons/melee/spatula/item_spatula_1.tres")
	arena._on_level_selected(0)
	var player = global.player
	player.set_process(false)
	player.set_physics_process(false)
	player.health_component.debug_invulnerable = true
	var spawner = arena.spawner
	# Validate original balance independently of the temporary crowd preview.
	spawner.temporary_crowd_test = false
	spawner.spawn_timer.stop()
	assert(spawner.last_wave_number() == 20 and spawner.waves_data.size() == 20)
	var allowed = [
		["chaser_mini"], ["chaser_mini","chaser_mid","chaser_fast"], ["chaser_mini","chaser_mid","chaser_fast"], ["chaser_mid","shooter"],
		["chaser_mid","chaser_slow","chaser_fast"], ["chaser_mid","charger","chaser_fast"], ["chaser_fast","shooter","chaser_mid"],
		["chaser_slow","charger","chaser_mid"], ["chaser_mid","chaser_fast","chaser_slow","charger","shooter"],
		["chaser_mid","chaser_fast","chaser_slow","charger","shooter"],
		["chaser_mid","chaser_fast","chaser_slow"], ["shooter","charger","chaser_mid"], ["chaser_fast","chaser_mid"],
		["chaser_slow","shooter","chaser_mid"], ["chaser_fast","charger","chaser_mid"], ["chaser_slow","chaser_fast","shooter"],
		["charger","shooter"], ["chaser_mid","chaser_fast","chaser_slow","charger"],
		["chaser_mid","chaser_fast","chaser_slow","charger","shooter"],
		["chaser_mid","chaser_fast","chaser_slow","charger","shooter"]]
	for index in range(3, allowed.size()): allowed[index].append("chaser_mini")
	for n in range(1,21):
		spawner.wave_index = n
		var wave = spawner.find_wave_data()
		assert(wave and wave.number == n)
		assert(wave.wave_time == (15 + n*5 if n<=8 else 90 if n==20 else 60))
		assert(wave.common_limit == (35 if n<=5 else 55 if n<=10 else 75 if n<=15 else 65 if n==20 else 90))
		var configured = []
		for group in wave.groups + wave.events:
			assert(group.interval > 0 and group.minimum_count <= group.maximum_count)
			for profile in group.enemies:
				assert(str(profile.id) in allowed[n-1])
				if not configured.has(str(profile.id)): configured.append(str(profile.id))
			for sample in 30: assert(group.select_enemy() in group.enemies)
		assert(configured.size() == allowed[n-1].size())
		for difficulty in 6:
			spawner.current_wave_data = wave
			spawner.difficulty_index = difficulty
			for id in allowed[n-1]:
				var profile = load("res://resources/wave/enemies/%s.tres" % id)
				var enemy = profile.scene.instantiate()
				var base = enemy.stats
				var hp = base.health
				spawner.prepare_enemy(enemy, profile)
				assert(enemy.stats != base and base.health == hp)
				assert(is_equal_approx(enemy.stats.speed, base.speed))
				assert(is_equal_approx(enemy.stats.health, (base.initial_health + base.health_increase_per_wave*(n-1)) * spawner.difficulty_data_for(difficulty).health_multiplier))
				enemy.free()
	# Shapes, facing and animation preserve relative visual size without root scaling.
	spawner.wave_index = 1
	spawner.current_wave_data = spawner.find_wave_data()
	for id in ["chaser_mid","chaser_fast","chaser_slow","charger","shooter","fueguito"]:
		var profile = load("res://resources/wave/enemies/%s.tres" % id)
		var enemy = profile.scene.instantiate()
		spawner.prepare_enemy(enemy, profile)
		arena.add_child(enemy)
		enemy.position = Vector2(600,200)
		enemy.update_rotation()
		assert(is_equal_approx(abs(enemy.visuals.scale.x), .5 * profile.visual_scale))
		assert(enemy.scale == Vector2.ONE * global.GAME_ENTITY_SCALE)
		assert(is_equal_approx(enemy.get_node("HurtboxComponent/CollisionShape2D").shape.radius, 37.0135 * profile.visual_scale))
		enemy.apply_knockback(Vector2.RIGHT, 1.0)
		assert(is_equal_approx(enemy.knockback_power, 1.0 - profile.knockback_resistance))
		enemy.queue_free()
	await process_frame
	# Real geometry safety, including configured physical margin and world obstacles.
	var slow = load("res://resources/wave/enemies/chaser_slow.tres")
	assert(not spawner.is_spawn_position_safe(player.global_position, slow))
	assert(not spawner.is_spawn_position_safe(spawner.arena_environment.movement_bounds.position, slow))
	var obstacle := StaticBody2D.new()
	obstacle.collision_layer = 1
	obstacle.position = Vector2(600,0)
	var shape := CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = 120
	obstacle.add_child(shape)
	arena.add_child(obstacle)
	await physics_frame
	await physics_frame
	assert(not spawner.is_spawn_position_safe(obstacle.position, slow))
	obstacle.queue_free()
	# Timing, priority, bounds, no backlog, actual introduction and cancellation.
	global.game_paused = false
	spawner.wave_index = 2
	spawner.start_wave()
	spawner.spawn_timer.stop()
	spawner.max_alive_enemies = 1
	spawner.scheduler_tick(2.0)
	assert(spawner.pending_spawns == 1)
	assert(spawner.active_groups[0].group.guaranteed)
	spawner.scheduler_tick(40.0)
	assert(spawner.pending_spawns == 1)
	await create_timer(1.2).timeout
	assert(spawner.alive_enemy_count() == 1 and spawner.generated_by_type.get(&"chaser_fast",0) == 1)
	assert(global.coins == global.STARTING_COINS and arena.run_experience.experience == 0)
	spawner.scheduler_tick(41.0)
	assert(spawner.pending_spawns == 0)
	spawner.clear_enemies()
	spawner.spawn_enemy()
	assert(spawner.pending_spawns == 1)
	spawner.reset_run(0)
	await create_timer(1.2).timeout
	assert(spawner.pending_spawns == 0 and spawner.alive_enemy_count() == 0)
	spawner.max_alive_enemies = 500
	# Fueguito belongs exclusively to the pan, never to wave composition.
	spawner.wave_index = 17
	spawner.start_wave()
	spawner.spawn_timer.stop()
	spawner.scheduler_tick(8)
	await create_timer(1.2).timeout
	spawner.scheduler_tick(26)
	await create_timer(1.2).timeout
	assert(spawner.population_count(1) == 0)
	spawner.scheduler_tick(44)
	await create_timer(1.2).timeout
	assert(spawner.population_count(1) == 0)
	spawner.wave_index = 18
	spawner.start_wave()
	spawner.spawn_timer.stop()
	await process_frame
	assert(spawner.population_count(1) == 0)
	spawner.reset_run(0)
	arena.queue_free()
	await process_frame
	print("PASS 20 compositions/durations/caps, 6 difficulties, immutable growth, sizes/shapes, obstacle safety, guaranteed intro, priority, real cap, no backlog/reward, cancellation and exclusive environmental Fueguito")
	quit()
