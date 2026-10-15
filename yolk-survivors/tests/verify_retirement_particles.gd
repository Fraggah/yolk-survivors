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
	arena.spawner.spawn_timer.stop()
	arena.spawner.spawn_profile(load("res://resources/wave/enemies/chaser_mid.tres"))
	await create_timer(1.15).timeout
	var enemy = arena.spawner.spawned_enemies[0]
	var old_scale: Vector2 = enemy.scale
	var coins_before: int = global.coins
	var xp_before: int = arena.run_experience.experience
	global.game_paused = true
	arena.spawner.clear_enemies()
	assert(enemy.is_retiring)
	await create_timer(0.08,true,false,true).timeout
	assert(is_instance_valid(enemy) and enemy.scale.length() < old_scale.length())
	await create_timer(0.15,true,false,true).timeout
	assert(not is_instance_valid(enemy))
	var bursts = arena.get_node("ArenaBursts")
	assert(bursts.particles.size() > 0)
	assert(global.coins == coins_before and arena.run_experience.experience == xp_before)
	await create_timer(0.4,true,false,true).timeout
	assert(bursts.particles.is_empty())
	global.game_paused = false
	bursts.emit_burst(Vector2.ZERO,true)
	assert(bursts.particles.size() == 28)
	global.game_paused = true
	var life: float = bursts.particles[0].life
	bursts._process(0.1)
	assert(bursts.particles[0].life == life)
	arena.stage_mechanics.stop()
	assert(bursts.particles.is_empty())
	print("PASS paused enemy absorption, delayed particles, no rewards, tray burst pool and cleanup")
	quit()
