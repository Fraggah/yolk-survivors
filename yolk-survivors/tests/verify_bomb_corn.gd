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
	var enemy = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	enemy.stats = enemy.stats.duplicate()
	enemy.stats.block_chance = 0
	stage.add_child(enemy)
	enemy.set_process(false)
	enemy.can_move = false
	enemy.health_component.max_health = 1000
	enemy.health_component.current_health = 1000
	for tier in range(1,5):
		var stats = load("res://resources/items/weapons/range/bomb_corn/stats_bomb_corn_%d.tres" % tier)
		assert(stats.cooldown > 0 and stats.ranged_settings.fuse > 0)
		var seed = stats.projectile_scene.instantiate()
		stage.add_child(seed)
		seed.set_process(false)
		seed.setup_projectile(Vector2.RIGHT * 600, 10, false, 0, source, 300)
		var config = stats.ranged_settings.duplicate()
		config.corn_explosion_chance = 1.0
		config.fuse = 0.5
		seed.configure_effects(config)
		assert(seed.hitbox.damage == 2.5)
		var hurtbox = enemy.get_node("HurtboxComponent")
		var contact_hp = enemy.health_component.current_health
		hurtbox._on_area_entered(seed.hitbox)
		assert(is_equal_approx(enemy.health_component.current_health, contact_hp - 2.5))
		assert(seed.armed)
		seed._on_hitbox_component_on_hit_hurtbox(hurtbox)
		hurtbox._on_area_entered(seed.hitbox)
		assert(is_equal_approx(enemy.health_component.current_health, contact_hp - 2.5), "Contact signals cannot damage twice")
		assert(not seed.visible, "Kernel vanishes on impact")
		var before = enemy.health_component.current_health
		# Detonation only waits for safe physics insertion, never a gameplay timer.
		seed.detonate()
		assert(seed.exploded)
		assert(enemy.health_component.current_health < before, "Explosion damages nearby enemy")
		var popped: Array = []
		for node in get_nodes_in_group("projectiles"):
			if str(node.name).begins_with("ProjectilePoppedCorn"): popped.append(node)
		assert(popped.size() == 1, "Exactly one follow-up per kernel")
		var popcorn = popped[0]
		popcorn.set_process(false)
		assert(popcorn.global_position.is_equal_approx(seed.global_position))
		assert(is_equal_approx(popcorn.velocity.length(), 700), "Random direction preserves configured speed")
		assert(popcorn.hitbox.damage == 10)
		var hp = enemy.health_component.current_health
		enemy.get_node("HurtboxComponent")._on_area_entered(popcorn.hitbox)
		assert(enemy.health_component.current_health < hp, "Popcorn is a damaging projectile")
		popcorn._process(10.0)
		assert(popcorn.is_queued_for_deletion())
		seed.detonate()
		await process_frame
	# Zero chance: impact damage remains, without explosion or popcorn.
	var stats = load("res://resources/items/weapons/range/bomb_corn/stats_bomb_corn_1.tres")
	var miss = stats.projectile_scene.instantiate()
	stage.add_child(miss)
	miss.set_process(false)
	miss.setup_projectile(Vector2.RIGHT * 600, 10, false, 0, source, 300)
	var config = stats.ranged_settings.duplicate()
	config.corn_explosion_chance = 0.0
	miss.configure_effects(config)
	var hp = enemy.health_component.current_health
	enemy.get_node("HurtboxComponent")._on_area_entered(miss.hitbox)
	assert(is_equal_approx(enemy.health_component.current_health, hp - 2.5))
	assert(miss.is_queued_for_deletion() and not miss.armed and not miss.exploded)
	miss.detonate()
	assert(not miss.exploded)
	await process_frame
	stage.queue_free()
	await process_frame
	print("PASS Bomb Corn: impact damage, 0/100 percent proc, immediate explosion, follow-up and cleanup")
	quit()
