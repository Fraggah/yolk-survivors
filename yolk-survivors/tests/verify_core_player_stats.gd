extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var global = root.get_node("Global")
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
	arena.environment_controller.debug_forced_stage = 1
	arena.start_panel.hide()
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	var player = global.player
	player.set_process(false)
	player.set_physics_process(false)
	for weapon in player.current_weapons: weapon.set_process(false)
	player.stats.block_chance = 0
	var hp = player.health_component
	hp.max_health = 100
	hp.current_health = 50
	assert(not player.try_life_steal(0))
	assert(player.try_life_steal(1))
	assert(is_equal_approx(hp.current_health, 50.1))
	assert(not player.try_life_steal(10), "Shared recovery cooldown remains")
	player.life_steal_cooldown = 0
	assert(player.try_life_steal(3))
	assert(is_equal_approx(hp.current_health, 50.4))
	seed(1234)
	var saw_extra := false
	var saw_base := false
	for attempt in 60:
		player.life_steal_cooldown = 0
		var before: float = hp.current_health
		player.try_life_steal(2.5)
		var gained: float = hp.current_health - before
		assert(is_equal_approx(gained,0.2) or is_equal_approx(gained,0.3))
		saw_extra = saw_extra or is_equal_approx(gained,0.3)
		saw_base = saw_base or is_equal_approx(gained,0.2)
	assert(saw_extra and saw_base)
	hp.current_health = 99.95
	player.life_steal_cooldown = 0
	player.try_life_steal(3)
	assert(hp.current_health == 100)
	var hitbox = load("res://scenes/components/hitbox_component.gd").new()
	root.add_child(hitbox)
	hitbox.damage = 16
	player.stats.armor = 10
	hp.current_health = 100
	assert(player.receive_hit(hitbox))
	assert(is_equal_approx(hp.current_health,90), "Armor applies in actual hit flow")
	player.stats.armor = -10
	assert(player.receive_hit(hitbox))
	assert(is_equal_approx(hp.current_health,64.4))
	player.stats.block_chance = 100
	player.stats.block_effectiveness = 100 # Explicit full mitigation test.
	assert(not player.receive_hit(hitbox) and is_equal_approx(hp.current_health,64.4))
	player.stats.block_chance = 0
	var enemy = load("res://resources/wave/enemies/chaser_mid.tres").scene.instantiate()
	arena.add_child(enemy)
	enemy.set_process(false)
	enemy.stats = enemy.stats.duplicate()
	enemy.stats.armor = 100
	enemy.stats.block_chance = 0
	enemy.health_component.max_health = 100
	enemy.health_component.current_health = 100
	hp.current_health = 50
	player.life_steal_cooldown = 0
	hitbox.source = player
	hitbox.life_steal_chance = 3
	assert(enemy.receive_hit(hitbox))
	assert(enemy.health_component.current_health == 84, "Player armor does not change enemy balance")
	assert(is_equal_approx(hp.current_health,50.3), "Actual enemy hit activates source life steal")
	enemy.queue_free()
	var weapon = player.current_weapons[0]
	weapon.data = weapon.data.duplicate(true)
	weapon.data.stats.crit_chance = 0.05
	weapon.data.stats.life_steal = 0.2
	player.stats.critical_chance = 95
	player.stats.life_steal = 350
	assert(is_equal_approx(weapon.weapon_behaviour.get_life_steal_chance(),3.7))
	assert(weapon.data.get_effective_critical_chance(player.stats) == 1)
	var crit_damage: float = weapon.weapon_behaviour.get_damage()
	assert(weapon.weapon_behaviour.critical)
	assert(is_equal_approx(crit_damage,weapon.data.get_effective_damage(player.stats)*weapon.data.stats.crit_damage))
	player.stats.critical_chance = -100
	assert(weapon.data.get_effective_critical_chance(player.stats) == 0)
	weapon.weapon_behaviour.get_damage()
	assert(not weapon.weapon_behaviour.critical)
	var coin = load("res://scenes/coins/coins.tscn").instantiate()
	arena.add_child(coin)
	coin.set_process(false)
	coin.global_position = player.global_position + Vector2(300,0)
	player.stats.pickup_range = 0
	coin._process(0.0)
	assert(not coin.collected)
	player.stats.apply_stat_change("pickup_range",100)
	assert(player.stats.pickup_range == 100)
	coin._process(0.01)
	assert(coin.collected)
	assert(coin.global_position.distance_to(player.global_position) < 300)
	player.stats.apply_stat_change("armor",5)
	assert(player.stats.armor == 5)
	player.stats.apply_stat_change("critical_chance",25)
	assert(player.stats.critical_chance == 25)
	global.game_paused = true
	player.life_steal_cooldown = 0
	assert(not player.try_life_steal(3))
	var before_pause: float = hp.current_health
	assert(not player.receive_hit(hitbox) and hp.current_health == before_pause)
	coin.queue_free()
	hitbox.queue_free()
	arena.queue_free()
	await process_frame
	print("PASS scaled fractional life steal, cooldown, healing cap, armor hit/block/pause flow, additive weapon criticals and dynamic pickup range/stat gains")
	quit()
