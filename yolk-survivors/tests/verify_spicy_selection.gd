extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	var menu=arena.weapon_selection_panel
	var items=load("res://resources/items/weapons/spicy_catalogue.gd").items()
	global.main_player_selected=arena.selection_panel.player_list[0].duplicate()
	# Even a character's own starting weapon must be omitted for these previews.
	global.main_player_selected.starting_weapon=load("res://resources/items/weapons/melee/spatula/item_spatula_1.tres")
	assert(menu.weapons_list.size()==42)
	assert(menu.weapons_container.get_child_count()==42)
	for item in items:
		assert(menu.weapons_list.has(item) and not item.selection_only)
		assert(arena.shop_panel.shop_items.has(item))
		assert(global.is_valid_selection(item) and global.is_valid_starting_weapon(item))
		menu._on_weapon_selected(item)
		assert(global.main_weapon_selected==item)
		assert(menu.weapon_icon.texture==item.item_icon)
		assert(menu.weapon_title.text=="Spicy")
		assert(global.get_starting_weapons().size()==2)
		assert(not global.is_empty_preview_loadout())
	global.main_weapon_selected=null
	assert(not global.is_empty_preview_loadout())
	arena._on_level_selected(0)
	assert(not arena.in_arena, "Missing selection must still be rejected")
	menu._on_weapon_selected(load("res://resources/items/weapons/pet_catalogue.gd").items()[0])
	arena._on_level_selected(0)
	assert(arena.in_arena and global.player)
	assert(global.player.current_weapons.is_empty())
	assert(global.equipped_weapons.is_empty())
	assert(not arena.spawner.wave_timer.is_stopped())
	await process_frame
	assert(arena.shop_panel.weapon_container.get_child_count()==0)
	global.main_weapon_selected=load("res://resources/items/weapons/range/knifer/item_knifer_1.tres")
	assert(not global.is_empty_preview_loadout())
	assert(global.get_starting_weapons().size()==2)
	print("PASS all ten active spicy choices/shop items, descriptions, valid loadouts, pets remain empty previews")
	quit()
