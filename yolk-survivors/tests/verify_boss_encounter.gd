extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	# Capture authored geometry rather than assuming fixed positions/scales.
	var authored=load("res://scenes/bosses/salchichon/salchichon.tscn").instantiate()
	var authored_transforms={}
	for path in ["Visuals","Visuals/Shadow","Visuals/Sprite","CollisionShape2D","HurtboxComponent","HurtboxComponent/CollisionShape2D","HitboxComponent","HitboxComponent/CollisionShape2D2"]:
		authored_transforms[path]=authored.get_node(path).transform
	assert(authored.get_node("AnimationPlayer").get_animation_list().is_empty())
	var authored_scale=authored.get_node("Visuals/Sprite").scale
	authored.free()
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	await process_frame
	var global = root.get_node("Global")
	var selection = arena.selection_panel.player_list[0]
	var base_health = selection.health
	var base_regen = selection.hp_regen
	global.main_player_selected = selection
	arena.boss_encounter.settings=arena.boss_encounter.settings.duplicate()
	arena.boss_encounter.settings.total_health=100
	var selected_weapon = arena.weapon_selection_panel.weapons_list[0]
	global.main_weapon_selected = selected_weapon
	arena.start_panel.hide()
	arena.selection_panel.hide()
	arena.weapon_selection_panel.hide()
	arena.level_panel.show()
	if OS.get_cmdline_user_args().has("--capture"):
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/boss-test-menu.png"))
	arena.level_panel.get_node("MarginContainer/VBoxContainer/BossTestButton").pressed.emit()
	assert(arena.boss_test_mode and arena.in_arena and arena.wave_active)
	assert(arena.spawner.wave_timer.is_stopped() and arena.spawner.spawn_timer.is_stopped())
	assert(not root.get_node("Progression").run_active)
	var player = global.player
	player.get_node("HPTimer").stop()
	player.set_process(false)
	assert(is_equal_approx(player.health_component.max_health,85))
	assert(is_equal_approx(player.stats.hp_regen,0))
	assert(is_equal_approx(player.stats.armor,15) and is_equal_approx(player.stats.block_chance,20) and is_equal_approx(player.stats.life_steal,20))
	assert(selection.health == base_health and selection.hp_regen == base_regen)
	for weapon in player.current_weapons:
		weapon.set_process(false)
		weapon.cooldown_timer.stop()
	var encounter = arena.boss_encounter
	encounter.set_process(false)
	encounter.settings=encounter.settings.duplicate()
	encounter.settings.departure_wait_seconds=0
	encounter.settings.takeoff_anticipation_seconds=0
	encounter.settings.takeoff_jump_seconds=0
	var boss = encounter.boss
	player.global_position = encounter.area.movement_bounds.get_center()+Vector2(400,200)
	await physics_frame
	assert(boss.health_component.current_health == 100 and not boss.visible and not boss.targetable)
	boss.health_component.take_damage(10000)
	assert(boss.health_component.current_health == 100)
	var before = encounter.time_left
	arena.set_wave_paused(true)
	encounter._process(100)
	assert(encounter.time_left == before)
	arena.set_wave_paused(false)
	assert(encounter.state == encounter.State.INTRO and encounter.section_history.is_empty())
	encounter._process(encounter.settings.initial_wait_seconds)
	for section in 3: encounter._process(encounter.settings.section_seconds+0.01)
	assert(encounter.state == encounter.State.WARNING)
	assert(encounter.section_history.size() == 3)
	var unique = {}
	for section in encounter.section_history: unique[section] = true
	assert(unique.size() == 3)
	assert(not encounter.hud.bar.visible and not boss.health_component.vulnerable)
	assert(boss.get_node("HitboxComponent").status_effects.size()>0)
	assert(encounter.landing_hit.status_effects.size()>0)
	assert(encounter.settings.line_damage==10 and encounter.settings.moving_line_damage==10 and encounter.settings.turret_line_damage==10)

	encounter._process(encounter.settings.landing_warning_seconds+0.01)
	assert(encounter.state == encounter.State.FALLING and boss.visible and not boss.targetable)
	assert(boss.visuals.transform.is_equal_approx(authored_transforms["Visuals"]))
	assert(boss.get_node("Visuals/Shadow").transform.is_equal_approx(authored_transforms["Visuals/Shadow"]))
	if OS.get_cmdline_user_args().has("--capture"):
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/boss-entry.png"))
	player.global_position = boss.anchor
	player.is_dashing = true
	await physics_frame
	await physics_frame
	var health_before_landing = player.health_component.current_health
	encounter._process(encounter.settings.fall_seconds+0.01)
	assert(player.health_component.current_health == health_before_landing, "Dash i-frames protect against landing")
	player.is_dashing = false
	assert(encounter.state == encounter.State.VULNERABLE and encounter.hud.bar.visible)
	assert(encounter.landing_radius() > boss.contact_world_radius())
	assert(boss.targetable and boss.health_component.vulnerable)
	assert(boss.rest_sprite_scale.is_equal_approx(authored_scale))
	for path in authored_transforms:
		if path=="Visuals/Sprite":
			assert(boss.sprite.position.is_equal_approx(authored_transforms[path].origin))
		else:
			assert(boss.get_node(path).transform.is_equal_approx(authored_transforms[path]))
	boss.play_landing_squash()
	boss._process(0.01)
	var squash_scale=boss.sprite.scale
	boss._process(0.25)
	assert(not boss.sprite.scale.is_equal_approx(squash_scale))
	assert(boss.sprite.position.is_equal_approx(boss.rest_sprite_position))
	var paused_scale=boss.sprite.scale
	global.game_paused=true
	boss._process(0.5)
	assert(boss.sprite.scale==paused_scale)
	global.game_paused=false
	await physics_frame
	await physics_frame
	await physics_frame
	await create_timer(0.2).timeout
	assert(player.health_component.current_health < health_before_landing, "Boss contact causes damage")
	assert(boss.get_node("Visuals/Shadow").transform.is_equal_approx(authored_transforms["Visuals/Shadow"]))
	player.global_position = boss.anchor+Vector2(400,200)
	await physics_frame
	# Status routes apply while the boss stays anchored.
	var hit = load("res://scenes/components/hitbox_component.tscn").instantiate()
	arena.add_child(hit)
	hit.setup(1,false,100,player)
	var fire = load("res://resources/statuses/fueguito_fire.tres")
	load("res://effects/status_controller.gd").apply_effect(boss,fire,hit)
	load("res://effects/fire_status.gd").apply(boss,"TestFire",hit,fire)
	boss.apply_slow(0.5,2)
	assert(boss.has_status_named("slow"))
	var electric=load("res://resources/status_effect.gd").new()
	electric.kind=1
	electric.damage=2
	electric.damage_scaling=0
	electric.maximum_chain_targets=0
	var before_electric=boss.health_component.current_health
	load("res://effects/status_controller.gd").apply_effect(boss,electric,hit)
	assert(boss.has_status_named("shoked") and boss.health_component.current_health<before_electric)
	var burn=boss.get_node("TestFire")
	var before_burn=boss.health_component.current_health
	burn._process(0.5)
	assert(boss.health_component.current_health<before_burn)
	boss.health_component.current_health=100
	boss.status_controller.add_slow(0,10)
	boss.immobilize_for(10)
	boss.pin_for(hit)
	boss.apply_knockback(Vector2.RIGHT,10000)
	boss.launch_from(hit)
	assert(boss.has_status_named("burning") and boss.has_status_named("rooted") and boss.has_status_named("airbourne"))
	assert(boss.knockback_power == 0 and boss.launch_velocity==Vector2.ZERO)
	var position_before=boss.global_position
	boss._process(0.1)
	assert(boss.global_position==position_before and boss.launch_left>0)
	boss.release_pin(hit)
	boss.slow_left=0
	boss.launch_left=0
	boss.status_controller.clear()
	boss.health_component.take_damage(5)
	assert(boss.health_component.current_health == 95)
	encounter._process(encounter.settings.vulnerable_seconds+0.01)
	assert(encounter.state == encounter.State.SECTION and encounter.sections.is_empty())
	assert(encounter.section_history.size() == 4 and boss.health_component.current_health == 95)
	encounter._process(encounter.settings.section_seconds+0.01)
	encounter._process(encounter.settings.landing_warning_seconds+0.01)
	player.global_position = boss.anchor
	player.hit_invulnerability_left = 0
	await physics_frame
	await physics_frame
	health_before_landing = player.health_component.current_health
	encounter._process(encounter.settings.fall_seconds+0.01)
	assert(player.health_component.current_health < health_before_landing, "Landing hits the player hurtbox")
	player.global_position = boss.anchor+Vector2(400,200)
	assert(boss.health_component.current_health == 95)
	if OS.get_cmdline_user_args().has("--capture"):
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/boss-vulnerable.png"))
	for phase in 3:
		assert(encounter.phase == phase)
		if phase > 0:
			for section in 3: encounter._process(encounter.settings.section_seconds+0.01)
			encounter._process(encounter.settings.landing_warning_seconds+0.01)
			encounter._process(encounter.settings.fall_seconds+0.01)
		hit.setup(10000,false,0,player)
		assert(boss.receive_hit(hit))
		if phase < 2:
			assert(is_equal_approx(boss.health_component.current_health,100.0*float(2-phase)/3.0))
			assert(encounter.phase == phase+1 and not boss.visible)
			assert(float(boss.get_meta("last_boss_damage")) <= 100.0/3.0 + 0.001)
			boss.health_component.take_damage(10000)
			assert(boss.health_component.current_health > 0)
	await process_frame
	assert(arena.final_screen.visible and arena.final_label.text == "BOSS TEST COMPLETE!")
	assert(not root.get_node("Progression").run_active and not encounter.active)
	assert(not encounter.hud.visible and global.player == null)
	arena._on_final_button_pressed()
	assert(not arena.boss_test_mode and not arena.in_arena)
	assert(arena.environment_controller.current_stage.id == &"neutral_plate")
	# Death cancels an in-flight encounter; exiting then restores normal runs.
	global.main_player_selected = selection
	global.main_weapon_selected = selected_weapon
	arena._on_boss_test_selected()
	assert(encounter.active)
	global.player.health_component.take_damage(10000)
	assert(arena.defeat_in_progress and not encounter.active and not encounter.hud.visible)
	assert(arena.spawner.wave_timer.is_stopped())
	arena._finish_defeat()
	assert(arena.final_label.text == "YOU LOSE!")
	arena._on_final_button_pressed()
	global.main_player_selected = selection
	global.main_weapon_selected = selected_weapon
	arena._on_level_selected(0)
	assert(not arena.boss_test_mode and not encounter.active)
	assert(not arena.spawner.wave_timer.is_stopped() and root.get_node("Progression").run_active)
	assert(arena.environment_controller.current_stage.id == &"neutral_plate")
	root.get_node("Progression").end_run()
	print("PASS boss encounter: menu entry, isolated stats, exclusive arena, pause, 3 shuffled sections, landing, persistence/retry, status support without displacement, 3 damage caps and test-only victory/reset")
	arena.spawner.wave_timer.stop()
	arena.spawner.spawn_timer.stop()
	arena.clear_arena()
	await process_frame
	arena.queue_free()
	await process_frame
	await process_frame
	quit()
