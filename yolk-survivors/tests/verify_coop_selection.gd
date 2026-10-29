extends SceneTree
func _initialize(): call_deferred("verify")

func event(device: int, pressed: bool, button: int = 0) -> InputEvent:
	if device<0:
		var key=InputEventKey.new()
		key.physical_keycode=KEY_ENTER
		key.pressed=pressed
		return key
	var pad=InputEventJoypadButton.new()
	pad.device=device
	pad.button_index=button
	pad.pressed=pressed
	return pad

func join_held(flow, device: int) -> void:
	flow._input(event(device,true))
	flow.advance_holds(flow.join_hold_seconds+.01)
	flow._input(event(device,false))

func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena); current_scene=arena
	await process_frame
	var menu=root.get_node("MenuInput")
	var flow=arena.coop_selection
	flow.set_process(false)
	assert(not arena.start_panel.has_node("MarginContainer/VBoxContainer/CoopButton"))
	arena._on_start_panel_on_play_pressed()
	assert(arena.selection_panel.visible and not flow.enabled)
	assert(flow.switch.visible and not arena.weapon_selection_panel.get_node("CoopGame").visible)
	# A controller activates the real switch; its triggering press is consumed.
	menu.last_device=7; menu.last_input_event=event(7,true)
	flow.switch.button_pressed=true
	assert(flow.enabled and arena.coop.sessions.size()==1)
	assert(arena.coop.sessions[0].device==7 and not arena.coop.sessions[0].ready)
	flow._input(event(7,true))
	assert(not arena.coop.sessions[0].ready)
	flow._input(event(7,false))
	assert(flow.character_rows.get_node("Rows").get_child_count()==4)
	assert(not arena.selection_panel.player_panel.get_node("MarginContainer").visible)
	var empty=flow.character_rows.get_node("Rows/Player2/Margin/Content")
	assert(empty.get_node("Description").text.contains("Hold"))
	assert(not empty.get_node("Header/Confirm").visible)
	await process_frame
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/coop-integrated-join.png"))
	# Releasing early cancels a join. Holding through the threshold joins once.
	flow._input(event(3,true)); flow.advance_holds(flow.join_hold_seconds*.5)
	assert(arena.coop.sessions.size()==1)
	flow._input(event(3,false)); flow.advance_holds(flow.join_hold_seconds)
	assert(arena.coop.sessions.size()==1)
	join_held(flow,3)
	assert(arena.coop.sessions.size()==2 and not arena.coop.sessions[1].ready)
	join_held(flow,-1); join_held(flow,5); join_held(flow,9)
	assert(arena.coop.sessions.size()==4)
	var original=arena.coop.sessions[0].character
	flow.move_cursor(arena.coop.sessions[1],1)
	assert(arena.coop.sessions[1].character!=original and arena.coop.sessions[0].character==original)
	# Toggle off restores the original solo preview, without changing menus.
	flow.switch.button_pressed=false
	assert(not flow.enabled and arena.coop.sessions.is_empty())
	assert(arena.selection_panel.player_panel.get_node("MarginContainer").visible)
	assert(arena.selection_panel.visible and not arena.weapon_selection_panel.visible)
	menu.last_device=-1; menu.last_input_event=InputEventMouseButton.new()
	flow.switch.button_pressed=true
	assert(arena.coop.sessions[0].device==-1)
	for device in [2,3,4]: join_held(flow,device)
	assert(arena.coop.sessions.size()==4)
	await process_frame
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/coop-integrated-characters.png"))
	var start=arena.selection_panel.player_panel.position
	for session in arena.coop.sessions: flow.confirm(session)
	assert(flow.transitioning and arena.selection_panel.transitioning)
	await create_timer(.35).timeout
	assert(arena.selection_panel.player_panel.position.x<start.x)
	await create_timer(.4).timeout
	assert(flow.mode=="weapons" and not flow.transitioning)
	assert(arena.weapon_selection_panel.visible and not arena.selection_panel.visible)
	assert(not arena.coop.active and not arena.in_arena)
	var back=arena.weapon_selection_panel.roster_layout.back
	assert(back.is_visible_in_tree() and back.get_global_rect().position.y>=0)
	assert(flow.weapon_character_rows.get_node("Rows").get_child_count()==4)
	assert(flow.weapon_rows.get_node("Rows").get_child_count()==4)
	var first_weapon=arena.coop.sessions[0].weapon
	flow.move_cursor(arena.coop.sessions[1],1)
	assert(arena.coop.sessions[0].weapon==first_weapon)
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/coop-integrated-weapons.png"))
	for session in arena.coop.sessions: flow.confirm(session)
	assert(flow.mode=="difficulty" and arena.level_panel.visible)
	await process_frame
	await process_frame
	var menu_input=root.get_node("MenuInput")
	assert(root.gui_get_focus_owner()==arena.level_panel.buttons[0],"Difficulty 0 is selected initially")
	assert(menu_input.coop_mouse_blocked())
	var mouse=InputEventMouseButton.new()
	mouse.button_index=MOUSE_BUTTON_LEFT
	mouse.pressed=true
	menu_input._input(mouse)
	assert(Input.mouse_mode==Input.MOUSE_MODE_HIDDEN)
	var other=InputEventJoypadButton.new()
	other.device=arena.coop.sessions[1].device
	other.button_index=JOY_BUTTON_A
	other.pressed=true
	flow._input(other)
	assert(flow.mode=="difficulty" and not arena.coop.active,"P2 cannot confirm difficulty")
	# Every visible action is reachable geometrically from difficulty 1.
	var reachable: Array=[arena.level_panel.buttons[0]]
	var pending: Array=reachable.duplicate()
	while not pending.is_empty():
		var origin=pending.pop_front()
		for direction in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
			origin.grab_focus()
			menu_input.move_focus(direction)
			var destination=root.gui_get_focus_owner()
			if destination and not reachable.has(destination):
				reachable.append(destination)
				pending.append(destination)
	for button in menu_input._controls(arena.level_panel): assert(reachable.has(button),"Unreachable difficulty action: "+str(button.name))
	flow._focus_difficulty()
	assert(not arena.weapon_selection_panel.visible and not arena.coop.active)
	assert(arena.spawner.wave_timer.is_stopped())
	arena._on_level_panel_on_level_selection_exited()
	assert(flow.mode=="weapons" and arena.weapon_selection_panel.visible)
	flow.back_to_characters()
	assert(flow.mode=="characters" and arena.selection_panel.visible)
	assert(not arena.selection_panel.transitioning)
	# Hover signals may still arrive when the pointer crosses an ignored GUI.
	var keyboard_session=arena.coop.sessions[0]
	var original_character=keyboard_session.character
	var original_ready=keyboard_session.ready
	for card in flow._roster_cards(false):
		assert(card.mouse_filter==Control.MOUSE_FILTER_IGNORE)
		card.mouse_entered.emit()
	assert(keyboard_session.character==original_character and keyboard_session.ready==original_ready)
	flow._mouse_confirm(0)
	assert(keyboard_session.ready==original_ready)
	# The existing difficulty choice applies to all four participants.
	for session in arena.coop.sessions: flow.confirm(session)
	await create_timer(.7).timeout
	for session in arena.coop.sessions: flow.confirm(session)
	arena._on_level_selected(2)
	assert(arena.coop.active and root.get_node("Global").coop_players.size()==4)
	assert(arena.spawner.difficulty_index==2 and not arena.level_panel.visible)
	arena.coop.stop()
	arena._on_start_panel_on_play_pressed()
	flow.disable()
	# Single-player still uses the existing auto-advance animation.
	arena.selection_panel._on_player_selected(arena.selection_panel.player_list[0])
	await create_timer(.7).timeout
	assert(arena.weapon_selection_panel.visible and not flow.enabled)
	var notice_flow=arena.coop_selection
	notice_flow.solo_notice_text="Aviso configurable desde el Inspector"
	notice_flow.refresh()
	for rows in [notice_flow.character_rows,notice_flow.weapon_character_rows,notice_flow.weapon_rows]:
		for card in rows.get_node("Rows").get_children():
			assert(card.get_node("Margin/Content/SoloNotice/Margin/Message").text==notice_flow.solo_notice_text)
	arena.queue_free()
	await process_frame; await process_frame
	print("PASS integrated co-op selection: normal entry/switch, activating device, four slots, held join/cancel/limit, independent selection, shared animation, paired weapon rows, one difficulty and solo restoration")
	quit()
