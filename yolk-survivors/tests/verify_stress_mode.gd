extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	var progression=root.get_node("Progression")
	var item=load("res://resources/items/weapons/range/hydrant/item_hydrant_1.tres")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=item
	arena.start_panel.hide()
	arena.level_panel.show()
	arena.level_panel.get_node("MarginContainer/VBoxContainer/StressTestButton").pressed.emit()
	var stress=arena.stress_test
	assert(stress.active and arena.in_arena and arena.wave_active)
	assert(global.player.current_weapons.size()==6 and global.equipped_weapons.size()==6)
	for weapon in global.player.current_weapons:
		assert(weapon.data==item)
		weapon.set_process(false)
	global.player.set_process(false)
	assert(global.player.health_component.debug_invulnerable)
	var hp=global.player.health_component.current_health
	global.player.health_component.take_damage(999999)
	assert(global.player.health_component.current_health==hp)
	assert(not progression.run_active and arena.spawner.spawn_timer.is_stopped() and arena.spawner.wave_timer.is_stopped())
	stress.set_process(false)
	global.game_paused=true
	stress._process(10)
	assert(stress.total_spawned==0,"Paused stress mode must not spawn")
	global.game_paused=false
	stress._process(0)
	assert(stress.enemies.size()==10 and stress.pending==90,"Tands are spread over multiple frames")
	# Test population scheduling without enabling 1000 moving actors in a unit test.
	for step in 120:
		stress._process(0.2)
		for enemy in stress.enemies: enemy.process_mode=Node.PROCESS_MODE_DISABLED
	assert(stress.enemies.size()==1000 and stress.total_spawned==1000)
	assert(arena.spawner.max_alive_enemies==500,"Normal-wave cap is unchanged")
	stress._process(100)
	assert(stress.enemies.size()==1000,"Never overshoot the stress cap")
	# Replenish one death while avoiding rewards/upgrades/progression interruptions.
	var victim=stress.enemies[0]
	var experience=arena.run_experience.experience
	var kills=progression.counters.get("kills",0)
	arena._on_enemy_died(victim)
	assert(arena.run_experience.experience==experience and progression.counters.get("kills",0)==kills)
	victim.queue_free()
	await process_frame
	stress._process(2)
	assert(stress.enemies.size()==1000 and stress.total_spawned==1001)
	for enemy in stress.enemies: enemy.process_mode=Node.PROCESS_MODE_DISABLED
	arena._on_pause_panel_on_exit_pressed()
	assert(not stress.active and not stress.label.visible and global.player==null)
	await process_frame
	assert(get_nodes_in_group("combat_enemies").is_empty())
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=item
	arena.level_panel.get_node("MarginContainer/VBoxContainer/Stress500Button").pressed.emit()
	assert(stress.active and stress.target_population==500)
	assert(global.player.current_weapons.size()==6)
	stress.set_process(false)
	arena._on_pause_panel_on_exit_pressed()
	await process_frame
	# Starting a normal game restores normal health/equipment/progression behavior.
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=item
	arena._on_level_selected(0)
	assert(not arena.stress_test.active and not global.player.health_component.debug_invulnerable)
	assert(global.player.current_weapons.size()==1 and progression.run_active)
	assert(not arena.spawner.wave_timer.is_stopped())
	print("PASS stress option: selection button, six selected weapons, immortal, staged 1000 cap, pause, replacements, no progression and normal-run cleanup")
	quit()
