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
	spawner.temporary_crowd_test = true
	for wave in spawner.waves_data:
		assert((wave.wave_type == 1) == (wave.number == 11))
	var six = load("res://resources/wave/data/wave_06.tres")
	assert(six.groups[2].school and six.groups[2].repetitions == 2)
	var nine = load("res://resources/wave/data/wave_09.tres")
	assert(nine.groups[0].school)
	var mini = load("res://resources/wave/enemies/chaser_mini.tres")
	assert(six.groups[2].enemies.has(mini) and nine.groups[0].enemies.has(mini))
	assert(load("res://resources/wave/data/wave_11.tres").groups[0].enemies.has(mini))
	for i in range(1,4):
		assert(not nine.groups[i].school and not nine.groups[i].affected_by_density)
		assert(nine.groups[i].repetitions == 2 and nine.groups[i].maximum_count == 1)
	for n in [9,11]:
		spawner.wave_index = n
		spawner.start_wave()
		spawner.spawn_timer.stop()
		var expected_density = spawner.current_wave_data.density_multiplier if spawner.current_wave_data.density_multiplier > 0 else 5
		assert(spawner.test_wave_multiplier() == expected_density)
		var expected_count = 10 if n == 9 else 2 * expected_density
		# Test one isolated group batch without timer interference.
		var group = spawner.current_wave_data.groups[0].duplicate(true)
		group.enemies.assign([mini])
		group.weights.assign([1.0])
		group.minimum_count = 10 if n == 9 else 1
		group.maximum_count = group.minimum_count
		group.school_probability = 1.0 if n == 11 else 0.0
		spawner.active_groups.clear()
		spawner.active_groups.append({"group":group,"next":0.0,"executions":0,"pending":0,"completed":0,"active":true})
		spawner.scheduler_tick(0.0)
		assert(spawner.pending_spawns == expected_count)
		await create_timer(1.15).timeout
		assert(spawner.alive_enemy_count() == expected_count)
		assert(spawner.generated_by_type.size() == 1)
		spawner.clear_enemies()
		await process_frame
	print("PASS scheduled school waves and horde override")
	quit()

