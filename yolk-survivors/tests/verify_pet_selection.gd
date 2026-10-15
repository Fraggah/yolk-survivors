extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0].duplicate()
	global.main_player_selected.starting_weapon=load("res://resources/items/weapons/melee/spatula/item_spatula_1.tres")
	var menu=arena.weapon_selection_panel
	assert(menu.weapons_list.size()==40 and menu.weapons_container.get_child_count()==40)
	var pets=load("res://resources/items/weapons/pet_catalogue.gd").items()
	assert(pets.size()==2)
	for pet in pets:
		assert(menu.weapons_list.has(pet) and pet.selection_only)
		assert(not arena.shop_panel.shop_items.has(pet))
		menu._on_weapon_selected(pet)
		assert(menu.weapon_title.text=="Pet — preview")
		assert(menu.weapon_icon.texture==pet.item_icon)
		assert(global.is_empty_preview_loadout() and global.get_starting_weapons().is_empty())
	assert(pets[1].item_icon.resource_path=="res://assets/sprites/Pets/Icons/toaster_cat.png")
	assert(load("res://assets/sprites/Pets/InGame/toaster_cat_attack.png") is Texture2D)
	arena._on_level_selected(0)
	assert(arena.in_arena and global.player.current_weapons.is_empty())
	assert(global.equipped_weapons.is_empty())
	print("PASS both pets selectable, cat idle icon, attack art ready, no shop offers or starting equipment")
	quit()
