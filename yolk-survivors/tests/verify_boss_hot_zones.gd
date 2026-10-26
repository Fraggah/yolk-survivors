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
	arena.selection_panel.hide()
	arena.weapon_selection_panel.hide()
	arena._on_boss_test_selected()
	var encounter=arena.boss_encounter
	encounter.set_process(false)
	encounter.settings=encounter.settings.duplicate()
	encounter.settings.departure_wait_seconds=0
	encounter.settings.takeoff_anticipation_seconds=0
	encounter.settings.takeoff_jump_seconds=0
	encounter.settings=encounter.settings.duplicate()
	encounter.settings.test_static_lines_first=true
	encounter.settings.test_moving_lines_first=true
	encounter.settings.test_complex_lines_first=true
	encounter._process(3.01)
	encounter._process(30.01)
	encounter._process(30.01)
	assert(encounter.phase==0 and encounter.current_section==2)
	var section=encounter.section_runner
	var player=global.player
	player.set_process(false)
	player.get_node("HPTimer").stop()
	player.stats.block_chance=0
	for weapon in player.current_weapons:
		weapon.set_process(false)
		weapon.cooldown_timer.stop()
	assert(section.pending==1 and section.hazards.is_empty())
	assert(section.zone_batch==0 and section.zones().size()>6 and section.zones().size()<=12)
	var first_zones=section.zones()
	var zone=first_zones[0]
	assert(zone.radius==350 and zone.damage==2 and zone.damage_interval==0.75)
	assert(is_equal_approx(zone.active_duration,2.8))
	player.global_position=zone.global_position
	var hp=player.health_component.current_health
	section.advance(0.44)
	assert(section.hazards.is_empty() and player.health_component.current_health==hp)
	section.advance(0.02)
	assert(section.hazards.size()==1 and section.births==1)
	var flame=section.hazards[0]
	flame.set_process(false)
	var distance_before=flame.global_position.distance_to(player.global_position)
	flame._process(0.1)
	assert(flame.global_position.distance_to(player.global_position)<distance_before,"Reused Fueguito pursues the player")
	assert(flame.stats.coin_drop==0 and flame.stats.experience_reward==0)
	assert(not flame.targetable and not flame.is_in_group("combat_enemies"))
	assert(flame.get_script().resource_path=="res://scenes/units/enemies/fueguito.gd")
	var flame_hp=flame.health_component.current_health
	flame.health_component.take_damage(9999)
	assert(flame.health_component.current_health==flame_hp)
	section.advance(0.55)
	assert(zone.state==zone.State.HOT and player.health_component.current_health<hp,"Reused hot zone damages after its warning")
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/boss-hot-zones-active.png"))
	var before=section.elapsed
	var zone_age=zone.elapsed
	arena.set_wave_paused(true)
	section.advance(10)
	assert(section.elapsed==before and zone.elapsed==zone_age)
	arena.set_wave_paused(false)
	# Reused Fueguito contact and Burning, away from the hot zones.
	for other in section.zones(): other.damage=0; other.damage_hitbox.damage=0
	var hurt_shape=player.get_node("HurtboxComponent/CollisionShape2D")
	flame.global_position=hurt_shape.global_position
	player.hit_invulnerability_left=0
	hp=player.health_component.current_health
	await physics_frame
	await physics_frame
	await create_timer(0.2).timeout
	assert(player.health_component.current_health<hp)
	assert(player.has_status_named("burning"),"Fueguito preserves its existing fire effect")
	# Freeze hazards in this deterministic timeline test, not in actual gameplay.
	player.is_dashing=true
	section.advance(2.0)
	assert(section.pending==1 and section.hazards.size()==1)
	section.advance(0.5)
	assert(section.hazards.size()==2)
	for enemy in section.hazards: enemy.set_process(false)
	section.advance(1.49)
	assert(section.zone_batch==1 and not first_zones[0].visible)
	assert(section.zones().size()>6 and section.zones().size()<=12)
	for old in first_zones: assert(old.damage_hitbox.damage==0 and old.is_queued_for_deletion())
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/boss-hot-zones.png"))
	# Cadence through t=29.5: ten accumulated Fueguitos and six zone batches.
	for step in 49:
		section.advance(0.5)
		for enemy in section.hazards: enemy.set_process(false)
	assert(is_equal_approx(section.elapsed,29.5))
	assert(section.births==10 and section.hazards.size()==10 and section.zone_batch==5)
	var remaining=section.hazards.duplicate()
	var remaining_zones=section.zones()
	encounter.time_left=0.5
	encounter._process(0.5)
	assert(encounter.state==encounter.State.WARNING and encounter.section_runner==null)
	assert(not section.running and section.hazards.is_empty())
	assert(arena.spawner.special_enemies.is_empty())
	for enemy in remaining:
		assert(enemy.is_retiring and not enemy.visible and enemy.get_node("HitboxComponent").damage==0)
	for old in remaining_zones: assert(old.damage_hitbox.damage==0 and not old.visible)
	await process_frame
	assert(get_nodes_in_group("boss_hazards").is_empty())
	arena.clear_arena()
	await process_frame
	arena.queue_free()
	await process_frame
	print("PASS boss hot zones: existing effects/contact, warning damage, pause, 5 s replacement, 3 s accumulation, 10 Fueguitos, cleanup before landing")
	quit()
