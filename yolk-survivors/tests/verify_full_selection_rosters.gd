extends SceneTree
func _initialize(): call_deferred("verify")

func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	root.size = Vector2i(1920,1080)
	var scene = load("res://scenes/ui/selection_panel/selection_panel.tscn")
	var characters = scene.instantiate()
	var weapons = scene.instantiate()
	weapons.selection_mode = weapons.SelectionMode.WEAPON
	weapons.weapons_list.append_array(load("res://resources/items/weapons/ranged_catalogue.gd").items())
	weapons.weapons_list.append_array(load("res://resources/items/weapons/spicy_catalogue.gd").items())
	weapons.weapons_list.append_array(load("res://resources/items/weapons/pet_catalogue.gd").items())
	while characters.player_list.size() < 30: characters.player_list.append(characters.player_list[0])
	while weapons.weapons_list.size() < 40: weapons.weapons_list.append(weapons.weapons_list[0])
	root.get_node("Global").main_player_selected = characters.player_list[0]
	root.add_child(characters)
	root.add_child(weapons)
	var navigation = root.get_node("MenuInput")
	var menus: Array[Control] = [characters,weapons]
	navigation.register_menus(menus)
	navigation._on_joy_connection_changed(77,true)
	for menu in [characters,weapons]:
		characters.visible = menu == characters
		weapons.visible = menu == weapons
		await process_frame
		await process_frame
		assert(menu.find_children("*", "ScrollContainer", true, false).is_empty())
		var cards = menu.get_player_cards() if menu == characters else menu.weapons_container.get_children()
		assert(cards.size() == (30 if menu == characters else 40))
		var controls = navigation._controls(menu)
		cards[0].grab_focus()
		var visited = {cards[0]:true}
		var queue = [cards[0]]
		while not queue.is_empty():
			var from = queue.pop_front()
			for direction in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
				from.grab_focus()
				navigation.move_focus(direction)
				var target = root.gui_get_focus_owner()
				if not visited.has(target):
					visited[target] = true
					queue.append(target)
		for control in controls: assert(visited.has(control), "Controller cannot reach " + str(control.get_path()))
		for card in cards: assert(menu.get_global_rect().encloses(card.get_global_rect()))
	print("PASS full 30-character / 40-weapon rosters, no scroll, all cards reachable by controller")
	quit()
