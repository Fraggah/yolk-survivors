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
	var snapshots: Array[Dictionary] = []
	for kind in ["yolker", "incognito"]:
		var enemy = load("res://scenes/units/enemies/enemy_%s.tscn" % kind).instantiate()
		arena.add_child(enemy)
		enemy.set_process(false)
		enemy._animate(enemy.bounce_period * 0.25)
		snapshots.append({"enemy":enemy, "sprite":enemy.sprite.transform, "root_scale":enemy.scale, "visuals":enemy.visuals.transform})
		arena.spawner.reward_enemies.append(enemy)
	arena.spawner.clear_enemies()
	for sample in snapshots:
		assert(sample.enemy.sprite.transform.is_equal_approx(sample.sprite), "Retirement must preserve normalized sprite transform")
	for frame in 30:
		await process_frame
		for sample in snapshots:
			if not is_instance_valid(sample.enemy): continue
			assert(sample.enemy.sprite.transform.is_equal_approx(sample.sprite), "No oversized sprite during any retirement frame")
			assert(sample.enemy.scale.length() <= sample.root_scale.length() + 0.001)
	await create_timer(0.3).timeout
	for sample in snapshots: assert(not is_instance_valid(sample.enemy))
	print("PASS reward retirement: Yolker and Incognito retain sprite transforms and only shrink during wave cleanup")
	arena.queue_free()
	await process_frame
	quit()
