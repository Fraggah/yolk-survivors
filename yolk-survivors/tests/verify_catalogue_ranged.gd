extends SceneTree

func _initialize(): call_deferred("verify")

func make_enemy(arena: Node, point: Vector2):
	var enemy = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	enemy.stats = enemy.stats.duplicate()
	enemy.stats.block_chance = 0.0
	arena.add_child(enemy)
	enemy.global_position = point
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.health_component.current_health = 10000.0
	enemy.health_component.max_health = 10000.0
	return enemy

func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var global = root.get_node("Global")
	var catalogue = load("res://resources/items/weapons/ranged_catalogue.gd")
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = load("res://resources/items/weapons/range/knifer/item_knifer_1.tres")
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	global.player.set_process(false)
	global.player.set_physics_process(false)
	for equipped in global.player.current_weapons: equipped.set_process(false)
	assert(arena.weapon_selection_panel.weapons_list.size() == 40)
	for item in catalogue.items():
		assert(arena.weapon_selection_panel.weapons_list.has(item))
		assert(root.get_node("Progression").is_weapon_unlocked(item))
		var tier_item = item
		for tier in 4:
			assert(tier_item.item_tier == tier and arena.shop_panel.shop_items.has(tier_item))
			assert(tier_item.item_icon and tier_item.stats.projectile_scene and tier_item.stats.ranged_settings)
			if tier < 3:
				assert(tier_item.matches_for_upgrade(tier_item))
				tier_item = tier_item.upgrade_to
			else: assert(tier_item.upgrade_to == null)
		var weapon = item.scene.instantiate()
		global.player.add_child(weapon)
		weapon.setup_weapon(item)
		weapon.set_process(false)
		weapon.rotation = 0.0
		weapon.weapon_behaviour.execute_attack()
		await create_timer(0.23).timeout
		var settings = item.stats.ranged_settings
		var shots = get_nodes_in_group("projectiles").filter(func(node): return node.has_method("setup_projectile"))
		assert(shots.size() == settings.projectile_count * settings.burst_count, item.item_name + " shot pattern")
		for projectile in shots:
			assert(projectile.hitbox.weapon_damage_record == weapon.damage_record)
		weapon.weapon_behaviour.reset_attack()
		for projectile in get_nodes_in_group("projectiles"): projectile.queue_free()
		await process_frame
		# Real physics contact; blast must respect the fuse and count damage once.
		var enemy = make_enemy(arena, weapon.weapon_behaviour.muzzle.global_position + Vector2(80, 0))
		weapon.weapon_behaviour.create_projectile()
		await create_timer(1.6).timeout
		assert(enemy.health_component.current_health < 10000.0, item.item_name + " must damage through physics/effects")
		assert(weapon.damage_record.wave_damage > 0.0)
		enemy.queue_free()
		for projectile in get_nodes_in_group("projectiles"): projectile.queue_free()
		weapon.queue_free()
		await process_frame
	# Direct blast checks: delayed, paused, oval area, once per target and recorded damage.
	var item = catalogue.items()[0]
	var settings = item.stats.ranged_settings
	var enemy = make_enemy(arena, Vector2(900, 500))
	var outside = make_enemy(arena, Vector2(900, 500 + settings.explosion_radius * 1.3))
	var projectile = item.stats.projectile_scene.instantiate()
	arena.add_child(projectile)
	projectile.position = enemy.position
	projectile.setup_projectile(Vector2.ZERO, 10.0, false, 0.0, global.player, 300)
	projectile.hitbox.weapon_damage_record = {"wave_damage":0.0,"total_damage":0.0}
	projectile.configure_effects(settings)
	await create_timer(0.15).timeout
	assert(enemy.health_component.current_health == 10000.0)
	global.game_paused = true
	var remaining: float = projectile.fuse_left
	await create_timer(0.2).timeout
	assert(is_equal_approx(projectile.fuse_left, remaining))
	global.game_paused = false
	await create_timer(0.8).timeout
	assert(enemy.health_component.current_health == 9990.0, "Blast must apply exactly once")
	assert(outside.health_component.current_health == 10000.0, "Oval must exclude points beyond its Y radius")
	enemy.queue_free()
	outside.queue_free()
	global.coins = 10000
	var plate = catalogue.items()[7]
	assert(arena.shop_panel.try_purchase_item(plate))
	assert(arena.shop_panel.try_purchase_item(plate))
	var card = arena.shop_panel.weapon_container.get_child(1)
	arena.shop_panel._on_item_card_selected(card, false)
	assert(not arena.shop_panel.combine_button.disabled)
	arena.shop_panel._on_combine_button_pressed()
	await process_frame
	assert(global.equipped_weapons.has(plate.upgrade_to))
	var coins_before: int = global.coins
	arena.shop_panel._on_sell_weapon_button_pressed()
	assert(global.coins > coins_before)
	await process_frame
	await process_frame
	print("PASS 10 ranged families, 40 tiers, selection/shop, actual attacks, patterns, timed blast/pause/oval/damage, combine/sell")
	quit()
