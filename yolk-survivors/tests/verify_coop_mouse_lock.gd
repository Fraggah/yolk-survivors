extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	await process_frame
	var coop=arena.coop
	var menu=root.get_node("MenuInput")
	coop.open()
	coop.join(-1); coop.join(0)
	coop.start_run()
	menu._sync_coop_mouse_lock()
	arena.spawner.spawn_timer.stop()
	arena.spawner.wave_timer.stop()
	for s in coop.sessions:
		s.actor.set_process(false)
		for w in s.actor.current_weapons: w.set_process(false)
	for phase in ["shop","upgrades","rewards"]:
		if phase=="upgrades": coop.sessions[0].experience.grant_levels(1)
		if phase=="rewards":
			for item in arena.shop_panel.shop_items:
				if item.get("effect_key")=="oregano": coop.sessions[0].rewards.append(item); break
		coop._show_post_wave_phase(phase)
		await process_frame
		await process_frame
		var panel=coop.panels[0]
		coop.sessions[0].cursor=0
		panel.present()
		panel._hover(1)
		assert(coop.sessions[0].cursor==0 and not panel.mouse_navigation)
		var old_balance=coop.sessions[0].coins
		panel.controls[0].pressed.emit()
		assert(coop.sessions[0].coins==old_balance)
		for button in panel.controls: assert(button.mouse_filter==Control.MOUSE_FILTER_IGNORE)
		var motion=InputEventMouseMotion.new()
		motion.position=panel.controls[1].get_global_rect().get_center()
		motion.relative=Vector2(50,50)
		Input.parse_input_event(motion)
		await process_frame
		assert(coop.sessions[0].cursor==0)
		assert(Input.mouse_mode==Input.MOUSE_MODE_HIDDEN)
	coop._set_paused(true,coop.sessions[0])
	await process_frame
	menu._controls(arena.pause_panel)
	assert(arena.pause_panel.return_button.mouse_filter==Control.MOUSE_FILTER_IGNORE)
	coop._set_paused(false)
	coop.stop()
	menu._sync_coop_mouse_lock()
	assert(not menu.coop_mouse_blocked() and not menu.coop_mouse_lock_active)
	assert(not arena.start_panel.has_meta("coop_saved_mouse_filter"))
	assert(arena.start_panel.mouse_filter!=Control.MOUSE_FILTER_IGNORE)
	print("PASS persistent co-op mouse lock: dynamic shop/upgrades/rewards, hover, click, pause and main menu restoration")
	arena.queue_free()
	await process_frame
	quit()
