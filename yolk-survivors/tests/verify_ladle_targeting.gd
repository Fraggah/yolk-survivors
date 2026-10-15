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
	global.player.health_component.debug_invulnerable = true
	for equipped in global.player.current_weapons:
		equipped.set_process(false)
		equipped.weapon_behaviour.reset_attack()
	var weapon = make_weapon("ladle")
	weapon.position = Vector2.ZERO
	var motion = weapon.weapon_behaviour
	var origin: Vector2 = global.player.global_position
	var primary = make_enemy(origin + Vector2(40,0))
	var secondary = make_enemy(origin + Vector2(80,35))
	var outside = make_enemy(origin + Vector2(400,0))
	var dead = make_enemy(origin + Vector2(20,0))
	dead.health_component.current_health = 0
	var untargetable = make_enemy(origin + Vector2(10,0))
	untargetable.targetable = false
	weapon.closest_target = primary
	await physics_frame
	await physics_frame
	motion.execute_attack()
	assert(motion.ladle_secondary_target == secondary, "Second nearest live target is ranked from player within range")
	var next_point: Vector2 = weapon.to_local(secondary.get_node("HurtboxComponent/CollisionShape2D").global_position)
	assert(motion.ladle_travel_direction.is_equal_approx(motion.ladle_start_point.direction_to(next_point)))
	await create_timer(0.8).timeout
	assert(primary.health_component.current_health < 1000 and secondary.health_component.current_health < 1000, "Ladle travels through both targets")
	secondary.queue_free()
	await process_frame
	motion.execute_attack()
	assert(motion.ladle_secondary_target == null)
	assert(motion.ladle_travel_direction.is_equal_approx(Vector2.from_angle(motion.attack_angle + PI / 3)), "No in-range second enemy uses fixed motion")
	motion.reset_attack()
	var effect = load("res://effects/pan_slow_burst.gd")
	assert(effect.contains_offset(Vector2(90,0),100))
	assert(effect.contains_offset(Vector2(0,50),100))
	assert(not effect.contains_offset(Vector2(0,70),100), "Ellipse excludes vertical points inside old circle")
	var pan = make_weapon("frying_pan")
	var center: Vector2 = pan.weapon_behaviour.hitbox.bb.global_position
	var radius: float = pan.weapon_behaviour.pan_slow_radius * absf(pan.global_scale.x)
	var in_oval = make_enemy(center + Vector2(radius*0.8,0))
	var outside_oval = make_enemy(center + Vector2(0,radius*0.8))
	pan.weapon_behaviour._pan_impact()
	assert(in_oval.slow_left > 0 and outside_oval.slow_left == 0)
	var preview = effect.new()
	assert(preview.opacity == 0.3 and preview.y_ratio == 0.55)
	preview.free()
	print("PASS player-ranked secondary targeting/range/alive filters, hits both enemies, fixed fallback, matching subdued elliptical pan area")
	quit()
