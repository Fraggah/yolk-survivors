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
	boss.set_present(false)
	var section=load("res://scenes/bosses/mobile_rotating_turrets.gd").new()
	section.forced_moving=1
	encounter.add_child(section)
	section.setup(encounter.area,encounter.settings,boss)
	section.advance(1.8)
	var turret=section.turrets[0]
	var body=turret.body
	var position_before: Vector2=body.global_position
	assert(position_before.distance_to(turret.path_end)>1)
	camera.global_position=position_before+Vector2(0,-50)
	camera.zoom=Vector2.ONE*2
	camera.force_update_scroll()
	section.stop()
	section.queue_free()
	assert(body.global_position.is_equal_approx(position_before),"Retirement must not teleport to the path endpoint")
	assert(body.is_visible_in_tree() and body.retiring)
	assert(body.get_node("HitboxComponent").damage==0)
	body.set_process(false)
	var frames=[0.0,0.08,0.18,0.28]
	for i in frames.size():
		body.animate_retirement(frames[i])
		await process_frame
		await RenderingServer.frame_post_draw
		assert(is_instance_valid(body) and body.is_visible_in_tree())
		assert(body.global_position.is_equal_approx(position_before))
		assert(body.get_node("Sprite").scale.y>0)
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/retire-%s.png"%i))
	body.set_process(true)
	body._process(1.0)
	assert(body.retire_age==0,"First processing pass must preserve the starting pose")
	body.animate_retirement(body.retire_seconds)
	await process_frame
	assert(not is_instance_valid(body))
	arena.clear_arena()
	arena.queue_free()
	await process_frame
	print("PASS turret exit: no endpoint teleport, visible rendered poses after section cleanup, no contact damage, first-frame preservation and final removal")
	quit()
