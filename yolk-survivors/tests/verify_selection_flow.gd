extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	var global = root.get_node("Global")
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	var characters = arena.selection_panel
	var weapons = arena.weapon_selection_panel
	arena._on_start_panel_on_play_pressed()
	assert(characters.visible and not weapons.visible)
	assert(characters.players_container.visible and not characters.weapons_container.visible)
	assert(characters.confirm_button.disabled)
	characters._on_custom_button_pressed()
	assert(characters.visible and not weapons.visible, "Cannot continue without character")
	var preview_card = characters.players_container.get_child(1)
	preview_card.mouse_entered.emit()
	assert(characters.player_name.text == "Tiny Egg" and characters.player_description.visible)
	assert(global.main_player_selected == null and characters.confirm_button.disabled, "Hover must not select a character")
	preview_card.mouse_exited.emit()
	assert(not characters.player_description.visible)
	characters.players_container.get_child(4).pressed.emit()
	var vampire = global.main_player_selected
	assert(vampire.name == "Vampire")
	preview_card.mouse_entered.emit()
	assert(characters.player_name.text == "Tiny Egg")
	assert(global.main_player_selected == vampire)
	assert(characters.players_container.get_child(4).button_pressed and not preview_card.button_pressed)
	preview_card.mouse_exited.emit()
	assert(characters.player_name.text == vampire.name and characters.player_description.visible)
	var text = characters.player_description.text
	assert(text.contains("-2"), "Health penalty must use real baseline 20")
	assert(text.contains("-5"), "Luck and block penalties must use real nonzero baseline")
	assert(text.contains("+10") and text.contains("+12%"))
	assert(not text.contains("Melee damage:") and not text.contains("Harvesting:"))
	assert(text.contains("Bloody"))
	characters.confirm_button.pressed.emit()
	assert(not characters.visible and weapons.visible and not arena.level_panel.visible)
	assert(not weapons.players_container.visible and weapons.weapons_container.visible)
	assert(weapons.confirm_button.disabled)
	assert(weapons.weapons_container.get_child_count() == 10)
	await process_frame
	for card in weapons.weapons_container.get_children():
		assert(weapons.get_global_rect().encloses(card.get_global_rect()), "Weapon card outside screen")
	assert(weapons.player_description.get_content_height() <= weapons.player_description.size.y, "Character and initial weapon description clipped")
	var back_button = weapons.get_node("MarginContainer/VBoxContainer/Label/CustomButtonExit")
	assert(is_equal_approx(back_button.global_position.y, weapons.confirm_button.global_position.y), "Back and Continue must stay aligned")
	weapons.weapons_container.get_child(0).pressed.emit()
	var selected = global.main_weapon_selected
	weapons._on_custom_button_exit_pressed()
	assert(characters.visible and not weapons.visible)
	assert(global.main_player_selected == vampire and global.main_weapon_selected == selected)
	characters.confirm_button.pressed.emit()
	assert(not weapons.confirm_button.disabled)
	weapons.confirm_button.pressed.emit()
	assert(arena.level_panel.visible and not weapons.visible)
	arena._on_level_panel_on_level_selection_exited()
	assert(weapons.visible and not arena.level_panel.visible)
	weapons.confirm_button.pressed.emit()
	arena._on_level_selected(0)
	assert(arena.in_arena and arena.wave_active)
	assert(global.player.current_weapons.size() == 2)
	assert(global.equipped_weapons.size() == 2)
	assert(arena.shop_panel.weapon_container.get_child_count() == 2)
	assert(global.player.current_weapons[0].data == vampire.starting_weapon)
	assert(global.player.current_weapons[1].data == selected)
	assert(global.player.current_weapons[0] != global.player.current_weapons[1])
	var current_player = global.player
	arena._on_level_selected(0)
	assert(global.player == current_player and global.equipped_weapons.size() == 2, "Repeated confirmation must not duplicate equipment")
	arena._on_pause_panel_on_exit_pressed()
	await process_frame
	assert(global.equipped_weapons.is_empty())
	assert(arena.shop_panel.weapon_container.get_child_count() == 0)
	for character in characters.player_list:
		global.main_player_selected = character
		global.main_weapon_selected = selected
		arena._on_level_selected(0)
		var count = 2 if character == vampire else 1
		assert(global.player.current_weapons.size() == count, character.name)
		assert(global.equipped_weapons.size() == count)
		assert(arena.shop_panel.weapon_container.get_child_count() == count)
		arena._on_pause_panel_on_exit_pressed()
		await process_frame
	# Selecting Bloody as well intentionally gives two copies, compatible with combining.
	global.main_player_selected = vampire
	global.main_weapon_selected = vampire.starting_weapon
	arena._on_level_selected(0)
	assert(global.player.current_weapons.size() == 2)
	assert(global.player.current_weapons[0].data == global.player.current_weapons[1].data)
	var card = arena.shop_panel.weapon_container.get_child(0)
	arena.shop_panel._on_item_card_selected(card)
	assert(not arena.shop_panel.combine_button.disabled)
	arena.shop_panel._on_combine_button_pressed()
	await process_frame
	assert(global.player.current_weapons.size() == 1)
	assert(global.equipped_weapons.size() == 1)
	assert(global.equipped_weapons[0] == vampire.starting_weapon.upgrade_to)
	arena._on_pause_panel_on_exit_pressed()
	await process_frame
	# Generic resource configuration works for another character without any name checks.
	var configured = characters.player_list[0].duplicate()
	configured.starting_weapon = vampire.starting_weapon
	global.main_player_selected = configured
	global.main_weapon_selected = selected
	assert(global.get_starting_weapons().size() == 2)
	configured.starting_weapon = load("res://resources/items/weapons/item_weapon.gd").new()
	assert(global.get_starting_weapons().size() == 1, "Ignore invalid optional equipment")
	global.main_weapon_selected = null
	assert(global.get_starting_weapons().is_empty())
	assert(characters.get_character_description(characters.base_player_stats) == "Balanced base stats.")
	assert(characters.base_player_stats.health == 20 and characters.base_player_stats.luck == 5 and characters.base_player_stats.block_chance == 5)
	assert(vampire.health == 18 and vampire.life_steal == 12)
	arena._on_final_button_pressed()
	assert(characters.visible and not weapons.visible and global.main_player_selected == null)
	await create_timer(6.5).timeout
	arena.queue_free()
	await process_frame
	print("PASS: character > weapon > difficulty navigation, Back preserves selections, base-stat differences, 10 starting loadouts, Vampire Bloody + chosen weapon, combine, configurable equipment, invalid references and duplicate-start guard")
	quit()
