extends SceneTree
var failures := 0
var arena
func _initialize(): call_deferred("verify")
func check(value: bool, message: String):
	if not value:
		failures += 1
		push_error(message)
func enemy_at(point):
	var enemy = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	enemy.stats = enemy.stats.duplicate()
	enemy.stats.block_chance = 0
	arena.add_child(enemy)
	enemy.global_position = point
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.health_component.max_health = 10000
	enemy.health_component.current_health = 10000
	return enemy
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var global = root.get_node("Global")
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = load("res://resources/items/weapons/range/knifer/item_knifer_1.tres")
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	arena.spawner.wave_timer.stop()
	var player = global.player
	player.set_process(false)
	player.set_physics_process(false)
	for equipped in player.current_weapons: equipped.set_process(false)
	var item = load("res://resources/items/weapons/spicy/item_carolina_reaper.tres").duplicate()
	item.stats = item.stats.duplicate(true)
	item.stats.crit_chance = 0
	var weapon = item.scene.instantiate()
	player.add_child(weapon)
	weapon.setup_weapon(item)
	weapon.set_process(false)
	var column = load("res://effects/spicy_pattern_effect.gd").new()
	column.configure(weapon, item.stats.spicy_pattern, Vector2(0, 200))
	arena.add_child(column)
	column.set_process(false)
	column.velocity = Vector2.ZERO
	var scheduler = root.get_node("FireContacts")
	var ground = root.get_node("GroundFire")
	var target = enemy_at(column.global_position)
	scheduler.rebuild()
	column._process(0.01)
	check(target.health_component.current_health < 10000, "Native column hits ground footprint")
	var hp: float = target.health_component.current_health
	for i in 5:
		scheduler.rebuild()
		column._process(0.01)
	check(target.health_component.current_health == hp, "Cooldown skips repeated native contact damage")
	var crossing = enemy_at(column.global_position + Vector2(column.radius * 3, 0))
	scheduler.rebuild()
	column._process(0.01)
	crossing.global_position.x -= column.radius * 6
	scheduler.rebuild()
	column._process(0.01)
	check(crossing.health_component.current_health < 10000, "Shared previous hurtbox sample catches fast crossing")
	var moving = enemy_at(column.global_position + Vector2(column.radius * 3, 0))
	scheduler.rebuild()
	var previous: Vector2 = column.global_position
	column.global_position.x += column.radius * 6
	column._update_column_contacts(previous)
	check(moving.health_component.current_health < 10000, "Moving column sweeps static target")
	# Production trail tokens, spatial field, shader data and expiration.
	var spacing: float = column.settings.column_trail_spacing * global.GAME_ENTITY_SCALE
	var begin := Vector2(1400, 400)
	column.global_position = begin + Vector2(spacing * 3.1, 0)
	column._leave_column_trail(begin, weapon)
	check(ground.patches.size() == 3, "Exactly three sparse patches from the production trail path")
	var patch = ground.patches[0]
	var edge = enemy_at(patch.point + Vector2(patch.radius * 0.8, 0))
	scheduler.rebuild()
	ground._process(0.01)
	check(edge.health_component.current_health < 10000, "Widened native field damages near outer edge")
	check(ground.floor_batch.multimesh.visible_instance_count == 3, "All patches actually rendered")
	var before = ground.floor_batch.multimesh.buffer
	ground._update_visuals()
	check(before == ground.floor_batch.multimesh.buffer, "Static patch buffers remain unchanged")
	check(ground.burned_batch.multimesh.visible_instance_count > 0, "Burned units rendered with shared clusters")
	check(ground.burned_batch.material.shader.resource_path.ends_with("burning_cluster.gdshader"), "Native cluster shader is active")
	global.game_paused = true
	var life: float = scheduler.clock
	scheduler._advance(5.0)
	check(scheduler.clock == life, "Paused scheduler preserves lifetime")
	global.game_paused = false
	scheduler.clock += 10.0
	ground._process(0.01)
	check(ground.patches.is_empty() and ground.floor_batch.multimesh.visible_instance_count == 0, "Expired patches remove contacts and presentation")
	arena.queue_free()
	await process_frame
	check(ground.owner_packets.is_empty(), "Freed weapons release shared logical hitboxes")
	print("NATIVE FIRE CONTACTS: ", "PASS" if failures == 0 else "FAIL (%s)" % failures)
	quit(0 if failures == 0 else 1)
