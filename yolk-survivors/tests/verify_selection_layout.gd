extends SceneTree
func _initialize(): call_deferred("verify")

func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var characters = arena.selection_panel
	var weapons = arena.weapon_selection_panel
	arena._on_start_panel_on_play_pressed()
	for viewport_size in [Vector2i(1280,720), Vector2i(1920,1080), Vector2i(2560,1440)]:
		root.size = viewport_size
		await process_frame
		await process_frame
		characters.roster_layout.refresh()
		weapons.roster_layout.refresh()
		await process_frame
		await process_frame
		var roster_rect = weapons.roster_layout.weapon_scroll.get_rect()
		assert(is_equal_approx(weapons.player_panel.size.x, weapons.weapon_panel.size.x))
		for panel in [weapons.player_panel, weapons.weapon_panel]:
			assert(is_equal_approx(panel.position.y, roster_rect.position.y))
			assert(is_equal_approx(panel.size.y, roster_rect.size.y))
		for menu in [characters, weapons]:
			var back_rect = menu.roster_layout.back.get_rect()
			assert(is_equal_approx(back_rect.position.x, menu.roster_layout.content_rect().position.x) and back_rect.end.y < 120)
			assert(is_equal_approx(menu.heading.get_rect().get_center().x, menu.size.x * 0.5))
		assert(is_equal_approx(characters.player_panel.get_rect().get_center().y, weapons.player_panel.get_rect().get_center().y))
		weapons._show_player_preview(characters.player_list[4])
		await process_frame
		await process_frame
		assert(weapons.player_description.get_content_height() <= weapons.player_description.size.y, "Player text clipped at " + str(viewport_size))
		assert(characters.players_container.get_child_count() == 15)
		assert(characters.roster_layout.right_players.get_child_count() == 15)
		assert(weapons.weapons_container.get_child_count() == 42)
		for menu in [characters,weapons]:
			var grids = [menu.players_container,menu.roster_layout.right_players] if menu == characters else [menu.weapons_container]
			for grid in grids:
				var visible_grid=grid if menu==characters else menu.roster_layout.weapon_scroll
				assert(menu.get_global_rect().encloses(visible_grid.get_global_rect()))
				for slot in grid.get_children(): assert(grid.get_global_rect().encloses(slot.get_global_rect()))
			for count in range(1,5):
				var slots = menu.roster_layout.player_slot_rects(count,menu == weapons)
				assert(slots.size() == count)
				for i in slots.size():
					assert(menu.get_rect().encloses(slots[i]))
					if i > 0: assert(not slots[i].intersects(slots[i-1]))
	root.size = Vector2i(1920,1080)
	await process_frame
	characters.players_container.get_child(4).mouse_entered.emit()
	await process_frame
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("user://characters-layout.png")
	characters.players_container.get_child(4).pressed.emit()
	assert(characters.transitioning and characters.visible and not weapons.visible)
	await create_timer(0.7).timeout
	assert(not characters.visible and weapons.visible)
	weapons.weapons_container.get_child(0).mouse_entered.emit()
	await create_timer(0.3).timeout
	assert(weapons.player_description.get_content_height() <= weapons.player_description.size.y)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("user://weapons-layout.png")
	weapons._on_custom_button_exit_pressed()
	assert(characters.visible and not weapons.visible and not characters.transitioning)
	assert(characters.players_container.modulate.a == 1)
	assert(characters.player_panel.position.is_equal_approx(characters.roster_layout.player_slot_rects(1)[0].position))
	weapons.show()
	characters.hide()
	weapons.weapons_container.get_child(6).pressed.emit()
	assert(arena.level_panel.visible and not weapons.visible)
	print("PASS 30/40 slots without scroll, three landscape sizes, 1-4 layout slots, transition, Back and weapon confirmation")
	quit()
