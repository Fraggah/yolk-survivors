extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=arena.weapon_selection_panel.weapons_list[0]
	arena.start_panel.hide()
	var short_run := "--short-difficulty" in OS.get_cmdline_user_args()
	var difficulty := 1 if short_run else 0
	if short_run:
		var route = arena.spawner.difficulties[1].duplicate()
		var boss_wave = load("res://resources/wave/data/wave_20.tres").duplicate()
		boss_wave.wave_type = 0
		route.waves = route.waves.slice(3, 4)
		route.waves.append(boss_wave)
		route.health_multiplier = 2.0
		route.damage_multiplier = 1.5
		route.speed_multiplier = 0.75
		arena.spawner.difficulties[1] = route
		assert(arena.level_panel._difficulty_description(1).contains("2 waves"))
	arena._on_level_selected(difficulty)
	var final_wave: int = arena.spawner.last_wave_number()
	if short_run:
		var spawner = arena.spawner
		assert(spawner.wave_index == 1 and spawner.last_wave_number() == 2)
		assert(spawner.find_wave_data() == spawner.difficulties[0].waves[3])
		assert(spawner.wave_data_for(3) == null)
		var profile = load("res://resources/wave/enemies/chaser_mid.tres")
		var enemy = profile.scene.instantiate()
		var base = enemy.stats
		spawner.prepare_enemy(enemy, profile)
		assert(is_equal_approx(enemy.stats.health, base.initial_health * 2.0))
		assert(is_equal_approx(enemy.stats.damage, base.initial_damage * 1.5))
		assert(is_equal_approx(enemy.stats.speed, base.speed * 0.75))
		enemy.free()
	var player=global.player
	player.get_node("HPTimer").stop()
	player.set_process(false)
	for weapon in player.current_weapons:
		weapon.set_process(false)
		weapon.cooldown_timer.stop()
	var stats=player.stats
	var max_health=player.health_component.max_health
	var weapon=player.current_weapons[0]
	arena.spawner.wave_index=final_wave - 1
	var stage=arena.environment_controller.prepare_wave(final_wave)
	arena.shop_panel.set_next_stage(stage,final_wave)
	assert(arena.shop_panel.next_stage_panel.visible)
	assert(arena.shop_panel.next_stage_label.text==load("res://resources/bosses/salchichon.tres").boss_name)
	arena.start_new_wave()
	var encounter=arena.boss_encounter
	encounter.set_process(false)
	assert(arena.spawner.wave_index==final_wave and arena.boss_wave_active and not arena.boss_test_mode)
	assert(arena.wave_active and encounter.active and root.get_node("Progression").run_active)
	assert(arena.spawner.wave_timer.is_stopped() and arena.spawner.spawn_timer.is_stopped())
	assert(global.player==player and player.stats==stats and player.current_weapons[0]==weapon)
	assert(player.health_component.max_health==max_health)
	assert(encounter.boss.health_component.current_health==1000)
	assert(arena.environment_controller.current_stage==encounter.settings.arena_stage)
	arena._on_spawner_on_wave_completed()
	assert(arena.wave_active and encounter.active and not arena.final_screen.visible)
	var before=encounter.time_left
	arena.set_wave_paused(true)
	encounter._process(100)
	assert(encounter.time_left==before)
	arena.set_wave_paused(false)
	encounter.settings=encounter.settings.duplicate()
	encounter.settings.departure_wait_seconds=0
	encounter.settings.takeoff_anticipation_seconds=0
	encounter.settings.takeoff_jump_seconds=0
	player.is_dashing=true
	encounter._process(encounter.settings.initial_wait_seconds+.01)
	for phase in 3:
		assert(encounter.phase==phase)
		for section in 3: encounter._process(encounter.settings.section_seconds+.01)
		encounter._process(encounter.settings.landing_warning_seconds+.01)
		encounter._process(encounter.settings.fall_seconds+.01)
		assert(encounter.state==encounter.State.VULNERABLE)
		encounter.boss.health_component.take_damage(100000)
	await process_frame
	await create_timer(1.2).timeout
	assert(arena.final_screen.visible and arena.final_label.text=="YOU WIN!")
	assert(not root.get_node("Progression").run_active and global.player==null)
	assert(not encounter.active and not arena.boss_wave_active)
	print("PASS difficulty %d: boss preview and victory at wave %d, build preserved, pause and three phases" % [difficulty, final_wave])
	arena.queue_free()
	await process_frame
	await process_frame
	quit()
