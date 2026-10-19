extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=arena.weapon_selection_panel.weapons_list[0]
	arena._on_level_selected(0)
	var player=global.player
	player.set_process(false)
	player.set_physics_process(false)
	player.health_component.debug_invulnerable=true
	for weapon in player.current_weapons:
		weapon.set_process(false)
		weapon.cooldown_timer.stop()
	var spawner=arena.spawner
	spawner.spawn_timer.stop()
	spawner.temporary_crowd_test=false
	var controller=arena.environment_controller
	controller.debug_forced_stage=0
	for wave in spawner.waves_data: assert(wave.wave_time==30.0)
	var wave=spawner.waves_data[0].duplicate(true)
	spawner.waves_data[0]=wave
	wave.groups.clear()
	wave.events.clear()
	wave.common_limit=2
	wave.density_multiplier=1
	var profile=load("res://resources/wave/enemies/chaser_mini.tres")
	var other=load("res://resources/wave/enemies/chaser_mid.tres")
	var group=load("res://resources/wave/spawn_group.gd").new()
	group.enemies.assign([profile,other])
	group.weights.assign([1.0,3.0])
	seed(1729)
	var first=0
	for draw in 20000:
		if group.select_enemy()==profile: first+=1
	assert(absf(float(first)/20000-0.25)<0.02)
	group.weights.assign([0.0,1.0])
	for draw in 100: assert(group.select_enemy()==other)
	# Normal and horde default to the neutral arena; fixed and random are per-wave.
	controller.reset_stage_selection()
	wave.arena_mode=0
	assert(controller.prepare_wave(1).mechanic_scene==null)
	wave.wave_type=1
	controller.reset_stage_selection()
	assert(controller.prepare_wave(1).mechanic_scene==null)
	wave.arena_mode=1
	wave.fixed_arena=load("res://resources/environments/stages/deep_wok.tres")
	controller.reset_stage_selection()
	assert(controller.prepare_wave(1)==wave.fixed_arena)
	wave.arena_mode=2
	controller.reset_stage_selection()
	var special=controller.prepare_wave(1)
	assert(special.mechanic_scene!=null and controller.prepare_wave(1)==special)
	wave.arena_mode=0
	controller.reset_stage_selection()
	# Both regions respect every utensil's actual outline and player clearance.
	for stage in controller.stages:
		spawner.arena_environment=stage.play_area
		player.global_position=stage.play_area.movement_bounds.get_center()
		for zone in [1,2]:
			for draw in 30:
				var point=spawner.get_safe_spawn_position(profile,zone,200.0)
				assert(point.is_finite(),str(stage.id)+" zone "+str(zone))
				assert(spawner.matches_spawn_zone(point,zone,200.0))
				assert(spawner.is_spawn_position_safe(point,profile))
	# Fixed events: exact enemy/count, no early spawn, no density, cap retries, no duplication.
	var event=load("res://resources/wave/scheduled_spawn.gd").new()
	event.enemy=profile
	event.second=5.0
	event.count=3
	event.spawn_zone=1
	wave.scheduled_spawns.assign([event])
	spawner.wave_index=1
	global.game_paused=false
	spawner.start_wave()
	spawner.spawn_timer.stop()
	assert(is_equal_approx(spawner.wave_timer.wait_time,30.0))
	spawner.scheduler_tick(4.99)
	assert(spawner.total_spawned==0)
	spawner.scheduler_tick(5.0)
	assert(spawner.total_spawned==2 and spawner.pending_spawns==0)
	assert(spawner.scheduled_events[0].completed==2)
	for enemy in spawner.spawned_enemies:
		assert(enemy.get_meta("enemy_profile")==profile.id)
		assert(spawner.matches_spawn_zone(enemy.global_position,1,200.0))
	spawner.scheduler_tick(6.0)
	assert(spawner.total_spawned==2)
	spawner.spawned_enemies[0].queue_free()
	await process_frame
	spawner.scheduler_tick(6.1)
	assert(spawner.total_spawned==3 and spawner.scheduled_events[0].completed==3)
	spawner.scheduler_tick(7.0)
	assert(spawner.total_spawned==3)
	# Weighted schools keep their zone even when scattered around the center.
	spawner.clear_enemies()
	spawner.wave_timer.start(30.0)
	group.spawn_zone=2
	group.edge_width=200.0
	var state={"group":group,"pending":0,"completed":0}
	spawner.spawn_school(profile,2,Vector2.INF,140.0,state)
	await create_timer(1.15).timeout
	assert(spawner.total_spawned>=2)
	for enemy in spawner.spawned_enemies: assert(spawner.matches_spawn_zone(enemy.global_position,2,200.0))
	# Restart clears execution state: a forced event may fire once again next wave.
	spawner.clear_enemies()
	assert(spawner.scheduled_events.is_empty() and spawner.pending_spawns==0)
	spawner.start_wave()
	spawner.spawn_timer.stop()
	spawner.scheduler_tick(5.0)
	assert(spawner.total_spawned==2 and spawner.scheduled_events[0].completed==2)
	arena.queue_free()
	await process_frame
	print("PASS spawner configuration: weighted sampling, 30s waves, base/fixed/random arenas, stable preview, all arena zones, literal timed events, capacity retry, schools and reset")
	quit()
