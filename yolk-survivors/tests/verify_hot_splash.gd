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
	var item = load("res://resources/items/passives/catalogue/item_045.tres")
	var block: float = player.stats.block_chance
	item.apply_passive_values()
	item.apply_passive_values()
	assert(is_equal_approx(player.passive_items.fire_spread_chance, 0.1))
	assert(player.stats.block_chance == block - 6.0)
	assert(player.passive_items.fire_spread_radius == 80.0)
	player.passive_items.fire_spread_chance = 1.0
	player.stats.effects = 10
	var a = enemy_at(arena, Vector2(0, 0))
	var b = enemy_at(arena, Vector2(70, 0))
	var c = enemy_at(arena, Vector2(140, 0))
	var far = enemy_at(arena, Vector2(230, 0))
	var template = load("res://scenes/components/hitbox_component.tscn").instantiate()
	arena.add_child(template)
	template.setup(1, false, 0, player)
	var record := {"instance_id":50, "wave_damage":0.0, "total_damage":0.0}
	template.weapon_damage_record = record
	var effect = load("res://resources/status_effect.gd").new()
	var status = load("res://effects/status_controller.gd")
	status.apply_effect(a, effect, template)
	assert(a.has_status_named("Burning") and b.has_status_named("Burning") and c.has_status_named("Burning"))
	assert(not far.has_status_named("Burning"), "Each hop must respect 80 world units")
	var fire_script = load("res://effects/fire_status.gd")
	for target in [a, b, c]:
		var burns = target.get_children().filter(func(child): return child.get_script() == fire_script)
		assert(burns.size() == 1, "Chains cannot revisit an already burning enemy")
		burns[0].set_process(false)
		burns[0]._process(0.5)
	assert(is_equal_approx(record.total_damage, 7.5), "Chained fire stays attributed to the initiating weapon")
	var isolated = enemy_at(arena, Vector2(1000, 0))
	status.apply_effect(isolated, effect, template)
	var late = enemy_at(arena, Vector2(1070, 0))
	status.apply_effect(isolated, effect, template)
	var burns = isolated.get_children().filter(func(child): return child.get_script() == fire_script)
	burns[0].set_process(false)
	burns[0]._process(0.5)
	assert(not late.has_status_named("Burning"), "No new roll on refresh, tick, or a neighbor arriving later")
	isolated.status_controller.clear()
	status.apply_effect(isolated, effect, template)
	assert(late.has_status_named("Burning"), "A new Burning episode can propagate again")
	global.player = null
	arena.queue_free()
	await process_frame
	await process_frame
	print("PASS hot splash: entry-only chaining, radius, no loops, no tick/refresh checks and weapon attribution")
	quit()
