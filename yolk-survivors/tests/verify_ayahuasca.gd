extends "res://tests/verify_status_system.gd"

func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var global = root.get_node("Global")
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	var player = global.get_selected_player()
	arena.add_child(player)
	player.set_process(false)
	await process_frame
	arena.start_panel.hide()
	var shop = arena.shop_panel
	var service = load("res://resources/items/ayahuasca.gd")
	var item = load("res://resources/items/passives/catalogue/item_098.tres")
	for index in 4: assert(service.roll_outcome(index * 0.25) == index)
	arena.spawner.wave_index = 5
	shop.load_shop(5)
	shop.reroll_count = 3
	var locked = shop.items_container.get_child(0)
	locked.set_locked(true)
	var locked_item = locked.shop_item
	var frozen_price = locked.get_effective_price()
	global.coins = 10000
	global.yolk_reserve = 17
	arena.run_experience.experience = 7
	shop._on_item_purchased(load("res://resources/items/passives/catalogue/item_001.tres"))
	var inventory_count = shop.passive_container.get_child_count()
	var forced = item.duplicate()
	forced.ayahuasca_outcome_weights = PackedFloat32Array([100, 0, 0, 0])
	var price = forced.get_shop_price(shop.shop_wave)
	assert(shop.try_purchase_item(forced))
	assert(arena.spawner.wave_index == 4 and shop.next_stage_wave == 5)
	assert(shop.shop_wave == 5 and shop.reroll_count == 3)
	assert(locked.locked and locked.shop_item == locked_item and locked.get_effective_price() == frozen_price)
	assert(global.coins == 10000 - price and global.yolk_reserve == 17)
	assert(arena.run_experience.experience == 7 and shop.passive_container.get_child_count() == inventory_count)
	service.apply(player, item, 1)
	assert(arena.spawner.wave_index == 2 and shop.next_stage_wave == 3)
	arena.spawner.wave_index = 1
	service.apply(player, item, 1)
	assert(arena.spawner.wave_index == 0 and shop.next_stage_wave == 1)
	# Only positive primary stats are eligible, never secondary stats or negatives.
	player.stats.apply_stat_change("armor", -8)
	player.stats.apply_stat_change("melee_damage", -4)
	player.stats.apply_stat_change("effects", 70)
	var candidates = service.eligible_primaries(player)
	assert(not candidates.has("effects") and not candidates.has("armor") and not candidates.has("melee_damage"))
	var speed = player.stats.speed
	service.apply(player, item, 3, "speed")
	assert(is_equal_approx(player.stats.speed, speed * 0.5))
	player.stats.apply_stat_change("speed", 30)
	assert(is_equal_approx(player.stats.speed, speed * 0.5 + 30), "Future gains are not halved")
	player.stats.apply_stat_change("block_chance", 100)
	assert(player.stats.get_block_chance() == 70)
	service.apply(player, item, 3, "block_chance")
	assert(is_equal_approx(player.stats.get_block_chance(), 35), "Half the visible block chance, including its cap")
	player.stats.apply_stat_change("damage_percent", 40)
	player.stats.set_final_modifiers({"damage_percent": -20, "attack_speed": 100})
	var damage = player.stats.damage_percent
	service.apply(player, item, 3, "damage_percent")
	assert(is_equal_approx(player.stats.damage_percent, damage * 0.5))
	player.stats.apply_stat_change("attack_speed", -20)
	var attack_speed = player.stats.attack_speed
	assert(attack_speed > 0)
	service.apply(player, item, 3, "attack_speed")
	assert(is_equal_approx(player.stats.attack_speed, attack_speed * 0.5), "Nonlinear final attack-speed modifier")
	player.stats.set_final_modifiers({})
	# Real levels retain XP and emit each acquisition hook exactly once.
	shop._on_item_purchased(load("res://resources/items/passives/catalogue/item_074.tres"))
	var regen = player.stats.hp_regen
	var health = player.stats.health
	var level = arena.run_experience.level
	service.apply(player, item, 2)
	assert(arena.run_experience.level == level + 10 and arena.run_experience.experience == 7)
	assert(arena.run_experience.pending_levels.size() == 10)
	assert(is_equal_approx(player.stats.hp_regen, regen + 10))
	assert(is_equal_approx(player.stats.health, health + 10))
	assert(shop.pending_level_rewards == 10)
	arena.spawner.wave_index = 4
	global.game_paused = true
	shop.show()
	arena._on_shop_panel_on_shop_next_wave()
	assert(arena.upgrade_panel.visible and not shop.visible and global.game_paused)
	assert(arena.spawner.wave_index == 4)
	for index in 10:
		var chosen = null
		for card in arena.upgrade_panel.item_container.get_children():
			if card.item.stat_id not in ["health", "hp_regen"]:
				chosen = card
				break
		assert(chosen != null)
		chosen._on_custom_button_pressed()
	assert(arena.run_experience.pending_levels.is_empty() and not arena.upgrade_panel.visible)
	assert(arena.spawner.wave_index == 5 and arena.wave_active)
	assert(is_equal_approx(player.stats.hp_regen, regen + 10), "Choosing rewards does not grant levels again")
	assert(arena.run_experience.experience == 7 and global.yolk_reserve == 17)
	arena.spawner.wave_timer.stop()
	arena.spawner.spawn_timer.stop()
	var enemy = enemy_at(arena, Vector2(900,0))
	var before_xp = arena.run_experience.experience
	arena._on_enemy_died(enemy)
	assert(arena.run_experience.experience > before_xp, "Replayed waves still award XP")
	global.game_paused = false
	print("PASS Ayahuasca: equal odds, actual purchase, rewind/clamp/preserved shop and progress, primary-only exact halving with caps/final modifiers, ten actual levels/hooks/choices before next wave, replay XP")
	arena.queue_free()
	await process_frame
	quit()
