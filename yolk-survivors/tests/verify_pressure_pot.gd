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
	for point in [Vector2.ZERO, Vector2(0,200)]:
		var enemy = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
		enemy.stats = enemy.stats.duplicate()
		enemy.stats.block_chance = 0
		stage.add_child(enemy)
		enemy.position = point
		enemy.can_move = false
		enemy.set_process(false)
		enemy.health_component.max_health = 1000
		enemy.health_component.current_health = 1000
		enemies.append(enemy)
	for tier in range(1,5):
		var stats = load("res://resources/items/weapons/range/pressure_cooker/stats_pressure_cooker_%d.tres" % tier)
		var pot = stats.projectile_scene.instantiate()
		stage.add_child(pot)
		pot.set_process(false)
		pot.position = Vector2(-100,0)
		pot.setup_projectile(Vector2(100,40), 20, false, 0, source, 300)
		pot.configure_effects(stats.ranged_settings)
		pot.configure_target(Vector2.ZERO)
		assert(pot.rotation == 0)
		pot._on_hitbox_component_on_hit_hurtbox(enemies[0].get_node("HurtboxComponent"))
		assert(pot._find_contact(Vector2(-100,0),Vector2.ZERO).is_empty())
		var hp = enemies[0].health_component.current_health
		pot._process(pot.flight_time)
		assert(pot.landed and not pot.exploded)
		assert(enemies[0].health_component.current_health == hp, "Landing deals no damage")
		assert(enemies[0].get_movement_multiplier() < 1)
		assert(enemies[1].get_movement_multiplier() == 1, "Slow respects oval footprint")
		var rest = pot.egg.scale
		pot._process(stats.ranged_settings.fuse * 0.9)
		assert(pot.egg.scale.x > rest.x)
		assert(pot.rotation == 0 and pot.egg.rotation == 0)
		var left = pot.fuse_left
		global.game_paused = true
		pot._process(5)
		assert(pot.fuse_left == left)
		global.game_paused = false
		pot._process(left + 0.001)
		assert(pot.exploded and pot.is_queued_for_deletion())
		assert(enemies[0].health_component.current_health < hp)
		await process_frame
	stage.queue_free()
	await process_frame
	print("PASS Pressure cooker: upright flight, harmless landing, oval slow, inflation, pause and explosion across four tiers")
	quit()
