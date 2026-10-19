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
	global.game_paused = false
	var manager = player.passive_items
	var item = load("res://resources/items/passives/catalogue/item_099.tres")
	assert(item.ready_for_shop and item.max_copies == 1)
	item.apply_passive_values()
	assert(not item.available_for(player) and manager.count("unknown_mushroom") == 1)
	manager.begin_wave()
	var runtime = manager.mushroom_runtime
	runtime.set_process(false)
	player.health_component.max_health = 100
	player.health_component.current_health = 100
	player.stats.armor = 0
	var damage_before = player.stats.damage_percent
	var speed_before = player.stats.speed
	var attack_before = player.stats.attack_speed
	runtime.trigger(item, 1)
	assert(is_equal_approx(player.stats.damage_percent, damage_before + 100))
	runtime._age_buffs(3.99)
	assert(player.stats.damage_percent > damage_before)
	runtime._age_buffs(0.01)
	assert(is_equal_approx(player.stats.damage_percent, damage_before))
	runtime.trigger(item, 2)
	assert(is_equal_approx(player.stats.speed, speed_before * 1.5))
	runtime.trigger(item, 3)
	assert(is_equal_approx(player.stats.attack_speed, attack_before + 100))
	manager.finish_wave()
	assert(is_equal_approx(player.stats.speed, speed_before))
	assert(is_equal_approx(player.stats.attack_speed, attack_before))
	player.health_component.max_health = 100
	player.health_component.current_health = 100
	player.stats.armor = 0
	runtime.trigger(item, 4)
	assert(is_equal_approx(player.health_component.current_health, 50))
	player.health_component.current_health = 0.1
	runtime.trigger(item, 4)
	assert(is_equal_approx(player.health_component.current_health, 0.05))
	player.health_component.current_health = 50
	runtime.trigger(item, 7)
	assert(is_equal_approx(player.health_component.current_health, 60))
	runtime.trigger(item, 8)
	assert(is_equal_approx(player.health_component.current_health, 100))
	runtime.trigger(item, 6)
	assert(player.has_status(load("res://scenes/units/unit.gd").State.SHOKED))
	assert(is_equal_approx(player.health_component.current_health, 95))
	assert(not player.has_status(load("res://scenes/units/unit.gd").State.SLOW))
	runtime.trigger(item, 5)
	assert(player.has_status(load("res://scenes/units/unit.gd").State.BURNING))
	var burn = null
	for child in player.get_children():
		if child.get_script() == load("res://effects/fire_status.gd"): burn = child
	assert(burn != null and is_equal_approx(burn.remaining, 4))
	assert(is_equal_approx(burn.hit.damage, 1) and is_equal_approx(burn.interval, 0.5))
	burn.set_process(false)
	burn._process(4.0)
	assert(is_equal_approx(player.health_component.current_health, 87))
	var near_enemy = enemy_at(arena, player.global_position + Vector2(10, 0))
	var far_enemy = enemy_at(arena, player.global_position + Vector2(3000, 0))
	player.stats.effects = 20
	runtime.trigger(item, 0)
	assert(is_equal_approx(near_enemy.health_component.current_health, 970))
	assert(is_equal_approx(far_enemy.health_component.current_health, 1000))
	# The scheduler excludes the wave's end, pauses outside combat and resets each wave.
	runtime.reset()
	player.health_component.debug_invulnerable = true
	runtime.advance(30, 30)
	assert(runtime.activation_count == 5)
	runtime.reset()
	arena.wave_active = true
	global.game_paused = true
	runtime._process(5)
	assert(runtime.activation_count == 0 and runtime.elapsed == 0)
	global.game_paused = false
	arena.wave_active = false
	runtime._process(5)
	assert(runtime.activation_count == 0 and runtime.elapsed == 0)
	var enhanced = load("res://resources/items/golden_enhancement.gd").improve(item, 1.0)
	assert(is_equal_approx(enhanced.mushroom_damage_bonus, 200))
	player.health_component.debug_invulnerable = false
	player.health_component.current_health = 50
	runtime.trigger(enhanced, 4)
	assert(is_equal_approx(player.health_component.current_health, 50))
	runtime.trigger(item, 1)
	manager.replace_owned(manager.find_owned_record(item), null)
	runtime.advance(0.01, 30)
	assert(runtime.buffs.is_empty() and is_equal_approx(player.stats.damage_percent, damage_before))
	assert(item.available_for(player))
	print("PASS Hongo desconocido: all nine outcomes, exact scaling, timed buffs, Burning/Shocked, pause/wave boundaries, unique ownership, gold and removal")
	arena.queue_free()
	await process_frame
	quit()
