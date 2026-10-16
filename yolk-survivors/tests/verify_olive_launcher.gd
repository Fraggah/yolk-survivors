extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var global = root.get_node("Global")
	var item = load("res://resources/items/weapons/range/olive_launcher/item_olive_launcher_1.tres")
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = item
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	var player = global.player
	player.set_process(false)
	var weapon = player.current_weapons[0]
	weapon.set_process(false)
	for angle in [0.0, PI/2, PI, -PI/2]:
		weapon.rotation = angle
		for i in 8:
			weapon.weapon_behaviour.create_projectile()
			var shots = get_nodes_in_group("projectiles")
			assert(shots.size() == 2, "One olive and one flying pit")
			for shot in shots:
				shot.set_process(false)
				if str(shot.name).contains("Pit"):
					var error = absf(wrapf(shot.velocity.angle()-angle-PI,-PI,PI))
					assert(error <= PI/4 + 0.0001)
					var expected = item.stats.max_range * absf(weapon.collision.global_scale.x) * 0.5
					assert(is_equal_approx(shot.max_distance, expected))
					assert(is_equal_approx(shot.hitbox.base_damage, item.get_effective_damage(player.stats)*item.stats.ranged_settings.pit_damage_multiplier))
					shot._process(10)
					assert(shot.is_queued_for_deletion())
				else:
					assert(shot.velocity.normalized().is_equal_approx(Vector2.from_angle(angle)))
				shot.queue_free()
			await process_frame
	arena.queue_free()
	await process_frame
	print("PASS Olive launcher: forward olive, backward pit, +/-45 degrees and half range")
	quit()
