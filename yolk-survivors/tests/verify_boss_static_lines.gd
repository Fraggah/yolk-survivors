extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
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
	assert(encounter.state==encounter.State.INTRO and encounter.section_runner==null)
	encounter._process(2.99)
	assert(encounter.section_runner==null)
	encounter._process(0.02)
	var section=encounter.section_runner
	assert(is_instance_valid(section) and encounter.current_section==0 and encounter.phase==0)
	assert(encounter.settings.section_seconds==30)
	var player=global.player
	assert(section.lines.any(func(stripe): return is_equal_approx(stripe.start.y,player.global_position.y)), "One warning targets the player")
	assert(section.lines[0].shape.shape.size.y==72)
	assert(section.lines[0].start.x==encounter.area.background_offset.x-encounter.area.background_size.x*0.5)
	player.set_process(false)
	player.get_node("HPTimer").stop()
	for weapon in player.current_weapons:
		weapon.set_process(false)
		weapon.cooldown_timer.stop()
	assert(section.lines.size()==20 and section.stage==0)
	var line=section.lines[0]
	var point=line.start.lerp(line.end,0.5)
	# Position the actual small player hurtbox on the warning stripe.
	var hurt_shape=player.get_node("HurtboxComponent/CollisionShape2D")
	var hurt_offset=hurt_shape.global_position-player.global_position
	player.global_position=point-hurt_offset
	var hp=player.health_component.current_health
	await create_timer(0.1).timeout
	assert(player.health_component.current_health==hp, "Warnings do not deal damage")
	assert(not line.fire.visible and line.hit.damage==0 and line.shape.disabled)
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/boss-lines-warning.png"))
	section.advance(1.21)
	assert(section.stage==1 and line.fire.visible and line.hit.damage==5)
	await create_timer(0.1).timeout
	assert(player.health_component.current_health<hp, "Active lines damage through player hurtbox")
	assert(player.get_active_statuses().is_empty(), "No Burning on this first version")
	player.is_dashing=true
	player.hit_invulnerability_left=0
	hp=player.health_component.current_health
	await create_timer(0.65).timeout
	assert(player.health_component.current_health==hp, "Dash i-frames protect inside the line")
	player.is_dashing=false
	await create_timer(0.1).timeout
	assert(player.health_component.current_health<hp)
	player.global_position=encounter.area.movement_bounds.position+encounter.area.movement_bounds.size*Vector2(0.79,0.29)-hurt_offset
	player.hit_invulnerability_left=0
	hp=player.health_component.current_health
	await create_timer(0.1).timeout
	assert(player.health_component.current_health==hp, "Gaps between lines remain safe")
	section.advance(1.1)
	assert(section.stage==2 and not line.visual.visible and line.hit.damage==0)
	player.global_position=point-hurt_offset
	player.hit_invulnerability_left=0
	hp=player.health_component.current_health
	await create_timer(0.1).timeout
	assert(player.health_component.current_health==hp, "Rest has no residual damage")
	section.advance(0.7)
	assert(section.pattern_index==1 and section.stage==0 and section.lines.size()==20)
	for i in 8:
		assert(is_equal_approx(section.lines[i].start.y,section.lines[i].end.y))
	for i in range(8,20):
		assert(is_equal_approx(section.lines[i].start.x,section.lines[i].end.x))
	section.advance(1.2)
	assert(section.stage==1)
	if OS.get_cmdline_user_args().has("--capture"):
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/boss-lines-active.png"))
	section.advance(1.8)
	assert(section.pattern_index==2 and section.stage==0 and section.lines.size()==20)
	assert(section.lines[0].start.y==section.lines[0].end.y)
	assert(section.lines[8].start.x==section.lines[8].end.x)
	arena.set_wave_paused(true)
	var before=section.elapsed
	section.advance(5)
	assert(section.elapsed==before)
	arena.set_wave_paused(false)
	# Ten attacks start at 0,3,...,27; no eleventh at 30.
	for attack in range(3,10):
		section.advance(3.0)
		assert(section.pattern_index==attack%3 and section.stage==0 and section.lines.size()==20)
		for i in 8:
			assert(is_equal_approx(section.lines[i].start.y,section.lines[i].end.y))
		for i in range(8,20):
			assert(is_equal_approx(section.lines[i].start.x,section.lines[i].end.x))
	assert(section.elapsed>27 and section.elapsed<28)
	var old_lines=section.lines.duplicate()
	encounter._process(30.01)
	assert(encounter.current_section==1 and is_instance_valid(encounter.section_runner))
	for old_line in old_lines:
		assert(old_line.hit.damage==0 and old_line.hit.collision_layer==0)
	await process_frame
	assert(get_nodes_in_group("boss_hazards").size()==1)
	# Geometry and width are data-driven, including non-default arena dimensions.
	var custom=encounter.settings.duplicate()
	custom.line_width=60
	custom.line_damage=7
	custom.line_target_player=false
	var pattern=load("res://resources/bosses/static_line_pattern.gd").new()
	pattern.horizontal_positions=PackedFloat32Array([0.2])
	pattern.vertical_positions=PackedFloat32Array([0.8])
	custom.static_line_patterns.assign([pattern])
	var area=encounter.area.duplicate()
	area.movement_bounds=Rect2(200,300,1000,600)
	area.corner_radius=0
	area.background_size=Vector2(1400,1000)
	area.background_offset=Vector2(700,600)
	var configurable=load("res://scenes/bosses/static_fire_lines.gd").new()
	arena.add_child(configurable)
	configurable.setup(area,custom,encounter.boss)
	assert(configurable.lines[0].start.is_equal_approx(Vector2(0,420)))
	assert(configurable.lines[0].end.is_equal_approx(Vector2(1400,420)))
	assert(configurable.lines[1].start.is_equal_approx(Vector2(1000,100)))
	assert(configurable.lines[0].shape.shape.size.y==60)
	configurable.advance(1.3)
	assert(configurable.lines[0].hit.damage==7)
	configurable.stop()
	configurable.queue_free()
	arena.clear_arena()
	await process_frame
	arena.queue_free()
	await process_frame
	print("PASS boss static lines: warning/active/rest, actual damage, dash, safe zones, 3 patterns, pause, section cleanup and resource/arena configuration")
	quit()
