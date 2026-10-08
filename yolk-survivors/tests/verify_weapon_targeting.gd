extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	var global = root.get_node("Global")
	global.game_paused = true
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	var player = global.get_selected_player()
	root.add_child(player)
	player.set_process(false)
	player.global_position = Vector2(1500, 700)
	var item = load("res://resources/items/weapons/range/hydrant/item_hydrant_1.tres")
	var weapon = item.scene.instantiate()
	player.add_child(weapon)
	weapon.setup_weapon(item)
	weapon.set_process(false)
	weapon.position = Vector2(-100, 0)
	var first = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	var second = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	root.add_child(first)
	root.add_child(second)
	first.set_process(false)
	second.set_process(false)
	first.global_position = player.global_position + Vector2(40, 0)
	second.global_position = player.global_position + Vector2(-80, 0)
	weapon._on_range_area_area_entered(first)
	weapon._on_range_area_area_entered(second)
	weapon._on_range_area_area_entered(first)
	assert(weapon.targets.size() == 2, "No duplicate candidates")
	assert(weapon.get_closest_target() == first, "Distance is measured from player, not local weapon slot")
	for slot in [Vector2(-100, 0), Vector2(100, 0), Vector2(0, -120)]:
		weapon.position = slot
		weapon.rotation = 1.2
		weapon._physics_process(0.0)
		assert(weapon.range_area.global_position.is_equal_approx(player.global_position), "Range stays centered on player in every slot")
		assert(weapon.get_closest_target() == first)
	var world_range: float = item.stats.max_range * absf(weapon.collision.global_scale.x)
	first.global_position = player.global_position + Vector2(world_range + 1.0, 0)
	assert(weapon.get_closest_target() == second, "Targets beyond player-centered range are excluded")
	first.global_position = player.global_position + Vector2(40, 0)
	global.game_paused = false
	weapon.is_attacking = true
	weapon._process(0.0)
	assert(weapon.closest_target == first)
	second.global_position = player.global_position + Vector2(20, 0)
	weapon._process(0.0)
	assert(weapon.closest_target == second, "Retarget during attack")
	first.global_position = player.global_position + Vector2(10, 0)
	weapon._process(0.0)
	assert(weapon.closest_target == first, "Retarget back to original enemy")
	first.health_component.current_health = 0.0
	assert(weapon.get_closest_target() == second, "Skip dead enemies")
	weapon._on_range_area_area_exited(second)
	assert(weapon.closest_target == null, "Do not retain an enemy outside range")
	assert(is_finite(weapon.get_rotation_to_target()), "Idle aim when all remaining candidates are dead")
	first.free()
	assert(weapon.get_closest_target() == null and weapon.targets.is_empty(), "Prune freed references")
	second.queue_free()
	global.game_paused = true
	global.player = null
	player.queue_free()
	await process_frame
	print("PASS: world-space player distance, A/B/A retargeting during attack, duplicate/dead/freed/out-of-range candidates and idle aim")
	quit()
