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
	global.player.set_process(false)
	global.player.health_component.debug_invulnerable = true
	arena.spawner.spawn_timer.stop()
	var expected := {"chaser_mid":1,"chaser_fast":1,"shooter":2,"charger":8,"chaser_slow":16}
	for wave in [1,5,20]:
		arena.spawner.wave_index = wave
		arena.spawner.current_wave_data = arena.spawner.find_wave_data()
		for id in expected:
			var profile = load("res://resources/wave/enemies/%s.tres" % id)
			var enemy = profile.scene.instantiate()
			var base = enemy.stats
			arena.spawner.prepare_enemy(enemy, profile)
			assert(enemy.stats.coin_drop == 1 and base.coin_drop != 1)
			assert(enemy.stats.experience_reward == ceili(enemy.stats.health / 10.0))
			if wave == 1: assert(enemy.stats.experience_reward == expected[id])
			var model = load("res://resources/run_experience.gd").new()
			model.add_experience(enemy.stats.experience_reward)
			arena.run_experience.reset()
			var coins_before: int = arena.gold_list.size()
			arena.add_child(enemy)
			enemy.set_process(false)
			arena._on_enemy_died(enemy)
			arena._on_enemy_died(enemy)
			assert(arena.gold_list.size() == coins_before + 1)
			assert(arena.gold_list.back().value == 1)
			assert(arena.run_experience.level == model.level and arena.run_experience.experience == model.experience)
			enemy.queue_free()
			await process_frame
	arena.spawner.temporary_reward_test = false
	var profile = load("res://resources/wave/enemies/chaser_mid.tres")
	var enemy = profile.scene.instantiate()
	var base = enemy.stats
	arena.spawner.prepare_enemy(enemy, profile)
	assert(enemy.stats.coin_drop == base.coin_drop and enemy.stats.experience_reward == base.experience_reward)
	enemy.free()
	arena.spawner.wave_timer.stop()
	arena.spawner.clear_enemies()
	global.game_paused = true
	arena.queue_free()
	await process_frame
	print("PASS one yolk value 1, XP proportional to effective HP, five profiles/three waves, actual reward flow, duplicate guard, immutable resources and reversible original rewards")
	quit()
