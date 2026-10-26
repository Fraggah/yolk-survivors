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
	encounter._process(3.01)
	encounter._process(30.01)
	assert(encounter.phase==0 and encounter.current_section==1)
	var section=encounter.section_runner
	var player=global.player
	player.set_process(false)
	player.get_node("HPTimer").stop()
	for weapon in player.current_weapons:
		weapon.set_process(false)
		weapon.cooldown_timer.stop()
	assert(section.turrets.size()==3 and section.last_batch==0)
	var first=section.turrets[0]
	var initial_target=player.global_position
	assert(aims_at(first,initial_target),"A turret aims at the player when the first batch appears")
	assert(not first.diagonal and section.turrets[1].diagonal)
	assert(not first.body.is_in_group("combat_enemies") and first.body.get_child_count()==2)
	assert(first.beams.lines.size()==2 and first.beams.stage==0)
	assert(first.contact.damage==5 and first.contact.status_effects.is_empty())
	assert(root.get_node("EnemyCrowd").nearest(first.position,100)==null,"Turrets are not weapon targets")
	for turret in section.turrets:
		for line in turret.beams.lines:
			assert(line.hit.damage==0 and line.shape.disabled)
			assert(line.shape.shape.size.y==72)
	# Each diagonal segment is clipped to the actual background rectangle.
	var background=Rect2(section.area.background_offset-section.area.background_size*0.5,section.area.background_size)
	for line in section.turrets[1].beams.lines:
		assert(background.grow(0.01).has_point(line.start) and background.grow(0.01).has_point(line.end))
		assert(absf(absf((line.end-line.start).normalized().x)-sqrt(0.5))<0.001)
	var hurt_shape=player.get_node("HurtboxComponent/CollisionShape2D")
	var hurt_offset=hurt_shape.global_position-player.global_position
	player.global_position=first.position-hurt_offset
	player.hit_invulnerability_left=0
	var hp=player.health_component.current_health
	await physics_frame
	await physics_frame
	await create_timer(0.2).timeout
	assert(player.health_component.current_health<hp,"Contact damages during the warning, before any beam fires")
	player.is_dashing=true
	player.hit_invulnerability_left=0
	hp=player.health_component.current_health
	await create_timer(0.6).timeout
	assert(player.health_component.current_health==hp,"Dash protects against turret contact")
	player.is_dashing=false
	player.global_position=first.position+Vector2(250,0)-hurt_offset
	player.hit_invulnerability_left=0
	await create_timer(0.1).timeout
	hp=player.health_component.current_health
	player.hit_invulnerability_left=0
	section.advance(1.21)
	await physics_frame
	await physics_frame
	await create_timer(0.2).timeout
	assert(first.beams.stage==1 and player.health_component.current_health<hp,"Beam damages away from the body")
	assert(player.get_active_statuses().is_empty())
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/boss-turrets-active.png"))
	section.advance(0.79)
	assert(first.beams.stage==1 and first.beams.lines[0].hit.damage==5,"Firing continues through the former rest period")
	assert(aims_at(first,initial_target),"Existing turret keeps its original aim after the player moves")
	assert(section.turrets.size()==6 and section.last_batch==1)
	assert(aims_at(section.turrets[3],player.global_position),"The next diagonal turret aims at the new player position")
	assert(first.beams.stage==1 and section.turrets[3].born==2)
	assert(section.turrets[3].beams.stage==0,"New batch warns while surviving turrets keep firing")
	section.advance(1.21)
	assert(first.beams.stage==1 and section.turrets[3].beams.stage==1,"Both batches can fire together")
	var before=section.elapsed
	arena.set_wave_paused(true)
	section.advance(10)
	assert(section.elapsed==before and section.turrets.size()==6)
	arena.set_wave_paused(false)
	section.advance(0.79)
	assert(section.last_batch==2 and section.turrets.size()==6)
	assert(first.contact.damage==0 and first.contact.collision_layer==0)
	assert(first.beams.lines.is_empty())
	for turret in section.turrets:
		assert(turret.born==2 or turret.born==4)
		assert(turret.beams.stage==(1 if turret.born==2 else 0))
	# Offscreen markers follow viewport transforms and show each turret's pattern.
	var camera=arena.get_node("Camera2D")
	camera.set_process(false)
	camera.position=Vector2.ZERO
	camera.zoom=Vector2(2.5,2.5)
	camera.force_update_scroll()
	await process_frame
	var markers=section.indicators.markers()
	assert(not markers.is_empty())
	var view=Rect2(Vector2.ZERO,root.get_visible_rect().size)
	for marker in markers:
		assert(view.has_point(marker.point) and marker.point.y>=132)
	for i in markers.size():
		for j in range(i+1,markers.size()):
			assert(markers[i].point.distance_to(markers[j].point)>=54,"Nearby edge icons remain separate")
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/boss-turrets-indicators.png"))
	for batch in range(3,15):
		section.advance(2)
		assert(section.turrets.size()==6 and section.last_batch==batch)
		for turret in section.turrets:
			assert(section.elapsed-turret.born<4)
	section.advance(1.99)
	assert(section.running and section.turrets.size()==6 and section.last_batch==14)
	var remaining=section.turrets.duplicate()
	var overlay=section.indicators
	encounter.time_left=0.01
	encounter._process(0.01)
	assert(not section.running and section.last_batch==14,"At 30 s all turrets stop and no extra batch spawns")
	assert(encounter.current_section==2 and is_instance_valid(encounter.section_runner))
	assert(section.turrets.is_empty() and not overlay.visible)
	for turret in remaining: assert(turret.contact.damage==0 and turret.beams.lines.is_empty())
	await process_frame
	assert(get_nodes_in_group("boss_hazards").size()==1 and get_nodes_in_group("boss_turret_indicators").is_empty())
	arena.clear_arena()
	await process_frame
	arena.queue_free()
	await process_frame
	print("PASS fixed turrets: batches 3/6/6, expiry, mixed +/x, warnings, beam/contact damage, dash, pause, background clipping, edge markers, section cleanup")
	quit()

func aims_at(turret: Dictionary, target: Vector2) -> bool:
	for line in turret.beams.lines:
		if Geometry2D.get_closest_point_to_segment(target,line.start,line.end).distance_to(target)<0.01: return true
	return false
