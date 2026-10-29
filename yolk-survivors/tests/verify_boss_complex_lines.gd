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
	assert(encounter.phase==2 and encounter.current_section==0)
	var section=encounter.section_runner
	section.random.seed=12345
	section.history.clear()
	section._begin_attack(0)
	section.advance(0)
	var damage_checked={}
	var old_attack
	for index in 12:
		section.advance(maxf(0,index*2.5+0.01-section.elapsed))
		assert(section.attack_index==index and section.stage==0 and section.history.size()==index+1)
		if index>0: assert(not (section.history[index-1]==1 and section.history[index]==1),"Moving attacks cannot be consecutive")
		if is_instance_valid(old_attack): assert(not old_attack.running)
		old_attack=section.attack
		if section.attack_kind==0:
			assert(section.attack.lines.size()==20)
			assert(section.attack.lines.any(func(line): return Geometry2D.get_closest_point_to_segment(player.global_position,line.start,line.end).distance_to(player.global_position)<0.01))
		else:
			assert(section.attack.barriers.size()==5 and section.attack.arrows.markers().size()==1)
			assert(section.attack.config.moving_line_warning_seconds==0.5 and section.attack.config.moving_line_travel_seconds==1.5)
			var barriers=section.attack.barriers
			for i in 5:
				assert(barriers[i].direction==barriers[0].direction and barriers[i].line.hit.damage==0)
				if i>0: assert(is_equal_approx(barriers[i].origin.distance_to(barriers[i-1].origin),108))
			var bounds=Rect2(section.area.background_offset-section.area.background_size*0.5,section.area.background_size)
			for barrier in barriers:
				for corner in [bounds.position,bounds.end,Vector2(bounds.position.x,bounds.end.y),Vector2(bounds.end.x,bounds.position.y)]:
					assert((corner-barrier.origin).dot(barrier.direction)>72,"All five lines start outside the background")
		var chosen_kind=section.attack_kind
		var before=section.elapsed
		section.advance(0.1)
		assert(section.attack_kind==chosen_kind and section.history.size()==index+1,"One roll per attack, not per frame")
		if not damage_checked.has(chosen_kind):
			section.advance(index*2.5+1.25-section.elapsed)
			assert(section.stage==1)
			await check_damage(section,player)
			damage_checked[chosen_kind]=true
			if OS.get_cmdline_user_args().has("--capture"):
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/boss-complex-%d.png" % chosen_kind))
		if index==0:
			before=section.elapsed
			arena.set_wave_paused(true)
			section.advance(10)
			assert(section.elapsed==before and section.history.size()==1)
			arena.set_wave_paused(false)
	assert(damage_checked.size()==2 and section.history.size()==12)
	assert(encounter.settings.moving_line_parallel_count==3 and encounter.settings.moving_line_interval==3)
	assert(encounter.settings.static_line_patterns[0].horizontal_positions.size()==8)
	# Reproducible sampling exercises the actual roll used by the section.
	var probe=load("res://scenes/bosses/complex_fire_lines.gd").new()
	probe.random.seed=9876
	var moving_count=0
	for sample in 10000: moving_count+=probe.roll_kind()
	assert(moving_count>4500 and moving_count<5500)
	probe.history.append(1)
	assert(probe.roll_kind()==0,"A moving attack forces a static successor")
	probe.history.clear()
	for sample in 10000:
		var kind=probe.roll_kind()
		assert(probe.history.is_empty() or probe.history.back()!=1 or kind==0)
		probe.history.append(kind)
	probe.free()
	var remaining=section.attack
	encounter.time_left=30-section.elapsed
	encounter._process(encounter.time_left)
	assert(not section.running and section.attack==null and section.history.size()==12)
	assert(not remaining.running)
	assert(encounter.current_section==1 and is_instance_valid(encounter.section_runner))
	await process_frame
	assert(get_nodes_in_group("boss_moving_line_arrows").is_empty() and get_nodes_in_group("boss_hazards").size()==1)
	arena.clear_arena()
	await process_frame
	arena.queue_free()
	await process_frame
	print("PASS complex lines: real phase 3 entry, 12 attacks/2.5 s, conditional 50/50 and no consecutive moving attacks, static 20/moving 5, 0.5/1.5 timing, exterior origins, unchanged phases, damage/dash, pause and cleanup")
	quit()

func check_damage(section,player):
	var line=section.attack.lines[0] if section.attack_kind==0 else section.attack.barriers[2].line
	var hurt_shape=player.get_node("HurtboxComponent/CollisionShape2D")
	var hurt_offset=hurt_shape.global_position-player.global_position
	player.is_dashing=false
	player.hit_invulnerability_left=0
	var hp=player.health_component.current_health
	player.global_position=line.visual.global_position-hurt_offset
	await physics_frame
	await physics_frame
	await create_timer(0.2).timeout
	assert(player.health_component.current_health<hp)
	assert(player.has_status(player.State.BURNING))
	player.is_dashing=true
	# Isolate dash contact immunity from the Burning already applied by the laser.
	player.status_controller.clear()
	await process_frame
	player.hit_invulnerability_left=0
	hp=player.health_component.current_health
	await create_timer(0.6).timeout
	assert(player.health_component.current_health==hp)
