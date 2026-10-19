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
	var bath = load("res://resources/items/passives/catalogue/item_056.tres")
	global.coins = 10000
	assert(player.stats.get_fire_interval() == 0.5 and player.stats.get_fire_duration(3.0) == 3.0)
	for copies in range(1, 6):
		assert(arena.shop_panel.try_purchase_item(bath))
		assert(player.passive_items.count("oil_bath") == copies)
		assert(is_equal_approx(player.stats.get_fire_interval(), 0.5 - 0.05 * copies))
		assert(is_equal_approx(player.stats.get_fire_duration(3.0), 3.0 - 0.1 * copies))
	assert(not bath.available_for(player))
	assert(not arena.shop_panel._eligible_shop_items().has(bath))
	var money: int = global.coins
	assert(not arena.shop_panel.try_purchase_item(bath) and global.coins == money)
	bath.apply_passive_values()
	assert(player.passive_items.count("oil_bath") == 5)
	assert(is_equal_approx(player.stats.get_fire_interval(), 0.25))
	assert(is_equal_approx(player.stats.get_fire_duration(3.0), 2.5))
	assert(player.stats.get_fire_duration(0.2) == 0.0)
	var target = enemy_at(arena, Vector2(900, 0))
	var template = load("res://scenes/components/hitbox_component.tscn").instantiate()
	arena.add_child(template)
	template.setup(1, false, 0, player)
	var effect = load("res://resources/status_effect.gd").new()
	var controller = load("res://effects/status_controller.gd")
	controller.apply_effect(target, effect, template)
	var fire_script = load("res://effects/fire_status.gd")
	var burns = target.get_children().filter(func(child): return child.get_script() == fire_script)
	assert(burns.size() == 1)
	var burn = burns[0]
	burn.set_process(false)
	assert(is_equal_approx(burn.remaining, 2.5) and is_equal_approx(burn.interval, 0.25))
	for tick in 10: burn._process(0.25)
	assert(is_equal_approx(target.health_component.current_health, 999.0), "Ten ticks at minimum 0.1 damage")
	assert(burn.is_queued_for_deletion())
	player.stats.fire_tick_speed = 100
	assert(is_equal_approx(player.stats.get_fire_interval(), 0.125))
	player.stats.reset_player_stats()
	assert(player.stats.fire_interval_reduction == 0.0 and player.stats.fire_duration_reduction == 0.0)
	global.player = null
	arena.queue_free()
	await process_frame
	await process_frame
	print("PASS oil bath: flat reductions, 5-copy shop cap, rejected sixth purchase, ten ticks and percentage speed compatibility")
	quit()
