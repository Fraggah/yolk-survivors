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
	var launched = enemy_at(arena, Vector2(900, 0))
	var target = enemy_at(arena, Vector2(1000, 0))
	var hit = load("res://scenes/components/hitbox_component.tscn").instantiate()
	arena.add_child(hit)
	hit.setup(10, false, 0, player)
	hit.launch_damage = 4
	hit.launch_direction = Vector2.RIGHT
	var record := {"wave_damage":0.0, "total_damage":0.0}
	hit.weapon_damage_record = record
	launched.launch_from(hit)
	assert(launched.launch_hitbox.base_damage == 4)
	var item = load("res://resources/items/passives/catalogue/item_060.tres")
	for copies in range(1, 3):
		item.apply_passive_values()
		launched.launch_from(hit)
		var expected := 4.0 * (1.0 + copies * 0.25)
		assert(launched.launch_hitbox.base_damage == expected)
		assert(hit.base_damage == 10 and hit.launch_damage == 4)
		var before: float = target.health_component.current_health
		var accounted: float = record.total_damage
		target.receive_hit(launched.launch_hitbox)
		assert(is_equal_approx(before - target.health_component.current_health, expected))
		assert(is_equal_approx(record.total_damage - accounted, expected))
	var before: float = target.health_component.current_health
	target.receive_hit(hit)
	assert(is_equal_approx(before - target.health_component.current_health, 10), "Normal hits never gain Pancake damage")
	hit.launch_damage = 0
	launched.launch_from(hit)
	assert(launched.launch_hitbox.base_damage == 15, "Fallback launch damage is boosted once")
	global.player = null
	arena.queue_free()
	await process_frame
	await process_frame
	print("PASS Pancake: additive collision-only bonus, original weapon damage accounting and unchanged initial hit")
	quit()
