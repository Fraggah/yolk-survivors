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
	var item = load("res://resources/items/passives/catalogue/item_063.tres")
	item.apply_passive_values()
	assert(player.passive_items.airbourne_explosion_damage_percent == 50)
	var carrier = enemy_at(arena, Vector2(-200, 0))
	var target = enemy_at(arena, Vector2(0, 0))
	var near = enemy_at(arena, Vector2(50, 0))
	var far = enemy_at(arena, Vector2(61, 0))
	var hit = load("res://scenes/components/hitbox_component.tscn").instantiate()
	arena.add_child(hit)
	hit.setup(10, false, 0, player)
	hit.launch_damage = 10
	hit.launch_direction = Vector2.RIGHT
	var record := {"wave_damage":0.0, "total_damage":0.0}
	hit.weapon_damage_record = record
	var blast_script = load("res://scenes/projectiles/ranged_area_effect.gd")
	for step in 3:
		if step == 1: load("res://resources/items/passives/catalogue/item_060.tres").apply_passive_values()
		if step == 2: item.apply_passive_values()
		carrier.launch_from(hit)
		var damage: float = carrier.launch_hitbox.base_damage
		var splash: float = damage * player.passive_items.airbourne_explosion_damage_percent / 100.0
		var before: float = target.health_component.current_health
		var near_before: float = near.health_component.current_health
		var accounted: float = record.total_damage
		target.get_node("HurtboxComponent")._on_area_entered(carrier.launch_hitbox)
		assert(is_equal_approx(before - target.health_component.current_health, damage + splash))
		assert(is_equal_approx(near_before - near.health_component.current_health, splash))
		assert(far.health_component.current_health == 1000)
		assert(is_equal_approx(record.total_damage - accounted, damage + 2 * splash))
		var blasts = arena.get_children().filter(func(child): return child.get_script() == blast_script)
		assert(blasts.size() == step + 1, "Only collision hitboxes create explosions")
		assert(is_equal_approx(blasts.back().radius, 60.0))
		assert(not blasts.back().hit.launch_on_hit)
		target.get_node("HurtboxComponent")._on_area_entered(carrier.launch_hitbox)
		assert(is_equal_approx(target.health_component.current_health, before - damage - splash), "Repeated contact cannot explode twice")
		assert(hit.damage == 10)
	global.player = null
	arena.queue_free()
	await process_frame
	await process_frame
	print("PASS fierce saute: collision explosion, radius, additive copies, Pancake synergy, no recursive/repeated blasts and weapon accounting")
	quit()
