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
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	var enemy = load("res://scenes/units/enemies/enemy_incognito.tscn").instantiate()
	arena.add_child(enemy)
	enemy.set_process(false)
	arena._on_enemy_died(enemy)
	var effects = get_nodes_in_group("incognito_confetti")
	assert(effects.size() == 1)
	var effect = effects[0]
	assert(effect.pieces.size() == 72)
	assert(effect.origin.is_equal_approx(arena.to_local(enemy.sprite.to_global(Vector2.ZERO)) - effect.position))
	arena._on_enemy_died(enemy)
	assert(get_nodes_in_group("incognito_confetti").size() == 1)
	global.game_paused = true
	effect._process(0.3)
	assert(effect.elapsed == 0)
	global.game_paused = false
	effect._process(0.3)
	assert(effect.elapsed > 0)
	effect._process(1.0)
	assert(effect.is_queued_for_deletion())
	print("PASS Incognito confetti: death trigger, 72 pieces, sprite origin, duplicate guard, pause and cleanup")
	arena.queue_free()
	await process_frame
	quit()
