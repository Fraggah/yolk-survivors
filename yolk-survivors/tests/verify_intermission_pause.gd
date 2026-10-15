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
	arena.start_panel.hide()
	arena._on_level_selected(0)
	var player = global.player
	player.set_process(false)
	arena.spawner.spawn_timer.stop()
	assert(player.global_position.is_equal_approx(player.arena_environment.movement_bounds.get_center()))
	arena.wave_active = false
	global.game_paused = true
	arena.spawner.wave_timer.stop()
	for panel in [arena.shop_panel, arena.upgrade_panel]:
		panel.show()
		var wave = arena.spawner.wave_index
		arena.set_wave_paused(true)
		assert(arena.pause_panel.visible and not panel.visible and global.game_paused)
		arena._on_pause_panel_on_return_pressed()
		assert(not arena.pause_panel.visible and panel.visible and global.game_paused)
		assert(arena.spawner.wave_index == wave and arena.spawner.wave_timer.is_stopped())
		panel.hide()
	player.global_position += Vector2(300, 100)
	player.set_flash_material()
	arena.player_health_bar.flash_damage()
	arena.start_new_wave()
	arena.spawner.spawn_timer.stop()
	assert(player.global_position.is_equal_approx(player.arena_environment.movement_bounds.get_center()))
	assert(player.sprite.material == null and player.flash_timer.is_stopped())
	assert(arena.player_health_bar.flash_left == 0)
	assert(arena.player_health_bar.clipped_fill.material.get_shader_parameter("fill_color") == root.get_node("UITheme").palette.health_fill)
	print("PASS shop/upgrade pause restores intermission, centered wave spawn and cleared damage flash")
	quit()
