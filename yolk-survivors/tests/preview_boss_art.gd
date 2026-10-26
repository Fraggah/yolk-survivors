extends SceneTree
func _initialize(): call_deferred("preview")
func preview():
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
	var boss=encounter.boss
	global.player.set_process(false)
	global.player.global_position=boss.anchor+Vector2(320,0)
	global.player.is_dashing=true
	for weapon in global.player.current_weapons:
		weapon.set_process(false)
		weapon.cooldown_timer.stop()
	boss.health_component.open_window(0)
	boss.set_present(true)
	boss._process(0.4)
	encounter.hud.show_boss(encounter.settings.boss_name,1000,1000)
	encounter.hud.status.text="BOSS VISUAL PREVIEW"
	var camera=arena.get_node("Camera2D")
	camera.set_process(false)
	camera.set_physics_process(false)
	camera.global_position=boss.anchor+Vector2(0,-250)
	if OS.get_cmdline_user_args().has("--arena"):
		camera.global_position=Vector2.ZERO
		camera.zoom=Vector2.ONE*0.5
	if OS.get_cmdline_user_args().has("--turret") or OS.get_cmdline_user_args().has("--warning"):
		boss.set_present(false)
		var section=load("res://scenes/bosses/rotating_turrets.gd").new()
		encounter.add_child(section)
		section.setup(encounter.area,encounter.settings,boss)
		section.advance(0.65 if OS.get_cmdline_user_args().has("--warning") else 1.8)
		camera.global_position=section.turrets[0].position+Vector2(0,-50)
		camera.zoom=Vector2.ONE*2.0
	if OS.get_cmdline_user_args().has("--arrows"):
		boss.set_present(false)
		var section=load("res://scenes/bosses/moving_fire_lines.gd").new()
		encounter.add_child(section)
		section.setup(encounter.area,encounter.settings,boss)
		section.advance(0.2)
		camera.global_position=Vector2.ZERO
		camera.zoom=Vector2.ONE*0.7
	if OS.get_cmdline_user_args().has("--landing"):
		encounter._begin_landing()
		encounter.time_left=encounter.settings.landing_warning_seconds*0.25
		encounter._update_landing_warning()
		camera.global_position=boss.anchor
		camera.zoom=Vector2.ONE*2.0
	camera.reset_smoothing()
	camera.force_update_scroll()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/boss-landing-warning.png" if OS.get_cmdline_user_args().has("--landing") else "res://../tmp/moving-line-arrow.png" if OS.get_cmdline_user_args().has("--arrows") else "res://../tmp/laser-heat-warning.png" if OS.get_cmdline_user_args().has("--warning") else ("res://../tmp/turret-redesign.png" if OS.get_cmdline_user_args().has("--turret") else ("res://../tmp/boss-arena.png" if OS.get_cmdline_user_args().has("--arena") else "res://../tmp/boss-redesign.png"))))
	arena.clear_arena()
	await process_frame
	arena.queue_free()
	await process_frame
	quit()
