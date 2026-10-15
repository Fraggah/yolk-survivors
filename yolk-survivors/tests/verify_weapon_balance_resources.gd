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
	var base = load("res://resources/items/weapons/melee/grater/stats_grater_1.tres")
	var tier2 = load("res://resources/items/weapons/melee/grater/stats_grater_2.tres")
	assert(base.melee_settings != tier2.melee_settings)
	var edited = base.duplicate(true)
	edited.damage = 4.0
	edited.cooldown = 1.4
	edited.melee_settings.hit_count = 2
	edited.melee_settings.capture_radius = 35.0
	edited.melee_settings.preparation_duration = 0.05
	edited.melee_settings.forward_duration = 0.2
	edited.melee_settings.return_duration = 0.05
	assert(ResourceSaver.save(edited,"user://balance_grater.tres") == OK)
	var saved = ResourceLoader.load("user://balance_grater.tres","",ResourceLoader.CACHE_MODE_IGNORE)
	assert(saved.damage == 4.0 and saved.cooldown == 1.4 and saved.melee_settings.hit_count == 2)
	assert(base.melee_settings.hit_count == 3 and tier2.melee_settings.hit_count == 3)
	var weapon = make_weapon("grater")
	weapon.data.stats = saved
	var enemy = make_enemy(weapon.to_global(Vector2(70,0)))
	weapon.closest_target = enemy
	weapon.weapon_behaviour.execute_attack()
	await create_timer(0.8).timeout
	assert(enemy.health_component.current_health == 992 and weapon.weapon_behaviour.pulse_count == 2)
	assert(is_equal_approx(weapon.get_effective_cooldown(),1.4))
	await clear(weapon,[enemy])
	weapon = make_weapon("mitten")
	weapon.data.stats.melee_settings = weapon.data.stats.melee_settings.duplicate(true)
	var tuning = weapon.data.stats.melee_settings
	tuning.direct_damage_multiplier = 0.1
	tuning.collision_damage_multiplier = 1.75
	tuning.launch_speed = 800
	tuning.launch_duration = 0.15
	weapon.weapon_behaviour._begin_pulse()
	assert(is_equal_approx(weapon.weapon_behaviour.hitbox.base_damage,weapon.data.stats.damage*0.1))
	enemy = make_enemy(global.player.global_position+Vector2(180,0))
	enemy.launch_from(weapon.weapon_behaviour.hitbox)
	assert(is_equal_approx(enemy.launch_velocity.length(),800) and enemy.launch_left == 0.15)
	assert(is_equal_approx(enemy.launch_hitbox.base_damage,weapon.data.stats.damage*1.75))
	await clear(weapon,[enemy])
	weapon = make_weapon("frying_pan")
	weapon.data.stats.melee_settings = weapon.data.stats.melee_settings.duplicate(true)
	tuning = weapon.data.stats.melee_settings
	tuning.slow_factor = 0.7
	tuning.slow_radius = 90
	tuning.effect_duration = 0.3
	tuning.effect_opacity = 0.1
	tuning.effect_y_ratio = 0.35
	tuning.status_text = "Chilled"
	tuning.status_text_duration = 0.2
	weapon.data.stats.slow_duration = 0.25
	enemy = make_enemy(weapon.weapon_behaviour.hitbox.bb.global_position)
	enemy.set_process(true)
	weapon.weapon_behaviour._pan_impact()
	assert(enemy.slow_left == 0.25 and enemy.get_movement_multiplier() == 0.7)
	assert(arena.get_children().any(func(node): return node.has_method("setup_text") and node.get_node("Label").text == "Chilled"))
	var burst = arena.get_children().filter(func(node): return node.get_script() == load("res://effects/pan_slow_burst.gd")).back()
	assert(burst.duration == 0.3 and burst.opacity == 0.1 and burst.y_ratio == 0.35)
	await create_timer(0.2).timeout
	assert(is_instance_valid(burst))
	await create_timer(0.2).timeout
	assert(not is_instance_valid(burst) and enemy.get_movement_multiplier() == 1.0)
	await clear(weapon,[enemy])
	print("PASS independent tiers and saved/reloaded tres drive actual damage, cooldown, repeat count, glove launches and pan status/visual lifetimes")
	quit()
