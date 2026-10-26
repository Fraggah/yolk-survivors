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
	assert(encounter.phase==1 and encounter.current_section==0)
	var section=encounter.section_runner
	assert(section.running and section.attack_index==0 and section.stage==0)
	assert(arena.spawner.special_enemies.is_empty(),"No Fueguito in this phase 2 test")
	assert(section.barriers.size()==1 and section.barriers[0].direction==Vector2.UP)
	assert_outside(section)
	var first=section.barriers[0]
	var origin=first.line.visual.position
	var markers=section.arrows.markers()
	assert(markers.size()==1 and markers[0].point.y>root.get_visible_rect().size.y*0.5)
	assert(markers[0].direction.is_equal_approx(Vector2.UP))
	section.advance(0.59)
	assert(first.line.visual.position==origin and first.line.hit.damage==0 and section.stage==0)
	section.advance(0.02)
	assert(section.stage==1 and first.line.hit.damage==5 and section.arrows.markers().is_empty())
	assert(first.line.visual.position.y<origin.y)
	section.advance(1.19)
	assert(first.line.visual.position.is_equal_approx(section.area.background_offset))
	# Freeze the barrier at its midpoint, checking its actual physics hitbox.
	var hurt_shape=player.get_node("HurtboxComponent/CollisionShape2D")
	var hurt_offset=hurt_shape.global_position-player.global_position
	player.global_position=first.line.visual.position-hurt_offset
	player.hit_invulnerability_left=0
	var hp=player.health_component.current_health
	await physics_frame
	await physics_frame
	await create_timer(0.2).timeout
	assert(player.health_component.current_health<hp,"Moving barrier damages through the shared hitbox")
	assert(player.get_active_statuses().is_empty(),"Moving lines do not apply Burning")
	player.is_dashing=true
	player.hit_invulnerability_left=0
	hp=player.health_component.current_health
	await create_timer(0.6).timeout
	assert(player.health_component.current_health==hp,"Existing dash i-frames protect against the moving barrier")
	var before=section.elapsed
	var position_before=first.line.visual.position
	arena.set_wave_paused(true)
	section.advance(10)
	assert(section.elapsed==before and first.line.visual.position==position_before)
	arena.set_wave_paused(false)
	section.advance(1.19)
	assert(section.attack_index==0 and first.line.visual.position.distance_to(first.destination)<15)
	section.advance(0.01)
	assert(first.line.hit.damage==0 and first.line.hit.collision_layer==0)
	assert(section.attack_index==1 and section.stage==0)
	for index in range(2,10):
		section.advance(3)
		assert(section.attack_index==index and section.stage==0)
		var group_size=3 if index>=5 else 1
		var groups=2 if index in [4,9] else 1
		assert(section.barriers.size()==groups*group_size)
		if group_size==3:
			assert(section.barriers[0].direction==section.barriers[1].direction and section.barriers[1].direction==section.barriers[2].direction)
			assert(is_equal_approx(section.barriers[0].origin.distance_to(section.barriers[1].origin),108))
		assert_outside(section)
		markers=section.arrows.markers()
		assert(markers.size()==groups,"Triples retain one warning arrow per incoming direction")
		if index in [4,9]:
			assert(is_zero_approx(section.barriers[0].direction.dot(section.barriers[group_size].direction)))
			assert(is_zero_approx(markers[0].direction.dot(markers[1].direction)))
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/boss-moving-lines-warning.png"))
	section.advance(1.2)
	assert(section.stage==1 and section.barriers.size()==6)
	for barrier in section.barriers: assert(barrier.line.hit.damage==5)
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/boss-moving-lines-active.png"))
	var remaining=section.barriers.duplicate()
	var overlay=section.arrows
	encounter.time_left=1.8
	encounter._process(1.8)
	assert(not section.running and section.barriers.is_empty() and section.attack_index==9)
	assert(encounter.current_section==1 and is_instance_valid(encounter.section_runner))
	assert(not overlay.visible)
	for barrier in remaining: assert(barrier.line.hit.damage==0 and barrier.line.hit.collision_layer==0)
	await process_frame
	assert(get_nodes_in_group("boss_moving_line_arrows").is_empty())
	# Different background size and center, diagonal first, editable damage/width.
	var custom=encounter.settings.duplicate()
	custom.moving_line_directions=PackedVector2Array([Vector2(1,-1)])
	custom.moving_line_width=100
	custom.moving_line_damage=7
	var geometry=encounter.area.duplicate()
	geometry.background_offset=Vector2(350,220)
	geometry.background_size=Vector2(1200,900)
	var configurable=load("res://scenes/bosses/moving_fire_lines.gd").new()
	arena.add_child(configurable)
	configurable.setup(geometry,custom,encounter.boss)
	assert_outside(configurable)
	configurable.advance(1.8)
	assert(configurable.barriers[0].line.visual.position.is_equal_approx(geometry.background_offset))
	assert(configurable.barriers[0].line.shape.shape.size.y==100 and configurable.barriers[0].line.hit.damage==7)
	configurable.stop()
	configurable.queue_free()
	arena.clear_arena()
	await process_frame
	arena.queue_free()
	await process_frame
	print("PASS moving lines: real phase transition, 10 attacks/3 s, exterior origins, oblique geometry, perpendicular doubles 5/10, edge arrows, damage/dash, pause, cleanup and configurable geometry")
	quit()

func assert_outside(section):
	var bounds=Rect2(section.area.background_offset-section.area.background_size*0.5,section.area.background_size)
	for barrier in section.barriers:
		assert(not bounds.has_point(barrier.origin))
		assert(barrier.line.shape.shape.size.y==section.config.moving_line_width)
		for corner in [bounds.position,bounds.end,Vector2(bounds.position.x,bounds.end.y),Vector2(bounds.end.x,bounds.position.y)]:
			assert((corner-barrier.origin).dot(barrier.direction)>section.config.moving_line_width,"Even visual fire margins begin outside the background")
