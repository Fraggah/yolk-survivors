extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func frames(count: int = 3) -> void:
	for index in count: await process_frame

func verify() -> void:
	var progress = load("res://tests/progression_fixture.gd").prepare(root, false)
	var global = root.get_node("Global")
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	await frames()
	var selection = arena.selection_panel
	var weapons = arena.weapon_selection_panel
	assert(progress.unlocked_characters == ["well_rounded"])
	assert(progress.unlocked_weapons.size() == 4)
	arena._on_start_panel_on_play_pressed()
	await frames()
	assert(selection.players_container.columns == 5)
	for index in selection.player_list.size():
		var card = selection.players_container.get_child(index)
		assert(card.locked == (index != 0), "%s: id=%s locked=%s unlocked=%s" % [selection.player_list[index].name, selection.player_list[index].unlock_id, card.locked, progress.unlocked_characters])
		assert((card.portrait.material != null) == card.locked)
		assert(card.material == null, "Shader must not recolor the slot or focus")
		assert(selection.get_global_rect().encloses(card.get_global_rect()))
		assert(card.portrait.texture == selection.player_list[index].icon)
	var vampire = selection.player_list[4]
	var locked_card = selection.players_container.get_child(4)
	locked_card.grab_focus()
	assert(selection.player_description.text.contains("20% Life Steal"))
	assert(selection.player_description.text.contains("0 / 20"))
	assert(selection.player_icon.material != null)
	assert(not selection.player_description.text.contains("PASSIVES"))
	locked_card.pressed.emit()
	assert(global.main_player_selected == null and selection.visible)
	global.main_player_selected = vampire
	global.main_weapon_selected = weapons.weapons_list[5]
	assert(global.get_starting_weapons().is_empty())
	assert(global.get_selected_player() == null, "Starting directly cannot bypass character lock")
	global.main_player_selected = null
	global.main_weapon_selected = null
	selection.players_container.get_child(0).pressed.emit()
	await frames()
	assert(weapons.visible)
	var locked_weapon = weapons.weapons_container.get_child(1) # Blender
	locked_weapon.grab_focus()
	assert(weapons.weapon_description.text.contains("Win a run with Scrapper"))
	assert(weapons.weapon_icon.material != null and not locked_weapon.disabled)
	locked_weapon.pressed.emit()
	assert(global.main_weapon_selected == null)
	weapons.weapons_container.get_child(0).pressed.emit()
	arena._on_level_selected(0)
	await frames()
	var player = global.player
	player.set_process(false)
	arena.spawner.spawn_timer.stop()
	assert(progress.run_active)
	global.coins = 10000
	var before_coins = global.coins
	var before_count = player.current_weapons.size()
	assert(not arena.shop_panel.try_purchase_item(weapons.weapons_list[1]))
	player.add_weapon(weapons.weapons_list[1])
	assert(player.current_weapons.size() == before_count and global.coins == before_coins)
	for wave in range(1, 11):
		for draw in 20:
			for item in arena.shop_panel.select_shop_offers(wave):
				if item.has_method("get_effective_damage"): assert(progress.is_weapon_unlocked(item))
	arena.shop_panel.load_shop(1)
	for draw in 5: assert(arena.shop_panel.try_reroll())
	for card in arena.shop_panel.items_container.get_children():
		if card.shop_item.has_method("get_effective_damage"): assert(progress.is_weapon_unlocked(card.shop_item))
	# A repaired hit still disqualifies the wave, regardless of the final HP.
	player.health_component.take_damage(1.0)
	player.health_component.heal(1.0)
	arena.spawner.wave_timer.stop()
	arena._on_spawner_on_wave_completed()
	await create_timer(1.15).timeout
	assert(not progress.unlocked_characters.has("glass_egg"))
	arena._on_upgrade_selected()
	arena._on_shop_panel_on_shop_next_wave()
	arena.spawner.spawn_timer.stop()
	arena.spawner.wave_timer.stop()
	arena._on_spawner_on_wave_completed()
	await create_timer(1.15).timeout
	assert(progress.unlocked_characters.has("glass_egg"))
	var flawless = progress.counters["flawless_waves"]
	progress.finish_wave()
	assert(progress.counters["flawless_waves"] == flawless, "Duplicate completion must not count twice")
	arena._on_upgrade_selected()
	arena._on_shop_panel_on_shop_next_wave()
	arena.spawner.spawn_timer.stop()
	# Single-run thresholds use effective stats and update through actual upgrades.
	for change in [["speed", 50.0], ["health", 20.0], ["life_steal", 20.0], ["luck", 20.0], ["melee_damage", 15.0]]:
		var upgrade = load("res://resources/items/upgrades/item_upgrades.gd").new()
		upgrade.stat_id = change[0]
		upgrade.value = change[1]
		upgrade.apply_upgrade()
	for id in ["tiny_egg", "hardboiled", "vampire", "gambler", "berserker"]:
		assert(progress.unlocked_characters.has(id))
	assert(progress.is_weapon_unlocked(weapons.weapons_list[5]), "Vampire must unlock Bloody simultaneously")
	progress.record("kills", 249.0)
	var enemy = load("res://scenes/units/enemies/enemy_chaser.tscn").instantiate()
	enemy.stats = enemy.stats.duplicate()
	arena.add_child(enemy)
	enemy.position = Vector2(900, 300)
	enemy.health_component.take_damage(100000)
	assert(progress.unlocked_characters.has("mutant"), "Real enemy death must count")
	progress.record("yolks", 299.0)
	global.yolk_reserve = 5
	var coin = load("res://scenes/coins/coins.tscn").instantiate()
	arena.add_child(coin)
	before_coins = global.coins
	coin.add_coins()
	assert(global.coins == before_coins + 2)
	assert(progress.counters["yolks"] == 300.0, "x2 pays twice but counts only the real base yolk")
	assert(progress.unlocked_characters.has("hoarder"))
	var counter = progress.counters["yolks"]
	global.get_harvesting_coins()
	assert(progress.counters["yolks"] == counter)
	var banked = load("res://scenes/coins/coins.tscn").instantiate()
	arena.add_child(banked)
	banked.fly_to_jar(arena.coins_bag.jar_icon)
	banked.add_coins()
	assert(progress.counters["yolks"] == counter, "Jar flights are not pickups")
	# Three actual merges, then an automatic full-slot merge, all count once.
	var spatula = weapons.weapons_list[0]
	for iteration in 2:
		arena.shop_panel._on_item_purchased(spatula)
		if iteration == 1: arena.shop_panel._on_item_purchased(spatula)
		await frames()
		var card = arena.shop_panel.weapon_container.get_children().filter(func(c): return c.item == spatula)[0]
		arena.shop_panel._on_item_card_selected(card)
		arena.shop_panel._on_combine_button_pressed()
		await frames()
	var tier_two = arena.shop_panel.weapon_container.get_child(0)
	arena.shop_panel._on_item_card_selected(tier_two)
	arena.shop_panel._on_combine_button_pressed()
	await frames()
	assert(progress.counters["combines"] == 3.0 and progress.unlocked_characters.has("scrapper"))
	for index in 5: arena.shop_panel._on_item_purchased(spatula)
	await frames()
	assert(global.equipped_weapons.size() == 6)
	assert(arena.shop_panel.try_purchase_item(spatula))
	assert(progress.counters["combines"] == 4.0 and global.equipped_weapons.size() == 6)
	assert(progress.unlocked_characters.size() == 10)
	arena._on_pause_panel_on_exit_pressed()
	await frames()
	var kills = progress.counters["kills"]
	progress.record("kills", 100)
	assert(progress.counters["kills"] == kills, "Events outside a run cannot grant progress")
	# Real wave-10 victory path awards each configured weapon family and all its tiers.
	for pair in [["Hardboiled", "wood_mace"], ["Scrapper", "blender"], ["Berserker", "mitten"], ["Mutant", "corpse_l"], ["Gambler", "smasher"]]:
		global.main_player_selected = selection.player_list.filter(func(s): return s.name == pair[0])[0]
		global.main_weapon_selected = spatula
		arena._on_level_selected(0)
		arena.spawner.wave_index = 10
		arena.spawner.wave_timer.stop()
		arena.spawner.spawn_timer.stop()
		arena._on_spawner_on_wave_completed()
		await create_timer(1.15).timeout
		assert(progress.unlocked_weapons.has(pair[1]))
		assert(not progress.run_active)
		arena._on_final_button_pressed()
		selection.hide()
		await frames()
	assert(progress.unlocked_weapons.size() == 10)
	var original_completed = progress.completed.duplicate()
	assert(progress.save_progress())
	var restored = load("res://autoload/progression.gd").new()
	restored.save_path = progress.save_path
	root.add_child(restored)
	assert(restored.completed == original_completed)
	assert(restored.unlocked_characters.size() == 10 and restored.unlocked_weapons.size() == 10)
	assert(restored.counters == progress.counters)
	root.get_node("DataManager").load_game()
	assert(progress.completed == original_completed, "Old manual save cannot relock content")
	restored.queue_free()
	await create_timer(6.5).timeout
	arena.queue_free()
	await frames()
	print("PASS: fresh profile, 10 silhouettes/focus/requirements, locked start/equipment/purchase/offer/reroll guards, healed damage disqualifies flawless wave, real stats/kills/yolks/merges, no jar/bonus/harvesting duplication, Vampire + Bloody, 5 victory rewards, automatic persistence and old-save compatibility")
	quit()
