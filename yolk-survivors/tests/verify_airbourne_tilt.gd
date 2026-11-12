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
	var hit = load("res://scenes/components/hitbox_component.tscn").instantiate()
	arena.add_child(hit)
	hit.setup(10, false, 0, player)
	hit.launch_speed = 600
	hit.launch_duration = 1
	hit.launch_direction = Vector2.RIGHT
	var collision = enemy.get_node("HurtboxComponent/CollisionShape2D")
	var shape_rotation = collision.global_rotation
	var shadow = enemy.get_node("Visuals/Shadow")
	var shadow_rotation = shadow.global_rotation
	enemy.launch_from(hit)
	enemy._update_airbourne_tilt(0.04)
	assert(enemy.visuals.rotation_degrees > 0 and enemy.visuals.rotation_degrees < 35)
	enemy._update_airbourne_tilt(0.04)
	assert(is_equal_approx(enemy.visuals.rotation_degrees, 35))
	assert(is_zero_approx(sin(shadow.global_rotation - shadow_rotation)))
	assert(is_equal_approx(collision.global_rotation, shape_rotation) and enemy.rotation == 0)
	# Facing flips do not reverse the horizontal launch direction's lean.
	enemy.visuals.scale.x *= -1
	enemy._update_airbourne_tilt(0.08)
	assert(is_equal_approx(enemy.visuals.rotation_degrees, 35))
	hit.launch_direction = Vector2.LEFT
	enemy.launch_from(hit)
	enemy._update_airbourne_tilt(0.16)
	assert(is_equal_approx(enemy.visuals.rotation_degrees, -35))
	assert(is_zero_approx(sin(shadow.global_rotation - shadow_rotation)))
	# Relaying an Airbourne state retains the tilt; ending it restores rest.
	enemy.launch_left = 0
	enemy._update_airbourne_tilt(0.08)
	assert(is_zero_approx(enemy.visuals.rotation))
	hit.launch_direction = Vector2.UP
	enemy.launch_from(hit)
	enemy._update_airbourne_tilt(0.08)
	assert(is_zero_approx(enemy.visuals.rotation))
	hit.launch_direction = Vector2.RIGHT
	enemy.launch_from(hit)
	global.game_paused = true
	enemy._process(0.08)
	assert(is_zero_approx(enemy.visuals.rotation))
	print("PASS Airbourne tilt: animated +/-35 degrees by launch X, facing independent, landing/vertical recovery, untouched collisions and pause")
	arena.queue_free()
	await process_frame
	quit()
