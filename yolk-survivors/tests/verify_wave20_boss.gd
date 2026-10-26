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
	arena._on_level_selected(0)
	var player=global.player
	player.get_node("HPTimer").stop()
	player.set_process(false)
	for weapon in player.current_weapons:
		weapon.set_process(false)
		weapon.cooldown_timer.stop()
	var stats=player.stats
	var max_health=player.health_component.max_health
	var weapon=player.current_weapons[0]
	arena.spawner.wave_index=19
	var stage=arena.environment_controller.prepare_wave(20)
	arena.shop_panel.set_next_stage(stage,20)
	assert(arena.shop_panel.next_stage_panel.visible)
	assert(arena.shop_panel.next_stage_label.text==load("res://resources/bosses/salchichon.tres").boss_name)
	arena.start_new_wave()
	var encounter=arena.boss_encounter
	encounter.set_process(false)
	assert(arena.spawner.wave_index==20 and arena.boss_wave_active and not arena.boss_test_mode)
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
	print("PASS wave20: shop preview, real build preserved, untimed encounter, pause, three phase caps and normal run victory")
	arena.queue_free()
	await process_frame
	await process_frame
	quit()
