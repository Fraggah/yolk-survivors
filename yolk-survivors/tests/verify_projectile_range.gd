extends SceneTree
func _initialize() -> void:
	call_deferred("verify")
func verify() -> void:
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
	global.player = null
	player.queue_free()
	await process_frame
	print("PASS: 20 ranged weapon tiers share detection/projectile range; pause, moving shooter, exact travel cap and enemy projectile compatibility")
	quit()
