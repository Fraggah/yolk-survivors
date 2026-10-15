extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var global = root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=arena.weapon_selection_panel.weapons_list[0]
	arena._on_level_selected(0)
	global.player.set_process(false)
	global.player.set_physics_process(false)
	global.player.health_component.debug_invulnerable=true
	for weapon in global.player.current_weapons:
		weapon.set_process(false)
		weapon.cooldown_timer.stop()
	var spawner=arena.spawner
	spawner.temporary_crowd_test=false
	var profile=load("res://resources/wave/enemies/chaser_mid.tres")
	for n in [1,6,11,18,20]:
		spawner.wave_index=n
		spawner.start_wave()
		spawner.spawn_timer.stop()
		var cap=spawner.population_limit(0)
		for attempt in cap+20: spawner.spawn_profile(profile)
		assert(spawner.pending_spawns==cap)
		await create_timer(1.15).timeout
		assert(spawner.pending_spawns==0 and spawner.alive_enemy_count()==cap)
		for attempt in 20:spawner.spawn_profile(profile)
		assert(spawner.pending_spawns==0)
		spawner.spawned_enemies[0].queue_free()
		await process_frame
		spawner.spawn_profile(profile)
		assert(spawner.pending_spawns==1, "Only one released slot can be filled")
		spawner.clear_enemies()
		await process_frame
		assert(spawner.pending_spawns==0 and spawner.alive_enemy_count()==0)
		print("PASS actual cap ",cap)
	arena.queue_free()
	await process_frame
	print("PASS all five actual population caps (35/55/75/90/65), bounded reservations, no backlog and single-slot refill")
	quit()
