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
	var item = load("res://resources/items/passives/catalogue/item_058.tres")
	item.apply_passive_values()
	assert(player.passive_items.controlled_damage_percent == 25)
	var target = enemy_at(arena, Vector2(900, 0))
	var hit = load("res://scenes/components/hitbox_component.tscn").instantiate()
	arena.add_child(hit)
	hit.setup(10, false, 0, player)
	var record := {"wave_damage":0.0, "total_damage":0.0}
	hit.weapon_damage_record = record
	for state in ["none", "slow", "root", "air", "all", "electric"]:
		target.status_controller.clear()
		target.launch_left = 0.0
		if state in ["slow", "all"]: target.status_controller.add_slow(0.5, 3)
		if state in ["root", "all"]: target.status_controller.add_slow(0.0, 3)
		if state in ["air", "all"]: target.launch_left = 3.0
		if state == "electric": target.status_controller.lightning_left = 3.0
		var before: float = target.health_component.current_health
		var accounted: float = record.total_damage
		assert(target.receive_hit(hit))
		var expected := 10.0 if state in ["none", "electric"] else 12.5
		assert(is_equal_approx(before - target.health_component.current_health, expected))
		assert(is_equal_approx(record.total_damage - accounted, expected))
		assert(hit.damage == 10.0, "Shared hitbox must not retain a target's bonus")
	item.apply_passive_values()
	assert(player.passive_items.controlled_damage_percent == 50)
	target.status_controller.clear()
	target.status_controller.add_slow(0.5, 3)
	var before: float = target.health_component.current_health
	target.receive_hit(hit)
	assert(is_equal_approx(before - target.health_component.current_health, 15.0))
	# Damage-over-time uses the same target condition and weapon accounting.
	hit.is_status_damage = true
	before = target.health_component.current_health
	target.receive_hit(hit)
	assert(is_equal_approx(before - target.health_component.current_health, 15.0))
	global.player = null
	arena.queue_free()
	await process_frame
	await process_frame
	print("PASS slow cooking: each control state, one bonus for overlaps, additive copies, status hits and weapon accounting")
	quit()
