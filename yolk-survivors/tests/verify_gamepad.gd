extends SceneTree

var navigation

func _initialize() -> void:
	call_deferred("verify")

func frames(count: int = 3) -> void:
	for index in count: await process_frame

func joy(button: int, pressed: bool) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	event.pressed = pressed
	Input.parse_input_event(event)
	await frames()

func press(button: int) -> void:
	await joy(button, true)
	await joy(button, false)

func find_button(panel, name: String):
	for button in panel.find_children("*", "Button", true, false):
		if button.name == name: return button
	return null

func route_to(target) -> void:
	var start = root.gui_get_focus_owner()
	var paths: Dictionary = {start: []}
	var queue: Array = [start]
	var directions = [[Vector2.LEFT, JOY_BUTTON_DPAD_LEFT], [Vector2.RIGHT, JOY_BUTTON_DPAD_RIGHT], [Vector2.UP, JOY_BUTTON_DPAD_UP], [Vector2.DOWN, JOY_BUTTON_DPAD_DOWN]]
	while not queue.is_empty():
		var control = queue.pop_front()
		for direction in directions:
			control.grab_focus()
			navigation.move_focus(direction[0])
			var next = root.gui_get_focus_owner()
			if paths.has(next): continue
			paths[next] = paths[control] + [direction[1]]
			queue.append(next)
	assert(paths.has(target), "Unreachable control: " + str(target.get_path()))
	start.grab_focus()
	for button in paths[target]: await press(button)
	assert(root.gui_get_focus_owner() == target, "Real D-pad events did not reach target")

func check_reachability() -> void:
	var start = root.gui_get_focus_owner()
	var controls = navigation._controls(navigation._visible_menu())
	for control in controls:
		await route_to(control)
		assert(control.has_theme_stylebox_override("focus"))
	start.grab_focus()

