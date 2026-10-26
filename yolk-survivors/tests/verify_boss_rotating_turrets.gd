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
	assert(encounter.phase==1 and encounter.current_section==1)
	var section=encounter.section_runner
	assert(section.turrets.size()==1 and section.last_batch==0)
	assert(encounter.settings.turret_lifetime==4 and encounter.settings.turret_batch_interval==2,"Fixed turret settings remain unchanged")
	assert(section.config.turret_lifetime==3 and section.config.turret_batch_interval==3)
	var first=section.turrets[0]
	assert(first.rotation_sign==1 and first.beams.stage==0 and first.angle==0)
	assert(is_instance_valid(first.cue) and first.cue.turn==1)
	var hurt_shape=player.get_node("HurtboxComponent/CollisionShape2D")
	var hurt_offset=hurt_shape.global_position-player.global_position
	player.global_position=first.position-hurt_offset
	player.hit_invulnerability_left=0
	var hp=player.health_component.current_health
	await physics_frame
	await physics_frame
	await create_timer(0.2).timeout
	assert(player.health_component.current_health<hp,"Rotating turret retains contact damage")
	section.advance(0.6)
	assert(first.angle==0 and first.beams.lines[0].hit.damage==0,"Warning holds the announced orientation")
	section.advance(0.61)
	assert(first.beams.stage==1 and is_equal_approx(first.angle,deg_to_rad(0.3)))
	section.advance(0.5)
	assert(is_equal_approx(first.angle,deg_to_rad(15.3)),"Clockwise rotation is 30 degrees per second after warning")
	assert(is_zero_approx(first.sprite.rotation),"Only the beams rotate")
	var line=first.beams.lines[0]
	var direction=Vector2.from_angle(first.angle)
	player.global_position=first.position+direction*300-hurt_offset
	await physics_frame
	await physics_frame
	player.hit_invulnerability_left=0
	hp=player.health_component.current_health
	await create_timer(0.2).timeout
	assert(player.health_component.current_health<hp,"Rotated beam physics matches the visual orientation")
	assert(player.get_active_statuses().is_empty())
	player.is_dashing=true
	player.hit_invulnerability_left=0
	hp=player.health_component.current_health
	await create_timer(0.6).timeout
	assert(player.health_component.current_health==hp)
	var bounds=Rect2(section.area.background_offset-section.area.background_size*0.5,section.area.background_size)
	for beam in first.beams.lines:
		assert(bounds.grow(0.01).has_point(beam.start) and bounds.grow(0.01).has_point(beam.end))
		assert(beam.shape.shape.size.y==72 and beam.hit.damage==5)
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/boss-rotating-active.png"))
	section.advance(0.1)
	assert(section.turrets.size()==2 and section.last_batch==1)
	assert(first.beams.stage==1 and section.turrets[1].beams.stage==0,"Next warning overlaps the previous firing turret")
	for beam in section.turrets[1].beams.lines: assert(beam.hit.damage==0)
	section.advance(1.19)
	assert(section.turrets.size()==1 and section.turrets[0].beams.stage==1,"At exactly 3 s the old attack ends and the new attack is active")
	assert(first.contact.damage==0 and first.beams.lines.is_empty())
	section.advance(0.01)
	assert(section.last_batch==1 and section.turrets.size()==1)
	assert(first.contact.damage==0 and first.beams.lines.is_empty())
	var second=section.turrets[0]
	assert(second.rotation_sign==-1 and second.beams.stage==1 and is_equal_approx(second.angle,PI*0.25-deg_to_rad(0.3)))
	section.advance(1.2)
	section.advance(0.5)
	assert(is_equal_approx(second.angle,PI*0.25-deg_to_rad(51.3)))
	var before=section.elapsed
	var angle_before=second.angle
	arena.set_wave_paused(true)
	section.advance(10)
	assert(section.elapsed==before and second.angle==angle_before)
	arena.set_wave_paused(false)
	# Move the camera away: the edge icon retains orientation and rotation sense.
	var camera=arena.get_node("Camera2D")
	camera.set_process(false)
	camera.zoom=Vector2(3,3)
	camera.position=second.position+Vector2(1000,0)
	camera.force_update_scroll()
	await process_frame
	var markers=section.indicators.markers()
	assert(markers.size()==1 and markers[0].turn==-1 and is_equal_approx(markers[0].angle,second.angle))
	section.advance(1.3)
	assert(section.last_batch==2 and section.turrets.size()==1)
	for batch in range(3,10):
		section.advance(3)
		assert(section.last_batch==batch and section.turrets.size()==1)
		assert(section.turrets[0].rotation_sign==(1 if batch%2==0 else -1))
		assert(section.turrets[0].beams.stage==1,"Each replacement is already firing at the handoff")
	var remaining=section.turrets[0]
	var overlay=section.indicators
	encounter.time_left=30-section.elapsed
	encounter._process(encounter.time_left)
	assert(section.turrets.is_empty() and not section.running and section.last_batch==9)
	assert(remaining.contact.damage==0 and remaining.beams.lines.is_empty() and not overlay.visible)
	assert(encounter.current_section==2 and is_instance_valid(encounter.section_runner))
	await process_frame
	assert(get_nodes_in_group("boss_turret_indicators").is_empty())
	arena.clear_arena()
	await process_frame
	arena.queue_free()
	await process_frame
	print("PASS rotating turrets: phase transition, one every 3 s, lifetime 3 s, warning, +/-30 degrees/s, contact/rotated damage, dash, pause, edge cues and cleanup")
	quit()
