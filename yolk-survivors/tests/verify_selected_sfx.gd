extends SceneTree
var sound
var global
var arena
var clip
var fields=["dash","enemy_death","yolker_burst","incognito_confetti","level_up","burning_apply","electric_apply","explosion","default_continuous_attack","coin_spin","coin_reveal","coin_win","coin_lose","golden_anticipation","golden_impact","golden_reveal","golden_success","golden_broken","breading_apply","laser_warning","laser_fire","turret_spawn","boss_jump","boss_fall_warning","boss_impact","fueguito_spawn","fueguito_exit"]
func _initialize(): call_deferred("verify")
func reset_audio():
	for p in sound.stream_players: p.stop()
	sound.event_times.clear()
func heard(event): assert(sound.event_times.has(event),"Missing audio event: "+event)
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	sound=root.get_node("SoundManager")
	global=root.get_node("Global")
	clip=load("res://assets/audio/SFX/UI_Acept.wav")
	for field in fields:
		sound.set(field,null)
		sound.play_event(field)
		sound.set(field,clip)
	arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	await process_frame
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=arena.weapon_selection_panel.weapons_list[0]
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	arena.stage_mechanics.stop()
	var player=global.player
	player.set_process(false)
	for w in player.current_weapons: w.set_process(false); w.cooldown_timer.stop()
	reset_audio()
	player.start_dash()
	heard("dash")
	reset_audio()
	arena._on_experience_level_gained(2)
	heard("level_up")
	reset_audio()
	var coin=arena.shop_panel.coin_animation
	coin.play(true,100,50)
	coin.set_process(false)
	coin._process(0.8)
	heard("coin_spin")
	assert(not sound.event_times.has("coin_win"))
	coin._process(1.3)
	heard("coin_reveal"); heard("coin_win")
	coin.elapsed=3
	coin.close()
	reset_audio()
	coin.play(false,0,50)
	coin.set_process(false)
	coin._process(2.1)
	heard("coin_reveal"); heard("coin_lose")
	coin.elapsed=3; coin.close()
	var weapon=player.current_weapons[0]
	var golden=arena.shop_panel.golden_animation
	reset_audio()
	golden.play_upgrade(weapon.data,weapon.data,0.25)
	golden.set_process(false)
	heard("golden_anticipation")
	golden._process(1.14)
	heard("golden_impact")
	assert(not sound.event_times.has("golden_success"))
	golden._process(0.3)
	heard("golden_reveal"); heard("golden_success")
	golden.elapsed=3; golden.close()
	reset_audio()
	golden.play_upgrade(weapon.data,null,-1)
	golden.set_process(false)
	golden._process(1.5)
	heard("golden_broken")
	golden.elapsed=3; golden.close()
	reset_audio()
	var flame=load("res://scenes/units/enemies/enemy_fueguito.tscn").instantiate()
	arena.add_child(flame)
	heard("fueguito_spawn")
	flame.announce_exit()
	heard("fueguito_exit")
	reset_audio()
	flame.queue_free()
	await process_frame
	assert(not sound.event_times.has("fueguito_exit"),"Retirement and tree exit must not double-play")
	weapon.continuous_sound=clip
	sound.set_weapon_loop(weapon,true)
	var loop=weapon.get_node("ContinuousAudio")
	loop._process(0)
	assert(loop.playing)
	global.game_paused=true
	loop._process(0)
	assert(loop.stream_paused)
	global.game_paused=false
	loop._process(0)
	assert(not loop.stream_paused)
	loop.stop(); loop._process(0)
	assert(loop.playing,"A finite clip must repeat while the attack is active")
	sound.set_weapon_loop(weapon,false)
	assert(not loop.playing and not loop.active)
	reset_audio()
	weapon.impact_sound=clip
	weapon.setup_weapon(weapon.data)
	var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	arena.add_child(enemy)
	enemy.set_process(false)
	var hit=load("res://scenes/components/hitbox_component.gd").new()
	arena.add_child(hit)
	hit.weapon_damage_record=weapon.damage_record
	hit.report_damage(enemy,1)
	heard("weapon_impact:"+weapon.scene_file_path)
	reset_audio()
	hit.is_status_damage=true
	hit.report_damage(enemy,1)
	assert(sound.event_times.is_empty(),"Burning ticks must not replay weapon impacts")
	reset_audio()
	hit.source=player
	var burn=load("res://resources/statuses/fueguito_fire.tres")
	load("res://effects/fire_status.gd").apply(enemy,"TestBurn",hit,burn)
	heard("burning_apply")
	reset_audio()
	load("res://effects/fire_status.gd").apply(enemy,"TestBurn",hit,burn)
	assert(not sound.event_times.has("burning_apply"),"Refreshing Burning must stay silent")
	var shock=load("res://resources/status_effect.gd").new()
	shock.kind=1
	shock.duration=1
	shock.damage=0
	shock.maximum_chain_targets=0
	load("res://effects/status_controller.gd").apply_effect(enemy,shock,hit)
	heard("electric_apply")
	reset_audio()
	enemy._on_health_component_on_unit_died()
	heard("enemy_death")
	for entry in [["enemy_yolker","yolker_burst"],["enemy_incognito","incognito_confetti"]]:
		var reward=load("res://scenes/units/enemies/%s.tscn"%entry[0]).instantiate()
		arena.add_child(reward)
		reset_audio()
		arena._on_enemy_died(reward)
		heard(entry[1])
		var audio_time=sound.event_times[entry[1]]
		arena._on_enemy_died(reward)
		assert(sound.event_times[entry[1]]==audio_time)
	reset_audio()
	arena.boss_test_mode=true
	arena.boss_encounter.start(arena)
	var encounter=arena.boss_encounter
	encounter.set_process(false)
	global.player.set_process(false)
	global.player.is_dashing=true
	for w in global.player.current_weapons: w.set_process(false); w.cooldown_timer.stop()
	reset_audio()
	var turrets=load("res://scenes/bosses/fixed_turrets.gd").new()
	encounter.add_child(turrets)
	turrets.setup(encounter.area,encounter.settings,encounter.boss)
	heard("turret_spawn"); heard("laser_warning")
	reset_audio()
	turrets.advance(1.3)
	heard("laser_fire")
	turrets.stop(); turrets.queue_free()
	reset_audio()
	encounter._begin_landing()
	heard("boss_fall_warning")
	reset_audio()
	encounter._process(encounter.settings.landing_warning_seconds)
	encounter._process(encounter.settings.fall_seconds)
	heard("boss_impact"); heard("explosion")
	reset_audio()
	encounter._begin_departure(false)
	assert(not sound.event_times.has("boss_jump"))
	encounter._process(encounter.settings.takeoff_anticipation_seconds+0.01)
	heard("boss_jump")
	for field in fields: sound.set(field,null)
	arena.clear_arena()
	await process_frame
	arena.queue_free()
	await process_frame
	print("PASS selected SFX: Inspector fields, dash/level, coin and golden timing/results, Fueguito lifecycle, weapon impact vs status tick, continuous replay/pause/stop")
	quit()



