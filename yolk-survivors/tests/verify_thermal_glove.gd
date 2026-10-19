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
	player.stats.apply_stat_change("hp_regen", 2)
	var glove = load("res://resources/items/passives/catalogue/item_073.tres")
	glove.apply_passive_values()
	assert(player.stats.hp_regen == 2)
	var hostile = enemy_at(arena, Vector2(900, 0))
	var hit = load("res://scenes/components/hitbox_component.tscn").instantiate()
	arena.add_child(hit)
	hit.setup(1, false, 0, hostile)
	var effect = load("res://resources/status_effect.gd").new()
	var fire = load("res://effects/fire_status.gd")
	fire.apply(player, "FirstFire", hit, effect)
	assert(player.stats.hp_regen == 3)
	fire.apply(player, "FirstFire", hit, effect)
	fire.apply(player, "SecondFire", hit, effect)
	assert(player.stats.hp_regen == 3, "Fire refreshes and multiple sources do not duplicate the item bonus")
	player.stats.apply_stat_change("hp_regen", 5)
	assert(player.stats.hp_regen == 8)
	glove.apply_passive_values()
	assert(player.stats.hp_regen == 9, "Each glove grants one stat point while burning")
	player.get_node("FirstFire").remaining = 0
	player.passive_items.refresh_burning_regen()
	assert(player.stats.hp_regen == 9, "Bonus remains while another burn is active")
	player.get_node("SecondFire").remaining = 0
	player.passive_items.refresh_burning_regen()
	assert(player.stats.hp_regen == 7, "Expiration removes only the temporary bonus, preserving permanent gains")
	fire.apply(player, "FirstFire", hit, effect)
	assert(player.stats.hp_regen == 9)
	player.health_component.current_health = 5
	player._update_regeneration(1.0)
	assert(is_equal_approx(player.health_component.current_health,5.9), "Boosted regen gives 0.1 HP/s per point, not a burst of the whole stat")
	player.status_controller.clear()
	assert(player.stats.hp_regen == 7, "Wave cleanup removes the bonus immediately")
	for repeat in 5:
		fire.apply(player, "FirstFire", hit, effect)
		assert(player.stats.hp_regen == 9)
		player.status_controller.clear()
		assert(player.stats.hp_regen == 7, "Repeated activation cannot accumulate or lose regen")
	global.player = null
	arena.queue_free()
	await process_frame
	await process_frame
	print("PASS thermal glove: visible regen stat, copies, refresh/multiple burns, expiry, cleanup and preserved permanent gains")
	quit()
