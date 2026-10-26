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
	global.player.set_process(false)
	global.player.is_dashing=true
	for weapon in global.player.current_weapons:
		weapon.set_process(false)
		weapon.cooldown_timer.stop()
	assert(encounter.boss.health_component.max_health==1000)
	assert(is_equal_approx(global.player.stats.ranged_damage,15) and is_equal_approx(global.player.stats.damage_percent,40) and is_zero_approx(global.player.stats.hp_regen))
	var camera=arena.get_node("Camera2D")
	var follow=camera.zoom
	assert(camera.overview_toggle_enabled and not camera.overview)
	var mouse=InputEventMouseButton.new()
	mouse.button_index=MOUSE_BUTTON_RIGHT
	mouse.pressed=true
	Input.parse_input_event(mouse)
	await process_frame
	assert(camera.overview and camera.zoom.x<follow.x)
	assert(camera.global_position.is_equal_approx(camera.overview_bounds.get_center()))
	var view_size=camera.get_viewport_rect().size/camera.zoom
	assert(view_size.x>=camera.overview_bounds.size.x-0.01 and view_size.y>=camera.overview_bounds.size.y-0.01)
	var old_available=camera.get_viewport_rect().size-Vector2(80,200)
	var old_zoom=minf(old_available.x/camera.world_bounds.size.x,old_available.y/camera.world_bounds.size.y)
	assert(camera.zoom.x>old_zoom*1.1,"Overview should fill substantially more of the viewport")
	var bg=arena.environment_controller.flat_background
	var view_rect=Rect2(camera.global_position-view_size*0.5,view_size)
	assert(Rect2(bg.global_position,bg.size).encloses(view_rect),"Backdrop must cover the entire viewport")
	for script in ["static_fire_lines","fixed_turrets","rotating_turrets","moving_fire_lines"]:
		var section=load("res://scenes/bosses/%s.gd"%script).new()
		encounter.add_child(section)
		section.setup(encounter.area,encounter.settings,encounter.boss)
		section.advance(1.3)
		var beams: Array=[]
		if script=="static_fire_lines": beams=section.lines
		elif script=="moving_fire_lines":
			section.renderer._clear_lines()
			section.barriers.clear()
			section._add_barrier(Vector2(1,1).normalized())
			beams=section.renderer.lines
		else:
			for turret in section.turrets: beams.append_array(turret.beams.lines)
		assert(not beams.is_empty())
		for line in beams:
			assert(not view_rect.grow(80).has_point(line.start) and not view_rect.grow(80).has_point(line.end),"Visible laser endpoint: %s"%script)
		if script=="static_fire_lines":
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/boss-overview-lasers.png"))
		section.stop()
		section.queue_free()
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/boss-overview-fit.png"))
	var before=camera.global_position
	global.player.global_position+=Vector2(150,80)
	await process_frame
	assert(camera.global_position==before)
	mouse.pressed=false
	Input.parse_input_event(mouse)
	await process_frame
	assert(camera.overview)
	var pad=InputEventJoypadButton.new()
	pad.button_index=JOY_BUTTON_RIGHT_SHOULDER
	pad.pressed=true
	Input.parse_input_event(pad)
	await process_frame
	assert(not camera.overview and camera.zoom==follow)
	arena.set_wave_paused(true)
	camera._input(mouse)
	assert(not camera.overview)
	arena.set_wave_paused(false)
	camera.toggle_view()
	camera.configure_view(camera.world_bounds,follow,false)
	assert(not camera.overview and not camera.overview_toggle_enabled and camera.zoom==follow)
	arena.clear_arena()
	await process_frame
	arena.queue_free()
	await process_frame
	print("PASS boss camera: real right-click/R1 events, complete bounds fit, stationary overview, follow zoom restoration and reset")
	quit()


