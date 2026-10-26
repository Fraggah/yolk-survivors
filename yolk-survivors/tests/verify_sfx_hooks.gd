extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var sound = root.get_node("SoundManager")
	var global = root.get_node("Global")
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	await process_frame
	var fields = ["ui_hover","ui_accept","ui_play","ui_back","selection_hover","selection_accept","selection_invalid","wave_start","wave_final_seconds","wave_complete","run_defeat","hit_al_player","hit_bloqueado_al_player","hit_al_enemigo","critico_al_enemigo","shop_reroll","shop_lock","shop_unlock","shop_buy","shop_no_money","shop_sell","shop_combine","unlock_reveal","unlock_sequence_start","unlock_sequence_end","yolk_pickup","fueguito","bubble_explosion","spatula_impact"]
	for field in fields:
		var old = sound.get(field)
		sound.set(field,null)
		sound.play_stream(sound.get(field),field)
		sound.set(field,old)
	assert(sound.stream_players.all(func(p): return not p.playing))
	var clip = AudioStreamWAV.new()
	clip.mix_rate = 22050
	var sample = PackedByteArray()
	sample.resize(44100)
	clip.data = sample
	sound.ui_play = clip
	sound.event_times.clear()
	arena.start_panel.get_node("MarginContainer/VBoxContainer/PlayButton").pressed.emit()
	assert(sound.stream_players.any(func(p): return p.playing and p.get_meta("sfx_event","") == "ui_play"))
	for p in sound.stream_players: p.stop()
	sound.event_times.clear()
	sound.play_stream(clip,"test_event")
	sound.play_stream(clip,"test_event")
	assert(sound.stream_players.filter(func(p): return p.playing).size() == 1)
	for p in sound.stream_players: p.stop()
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	for p in sound.stream_players: p.stop()
	var weapon = global.player.current_weapons[0]
	weapon.attack_sound = clip
	sound.play_weapon_attack(weapon)
	assert(sound.stream_players.any(func(p): return p.playing and p.stream == clip))
	print("PASS all inspector SFX fields, safe empty slots, Play semantic event, repeat limit and per-weapon override")
	quit()

