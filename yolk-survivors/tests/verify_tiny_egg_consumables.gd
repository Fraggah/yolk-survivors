extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	await process_frame
	var global=root.get_node("Global")
	global.main_player_selected=load("res://resources/units/players/player_tiny_egg.tres")
	for item in arena.weapon_selection_panel.weapons_list:
		if global.is_valid_starting_weapon(item) and global.main_player_selected.can_use_weapon(item):
			global.main_weapon_selected=item
			break
	arena._on_level_selected(0)
	assert(global.player.passive_items.golden_yolks==2)
	assert(global.player.passive_items.breading_charges==2)
	arena.wave_active=false
	global.game_paused=true
	arena.spawner.spawn_timer.stop()
	arena.spawner.wave_timer.stop()
	arena.clear_arena()
	arena.shop_panel.load_shop(1)
	arena.start_panel.hide()
	arena.shop_panel.show()
	await process_frame
	await process_frame
	for button in [arena.shop_panel.golden_control,arena.shop_panel.breading_control]:
		button.refresh()
		var weapons=arena.shop_panel.get_node("MarginContainer/Control/EquipmentArea/WeaponPanel").get_global_rect()
		assert(button.get_global_rect().end.x<weapons.position.x)
		assert(button.get_global_rect().position.y>=weapons.position.y)
		assert(button.get_global_rect().end.y<=weapons.end.y)
		assert(button.text=="" and button.get_node("Count").text=="2")
		assert(is_equal_approx(button.size.x,button.size.y))
		assert(button.get_node("Count").get_global_rect().end.x<button.get_global_rect().position.x)
	var grid=arena.shop_panel.weapon_container
	arena.shop_panel._sync_weapon_slots()
	await process_frame
	await process_frame
	assert(grid.get_child_count()==global.player.get_weapon_limit())
	var title=arena.shop_panel.get_node("MarginContainer/Control/EquipmentArea/WeaponPanel/Label")
	assert(absf(grid.get_global_rect().get_center().x-title.get_global_rect().get_center().x)<10)
	var golden=arena.shop_panel.golden_control
	var breading=arena.shop_panel.breading_control
	assert(golden.size.x<grid.get_child(0).size.x)
	assert(absf(golden.get_global_rect().get_center().y-grid.get_child(0).get_global_rect().get_center().y)<3)
	assert(absf(breading.get_global_rect().get_center().y-grid.get_child(3).get_global_rect().get_center().y)<3)
	var first_position=grid.get_child(0).global_position
	var data=global.player.current_weapons[0].data
	var extra=null
	for item in arena.shop_panel.shop_items:
		if item.get("effect_key")=="extra_slot": extra=item; break
	assert(extra!=null)
	for i in 3: global.player.passive_items.owned_records.append({"item":extra})
	for n in range(1,9):
		global.player.add_weapon(data)
		arena.shop_panel.create_item_weapon(data)
		arena.shop_panel._sync_weapon_slots()
		await process_frame
		await process_frame
		assert(grid.get_child(0).global_position.distance_to(first_position)<10)
		for j in range(1,n+1):
			var previous=grid.get_child(j-1).position
			var current=grid.get_child(j).position
			if j%3==0: assert(current.x==0 and current.y>previous.y)
			else: assert(current.x>previous.x and current.y==previous.y)
	assert(grid.get_child_count()==9)
	var scroll=grid.get_parent().get_parent()
	assert(scroll is ScrollContainer and scroll.get_v_scroll_bar().max_value>scroll.size.y)
	scroll.scroll_vertical=80
	await process_frame
	assert(scroll.scroll_vertical>0)
	scroll.scroll_vertical=0
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/solo-consumable-buttons.png"))
	arena.shop_panel._on_item_card_selected(grid.get_child(0),false)
	arena.shop_panel._on_sell_weapon_button_pressed()
	await process_frame
	arena.shop_panel._sync_weapon_slots()
	await process_frame
	assert(grid.get_child_count()==9)
	assert(grid.get_child(0).global_position.distance_to(first_position)<10)
	assert(grid.get_child(8).get_meta("empty_weapon_slot",false))
	arena.shop_panel._on_item_card_selected(grid.get_child(0),false)
	arena.shop_panel._on_combine_button_pressed()
	await process_frame
	arena.shop_panel._sync_weapon_slots()
	await process_frame
	assert(global.player.current_weapons.size()==7 and grid.get_child_count()==9)
	assert(grid.get_child(0).global_position.distance_to(first_position)<10)
	print("PASS solo consumables, fixed weapon slots, left-to-right rows, extra-slot scrolling, sale and combine")
	arena.queue_free()
	await process_frame
	quit()
