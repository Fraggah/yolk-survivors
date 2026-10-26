extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	await process_frame
	var global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=arena.weapon_selection_panel.weapons_list[0]
	arena.start_panel.hide()
	arena.selection_panel.hide()
	arena.weapon_selection_panel.hide()
	arena._on_boss_test_selected()
	var encounter=arena.boss_encounter
	encounter.set_process(false)
	encounter.settings=encounter.settings.duplicate()
	encounter.settings.departure_wait_seconds=0
	encounter.settings.takeoff_anticipation_seconds=0
	encounter.settings.takeoff_jump_seconds=0
	encounter.settings=encounter.settings.duplicate()
	encounter.settings.test_static_lines_first=true
	encounter.settings.test_moving_lines_first=true
	encounter.settings.test_complex_lines_first=true
	var player=global.player
	player.set_process(false)
	player.get_node("HPTimer").stop()
	player.stats.block_chance=0
	player.is_dashing=true
	for weapon in player.current_weapons:
		weapon.set_process(false)
		weapon.cooldown_timer.stop()
	assert(encounter.phase_hazard==null)
	encounter._process(3.01)
	for section in 3: encounter._process(30.01)
	encounter._process(encounter.settings.landing_warning_seconds+0.01)
	encounter._process(encounter.settings.fall_seconds+0.01)
	encounter.boss.health_component.take_damage(10000)
	assert(encounter.phase==1 and is_instance_valid(encounter.phase_hazard))
	var manager=encounter.phase_hazard
	assert(manager.pending==1 and manager.hazards.is_empty())
	encounter._process(0.44)
	assert(manager.hazards.is_empty())
	var before=manager.elapsed
	arena.set_wave_paused(true)
	encounter._process(10)
	assert(manager.elapsed==before and manager.hazards.is_empty())
	arena.set_wave_paused(false)
	encounter._process(0.02)
	assert(manager.births==1 and manager.hazards.size()==1 and arena.spawner.special_enemies.size()==1)
	var flame=manager.hazards[0]
	flame.set_process(false)
	assert(not flame.targetable and flame.stats.coin_drop==0 and flame.stats.experience_reward==0)
	var hp=flame.health_component.current_health
	flame.health_component.take_damage(9999)
	assert(flame.health_component.current_health==hp)
	var distance=flame.global_position.distance_to(player.global_position)
	flame._process(0.1)
	assert(flame.global_position.distance_to(player.global_position)<distance)
	player.is_dashing=false
	player.hit_invulnerability_left=0
	flame.global_position=player.get_node("HurtboxComponent/CollisionShape2D").global_position
	hp=player.health_component.current_health
	await physics_frame
	await physics_frame
	await create_timer(0.2).timeout
	assert(player.health_component.current_health<hp and player.has_status_named("burning"))
	player.is_dashing=true
	# Sections retain the pursuer until the landing impact.
	for section in 3:
		encounter._process(30.01)
		assert(encounter.phase_hazard==manager and manager.hazards.size()==1 and manager.hazards[0]==flame)
	assert(encounter.state==encounter.State.WARNING)
	encounter._process(encounter.settings.landing_warning_seconds+0.01)
	encounter._process(encounter.settings.fall_seconds+0.01)
	assert(encounter.state==encounter.State.VULNERABLE and encounter.phase_hazard==null and not manager.running)
	assert(not get_nodes_in_group("boss_fueguito_exits").is_empty())
	encounter._process(encounter.settings.vulnerable_seconds+0.01)
	assert(encounter.state==encounter.State.SECTION and encounter.phase_hazard==null)
	encounter._process(30.01)
	encounter._process(encounter.settings.landing_warning_seconds+0.01)
	encounter._process(encounter.settings.fall_seconds+0.01)
	encounter.boss.health_component.take_damage(10000)
	assert(encounter.phase==2 and encounter.phase_hazard==null and arena.spawner.special_enemies.is_empty())
	assert(flame.is_retiring and not flame.visible and flame.get_node("HitboxComponent").damage==0)
	await process_frame
	assert(not is_instance_valid(flame) and get_nodes_in_group("boss_phase_hazards").is_empty())
	# Cancellation during an arrival also removes the flare and pending birth.
	encounter.phase=1
	encounter._begin_phase()
	manager=encounter.phase_hazard
	assert(manager.pending==1)
	encounter.stop()
	assert(encounter.phase_hazard==null and not manager.running and manager.pending==0)
	await process_frame
	assert(get_nodes_in_group("boss_phase_hazards").is_empty())
	arena.clear_arena()
	await process_frame
	arena.queue_free()
	await process_frame
	print("PASS phase 2 Fueguito: safe preview, pursuit/contact/Burning, pause, persistent across sections, removed on impact and absent during window/retry, no rewards, phase cleanup and cancellation")
	quit()
