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
	encounter.settings=encounter.settings.duplicate()
	encounter.settings.phase_two_fueguito_enabled=false
	var player=global.player
	player.set_process(false)
	player.get_node("HPTimer").stop()
	player.stats.block_chance=0
	player.is_dashing=true
	for weapon in player.current_weapons:
		weapon.set_process(false)
		weapon.cooldown_timer.stop()
	encounter._process(3.01)
	for phase in 2:
		for section in 3: encounter._process(30.01)
		encounter._process(encounter.settings.landing_warning_seconds+0.01)
		encounter._process(encounter.settings.fall_seconds+0.01)
		encounter.boss.health_component.take_damage(10000)
	encounter._process(30.01)
	assert(encounter.phase==2 and encounter.current_section==1)
	var section=encounter.section_runner
	assert(section.turrets.size()==1 and section.last_batch==0)
	section.random.seed=789
	var modes={}
	var first=section.turrets[0]
	modes[first.moving]=true
	var bounds=section.area.movement_bounds
	assert(first.path_start.is_equal_approx(bounds.position+bounds.size*Vector2(0.18,0.25)))
	assert(first.path_end.is_equal_approx(bounds.position+bounds.size*Vector2(0.82,0.25) if first.moving else first.path_start))
	assert(first.position==first.path_start and first.path_cue.visible==first.moving and first.cue.visible!=first.moving and first.beams.stage==0)
	var initial_angle=first.base_angle
	assert(Vector2.from_angle(initial_angle).dot(first.path_start.direction_to(player.global_position))>0.999)
	section.advance(0.6)
	assert(first.position==first.path_start and first.angle==initial_angle)
	section.advance(0.61)
	assert(first.beams.stage==1)
	assert(first.position.distance_to(first.path_start)>0 if first.moving else first.position==first.path_start)
	section.advance(0.89)
	assert(first.position.is_equal_approx(first.path_start.lerp(first.path_end,0.5)))
	assert(first.body.position==first.position and is_equal_approx(first.angle,initial_angle+(0 if first.moving else deg_to_rad(27))))
	assert(section.turrets.size()==2 and section.turrets[1].beams.stage==0)
	var preview=section.turrets[1]
	assert(preview.position==preview.path_start and preview.path_cue.visible==preview.moving)
	for line in first.beams.lines:
		assert(Geometry2D.get_closest_point_to_segment(first.position,line.start,line.end).distance_to(first.position)<0.01)
		assert(line.hit.damage==5 and line.shape.shape.size.y==72)
	var hurt_shape=player.get_node("HurtboxComponent/CollisionShape2D")
	var hurt_offset=hurt_shape.global_position-player.global_position
	player.global_position=first.position-hurt_offset
	player.is_dashing=false
	player.hit_invulnerability_left=0
	var hp=player.health_component.current_health
	await physics_frame
	await physics_frame
	await create_timer(0.2).timeout
	assert(first.shape.global_position.is_equal_approx(first.body.global_position))
	assert(player.health_component.current_health<hp and player.get_active_statuses().is_empty())
	player.is_dashing=true
	player.hit_invulnerability_left=0
	hp=player.health_component.current_health
	await create_timer(0.6).timeout
	assert(player.health_component.current_health==hp)
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/boss-mobile-turrets.png"))
	section.advance(0.9)
	assert(first.body.position==first.path_end and first.body.retiring and not first.path_cue.visible)
	assert(first.contact.damage==0 and first.beams.lines.is_empty())
	assert(section.turrets.size()==1 and preview.beams.stage==1 and preview.position==preview.path_start)
	section.advance(1.5)
	assert(preview.position.is_equal_approx(preview.path_start.lerp(preview.path_end,0.5)))
	assert(preview.rotation_sign==(0 if preview.moving else -1))
	modes[preview.moving]=true
	var before=preview.position
	var angle_before=preview.angle
	arena.set_wave_paused(true)
	section.advance(10)
	assert(preview.position==before and preview.angle==angle_before)
	arena.set_wave_paused(false)
	section.advance(1.51)
	assert(section.last_batch==2 and section.turrets.size()==1)
	for batch in range(3,10):
		section.advance(batch*3.0+0.01-section.elapsed)
		assert(section.turrets.size()==1 and section.last_batch==batch and section.turrets[0].beams.stage==1)
		var turret=section.turrets[0]
		modes[turret.moving]=true
		section.advance(1.49)
		assert(turret.position.is_equal_approx(turret.path_start.lerp(turret.path_end,0.5)))
		assert(is_equal_approx(turret.angle,turret.base_angle+turret.rotation_sign*deg_to_rad(45)))
		if turret.moving:
			assert(turret.angle==turret.base_angle and turret.rotation_sign==0 and not turret.cue.visible)
		else:
			assert(turret.position==turret.path_start and not turret.path_cue.visible)
		for fraction in [0.0,0.25,0.5,0.75,1.0]:
			var point=turret.path_start.lerp(turret.path_end,fraction)
			assert(section.area.clamp_position(point).is_equal_approx(point))
	assert(modes.size()==2,"Both mutually exclusive modes occur")
	var probe=load("res://scenes/bosses/mobile_rotating_turrets.gd").new()
	probe.random.seed=1234
	var moving_count=0
	for sample in 10000:
		if probe.roll_moving(): moving_count+=1
	assert(moving_count>4500 and moving_count<5500)
	probe.free()
	var remaining=section.turrets[0]
	var overlay=section.indicators
	encounter.time_left=30-section.elapsed
	encounter._process(encounter.time_left)
	assert(not section.running and section.turrets.is_empty() and section.last_batch==9)
	assert(not remaining.path_cue.visible and remaining.contact.damage==0 and not overlay.visible)
	assert(encounter.current_section==2 and is_instance_valid(encounter.section_runner))
	encounter._clear_section() # Isolate retired overlays from the new random final attack.
	await process_frame
	assert(get_nodes_in_group("boss_turret_paths").is_empty() and get_nodes_in_group("boss_turret_indicators").is_empty())
	arena.clear_arena()
	await process_frame
	arena.queue_free()
	await process_frame
	print("PASS mobile turrets: real phase 3 entry, normalized A/B, stationary warning/path, exclusive 50/50 movement or rotation, contact/beam alignment, dash, seamless 3 s handoffs, pause, valid paths and cleanup")
	quit()