func verify() -> void:
	load("res://tests/progression_fixture.gd").prepare(root)
	navigation = root.get_node("MenuInput")
	var global = root.get_node("Global")
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	await frames()
	assert(root.gui_get_focus_owner().name == "PlayButton")
	var stick := InputEventJoypadMotion.new()
	stick.axis = JOY_AXIS_LEFT_Y
	stick.axis_value = 0.8
	Input.parse_input_event(stick)
	await frames()
	assert(root.gui_get_focus_owner().name == "OptionsButton", "Stick must navigate menus")
	await frames(24)
	assert(root.gui_get_focus_owner().name != "OptionsButton", "Holding stick must repeat navigation")
	stick.axis_value = 0.0
	Input.parse_input_event(stick)
	await frames()
	var focused = root.gui_get_focus_owner()
	stick.axis_value = 0.2
	Input.parse_input_event(stick)
	await frames(20)
	assert(root.gui_get_focus_owner() == focused, "Stick deadzone must prevent drift")
	stick.axis_value = 0.0
	Input.parse_input_event(stick)
	await frames()
	await check_reachability()
	await route_to(find_button(arena.start_panel, "OptionsButton"))
	await press(JOY_BUTTON_A)
	assert(arena.options_panel.visible)
	await check_reachability()
	await route_to(arena.options_panel.music_slider)
	var volume = arena.options_panel.music_slider.value
	await press(JOY_BUTTON_DPAD_LEFT)
	assert(arena.options_panel.music_slider.value < volume)
	await route_to(find_button(arena.options_panel, "SaveGameButton"))
	await press(JOY_BUTTON_A)
	await route_to(find_button(arena.options_panel, "LoadGameButton"))
	await press(JOY_BUTTON_A)
	await press(JOY_BUTTON_B)
	assert(arena.start_panel.visible and not arena.options_panel.visible)
	await route_to(find_button(arena.start_panel, "CreditsButton"))
	await press(JOY_BUTTON_A)
	await check_reachability()
	await press(JOY_BUTTON_B)
	await route_to(find_button(arena.start_panel, "PlayButton"))
	await press(JOY_BUTTON_A)
	assert(arena.selection_panel.visible)
	assert(global.main_player_selected == null)
	await route_to(arena.selection_panel.players_container.get_child(4))
	assert(arena.selection_panel.player_name.text == "Vampire", "Focus must preview character")
	await press(JOY_BUTTON_A)
	assert(global.main_player_selected.name == "Vampire")
	await check_reachability()
	await route_to(arena.selection_panel.confirm_button)
	await press(JOY_BUTTON_A)
	assert(arena.weapon_selection_panel.visible)
	await check_reachability()
	var bloody_card = arena.weapon_selection_panel.weapons_container.get_child(5)
	await route_to(bloody_card)
	assert(arena.weapon_selection_panel.weapon_name.text.contains("Bloody"))
	await press(JOY_BUTTON_A)
	await route_to(arena.weapon_selection_panel.confirm_button)
	await press(JOY_BUTTON_A)
	assert(arena.level_panel.visible)
	await check_reachability()
	await press(JOY_BUTTON_B)
	assert(arena.weapon_selection_panel.visible)
	await route_to(arena.weapon_selection_panel.confirm_button)
	await press(JOY_BUTTON_A)
	await route_to(arena.level_panel.buttons[0])
	await press(JOY_BUTTON_A)
	assert(arena.wave_active and not global.game_paused)
	var player = global.player
	var origin = player.position
	await joy(JOY_BUTTON_DPAD_RIGHT, true)
	await frames(10)
	assert(player.position.x > origin.x, "D-pad must move player")
	await press(JOY_BUTTON_A)
	assert(player.is_dashing, "Face button must dash")
	await joy(JOY_BUTTON_DPAD_RIGHT, false)
	var motion := InputEventJoypadMotion.new()
	motion.axis = JOY_AXIS_LEFT_Y
	motion.axis_value = -0.8
	Input.parse_input_event(motion)
	origin = player.position
	await frames(10)
	assert(player.position.y < origin.y, "Left joystick must move player")
	motion.axis_value = 0.0
	Input.parse_input_event(motion)
	await press(JOY_BUTTON_START)
	assert(global.game_paused and arena.pause_panel.visible)
	await check_reachability()
	var paused_position = player.position
	await frames(10)
	assert(player.position == paused_position)
	await press(JOY_BUTTON_START)
	assert(not global.game_paused and not arena.pause_panel.visible, "Start must also resume")
	await press(JOY_BUTTON_START)
	assert(global.game_paused and arena.pause_panel.visible)
	await press(JOY_BUTTON_B)
	assert(not global.game_paused and not arena.pause_panel.visible)
	arena.spawner.wave_timer.stop()
	arena.spawner.spawn_timer.stop()
	arena._on_spawner_on_wave_completed()
	await create_timer(1.2).timeout
	await frames()
	assert(arena.upgrade_panel.visible)
	await check_reachability()
	await press(JOY_BUTTON_A)
	await frames()
	assert(arena.shop_panel.visible)
	global.coins = 10000
	await frames()
	await check_reachability()
	var first_slot = arena.shop_panel.weapon_container.get_child(0)
	await route_to(first_slot)
	await frames()
	assert(arena.shop_panel.weapon_tooltip.visible, "Focus must show weapon tooltip without mouse")
	await press(JOY_BUTTON_A)
	await route_to(arena.shop_panel.combine_button)
	await press(JOY_BUTTON_A)
	assert(global.equipped_weapons.size() == 1)
	var purchase = find_button(arena.shop_panel.items_container.get_child(0), "CustomButton")
	if not purchase:
		purchase = arena.shop_panel.items_container.get_child(0).find_children("*", "Button", true, false)[0]
	await route_to(purchase)
	var before_coins = global.coins
	await press(JOY_BUTTON_A)
	assert(global.coins < before_coins, "A must buy an offer")
	await route_to(arena.shop_panel.reroll_button)
	await press(JOY_BUTTON_A)
	assert(arena.shop_panel.reroll_count == 1)
	await check_reachability()
	await route_to(arena.shop_panel.weapon_container.get_child(0))
	await press(JOY_BUTTON_A)
	await route_to(find_button(arena.shop_panel, "SellWeaponButton"))
	var before_count = global.equipped_weapons.size()
	await press(JOY_BUTTON_A)
	assert(global.equipped_weapons.size() == before_count - 1)
	await route_to(find_button(arena.shop_panel, "NewWaveButton"))
	await press(JOY_BUTTON_A)
	assert(arena.wave_active and not global.game_paused)
	player.health_component.take_damage(100000)
	await frames()
	assert(arena.final_screen.visible)
	await check_reachability()
	await press(JOY_BUTTON_A)
	assert(arena.selection_panel.visible and not arena.final_screen.visible)
	await create_timer(6.5).timeout
	arena.queue_free()
	await frames()
	print("PASS: real gamepad buttons navigate/confirm/back, all enabled controls reachable in every menu, options sliders/save/load, character/weapon focus previews, stick/D-pad movement, dash/pause, upgrades, shop tooltip/buy/refill/reroll/combine/sell/new wave and final retry")
	quit()
