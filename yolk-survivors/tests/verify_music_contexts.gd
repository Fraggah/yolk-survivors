extends SceneTree
func _initialize(): call_deferred("verify")

func track() -> AudioStreamWAV:
	var audio=AudioStreamWAV.new()
	audio.mix_rate=44100
	audio.format=AudioStreamWAV.FORMAT_16_BITS
	var samples=PackedByteArray()
	samples.resize(44100*2)
	audio.data=samples
	return audio

func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var manager=arena.spawner
	var audio=arena.music_player
	assert(audio.context=="menu" and audio.stream==audio.menu_music and audio.playing)
	var menu=track()
	var shop=track()
	var wave=track()
	var boss=track()
	audio.menu_music=menu
	audio.shop_music=shop
	audio.wave_music_tracks.assign([wave])
	audio.boss_music_tracks.assign([boss])
	arena._play_menu_music()
	await create_timer(.12).timeout
	var position=audio.get_playback_position()
	arena._play_menu_music()
	assert(audio.get_playback_position()>=position, "Same track does not restart between menus")
	var global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=arena.weapon_selection_panel.weapons_list[0]
	arena.start_panel.hide()
	arena._on_level_selected(0)
	assert(audio.context=="wave" and audio.stream==wave and audio.playing)
	assert(not arena.coocking_player.stream_paused)
	arena.set_wave_paused(true)
	assert(audio.stream_paused and arena.coocking_player.stream_paused)
	arena.set_wave_paused(false)
	assert(not audio.stream_paused)
	arena.spawner.wave_timer.stop()
	arena.spawner.spawn_timer.stop()
	arena._on_spawner_on_wave_completed()
	assert(audio.context=="shop" and audio.stream==shop and audio.playing)
	assert(arena.coocking_player.stream_paused)
	await create_timer(1.2).timeout
	# Non-looping source tracks repeat without modifying shared imports.
	assert(audio.playing and shop.loop_mode==AudioStreamWAV.LOOP_DISABLED)
	var stage=arena.environment_controller.current_stage.duplicate()
	var data=manager.wave_data_for(2).duplicate()
	data.music_tracks.clear()
	stage.music_tracks.assign([menu])
	assert(audio.choose_music(data,stage)==menu)
	data.music_tracks.assign([shop])
	assert(audio.choose_music(data,stage)==shop)
	data.music_tracks.assign([null])
	stage.music_tracks.clear()
	assert(audio.choose_music(data,stage)==wave)
	data.music_tracks.assign([menu,shop,null])
	var observed={}
	for i in 100:
		var chosen=audio.choose_music(data,stage)
		assert(chosen==menu or chosen==shop)
		observed[chosen]=true
	assert(observed.size()==2)
	# Real wave-20 entry uses the boss defaults, not the normal playlist.
	manager.wave_index=19
	arena.start_new_wave()
	assert(audio.context=="boss" and audio.stream==boss and audio.playing)
	assert(arena.boss_wave_active)
	arena.clear_arena()
	arena._play_menu_music()
	assert(audio.context=="menu" and audio.stream==menu)
	root.get_node("Progression").end_run()
	global.player.queue_free()
	global.player=null
	arena.queue_free()
	await process_frame
	await process_frame
	print("PASS music contexts: menu continuity, waves, pause, shop/rewards, looping, wave/arena overrides, random pool and wave-20 boss")
	quit()
