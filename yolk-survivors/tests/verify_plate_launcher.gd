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
	for x in [100,200,300]:
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
	var stats = load("res://resources/items/weapons/range/plate_launcher/stats_plate_launcher_1.tres")
	for chance in [0.0,1.0]:
		var plate = stats.projectile_scene.instantiate()
		stage.add_child(plate)
		plate.set_process(false)
		plate.setup_projectile(Vector2(0,100),10,false,0,source,300)
		var config = stats.ranged_settings.duplicate()
		config.plate_break_chance = chance
		plate.configure_effects(config)
		var hurtbox = enemies[0].get_node("HurtboxComponent")
		var hp = enemies[0].health_component.current_health
		hurtbox._on_area_entered(plate.hitbox)
		assert(enemies[0].health_component.current_health == hp-10)
		hurtbox._on_area_entered(plate.hitbox)
		assert(enemies[0].health_component.current_health == hp-10)
		assert(plate.rotation == 0)
		if chance == 0.0:
			assert(not plate.broken and not plate.is_queued_for_deletion())
			assert(plate.velocity != Vector2(0,100))
			plate.queue_free()
		else:
			assert(plate.broken and plate.is_queued_for_deletion())
		await process_frame
	var fragments = []
	for node in get_nodes_in_group("projectiles"):
		if node.get_script().resource_path.ends_with("plate_fragments.gd"): fragments.append(node)
	assert(fragments.size() == 1 and fragments[0].pieces.size() == 12)
	fragments[0]._process(1)
	assert(fragments[0].is_queued_for_deletion())
	stage.queue_free()
	await process_frame
	print("PASS Plates: horizontal sprite, survival bounce, certain break, single damage, fragments and cleanup")
	quit()
