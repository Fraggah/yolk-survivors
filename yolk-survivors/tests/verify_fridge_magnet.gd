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
	var target = enemy_at(arena, Vector2(0, 0))
	var near = enemy_at(arena, Vector2(100, 0))
	var far = enemy_at(arena, Vector2(220, 0))
	var hit = load("res://scenes/components/hitbox_component.tscn").instantiate()
	arena.add_child(hit)
	hit.setup(1, false, 0, player)
	var electric = load("res://resources/statuses/electricity_default.tres").duplicate()
	electric.chain_radius = 80
	var status = load("res://effects/status_controller.gd")
	status.apply_effect(target, electric, hit)
	assert(not target.has_status_named("Slow"), "Electricity alone does not slow")
	var magnet = load("res://resources/items/passives/catalogue/item_076.tres")
	magnet.apply_passive_values()
	status.apply_effect(target, electric, hit)
	assert(is_equal_approx(target.get_status_movement_multiplier(), 0.8))
	assert(target.has_status_named("Slow") and near.has_status_named("Slow"))
	assert(not far.has_status_named("Slow"))
	assert(target.status_controller.slows.size() == 1)
	target.status_controller._process(0.4)
	status.apply_effect(target, electric, hit)
	assert(target.status_controller.slows.size() == 1)
	assert(is_equal_approx(target.status_controller.slows[0].left, 1.0))
	magnet.apply_passive_values()
	status.apply_effect(target, electric, hit)
	assert(is_equal_approx(target.get_status_movement_multiplier(), 0.8))
	target.status_controller._process(1.01)
	assert(not target.has_status_named("Slow") and target.has_status_named("Shoked"), "Slow and electric visual have independent timers")
	player.stats.crowd_control = 50
	player.stats.effects = 100
	status.apply_effect(target, electric, hit)
	assert(is_equal_approx(target.get_status_movement_multiplier(), 0.7))
	assert(is_equal_approx(target.status_controller.slows[0].left, 1.5), "CC scales slow; Effects does not")
	hit.setup(1, false, 0, near)
	status.apply_effect(player, electric, hit)
	assert(not player.has_status_named("Slow"), "Player item does not grant slowing attacks to enemies")
	assert(magnet.electric_slow_strength == 0.2 and magnet.electric_slow_duration == 1.0)
	global.player = null
	arena.queue_free()
	await process_frame
	await process_frame
	print("PASS fridge magnet: optional electric Slow, chain targets, refresh without stacking, independent expiry and CC scaling")
	quit()
