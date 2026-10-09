extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	load("res://tests/progression_fixture.gd").prepare(root)
	var global = root.get_node("Global")
	var stats_script = load("res://resources/unit_stats.gd")
	var passive_script = load("res://resources/character_passives/character_passive.gd")
	var upgrade_script = load("res://resources/items/upgrades/item_upgrades.gd")
	var speed_bonus = passive_script.new()
	speed_bonus.effect = 1
	speed_bonus.target_stat = "speed"
	var conversion = passive_script.new()
	conversion.source_stat = "speed"
	conversion.target_stat = "melee_damage"
	conversion.source_amount = 1.0
	conversion.bonus_amount = 2.0
	var melee_bonus = passive_script.new()
	melee_bonus.effect = 1
	melee_bonus.target_stat = "melee_damage"
	var stats = stats_script.new()
	stats.speed = 10.0
	stats.character_passives.assign([speed_bonus, conversion, melee_bonus])
	stats.initialize_character_passives()
	assert(stats.speed == 10.0 and stats.melee_damage == 25.0, "Initial bases stay unchanged; conversion benefits from target gain bonus")
	stats.apply_stat_change("speed", 100.0)
	assert(stats.speed == 135.0 and stats.melee_damage == 337.5, "+100 becomes +125, then conversion recalculates")
	stats.apply_stat_change("melee_damage", 100.0)
	assert(stats.melee_damage == 462.5)
	stats.apply_stat_change("speed", -100.0)
	assert(stats.speed == 35.0 and stats.melee_damage == 212.5, "Penalties are not amplified; derived bonuses decrease")
	for index in 100:
		stats.apply_stat_change("luck", 0.0)
		stats.initialize_character_passives()
	assert(stats.melee_damage == 212.5, "No recursive or cumulative bonuses")
	var preview = stats.get_passive_preview()
	assert(preview.melee_damage == stats.melee_damage)
	preview.apply_stat_change("speed", 4.0)
	assert(preview.speed == 40.0 and stats.speed == 35.0, "Preview is isolated")
	var cycle = passive_script.new()
	cycle.source_stat = "melee_damage"
	cycle.target_stat = "speed"
	var cyclic_stats = stats_script.new()
	cyclic_stats.speed = 10.0
	cyclic_stats.character_passives.assign([conversion, cycle])
	cyclic_stats.initialize_character_passives()
	assert(cyclic_stats.speed == 10.0 and cyclic_stats.melee_damage == 20.0)
	var reversed_stats = stats_script.new()
	reversed_stats.speed = 10.0
	reversed_stats.character_passives.assign([cycle, conversion])
	reversed_stats.initialize_character_passives()
	assert(reversed_stats.speed == cyclic_stats.speed and reversed_stats.melee_damage == cyclic_stats.melee_damage, "Definition order does not change results")
	var invalid = passive_script.new()
	invalid.source_amount = 0.0
	stats.character_passives.append(invalid)
	stats.apply_stat_change("luck", 0.0)
	assert(is_finite(stats.melee_damage))
	var plain = stats_script.new()
	plain.apply_stat_change("speed", 100)
	assert(plain.speed == 400.0, "Characters without passives keep normal behavior")

	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	var characters = arena.selection_panel
	var weapons = arena.weapon_selection_panel
	var names: Array = []
	for base in characters.player_list:
		assert(not base.character_passives.is_empty())
		var signature := ""
		for passive in base.character_passives:
			assert(passive.is_valid())
			signature += passive.get_description()
		assert(not names.has(signature), "Each test character has a distinct configuration")
		names.append(signature)
		global.main_player_selected = base
		global.main_weapon_selected = weapons.weapons_list.filter(func(w): return base.can_use_weapon(w))[0]
		arena._on_level_selected(0)
		var player = global.player
		player.set_process(false)
		arena.spawner.wave_timer.stop()
		arena.spawner.spawn_timer.stop()
		global.game_paused = true
		var expected = base.get_passive_preview()
		for key in passive_script.STAT_LABELS:
			assert(is_equal_approx(player.stats.get(key), expected.get(key)))
		for weapon in global.equipped_weapons:
			assert(base.can_use_weapon(weapon))
		global.coins = 100000
		for wave in range(1, 11):
			for draw in 10:
				for offered in arena.shop_panel.select_shop_offers(wave):
					if offered.has_method("get_effective_damage"): assert(base.can_use_weapon(offered), "Forbidden weapon offered")
		for weapon in weapons.weapons_list:
			if base.can_use_weapon(weapon): continue
			var before_coins = global.coins
			var before_count = player.current_weapons.size()
			assert(not arena.shop_panel.try_purchase_item(weapon))
			player.add_weapon(weapon)
			assert(player.current_weapons.size() == before_count and global.coins == before_coins)
		# Use both real stat acquisition paths, with a gain bonus and a conversion.
		if base.name == "Well Rounded":
			var upgrade = upgrade_script.new()
			upgrade.stat_id = "damage_percent"
			upgrade.value = 100.0
			upgrade.apply_upgrade()
			assert(player.stats.damage_percent == 125.0)
			var item = load("res://resources/items/passives/item_passive.gd").new()
			item.add_stats_id = "damage_percent"
			item.add_value = 100.0
			item.remove_stats_id = "speed"
			item.remove_value = 10.0
			item.apply_passive_values()
			assert(player.stats.damage_percent == 250.0 and player.stats.speed == 290.0)
		if base.name == "Tiny Egg":
			var before = player.stats.ranged_damage
			player.stats.apply_stat_change("speed", 50.0)
			assert(is_equal_approx(player.stats.ranged_damage, before + 1.0))
			var ranged = global.equipped_weapons[0]
			assert(ranged.get_effective_damage(player.stats) > ranged.get_effective_damage(base))
		arena._on_pause_panel_on_exit_pressed()
		await process_frame
		global.main_player_selected = base
		var fresh = global.get_selected_player()
		for key in passive_script.STAT_LABELS:
			assert(is_equal_approx(fresh.stats.get(key), expected.get(key)), "New run retained a gain")
		fresh.free()
		global.player = null
		assert(base.speed == expected._base_stat_values["speed"], "Permanent resource changed")
	# Returning to another character clears an incompatible previously selected weapon.
	global.main_weapon_selected = weapons.weapons_list[0]
	characters._on_player_selected(characters.player_list[1])
	assert(global.main_weapon_selected == null)
	weapons.show()
	await process_frame
	assert(not weapons.weapons_container.get_child(0).toggle_mode)
	assert(global.main_weapon_selected == null)
	await create_timer(6.5).timeout
	arena.queue_free()
	await process_frame
	print("PASS: three passive types, combined conversions/gain bonuses, fractions/penalties/idempotence/cycles, immutable previews, 10 unique configurations, initial equipment, real upgrades/items, forbidden offers/purchases/equipment, selection and fresh runs")
	quit()
