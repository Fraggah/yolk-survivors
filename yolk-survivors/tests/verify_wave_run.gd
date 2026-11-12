extends SceneTree
func _initialize(): call_deferred("verify")

func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var global = root.get_node("Global")
	var spawner = arena.spawner
	# Test-only copies compress time, while preserving all real transitions.
	var copies: Array[WaveData] = []
	for resource in spawner.waves_data:
		var wave = resource.duplicate(true)
		# Exercise the timed-wave fallback; the configured wave-20 encounter
		# and its real victory path are covered by verify_wave20_boss.gd.
		wave.boss_encounter = null
		wave.wave_time = 8.0
		for group in wave.groups + wave.events:
			group.start_second *= .02
			group.interval = maxf(.45, group.interval * .04)
			group.minimum_interval = .45
			group.interval_reduction = 0
			group.minimum_count = 1
			group.maximum_count = 1
		copies.append(wave)
	spawner.difficulties[0].waves = copies
	spawner.debug_enabled = true
	spawner.debug_time_scale = 8.0
	spawner.debug_invulnerable = true
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
	arena.start_panel.hide()
	arena._on_level_selected(0)
	var player = global.player
	player.set_process(false)
	player.set_physics_process(false)
	for weapon in player.current_weapons: weapon.set_process(false)
	for n in range(1,21):
		assert(spawner.wave_index == n and arena.wave_active)
		while spawner.total_spawned == 0 and arena.wave_active:
			await process_frame
		print("SPAWN CHECK ", n, " left=", spawner.wave_timer.time_left, " count=", spawner.total_spawned, " pending=", spawner.pending_spawns)
		assert(spawner.alive_enemy_count() + spawner.pending_population[0] <= spawner.population_limit(0))
		assert(spawner.population_count(1) + spawner.pending_population[1] <= spawner.population_limit(1))
		assert(spawner.total_spawned > 0, "Every wave produces actual enemies")
		if n == 1:
			var enemy = spawner.spawned_enemies[0]
			var before = arena.run_experience.experience
			var reward = enemy.stats.experience_reward
			enemy.health_component.take_damage(enemy.stats.health)
			assert(arena.run_experience.experience == before + reward)
			arena._on_enemy_died(enemy)
			assert(arena.run_experience.experience == before + reward, "No double kill reward")
			await process_frame
			var expected_yolks := 1 if spawner.temporary_reward_test else 2
			assert(arena.gold_list.size() == expected_yolks)
			assert(arena.uncollected_yolk_value() == expected_yolks)
			global.collect_yolk(30)
			assert(arena.run_experience.experience == before + reward, "Money gives no XP")
		await spawner.on_wave_completed
		assert(not arena.wave_active and spawner.pending_spawns == 0)
		assert(spawner.population_count(1) == 0)
		await create_timer(1.15, true, false, true).timeout
		if n == 20:
			assert(arena.final_screen.visible and arena.final_label.text == "YOU WIN!")
			assert(global.player == null)
			assert(not arena.shop_panel.visible and not arena.upgrade_panel.visible)
		else:
			assert(arena.shop_panel.visible or arena.upgrade_panel.visible)
			assert(not arena.final_screen.visible, "No premature victory on wave ten")
			while arena.upgrade_panel.visible:
				arena._on_upgrade_selected()
			assert(arena.shop_panel.shop_wave == n)
			if n == 1:
				var held = arena.shop_panel.items_container.get_child(0)
				held.set_locked(true)
				held.set_meta("expected_key", held.shop_item.get_offer_key())
			if n == 2:
				var held = arena.shop_panel.items_container.get_child(0)
				assert(held.locked and held.shop_item.get_offer_key() == held.get_meta("expected_key"))
			arena._on_shop_panel_on_shop_next_wave()
		print("TRANSITION wave ",n," PASS")
	Engine.time_scale = 1.0
	arena.queue_free()
	await process_frame
	print("PASS full 20-wave run, actual enemies/caps, no early victory, final victory, shop/upgrade transitions, lock persistence, XP/yolk rewards and duplicate guard (test-only compressed timings)")
	quit()
