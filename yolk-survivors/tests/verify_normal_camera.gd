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
	arena.start_panel.hide(); arena.selection_panel.hide(); arena.weapon_selection_panel.hide()
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop(); arena.spawner.wave_timer.stop()
	arena.stage_mechanics.stop()
	global.player.set_process(false)
	global.player.is_dashing=true
	for weapon in global.player.current_weapons: weapon.set_process(false); weapon.cooldown_timer.stop()
	var camera=arena.get_node("Camera2D")
	assert(not arena.boss_test_mode)
	for stage in arena.environment_controller.stages:
		var geometry=arena.environment_controller.apply_stage(stage)
		arena._configure_environment(geometry)
		var follow=camera.zoom
		var mouse=InputEventMouseButton.new()
		mouse.button_index=MOUSE_BUTTON_RIGHT; mouse.pressed=true
		Input.parse_input_event(mouse)
		await process_frame
		assert(camera.overview,"Normal mode right-click: "+stage.id)
		assert(camera.global_position.distance_to(geometry.movement_bounds.get_center())<0.01,"Playable area must be centered: "+stage.id)
		assert(camera.overview_bounds.encloses(geometry.movement_bounds),"Playable margins: "+stage.id)
		var size=camera.get_viewport_rect().size/camera.zoom
		var view=Rect2(camera.global_position-size*0.5,size)
		assert(view.grow(0.01).encloses(camera.overview_bounds),"Arena cropped: "+stage.id)
		if stage.vessel_body_rect.has_area():
			var sprite=arena.environment_controller.vessel
			var body: Rect2=sprite.global_transform*Rect2(sprite.get_rect().position+stage.vessel_body_rect.position,stage.vessel_body_rect.size)
			assert(body.get_center().distance_to(geometry.movement_bounds.get_center())<0.01,"Sprite and gameplay centers differ: "+stage.id)
			assert(view.grow(0.01).encloses(body),"Vessel body must retain margins: "+stage.id)
		var bg=arena.environment_controller.flat_background
		assert(Rect2(bg.global_position,bg.size).encloses(view),"Background gap: "+stage.id)
		var available=camera.get_viewport_rect().size-camera.overview_padding
		var occupied=camera.overview_bounds.size*camera.zoom
		assert(is_equal_approx(occupied.x,available.x) or is_equal_approx(occupied.y,available.y),"Overview must maximize fit: "+stage.id)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/overview-%s.png"%stage.id))
		var pad=InputEventJoypadButton.new()
		pad.button_index=JOY_BUTTON_RIGHT_SHOULDER; pad.pressed=true
		Input.parse_input_event(pad)
		await process_frame
		assert(not camera.overview and camera.zoom==follow,"Restore follow zoom: "+stage.id)
		arena.set_wave_paused(true)
		camera._input(mouse)
		assert(not camera.overview)
		arena.set_wave_paused(false)
		print("PASS normal camera: ",stage.id)
	arena.clear_arena()
	await process_frame
	arena.queue_free()
	await process_frame
	quit()

