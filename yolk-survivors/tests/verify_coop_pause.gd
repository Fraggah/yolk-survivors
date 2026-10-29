extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	await process_frame
	var coop=arena.coop
	coop.open()
	for device in [-1,0,1,2]: coop.join(device)
	coop.start_run()
	arena.spawner.spawn_timer.stop()
	for s in coop.sessions:
		s.actor.set_process(false)
		for weapon in s.actor.current_weapons: weapon.set_process(false)
	for i in 4:
		var s=coop.sessions[i]
		s.actor.stats.ranged_damage=10+i
		var pause_event: InputEvent
		if s.device<0:
			pause_event=InputEventKey.new()
			pause_event.physical_keycode=KEY_ESCAPE
		else:
			pause_event=InputEventJoypadButton.new()
			pause_event.device=s.device
			pause_event.button_index=JOY_BUTTON_START
		pause_event.pressed=true
		coop._input(pause_event)
		await process_frame
		assert(coop.paused and arena.pause_panel.visible and not coop.screen.visible)
		assert(arena.pause_panel.bound_player==s.actor and arena.pause_panel.stats.bound_player==s.actor)
		assert(arena.pause_panel.weapons_grid.get_child_count()==s.actor.current_weapons.size())
		arena.pause_panel.stats._update_values()
		assert(arena.pause_panel.stats.stat_labels["ranged_damage"].text==str(10+i))
		assert(arena.spawner.wave_timer.paused and arena.spawner.spawn_timer.paused)
		var event=InputEventJoypadButton.new()
		event.device=coop.sessions[(i+1)%4].device
		event.button_index=JOY_BUTTON_Y
		event.pressed=true
		coop._input(event)
		assert(not arena.pause_panel.stats.secondary_visible)
		if i==1 and OS.get_cmdline_user_args().has("--capture"):
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/coop-pause-p2.png"))
		arena._on_pause_panel_on_return_pressed()
		assert(not coop.paused and not arena.pause_panel.visible and not root.get_node("Global").game_paused)
		assert(not arena.spawner.wave_timer.paused)
	# All intermission phases resume their existing panel and cursor.
	for phase in ["shop","upgrades","rewards"]:
		if phase=="upgrades": coop.sessions[0].experience.grant_levels(1)
		if phase=="rewards":
			for item in arena.shop_panel.shop_items:
				if item.get("effect_key")=="oregano": coop.sessions[0].rewards.append(item); break
		coop._show_post_wave_phase(phase)
		var old_panels=coop.panels.duplicate()
		coop.sessions[0].cursor=1
		coop._set_paused(true,coop.sessions[1])
		assert(not coop.screen.visible and arena.pause_panel.visible)
		coop._set_paused(false)
		assert(coop.screen.visible and coop.mode==phase and root.get_node("Global").game_paused)
		assert(coop.panels==old_panels and coop.sessions[0].cursor==1)
	arena._on_pause_panel_on_exit_pressed()
	assert(not coop.active and not arena.pause_panel.visible and arena.start_panel.visible)
	print("PASS co-op pause: four owners, personal stats/weapons, timer freeze, owner input, intermission restoration and exit")
	arena.queue_free()
	await process_frame
	quit()
