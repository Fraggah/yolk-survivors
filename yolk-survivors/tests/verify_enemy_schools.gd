extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var global = root.get_node("Global")
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
	arena.environment_controller.debug_forced_stage = 1
	arena._on_level_selected(0)
	global.player.position = Vector2.ZERO
	global.player.set_process(false)
	global.player.health_component.debug_invulnerable = true
	var spawner = arena.spawner
	spawner.spawn_timer.stop()
	var mid = load("res://resources/wave/enemies/chaser_mid.tres")
	var fast = load("res://resources/wave/enemies/chaser_fast.tres")
	var shooter = load("res://resources/wave/enemies/shooter.tres")
	var center := Vector2(-600,0)
	assert(spawner.spawn_school(shooter,15,center) == 0)
	assert(spawner.spawn_school(mid,15,center) == 15 and spawner.pending_spawns == 15)
	await create_timer(1.15).timeout
	assert(spawner.alive_enemy_count() == 15)
	assert(spawner.generated_by_type.get(&"chaser_mid",0) == 15)
	spawner.clear_enemies()
	await process_frame
	spawner.max_alive_enemies = 10
	assert(spawner.spawn_school(fast,15,center) == 10 and spawner.pending_spawns == 10)
	spawner.clear_enemies()
	await create_timer(1.15).timeout
	assert(spawner.alive_enemy_count() == 0 and spawner.pending_spawns == 0)
	spawner.max_alive_enemies = 500
	spawner.spawn_school(fast,10,center)
	for warning in get_nodes_in_group("spawn_effects"):
		assert(warning.global_position.distance_to(center) <= 140)
	global.game_paused = true
	await create_timer(1.15).timeout
	assert(spawner.alive_enemy_count() == 0)
	spawner.clear_enemies()
	await process_frame
	assert(spawner.pending_spawns == 0)
	arena.queue_free()
	await process_frame
	print("PASS schools restricted to Mid/Fast, 15 real arrivals, local cluster positions, 10-slot cap, cancellation and pause")
	quit()
