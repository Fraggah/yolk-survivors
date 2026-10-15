extends SceneTree
const IDS = ["tenderizer", "grater", "carving_fork", "ladle", "frying_pan", "pizza_cutter", "electric_knife", "immersion_blender", "blender"]
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var global = root.get_node("Global")
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = load("res://resources/items/weapons/melee/tenderizer/item_tenderizer_1.tres")
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	global.player.set_process(false)
	for equipped in global.player.current_weapons: equipped.set_process(false)
	for index in IDS.size():
		var id: String = IDS[index]
		var item = load("res://resources/items/weapons/melee/%s/item_%s_1.tres" % [id,id])
		assert(arena.weapon_selection_panel.weapons_list.has(item))
		assert(root.get_node("Progression").is_weapon_unlocked(item))
		var current = item
		for tier in 4:
			assert(current.item_tier == tier and arena.shop_panel.shop_items.has(current))
			assert(current.item_icon and current.stats.damage > 0)
			if tier < 3:
				assert(current.matches_for_upgrade(current))
				current = current.upgrade_to
			else: assert(current.upgrade_to == null)
		var weapon = item.scene.instantiate()
		global.player.add_child(weapon)
		weapon.setup_weapon(item)
		weapon.set_process(false)
		weapon.position = Vector2(180,0)
		weapon.rotation = 0
		var behavior = weapon.weapon_behaviour
		assert(behavior.style == index and behavior.lock_aim_during_attack)
		var enemy = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
		arena.add_child(enemy)
		enemy.set_process(false)
		enemy.can_move = false
		enemy.stats = enemy.stats.duplicate()
		enemy.stats.block_chance = 0
		enemy.health_component.current_health = 10000
		enemy.health_component.max_health = 10000
		var reach: float = [0.85,0.65,0.85,0.6,0.65,0.6,0.7,0.6,0.65][index]
		enemy.global_position = weapon.to_global(Vector2(item.stats.max_range * reach + 24,0))
		weapon.closest_target = enemy
		if index == 5:
			enemy.global_position = weapon.to_global(Vector2(weapon.atk_start_pos.x + item.stats.max_range * 0.8 * 0.6 + 14, 0))
		await physics_frame
		await physics_frame
		behavior.execute_attack()
		await create_timer(1.25).timeout
		assert(not weapon.is_attacking and not behavior.contact_active)
		assert(weapon.sprite_2d.position.is_equal_approx(weapon.atk_start_pos))
		assert(is_zero_approx(weapon.sprite_2d.rotation))
		var expected: int = [2,3,1,1,1,2,6,4,3][index]
		assert(behavior.pulse_count == expected)
		var dealt: float = 10000 - enemy.health_component.current_health
		print(id, " damage=", dealt, " pulses=", behavior.pulse_count)
		assert(dealt > 0, "Attack must damage through actual physics overlap: " + id)
		assert(is_equal_approx(dealt, weapon.damage_record.wave_damage))
		if expected > 1: assert(dealt >= item.stats.damage * 2, "Sustained overlap must receive repeated pulses: " + id)
		behavior.execute_attack()
		await create_timer(0.2).timeout
		global.game_paused = true
		var pulses: int = behavior.pulse_count
		await create_timer(0.15, true).timeout
		assert(behavior.pulse_count == pulses, "Menu pause freezes attack")
		behavior.reset_attack()
		assert(not behavior.contact_active and not weapon.is_attacking)
		global.game_paused = false
		weapon.queue_free()
		enemy.queue_free()
		await process_frame
	global.coins = 10000
	var grater = load("res://resources/items/weapons/melee/grater/item_grater_1.tres")
	assert(arena.shop_panel.try_purchase_item(grater))
	assert(arena.shop_panel.try_purchase_item(grater))
	var card = arena.shop_panel.weapon_container.get_child(1)
	arena.shop_panel._on_item_card_selected(card, false)
	assert(not arena.shop_panel.combine_button.disabled)
	arena.shop_panel._on_combine_button_pressed()
	await process_frame
	assert(global.equipped_weapons.has(grater.upgrade_to))
	var coins_before: int = global.coins
	arena.shop_panel._on_sell_weapon_button_pressed()
	assert(global.coins == coins_before + grater.upgrade_to.get_sell_price(arena.shop_panel.shop_wave))
	print("PASS eight new melee families plus reworked whisk, tiers, real attacks/multiple contacts, pause/reset, purchase/combine/sell")
	quit()
