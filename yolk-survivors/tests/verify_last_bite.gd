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
	var manager = player.passive_items
	var item = load("res://resources/items/passives/catalogue/item_100.tres")
	item.apply_passive_values()
	var health = player.health_component
	player.stats.apply_stat_change("knockback", 10)
	var base_push = player.stats.get_push_force(100)
	var base_cooldown = player.get_dash_cooldown()
	assert(not manager.last_bite_active and base_cooldown == 2.0)
	health.current_health = health.max_health * 0.25
	health.on_health_changed.emit(health.current_health, health.max_health)
	assert(not manager.last_bite_active)
	player.dash_cooldown_timer.start(1.5)
	health.current_health = health.max_health * 0.24
	health.on_health_changed.emit(health.current_health, health.max_health)
	assert(manager.last_bite_active)
	assert(is_equal_approx(player.stats.get_push_force(100), base_push * 1.5))
	assert(is_equal_approx(player.stats.knockback, 10))
	assert(is_equal_approx(player.get_dash_cooldown(), 1.0))
	assert(is_equal_approx(player.dash_cooldown_timer.time_left, 0.75))
	# Repeated health signals never compound either multiplier or timer adjustment.
	manager.refresh_last_bite()
	assert(is_equal_approx(player.dash_cooldown_timer.time_left, 0.75))
	health.heal(health.max_health * 0.01)
	assert(not manager.last_bite_active)
	assert(is_equal_approx(player.stats.get_push_force(100), base_push))
	assert(is_equal_approx(player.dash_cooldown_timer.time_left, 1.5))
	# Max-health changes and buying/removing a copy reevaluate the condition immediately.
	health.current_health = health.max_health * 0.2
	health.on_health_changed.emit(health.current_health, health.max_health)
	item.apply_passive_values()
	assert(is_equal_approx(player.stats.get_push_force(100), base_push * 2.0))
	assert(is_equal_approx(player.get_dash_cooldown(), 0.05))
	manager.replace_owned(manager.find_owned_record(item), null)
	assert(is_equal_approx(player.stats.get_push_force(100), base_push * 1.5))
	var improved = load("res://resources/items/golden_enhancement.gd").improve(item, 0.25)
	manager.replace_owned(manager.find_owned_record(item), improved)
	assert(is_equal_approx(player.stats.get_push_force(100), base_push * 1.625))
	assert(is_equal_approx(player.get_dash_cooldown(), 0.75))
	manager.replace_owned(manager.find_owned_record(improved), null)
	assert(not manager.last_bite_active and is_equal_approx(player.stats.get_push_force(100), base_push))
	assert(is_equal_approx(player.get_dash_cooldown(), base_cooldown))
	item.apply_passive_values()
	health.current_health = 0.0
	health.on_health_changed.emit(0.0, health.max_health)
	assert(not manager.last_bite_active)
	print("PASS Last bite: strict threshold, healing, flat push preserved, cooldown progress, repeat signals, copies, gold/removal, no activation on death")
	arena.queue_free()
	await process_frame
	quit()
