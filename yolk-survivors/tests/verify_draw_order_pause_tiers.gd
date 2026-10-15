extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var global = root.get_node("Global")
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	for i in 5:
		var data = global.main_weapon_selected.duplicate()
		data.item_tier = (i+1)%4
		global.player.add_weapon(data)
	arena.set_wave_paused(true)
	await process_frame
	for tile in arena.pause_panel.weapons_grid.get_children():
		var marker = tile.get_child(0).get_node("RarityMarker")
		var tile_rect: Rect2 = tile.get_global_rect()
		var marker_rect: Rect2 = marker.get_global_rect()
		assert(tile_rect.encloses(marker_rect))
		assert(marker_rect.get_center().y > tile_rect.get_center().y)
	arena.shop_panel.load_shop(6)
	assert(arena.shop_panel.get_node("MarginContainer/Control/VBoxContainer/NewWaveButton").text == "next wave 7")
	var fried = load("res://scenes/units/fried.tscn").instantiate()
	arena.add_child(fried)
	var coin = load("res://scenes/coins/coins.tscn").instantiate()
	arena.add_child(coin)
	var number = load("res://scenes/ui/floating_text/floating_text.tscn").instantiate()
	arena.add_child(number)
	assert(fried.z_index < coin.get_node("Shadow").z_index)
	assert(coin.get_node("Shadow").z_index == global.player.shadow.z_index)
	assert(global.player.shadow.z_index < coin.sprite.z_index)
	assert(coin.sprite.z_index == global.player.sprite.z_index)
	assert(number.get_node("Label").z_index > global.player.sprite.z_index)
	assert(not fried.z_as_relative and not global.player.shadow.z_as_relative)
	print("PASS pause tier anchors, next wave label and absolute corpse/shadow/actor/number draw order")
	quit()
