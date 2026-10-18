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
	arena.start_panel.hide()
	arena._on_level_selected(0)
	var player = global.player
	player.set_process(false)
	player.set_physics_process(false)
	arena.spawner.spawn_timer.stop()
	var hp = player.health_component
	var feedback = arena.damage_feedback
	assert(feedback.vignette.get_parent().layer < arena.get_node("GameUI").layer, "HUD must render above vignette")
	assert(feedback.strength_for_health(0.5) == 0.0)
	assert(feedback.strength_for_health(0.49) < feedback.strength_for_health(0.34))
	assert(feedback.strength_for_health(0.19) < feedback.strength_for_health(0.09))
	hp.take_damage(hp.max_health * 0.60)
	assert(arena.player_health_bar.flash_left > 0)
	assert(is_equal_approx(feedback.health_ratio, 0.4))
	await create_timer(0.45).timeout
	assert(arena.player_health_bar.flash_left == 0)
	assert(feedback.strength > 0)
	hp.heal(hp.max_health)
	assert(feedback.target_strength == 0 and arena.player_health_bar.flash_left == 0)
	await create_timer(0.45).timeout
	assert(feedback.strength == 0)
	arena.set_wave_paused(true)
	hp.take_damage(10)
	assert(hp.current_health == hp.max_health and arena.player_health_bar.flash_left == 0)
	arena.set_wave_paused(false)
	var enemy_profile = load("res://resources/wave/enemies/chaser_mid.tres")
	arena.spawner.spawn_profile(enemy_profile)
	await create_timer(1.15).timeout
	assert(arena.spawner.alive_enemy_count() == 1)
	hp.take_damage(hp.max_health)
	assert(arena.defeat_in_progress and feedback.dying)
	assert(is_equal_approx(feedback.corpse.scale.x*feedback.corpse.texture.get_width(),feedback.start_size), "Corpse has its intended size immediately, before the first presentation frame")
	assert(global.player == null and global.game_paused)
	assert(not arena.final_screen.visible)
	assert(arena.spawner.alive_enemy_count() == 1, "Scene retained through defeat")
	await create_timer(0.6).timeout
	assert(not arena.final_screen.visible)
	await create_timer(1.6).timeout
	assert(feedback.finished and arena.final_screen.visible)
	assert(feedback.corpse.position.is_equal_approx(root.get_visible_rect().size * 0.5))
	assert(arena.spawner.alive_enemy_count() == 0)
	arena._on_final_button_pressed()
	assert(not feedback.finished and not feedback.corpse.visible and feedback.strength == 0)
	assert(not arena.defeat_in_progress and arena.selection_panel.visible)
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
	arena._on_level_selected(0)
	assert(global.player != null and arena.wave_active and not arena.defeat_in_progress)
	var retry_hp=global.player.health_component
	retry_hp.take_damage(retry_hp.max_health)
	assert(is_equal_approx(feedback.corpse.scale.x*feedback.corpse.texture.get_width(),feedback.start_size), "Retry death does not reuse the previous final corpse size")
	arena.queue_free()
	await process_frame
	print("PASS damage flash, four vignette levels, healing/pause, staged defeat, centered corpse and retry")
	quit()

