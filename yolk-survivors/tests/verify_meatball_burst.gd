extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var global = root.get_node("Global")
	var item = load("res://resources/items/weapons/range/meatball_machinegun/item_meatball_machinegun_1.tres")
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = item
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	var player = global.player
	player.set_process(false)
	var weapon = player.current_weapons[0]
	weapon.set_process(false)
	var target = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	arena.add_child(target)
	target.set_process(false)
	target.can_move = false
	target.global_position = weapon.global_position + Vector2(0,200)
	weapon.closest_target = target
	var current = item
	for tier in 4:
		assert(current.stats.ranged_settings.lock_burst_aim)
		assert(current.stats.ranged_settings.burst_count == 3)
		current = current.upgrade_to
	for direction in [0.0, PI/2]:
		weapon.rotation = direction
		weapon.weapon_behaviour.execute_attack()
		var seen = {}
		var elapsed := 0.0
		while elapsed < 0.4:
			if weapon.is_attacking:
				weapon.rotate_to_target()
				assert(is_equal_approx(weapon.rotation, direction), "Burst keeps its original aim")
			for node in get_nodes_in_group("projectiles"):
				if node.has_method("setup_projectile") and not seen.has(node.get_instance_id()):
					seen[node.get_instance_id()] = true
					node.set_process(false)
					assert(node.velocity.normalized().is_equal_approx(Vector2.from_angle(direction)))
			await process_frame
			elapsed += root.get_process_delta_time()
		assert(seen.size() == 3)
		assert(not weapon.is_attacking and not weapon.weapon_behaviour.lock_aim_during_attack)
		for node in get_nodes_in_group("projectiles"): node.queue_free()
		await process_frame
	weapon.weapon_behaviour.execute_attack()
	weapon.weapon_behaviour.reset_attack()
	assert(not weapon.weapon_behaviour.lock_aim_during_attack)
	await create_timer(0.25).timeout
	assert(get_nodes_in_group("projectiles").is_empty(), "Reset cancels pending shots")
	arena.queue_free()
	await process_frame
	print("PASS Meatball burst: three fixed-direction shots, next burst reaims and reset cancels pending shots")
	quit()
