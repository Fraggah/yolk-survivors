extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var global = root.get_node("Global")
	global.game_paused = false
	var stage = Node2D.new()
	root.add_child(stage)
	current_scene = stage
	var source = Node2D.new()
	stage.add_child(source)
	var enemies = []
	for x in [100,200]:
		var enemy = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
		enemy.stats = enemy.stats.duplicate()
		enemy.stats.block_chance = 0
		stage.add_child(enemy)
		enemy.position = Vector2(x,0)
		enemy.can_move = false
		enemy.set_process(false)
		enemy.health_component.max_health = 1000
		enemy.health_component.current_health = 1000
		enemies.append(enemy)
	await physics_frame
	await physics_frame
	var stats = load("res://resources/items/weapons/range/baguette_harpoon/stats_baguette_harpoon_1.tres")
	assert(stats.damage == 7.5)
	var arrow = stats.projectile_scene.instantiate()
	stage.add_child(arrow)
	arrow.set_process(false)
	arrow.position = Vector2(0,enemies[0].get_node("HurtboxComponent").global_position.y)
	arrow.setup_projectile(Vector2(1000,0),7.5,false,0,source,300)
	arrow.configure_effects(stats.ranged_settings)
	arrow._process(0.3)
	assert(arrow.planted and arrow.carried.size() == 2, "Swept flight captures both enemies")
	for enemy in enemies:
		assert(enemy.health_component.current_health == 992.5, "One hit per enemy")
		assert(enemy.global_position.is_equal_approx(arrow.global_position))
		assert(enemy.get_movement_multiplier() == 0)
	var left = arrow.hold_left
	global.game_paused = true
	arrow._process(1)
	assert(arrow.hold_left == left)
	global.game_paused = false
	arrow._process(left + 0.001)
	for enemy in enemies: assert(enemy.pins.is_empty())
	await process_frame
	# Arena edge ends travel before range, with proper release on external cleanup.
	var edge = stats.projectile_scene.instantiate()
	stage.add_child(edge)
	edge.set_process(false)
	edge.position = Vector2.ZERO
	edge.setup_projectile(Vector2(1000,0),7.5,false,0,source,999)
	edge.configure_effects(stats.ranged_settings)
	edge.arena_environment = load("res://resources/arena_environment.gd").new()
	edge.arena_environment.movement_bounds = Rect2(-50,-50,100,100)
	edge._on_hitbox_component_on_hit_hurtbox(enemies[0].get_node("HurtboxComponent"))
	edge._process(0.3)
	assert(edge.planted and is_equal_approx(edge.position.x,50))
	edge.queue_free()
	await process_frame
	assert(enemies[0].pins.is_empty())
	stage.queue_free()
	await process_frame
	print("PASS Baguette harpoon: swept capture, single damage, drag, range/arena end, pause, hold and cleanup")
	quit()
