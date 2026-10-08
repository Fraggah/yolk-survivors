extends SceneTree
func _initialize() -> void:
	call_deferred("verify")
func verify() -> void:
	var global = root.get_node("Global")
	global.game_paused = true
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	var spawner = arena.spawner
	var rules = load("res://resources/difficulty_rules.gd")
	var names = ["chaser_fast", "chaser_mid", "chaser_slow", "charger", "shooter"]
	var paths = ["enemy_chaser_fast", "enemy_chaser_mid", "enemy_chaser", "enemy_charger", "enemy_shooter"]
	for difficulty in range(6):
		spawner.reset_run(difficulty)
		assert(spawner.wave_index == 1 and spawner.difficulty_index == difficulty)
		for wave in range(1, 11):
			spawner.wave_index = wave
			spawner.current_wave_data = spawner.find_wave_data()
			assert(spawner.current_wave_data != null)
			spawner.start_spawn_timer()
			var expected_interval: float = spawner.current_wave_data.fixed_spawn_time * (0.65 if rules.is_horde(difficulty, wave) else 1.0)
			assert(is_equal_approx(spawner.spawn_timer.wait_time, expected_interval))
			spawner.spawn_timer.stop()
			for index in names.size():
				var base = load("res://resources/units/enemies/stats_enemy_%s.tres" % names[index])
				var original_hp: float = base.health
				var original_damage: float = base.damage
				var enemy = load("res://scenes/units/enemies/%s.tscn" % paths[index]).instantiate()
				spawner.prepare_enemy(enemy)
				var multiplier: float = [1.0, 1.0, 1.0, 1.12, 1.26, 1.4][difficulty]
				assert(enemy.stats != base)
				assert(is_equal_approx(enemy.stats.health, (base.initial_health + base.health_increase_per_wave * (wave-1)) * multiplier))
				assert(is_equal_approx(enemy.stats.damage, (base.initial_damage + base.damage_increase_per_wave * (wave-1)) * multiplier))
				assert(enemy.stats.speed == base.speed)
				assert(base.health == original_hp and base.damage == original_damage)
				enemy.free()
			for sample in 50:
				assert(spawner.get_enemy_scene() != null, "Empty weighted spawn")
	assert(not rules.is_horde(1, 6) and rules.is_horde(2, 6))
	assert(not rules.is_horde(3, 4) and rules.is_horde(4, 4))
	var early_wave = load("res://resources/wave/data/wave_config_1.tres")
	var early_count := 0
	for entry in early_wave.units:
		assert(entry.unit_scene != null)
		if entry.minimum_difficulty == 1:
			early_count += 1
			assert(not entry.is_eligible(0,3))
			assert(not entry.is_eligible(1,2))
			assert(entry.is_eligible(1,3))
	assert(early_count == 2)
	# Starting through the actual selection applies difficulty before wave 1.
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	global.main_weapon_selected = load("res://resources/items/weapons/melee/spatula/item_spatula_1.tres")
	arena._on_level_selected(5)
	assert(spawner.difficulty_index == 5 and global.level_selected == 5 and spawner.wave_index == 1)
	global.player.set_process(false)
	global.player.set_physics_process(false)
	spawner.spawn_timer.stop()
	global.player.position = Vector2(10000, 10000)
	spawner.max_alive_enemies = 1
	spawner.spawn_enemy()
	spawner.spawn_enemy()
	assert(spawner.pending_spawns == 1, "Concurrent spawn reservations respect cap")
	spawner.spawn_timer.stop()
	await create_timer(1.1).timeout
	assert(spawner.alive_enemy_count() == 1)
	var spawned = spawner.spawned_enemies[0]
	assert(is_equal_approx(spawned.health_component.max_health, spawned.stats.initial_health * 1.4))
	var count_before: int = spawner.alive_enemy_count()
	spawner.spawn_enemy()
	assert(spawner.pending_spawns == 0 and spawner.alive_enemy_count() == count_before)
	spawner.spawn_timer.stop()
	# Cancel a pending effect by restarting; no enemy may leak into the new run.
	# Counting must tolerate freed, queued and null entries without losing typing.
	var freed_enemy = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	spawner.spawned_enemies.append(freed_enemy)
	freed_enemy.free()
	var queued_enemy = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	root.add_child(queued_enemy)
	spawner.spawned_enemies.append(queued_enemy)
	queued_enemy.queue_free()
	spawner.spawned_enemies.append(null)
	assert(spawner.alive_enemy_count() == 1, "Ignore freed, queued and null enemies")
	assert(spawner.spawned_enemies.size() == 1 and spawner.spawned_enemies.is_typed())
	var saved_health: float = spawned.health_component.current_health
	spawned.health_component.current_health = 0.0
	assert(spawner.alive_enemy_count() == 0, "Dead enemies do not consume live capacity")
	spawned.health_component.current_health = saved_health
	assert(spawner.alive_enemy_count() == 1)
	spawner.clear_enemies()
	spawner.spawn_enemy()
	assert(spawner.pending_spawns == 1)
	spawner.reset_run(0)
	await create_timer(1.1).timeout
	assert(spawner.alive_enemy_count() == 0 and spawner.pending_spawns == 0)
	assert(spawner.wave_index == 1 and spawner.difficulty_index == 0)
	assert(spawner.wave_timer.is_stopped() and spawner.spawn_timer.is_stopped())
	var fueguito = load("res://resources/units/enemies/stats_enemy_fueguito.tres")
	assert(fueguito.health == 1 and fueguito.damage == 5 and fueguito.speed == 150)
	arena.level_panel.enable_buttons(2)
	for index in 6:
		assert(arena.level_panel.buttons[index].disabled == (index > 2))
	arena.level_panel._show_difficulty(5)
	assert(arena.level_panel.get_node("%DifficultyDescription").text.contains("40%"))
	global.game_paused = true
	global.player.queue_free()
	global.player = null
	await create_timer(6.5).timeout
	arena.queue_free()
	await process_frame
	print("PASS: 300 enemy/difficulty/wave combinations, immutable bases, wave 1 scaling, pools/hordes, real concurrent cap, stale spawn cancellation, resets, difficulty UI and unchanged Fueguito")
	quit()
