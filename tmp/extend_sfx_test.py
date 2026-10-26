from pathlib import Path
p=Path('yolk-survivors/tests/verify_selected_sfx.gd');s=p.read_text()
needle='\tfor field in fields: sound.set(field,null)'
addition='''	reset_audio()
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
	arena._on_boss_test_selected()
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
'''
assert needle in s;s=s.replace(needle,addition+needle);p.write_text(s)
