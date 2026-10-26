extends SceneTree
func _initialize(): call_deferred("verify")

func pointer(point: Vector2) -> void:
	var motion=InputEventMouseMotion.new()
	motion.position=point
	motion.global_position=point
	motion.relative=Vector2(10,0)
	Input.parse_input_event(motion)

func click(point: Vector2) -> void:
	pointer(point)
	for pressed in [true,false]:
		var input=InputEventMouseButton.new()
		input.button_index=MOUSE_BUTTON_LEFT
		input.position=point
		input.global_position=point
		input.pressed=pressed
		Input.parse_input_event(input)
		await process_frame

func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena); current_scene=arena
	await process_frame
	arena._on_start_panel_on_play_pressed()
	await process_frame
	var flow=arena.coop_selection
	flow.set_process(false)
	var menu=root.get_node("MenuInput")
	var sound=root.get_node("SoundManager")
	var theme=root.get_node("UITheme")
	var switch=flow.switch
	menu.connected_gamepads.assign([0])
	menu._set_gamepad_active(true)
	menu._controls(arena.selection_panel)
	assert(switch.mouse_filter==Control.MOUSE_FILTER_STOP,"Switch stays clickable with a controller connected")
	var track=switch.get_node("Margin/Row/Track")
	var title=switch.get_node("Margin/Row/Title")
	assert(track.size.x>=26 and track.size.y>=44 and track.size.y>track.size.x)
	assert(title.get_global_rect().end.x<=track.get_global_rect().position.x)
	assert(title.get_global_rect().position.x>=switch.get_global_rect().position.x+12)
	assert(absf(track.get_global_rect().get_center().y-title.get_global_rect().get_center().y)<1)
	assert(switch.size==arena.selection_panel.roster_layout.back.size)
	assert(title.get_theme_font_size("font_size")==arena.selection_panel.roster_layout.back.get_theme_font_size("font_size"))
	var off_position=switch.knob.position.y
	await click(switch.get_global_rect().get_center())
	assert(flow.enabled and switch.button_pressed,"A real mouse click must reach the switch through the layout")
	assert(arena.coop.sessions[0].device==-1)
	await create_timer(.15).timeout
	assert(switch.knob.position.y<off_position)
	var cards=arena.selection_panel.get_player_cards()
	var target=cards[1]
	sound.event_times.erase("selection_hover")
	pointer(target.get_global_rect().get_center())
	await process_frame
	await process_frame
	assert(arena.coop.sessions[0].character==target.get_meta("selection_data"))
	assert(target.coop_highlights.size()==1)
	assert(target.get_theme_stylebox("normal").bg_color==theme.palette.hover_surface)
	assert(target.get_theme_stylebox("normal").border_width_left>=theme.palette.focus_width)
	assert(sound.event_times.has("selection_hover"),"Mouse hover emits the existing selection sound")
	var notice=flow.character_rows.get_node("Rows").get_child(0).get_node("Margin/Content/SoloNotice")
	assert(not notice.visible)
	await click(target.get_global_rect().get_center())
	assert(arena.coop.sessions[0].ready,"Mouse click immediately confirms the character")
	assert(flow.mode=="characters" and not flow.transitioning,"One ready player cannot advance co-op")
	assert(notice.visible)
	pointer(cards[2].get_global_rect().get_center())
	await process_frame
	assert(arena.coop.sessions[0].character==target.get_meta("selection_data"),"Hover cannot change a ready character")
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/coop-single-ready.png"))
	flow.confirm(arena.coop.sessions[0])
	assert(not notice.visible)
	flow.confirm(arena.coop.sessions[0])
	assert(notice.visible)
	# Each controller receives the same feedback without stealing another selector.
	var second=flow._join_device(3)
	assert(not notice.visible,"Solo notice disappears when another player joins")
	var first_choice=arena.coop.sessions[0].character
	sound.event_times.erase("selection_hover")
	flow.move_cursor(second,2)
	assert(sound.event_times.has("selection_hover"))
	assert(arena.coop.sessions[0].character==first_choice)
	var count:=0
	for card in cards:
		if card.coop_highlights.has(arena.coop.COLORS[1]): count+=1
	assert(count==1)
	var stamp=sound.event_times.selection_hover
	flow.refresh()
	assert(sound.event_times.selection_hover==stamp,"Refresh itself must not replay hover audio")
	theme.set_palette("sage")
	assert(target.get_theme_stylebox("normal").bg_color==theme.palette.hover_surface)
	theme.set_palette("cream")
	if OS.get_cmdline_user_args().has("--capture"):
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/coop-hover-toggle.png"))
	# Mouse remains available even when co-op owns input after controller use.
	menu.gamepad_active=true
	switch.mouse_filter=Control.MOUSE_FILTER_STOP
	pointer(switch.get_global_rect().get_center())
	await process_frame
	assert(Input.mouse_mode==Input.MOUSE_MODE_VISIBLE)
	await click(switch.get_global_rect().get_center())
	assert(not flow.enabled and not switch.button_pressed)
	for card in cards: assert(card.coop_highlights.is_empty())
	menu.connected_gamepads.clear(); menu._set_gamepad_active(false)
	arena.queue_free()
	await process_frame; await process_frame
	print("PASS co-op hover/toggle: real mouse clicks, controller coexistence, vertical margins/knob, independent player borders, hover SFX, palette and solo restoration")
	quit()


