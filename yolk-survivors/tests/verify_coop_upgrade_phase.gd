extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena); current_scene=arena
	await process_frame
	var coop=arena.coop
	coop.set_process(false)
	coop.open()
	for device in [-1,0,1]: coop.join(device)
	coop.start_run()
	coop.sessions[0].experience.grant_levels(2)
	coop.sessions[2].experience.grant_levels(1)
	await coop.wave_completed()
	assert(coop.mode=="upgrades")
	await process_frame; await process_frame
	assert(coop.screen.theme_type_variation==&"OverlayPanel")
	assert(coop.panels[1].get_node("Waiting").visible)
	assert(coop.panels[1].get_node("Waiting").text=="Listo")
	assert(not coop.panels[1].get_node("Margin").visible)
	assert(coop.panels[3].get_node("Waiting").text=="Jugador no conectado")
	for i in [0,2]:
		assert(coop.panels[i].cards[0].get_script()==load("res://scenes/ui/upgrades/upgrade_card.gd"))
		assert(coop.panels[i].get_node("Margin").visible)
	var palette=root.get_node("UITheme").palette
	var mouse_panel=coop.panels[0]
	for j in 4:
		mouse_panel.cards[j].mouse_entered.emit()
		assert(mouse_panel.controls[j].get_theme_stylebox("normal").bg_color==palette.hover_surface)
		mouse_panel.cards[j].mouse_exited.emit()
		assert(mouse_panel.controls[j].get_theme_stylebox("normal").bg_color!=palette.hover_surface)
	mouse_panel.move_selector(Vector2.RIGHT)
	assert(mouse_panel.controls[coop.sessions[0].cursor].get_theme_stylebox("normal").bg_color==palette.hover_surface)
	coop.panels[2].move_selector(Vector2.RIGHT)
	assert(coop.panels[2].controls[coop.sessions[2].cursor].get_theme_stylebox("normal").bg_color==palette.hover_surface)
	var coins=coop.sessions[1].coins
	coop.activate(coop.sessions[1],4)
	coop.activate(coop.sessions[1],7)
	assert(coop.sessions[1].coins==coins and coop.mode=="upgrades")
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/coop-upgrades-separated.png"))
	coop.activate(coop.sessions[2],0)
	assert(coop.mode=="upgrades" and coop.panels[2].get_node("Waiting").visible)
	coop.activate(coop.sessions[0],0)
	assert(coop.mode=="upgrades" and coop.sessions[0].experience.pending_levels.size()==1)
	coop.activate(coop.sessions[0],0)
	assert(coop.mode=="shop" and coop.screen.theme_type_variation==&"ScreenPanel")
	for session in coop.sessions:
		assert(not session.ready)
		for item in session.offers:
			assert(not is_instance_of(item,load("res://resources/items/upgrades/item_upgrades.gd")))
	coop.activate(coop.sessions[0],7)
	coop.activate(coop.sessions[1],7)
	assert(coop.mode=="shop")
	coop.activate(coop.sessions[2],7)
	assert(coop.mode=="combat")
	coop.stop(); arena.queue_free()
	await process_frame; await process_frame
	print("PASS separate upgrades: only leveled players choose, automatic waiting, multiple levels, no shop until all finish, transparent solo visuals, shop-ready barrier")
	quit()
