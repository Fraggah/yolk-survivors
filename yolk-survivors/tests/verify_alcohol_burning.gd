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
	var alcohol = load("res://resources/items/passives/catalogue/item_044.tres")
	var hp: float = player.stats.health
	alcohol.apply_passive_values()
	alcohol.apply_passive_values()
	assert(player.stats.health == hp - 6.0)
	assert(player.stats.attack_effects.size() == 1)
	assert(is_equal_approx(player.stats.attack_effects[0].chance, 0.04))
	assert(alcohol.on_hit_effects[0].chance == 0.02, "Catalogue resource stays immutable")
	for value in [-10.0, 0.0, 10.0]:
		player.stats.effects = value
		assert(is_equal_approx(player.stats.get_burning_damage(), maxf(0.1, value * 0.25)))
	player.stats.effects = 10
	player.stats.damage_percent = 100
	var effect = player.stats.attack_effects[0]
	var target = enemy_at(arena, Vector2(900, 0))
	var template = load("res://scenes/components/hitbox_component.tscn").instantiate()
	arena.add_child(template)
	template.setup(100, false, 0, player)
	var first := {"instance_id":101, "wave_damage":0.0, "total_damage":0.0}
	var second := {"instance_id":102, "wave_damage":0.0, "total_damage":0.0}
	template.weapon_damage_record = first
	var controller = load("res://effects/status_controller.gd")
	controller.apply_effect(target, effect, template)
	var fire_script = load("res://effects/fire_status.gd")
	var burns = target.get_children().filter(func(child): return child.get_script() == fire_script)
	assert(burns.size() == 1)
	var burn = burns[0]
	burn.set_process(false)
	assert(burn.interval == 0.5 and burn.hit.base_damage == 5.0, "Flat Effects scaling precedes the +100% general damage")
	burn._process(0.25)
	controller.apply_effect(target, effect, template)
	assert(burn.tick_left == 0.25, "Refresh must not postpone ticks")
	template.weapon_damage_record = second
	controller.apply_effect(target, effect, template)
	burns = target.get_children().filter(func(child): return child.get_script() == fire_script)
	assert(burns.size() == 2, "Separate weapons preserve separate attribution")
	for active in burns:
		active.set_process(false)
		active._process(0.5)
	assert(is_equal_approx(first.total_damage, 5.0) and is_equal_approx(second.total_damage, 5.0))
	assert(is_equal_approx(target.health_component.current_health, 990.0))
	player.stats.fire_tick_speed = 100
	assert(player.stats.get_fire_interval(9.0) == 0.25, "Every fire starts at the shared half-second interval")
	# Hostile fire uses its configured damage and the same base cadence.
	template.setup(1, false, 0, target)
	var hostile = effect.duplicate()
	hostile.damage = 7
	hostile.tick_interval = 2
	controller.apply_effect(player, hostile, template)
	var hostile_burns = player.get_children().filter(func(child): return child.get_script() == fire_script)
	assert(hostile_burns.size() == 1)
	assert(hostile_burns[0].hit.base_damage == 7 and hostile_burns[0].interval == 0.5)
	global.player = null
	arena.queue_free()
	await process_frame
	await process_frame
	print("PASS Alcohol: additive chance, health penalty, fire floor/scaling/cadence, refresh and per-weapon damage attribution")
	quit()
