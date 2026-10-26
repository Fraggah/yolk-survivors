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
	var checks=0
	for script in ["fixed_turrets","rotating_turrets","mobile_rotating_turrets"]:
		for fraction in [Vector2(0.18,0.23),Vector2(0.52,0.2),Vector2(0.5,0.5),Vector2.ZERO,Vector2.ONE,Vector2(0,1),Vector2(1,0)]:
			global.player.global_position=encounter.area.clamp_position(encounter.area.movement_bounds.position+encounter.area.movement_bounds.size*fraction)
			var section=load("res://scenes/bosses/%s.gd"%script).new()
			encounter.add_child(section)
			section.setup(encounter.area,encounter.settings,boss)
			for batch in 12:
				if batch>0: section._spawn_batch(batch,batch*3.0)
				for turret in section.turrets:
					assert(turret.body.global_position.distance_to(global.player.global_position)>=219.99,"Unsafe turret birth: %s"%script)
					assert(encounter.area.clamp_position(turret.body.position).is_equal_approx(turret.body.position))
					checks+=1
				# Also validate the shared fallback when the planned point overlaps exactly.
				var safe: Vector2=section._safe_spawn_position(global.player.global_position)
				assert(safe.distance_to(global.player.global_position)>=219.99)
			section.stop()
			section.queue_free()
			await process_frame
	arena.clear_arena()
	arena.queue_free()
	await process_frame
	print("PASS turret spawn clearance: ",checks," births across fixed/rotating/mobile, player on spawn points and arena corners, shared overlap fallback")
	quit()
