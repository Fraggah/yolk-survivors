extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena); current_scene=arena
	await process_frame
	arena._on_start_panel_on_play_pressed()
	var flow=arena.coop_selection
	flow.set_process(false)
	flow.enable(-1)
	for device in [0,1,2]: flow._join_device(device)
	flow.mode="weapons"
	arena.selection_panel.hide(); arena.weapon_selection_panel.show()
	var restricted=null
	var unrestricted=null
	var weapon=null
	for character in flow._choices(false):
		for item in flow._choices(true):
			if not character.can_use_weapon(item): restricted=character; weapon=item; break
		if restricted: break
	assert(restricted!=null,"Fixture must include restricted weapons")
	for character in flow._choices(false):
		if character.can_use_weapon(weapon): unrestricted=character; break
	assert(unrestricted!=null)
	for i in 4:
		var session=arena.coop.sessions[i]
		session.character=restricted
		session.weapon=weapon
		flow.refresh()
		var content=flow.weapon_rows.get_node("Rows").get_child(i).get_node("Margin/Content")
		assert(content.get_node("Description").text.contains("No compatible"))
		assert(content.get_node("Header/Confirm").disabled)
		flow.confirm(session)
		assert(not session.ready and flow.mode=="weapons")
		for card in flow._roster_cards(true):
			if card.get_meta("selection_data")==weapon:
				assert(card.get_node("CoopMarkers").get_child(i).text.contains("✕"))
	# Mouse previews the incompatible weapon and clicking still cannot ready it.
	flow.choose_weapon(weapon,true)
	assert(arena.coop.sessions[0].weapon==weapon and not arena.coop.sessions[0].ready)
	# The same card remains compatible for a different player.
	arena.coop.sessions[1].character=unrestricted
	flow.refresh()
	flow.confirm(arena.coop.sessions[1])
	assert(arena.coop.sessions[1].ready)
	assert(not arena.coop.sessions[0].ready)
	await process_frame; await process_frame
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/coop-incompatible.png"))
	arena.queue_free()
	await process_frame; await process_frame
	print("PASS individual weapon restrictions: all four notices, markers, blocked confirmation, mouse and shared compatible card")
	quit()
