extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var menu=arena.weapon_selection_panel
	assert(menu.weapons_list.size()==40 and menu.weapons_container.get_child_count()==40)
	var pets=load("res://resources/items/weapons/pet_catalogue.gd").items()
	assert(pets.size()==2)
	for pet in pets:
		assert(not menu.weapons_list.has(pet) and pet.selection_only)
		assert(not arena.selection_panel.weapons_list.has(pet))
		for card in menu.weapons_container.get_children():
			assert(card.get_meta("selection_data", null) != pet)
		assert(not arena.shop_panel.shop_items.has(pet))
	assert(pets[1].item_icon.resource_path=="res://assets/sprites/Pets/Icons/toaster_cat.png")
	assert(load("res://assets/sprites/Pets/InGame/toaster_cat_attack.png") is Texture2D)
	arena.queue_free()
	await process_frame
	print("PASS pets absent from the starter roster and shop; artwork still available")
	quit()
