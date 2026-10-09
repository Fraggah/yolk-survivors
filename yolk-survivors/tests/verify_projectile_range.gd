extends SceneTree
func _initialize() -> void:
	call_deferred("verify")
func verify() -> void:
	load("res://tests/progression_fixture.gd").prepare(root)
	var global = root.get_node("Global")
	global.game_paused = true
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	var player = global.get_selected_player()
	root.add_child(player)
	var count := 0
	for folder in ["the_bloody", "knifer", "corpse_l", "smasher", "hydrant"]:
		var directory = DirAccess.open("res://resources/items/weapons/range/" + folder)
		for file in directory.get_files():
			if not file.begins_with("item_") or not file.ends_with(".tres"): continue
			var item = load("res://resources/items/weapons/range/" + folder + "/" + file)
			var weapon = item.scene.instantiate()
			player.add_child(weapon)
			weapon.setup_weapon(item)
			weapon.get_node("WeaponBehaviour").create_projectile()
			var projectile = root.get_child(root.get_child_count()-1)
			assert(projectile.has_method("setup_projectile"))
			projectile.set_process(false)
			var expected: float = item.stats.max_range * absf(weapon.collision.global_scale.x)
			assert(is_equal_approx(projectile.max_distance, expected))
			var origin: Vector2 = projectile.global_position
			projectile._process(1.0)
			assert(projectile.global_position == origin and projectile.distance_travelled == 0)
			player.position += Vector2(20,15)
			global.game_paused = false
			var first_delta: float = expected * 0.4 / projectile.velocity.length()
			projectile._process(first_delta)
			assert(not projectile.is_queued_for_deletion())
			assert(is_equal_approx(projectile.distance_travelled, expected * 0.4))
			projectile._process(10.0)
			assert(projectile.is_queued_for_deletion())
			assert(is_equal_approx(origin.distance_to(projectile.global_position), expected))
			global.game_paused = true
			weapon.queue_free()
			count += 1
	assert(count == 20)
	var enemy_projectile = load("res://scenes/projectiles/projectile_enemy.tscn").instantiate()
	root.add_child(enemy_projectile)
	enemy_projectile.set_process(false)
	enemy_projectile.setup_projectile(Vector2(100,0), 1, false, 0, player)
	assert(is_inf(enemy_projectile.max_distance))
	global.game_paused = false
	enemy_projectile._process(10)
	assert(not enemy_projectile.is_queued_for_deletion())
	enemy_projectile.queue_free()
	global.game_paused = true
	await process_frame
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	for scene_name in ["enemy_chaser_fast", "enemy_chaser_mid", "enemy_chaser", "enemy_charger", "enemy_shooter", "enemy_fueguito"]:
		var enemy = load("res://scenes/units/enemies/%s.tscn" % scene_name).instantiate()
		arena.add_child(enemy)
		assert(not enemy.get_node("HealthBar").visible, "Enemy health bars stay hidden")
		enemy.queue_free()
	var player_shot = load("res://scenes/projectiles/projectile_smg.tscn").instantiate()
	root.add_child(player_shot)
	var enemy_shot = load("res://scenes/projectiles/projectile_enemy.tscn").instantiate()
	arena.add_child(enemy_shot)
	assert(get_nodes_in_group("projectiles").size() == 2)
	arena._on_spawner_on_wave_completed()
	assert(player_shot.is_queued_for_deletion() and enemy_shot.is_queued_for_deletion())
	assert(not player_shot.visible and not enemy_shot.visible)
	await create_timer(1.1).timeout
	assert(get_nodes_in_group("projectiles").is_empty(), "No shots remain in upgrades")
	arena.queue_free()
	global.player = null
	player.queue_free()
	await process_frame
	print("PASS: 20 ranged tiers, travel cap, pause, enemy compatibility, wave-end cleanup and six hidden enemy health bars")
	quit()
