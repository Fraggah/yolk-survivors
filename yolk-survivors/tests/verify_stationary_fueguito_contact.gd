extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	await process_frame
	var global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=arena.weapon_selection_panel.weapons_list[0]
	arena.start_panel.hide()
	arena._on_boss_test_selected()
	arena.boss_encounter.set_process(false)
	var player=global.player
	player.set_process(false)
	player.get_node("HPTimer").stop()
	player.stats.block_chance=0
	player.stats.armor=0
	player.is_dashing=false
	player.hit_invulnerability_left=0
	for weapon in player.current_weapons:
		weapon.set_process(false)
		weapon.cooldown_timer.stop()
	var flame=load("res://scenes/units/enemies/enemy_fueguito.tscn").instantiate()
	arena.add_child(flame)
	var origin=player.global_position
	flame.global_position=origin+Vector2(250,0)
	var hp=player.health_component.current_health
	for frame in 150:
		player.hit_invulnerability_left=0
		await physics_frame
	print("CONTACT distance=",flame.global_position.distance_to(origin)," HP=",hp," -> ",player.health_component.current_health)
	assert(player.global_position==origin)
	if not OS.get_cmdline_user_args().has("--reproduce"):
		assert(player.health_component.current_health<hp)
		assert(player.has_status_named("burning"))
		print("PASS stationary Fueguito: pursues idle player into real contact and applies damage/Burning")
	flame.queue_free()
	arena.clear_arena()
	await process_frame
	arena.queue_free()
	await process_frame
	quit()
