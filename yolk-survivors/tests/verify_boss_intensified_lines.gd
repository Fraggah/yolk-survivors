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
	# Isolate this attack suite; the persistent pursuer has its own integration test.
	encounter.settings=encounter.settings.duplicate()
	encounter.settings.phase_two_fueguito_enabled=false
	var player=global.player
	player.set_process(false)
	player.get_node("HPTimer").stop()
	player.stats.block_chance=0
	for weapon in player.current_weapons:
		weapon.set_process(false)
		weapon.cooldown_timer.stop()
	encounter._process(3.01)
	for section in 3: encounter._process(30.01)
	encounter._process(encounter.settings.landing_warning_seconds+0.01)
	encounter._process(encounter.settings.fall_seconds+0.01)
	encounter.boss.health_component.take_damage(10000)
	encounter._process(30.01)
	encounter._process(30.01)
	assert(encounter.phase==1 and encounter.current_section==2)
	var section=encounter.section_runner
	assert(section.lines.size()==8 and section.stage==0 and section.pattern_index==0)
	assert(encounter.settings.static_line_patterns[0].horizontal_positions.size()==8)
	assert(encounter.settings.static_line_patterns[0].vertical_positions.size()==12)
	assert(encounter.settings.line_warning_seconds==1.2 and encounter.settings.line_active_seconds==1.0)
	assert(is_equal_approx(section.config.line_warning_seconds,0.8))
	assert(is_equal_approx(section.config.line_warning_seconds+section.config.line_active_seconds+section.config.line_rest_seconds,2))
	for pattern in section.config.static_line_patterns:
		assert(pattern.horizontal_positions.size()==3 and pattern.vertical_positions.size()==5)
	assert(section.lines.any(func(line): return Geometry2D.get_closest_point_to_segment(player.global_position,line.start,line.end).distance_to(player.global_position)<0.01))
	var line=section.lines[0]
	var hurt_shape=player.get_node("HurtboxComponent/CollisionShape2D")
	var hurt_offset=hurt_shape.global_position-player.global_position
	player.global_position=line.start.lerp(line.end,0.5)-hurt_offset
	player.hit_invulnerability_left=0
	var hp=player.health_component.current_health
	section.advance(0.79)
	await physics_frame
	await physics_frame
	assert(section.stage==0 and player.health_component.current_health==hp)
	section.advance(0.02)
	await physics_frame
	await physics_frame
	await create_timer(0.2).timeout
	assert(section.stage==1 and player.health_component.current_health<hp)
	assert(player.has_status(player.State.BURNING))
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/boss-intensified-lines.png"))
	player.is_dashing=true
	# Isolate dash contact immunity from the Burning already applied by the laser.
	player.status_controller.clear()
	await process_frame
	player.hit_invulnerability_left=0
	hp=player.health_component.current_health
	await create_timer(0.6).timeout
	assert(player.health_component.current_health==hp)
	var before=section.elapsed
	arena.set_wave_paused(true)
	section.advance(10)
	assert(section.elapsed==before)
	arena.set_wave_paused(false)
	section.advance(0.66)
	assert(section.stage==2 and line.hit.damage==0)
	section.advance(2.01-section.elapsed)
	assert(section.pattern_index==1 and section.stage==0)
	for attack in range(2,15):
		section.advance(2)
		assert(section.pattern_index==attack%3 and section.stage==0 and section.lines.size()==8)
		for index in 3: assert(is_equal_approx(section.lines[index].start.y,section.lines[index].end.y))
		for index in range(3,8): assert(is_equal_approx(section.lines[index].start.x,section.lines[index].end.x))
	var remaining=section.lines.duplicate()
	encounter.time_left=30-section.elapsed
	encounter._process(encounter.time_left)
	assert(encounter.state==encounter.State.WARNING and encounter.section_runner==null)
	assert(not section.running and section.lines.is_empty())
	for old in remaining: assert(old.hit.damage==0 and old.hit.collision_layer==0)
	await process_frame
	assert(get_nodes_in_group("boss_hazards").is_empty())
	arena.clear_arena()
	await process_frame
	arena.queue_free()
	await process_frame
	print("PASS intensified lines: phase transition, 15 attacks/2 s, 37.5% density, 3 horizontal/5 vertical, unchanged Phase 1, targeting, damage/dash, pause, cleanup before boss")
	quit()
