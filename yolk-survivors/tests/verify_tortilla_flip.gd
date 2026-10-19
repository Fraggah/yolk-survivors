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
	var enemy = enemy_at(arena, Vector2(900, 0))
	var target = enemy_at(arena, Vector2(1000, 0))
	enemy.knockback_resistance = 0.2
	var template = load("res://scenes/components/hitbox_component.tscn").instantiate()
	arena.add_child(template)
	template.setup(10, false, 0, player)
	template.launch_damage = 4
	template.launch_speed = 600
	template.launch_duration = 0.8
	template.launch_direction = Vector2.RIGHT
	var record = {"wave_damage":0.0, "total_damage":0.0}
	template.weapon_damage_record = record
	load("res://resources/items/passives/catalogue/item_060.tres").apply_passive_values()
	var item = load("res://resources/items/passives/catalogue/item_082.tres")
	enemy.launch_from(template)
	enemy.launch_left = 0
	assert(not enemy._try_tortilla_relaunch(0.0), "No item means no relaunch")
	item.apply_passive_values()
	assert(is_equal_approx(player.passive_items.get_tortilla_relaunch().chance, 0.1))
	enemy.launch_from(template)
	var collision_hit = enemy.launch_hitbox
	assert(is_equal_approx(enemy.launch_velocity.x, 480))
	assert(is_equal_approx(collision_hit.base_damage, 5), "Pancake applies once")
	assert(not enemy._try_tortilla_relaunch(0.0), "Do not roll before landing")
	enemy.launch_left = 0
	assert(not enemy._try_tortilla_relaunch(0.1), "10% chance boundary")
	var hurtbox = target.get_node("HurtboxComponent")
	assert(collision_hit.claim_hit(hurtbox) and not collision_hit.claim_hit(hurtbox))
	assert(enemy._try_tortilla_relaunch(0.099))
	assert(enemy.launch_hitbox == collision_hit and collision_hit.claim_hit(hurtbox))
	assert(is_equal_approx(enemy.launch_velocity.x, 360))
	assert(is_equal_approx(enemy.launch_left, 0.4))
	target.receive_hit(collision_hit)
	assert(is_equal_approx(record.total_damage, 5))
	enemy.launch_left = 0
	assert(enemy._try_tortilla_relaunch(0.0))
	assert(is_equal_approx(enemy.launch_velocity.x, 270))
	assert(is_equal_approx(enemy.launch_left, 0.2))
	target.receive_hit(collision_hit)
	assert(is_equal_approx(record.total_damage, 10) and collision_hit.base_damage == 5)
	enemy.launch_left = 0
	assert(not enemy._try_tortilla_relaunch(0.0), "Hard cap of two extra launches")
	enemy._move_launched(0.01)
	assert(enemy.launch_hitbox == null and enemy.launch_velocity == Vector2.ZERO)
	assert(not enemy.has_status_named("Airbourne"))
	item.apply_passive_values()
	assert(is_equal_approx(player.passive_items.get_tortilla_relaunch().chance, 0.2))
	var forced = item.duplicate()
	forced.proc_chance = 1.0
	forced.apply_passive_values()
	enemy.launch_from(template)
	assert(enemy._tortilla_relaunches == 0, "A new weapon launch starts a new chain")
	enemy._move_launched(0.8)
	assert(enemy._tortilla_relaunches == 1 and is_equal_approx(enemy.launch_left, 0.4))
	enemy._move_launched(0.4)
	assert(enemy._tortilla_relaunches == 2 and is_equal_approx(enemy.launch_left, 0.2))
	enemy._move_launched(0.2)
	assert(enemy.launch_left == 0 and enemy.launch_hitbox == null)
	# Exact-copy upgrades/removal use the same ownership ledger as other passives.
	var owned = player.passive_items.find_owned_record(item)
	var enhanced = load("res://resources/items/golden_enhancement.gd").improve(item, 0.25)
	assert(is_equal_approx(enhanced.proc_chance, 0.125))
	assert(is_equal_approx(enhanced.relaunch_speed_multiplier, 0.8125))
	assert(is_equal_approx(enhanced.relaunch_duration_multiplier, 0.625))
	assert(enhanced.relaunch_maximum == 2)
	player.passive_items.replace_owned(owned, enhanced)
	assert(is_equal_approx(player.passive_items.get_tortilla_relaunch().speed_multiplier, 0.8125))
	for entry in player.passive_items.owned_records.duplicate():
		if entry.item.effect_key == "tortilla_flip": player.passive_items.replace_owned(entry, null)
	assert(player.passive_items.get_tortilla_relaunch().chance == 0)
	print("PASS tortilla flip: 10% per landing, two relaunches, 75%/50% then 56.25%/25%, same damage/credit, collision reset, no repeated resistance/CC/Pancake, copy stacking, production landing, gold/removal")
	arena.queue_free()
	await process_frame
	quit()
