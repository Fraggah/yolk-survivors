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
	arena._on_boss_test_selected()
	var encounter=arena.boss_encounter
	encounter.set_process(false)
	global.player.set_process(false)
	global.player.is_dashing=true
	for weapon in global.player.current_weapons:
		weapon.set_process(false)
		weapon.cooldown_timer.stop()
	assert(encounter.boss.health_component.max_health==1000)
	assert(is_equal_approx(global.player.stats.ranged_damage,15) and is_equal_approx(global.player.stats.damage_percent,40) and is_zero_approx(global.player.stats.hp_regen))
	encounter._process(3)
	for section in 3: encounter._process(30)
	assert(encounter.landing_warning.visible and encounter.landing_warning.material.get_shader_parameter("oval"))
	var shadow_rect: Rect2=encounter.boss.shadow_world_rect()
	assert(encounter.landing_warning.global_position.is_equal_approx(shadow_rect.get_center()))
	assert(encounter.landing_warning.scale.is_equal_approx(shadow_rect.size))
	var shadow=encounter.boss.get_node("Visuals/Shadow")
	var original_shadow=shadow.transform
	shadow.position+=Vector2(12,8)
	shadow.scale*=Vector2(1.2,0.9)
	encounter._update_landing_warning()
	assert(encounter.landing_warning.global_position.is_equal_approx(encounter.boss.shadow_world_rect().get_center()))
	assert(encounter.landing_warning.scale.is_equal_approx(encounter.boss.shadow_world_rect().size))
	shadow.transform=original_shadow
	encounter._update_landing_warning()
	var authored_visuals=encounter.boss.visuals.transform
	var authored_shadow=encounter.boss.get_node("Visuals/Shadow").transform
	encounter._process(encounter.settings.landing_warning_seconds)
	encounter._process(encounter.settings.fall_seconds)
	assert(not encounter.landing_warning.visible)
	var effects=get_nodes_in_group("boss_landing_effects")
	assert(effects.size()==1 and effects[0].blast.detonated)
	assert(effects[0].global_position.is_equal_approx(shadow_rect.get_center()))
	assert(is_equal_approx(effects[0].visual_radius,shadow_rect.size.x*0.5*1.1))
	assert(is_equal_approx(effects[0].y_ratio,shadow_rect.size.y/shadow_rect.size.x))
	assert(effects[0].get_node("Flash").material.get_shader_parameter("progress")==0)
	effects[0]._process(0.11)
	assert(effects[0].get_node("Flash").material.get_shader_parameter("progress")==1)
	encounter._process(encounter.settings.vulnerable_seconds)
	assert(encounter.state==encounter.State.TAKEOFF and encounter.boss.visible and not encounter.boss.targetable)
	encounter._process(encounter.settings.takeoff_anticipation_seconds)
	assert(encounter.boss.takeoff_vertical<1)
	encounter._process(encounter.settings.takeoff_jump_seconds*0.5)
	assert(encounter.boss.sprite.position.y<encounter.boss.rest_sprite_position.y)
	assert(encounter.boss.visuals.transform==authored_visuals and encounter.boss.get_node("Visuals/Shadow").transform==authored_shadow)
	encounter._process(encounter.settings.takeoff_jump_seconds*0.5)
	assert(encounter.state==encounter.State.DEPARTURE and encounter.time_left==2 and not encounter.boss.targetable)
	var count=encounter.section_history.size()
	encounter._process(1)
	assert(encounter.state==encounter.State.DEPARTURE and encounter.section_history.size()==count)
	arena.set_wave_paused(true)
	encounter._process(10)
	assert(encounter.time_left==1)
	arena.set_wave_paused(false)
	encounter._process(1)
	assert(encounter.state==encounter.State.SECTION and encounter.section_history.size()==count+1)
	encounter._clear_section()
	encounter.state=encounter.State.VULNERABLE
	encounter._phase_cleared()
	assert(encounter.phase==1 and encounter.state==encounter.State.TAKEOFF and encounter.phase_hazard==null)
	encounter._process(encounter.settings.takeoff_anticipation_seconds+encounter.settings.takeoff_jump_seconds)
	encounter._process(1.99)
	assert(encounter.state==encounter.State.DEPARTURE)
	encounter._process(0.02)
	assert(encounter.state==encounter.State.SECTION and is_instance_valid(encounter.phase_hazard))
	arena.clear_arena()
	await process_frame
	arena.queue_free()
	await process_frame
	print("PASS boss departure: 1000 HP, player damage stats, oval heat warning, Scotch visual/flash, squash/takeoff preserving scene transforms, pause and 2 s wait after exit")
	quit()

