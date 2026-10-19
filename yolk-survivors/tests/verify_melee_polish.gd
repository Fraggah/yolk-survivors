extends "res://tests/verify_melee_rework.gd"
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	global = root.get_node("Global")
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	arena.stage_mechanics.stop()
	global.player.set_process(false)
	global.player.stats.critical_chance = 0
	global.player.health_component.debug_invulnerable = true
	for equipped in global.player.current_weapons:
		equipped.set_process(false)
		equipped.weapon_behaviour.reset_attack()
	var weapon = make_weapon("mitten")
	var motion = weapon.weapon_behaviour
	var original_timing: float = weapon.get_animation_time_scale(0.95 + weapon.data.stats.back_duration)
	assert(motion._timing() > original_timing * 2.0)
	motion._begin_pulse()
	assert(is_equal_approx(motion.hitbox.base_damage, weapon.data.stats.damage * 0.15))
	assert(motion.hitbox.launch_damage == weapon.data.stats.damage)
	motion.reset_attack()
	motion.execute_attack()
	await create_timer(0.3).timeout
	assert(weapon.is_attacking, "Glove swing is slower than half original speed")
	var profile = motion.tuning
	var total_time: float = (profile.preparation_duration + profile.hit_count * (profile.forward_duration + profile.contact_duration + profile.return_duration) + weapon.data.stats.back_duration) * motion._timing()
	await create_timer(maxf(0.01, total_time - 0.3 + 0.1)).timeout
	assert(not weapon.is_attacking)
	await clear(weapon,[])
	weapon = make_weapon("grater")
	motion = weapon.weapon_behaviour
	var enemy = make_enemy(weapon.to_global(Vector2(70,0)))
	weapon.closest_target = enemy
	motion.execute_attack()
	await create_timer(0.2).timeout
	var before: Vector2 = motion.hitbox.bb.global_position
	global.player.position += Vector2(100,45)
	motion._update_grater_anchor()
	assert(motion.hitbox.bb.global_position.distance_to(before) < 0.01)
	await create_timer(1.0).timeout
	assert(not motion.grater_world_locked and weapon.sprite_2d.position.is_equal_approx(weapon.atk_start_pos))
	assert(enemy.health_component.current_health == 1000 - weapon.data.stats.damage * 3)
	await clear(weapon,[enemy])
	for tier in range(1,5):
		var stats = load("res://resources/items/weapons/melee/frying_pan/stats_frying_pan_%s.tres" % tier)
		assert(stats.slow_duration >= 0.0, "Each tier has independently configurable duration")
	weapon = make_weapon("frying_pan")
	motion = weapon.weapon_behaviour
	enemy = make_enemy(motion.hitbox.global_position)
	motion._pan_impact()
	assert(is_equal_approx(enemy.slow_left, weapon.data.stats.slow_duration))
	assert(enemy.has_status_named("Slow") and enemy.status_controller.control_label.text == "Slow")
	var burst = arena.get_children().filter(func(node): return node.get_script() == load("res://effects/pan_slow_burst.gd")).back()
	assert(burst.DURATION == 0.125)
	enemy.set_process(true)
	await create_timer(0.2).timeout
	assert(not is_instance_valid(burst))
	await create_timer(0.3).timeout
	assert(enemy.get_movement_multiplier() == 1.0)
	await clear(weapon,[enemy])
	weapon = make_weapon("pizza_cutter")
	motion = weapon.weapon_behaviour
	for progress in [0.0,0.5,1.0]:
		motion._set_roll_progress(progress)
		assert(is_zero_approx(weapon.sprite_2d.position.y) and is_zero_approx(weapon.sprite_2d.rotation))
	motion._start_roll_return()
	motion._set_roll_progress(0.5)
	assert(weapon.sprite_2d.position.y < 0 and is_equal_approx(weapon.sprite_2d.rotation, deg_to_rad(12)))
	await clear(weapon,[])
	var lengths := []
	for distance in [15.0,140.0]:
		weapon = make_weapon("ladle")
		motion = weapon.weapon_behaviour
		enemy = make_enemy(weapon.to_global(Vector2(distance,0)))
		weapon.closest_target = enemy
		motion.execute_attack()
		var previous: Vector2 = motion.hitbox.bb.global_position
		assert(previous.distance_to(enemy.get_node("HurtboxComponent/CollisionShape2D").global_position) < 0.01)
		var length := 0.0
		for i in range(1,101):
			motion._set_ladle_progress(i / 100.0)
			var point: Vector2 = motion.hitbox.bb.global_position
			length += previous.distance_to(point)
			previous = point
		lengths.append(length)
		assert(absf(length - weapon.data.stats.max_range * absf(weapon.global_scale.x)) < 0.1)
		await clear(weapon,[enemy])
	assert(absf(lengths[0] - lengths[1]) < 0.1, "Ladle arc length independent of target distance")
	print("PASS slow glove/minor direct/full collision damage, anchored grater, tier slows/Slowed/4x effect speed, straight cutter/angled return, range-defined ladle arc")
	quit()
