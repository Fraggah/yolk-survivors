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
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	arena.spawner.wave_timer.stop()
	arena.spawner.clear_enemies()
	global.game_paused = false
	var player = global.player
	player.set_process(false)
	player.set_physics_process(false)
	player.health_component.debug_invulnerable = true
	player.position = Vector2.ZERO
	var charger = load("res://scenes/units/enemies/enemy_charger.tscn").instantiate()
	arena.add_child(charger)
	charger.position = Vector2(-500,0)
	charger.set_process(false)
	var charge = charger.get_node("ChargeAttackBehaviour")
	charge.set_process(false)
	charge.preparation_duration = .6
	charge.recovery_duration = .4
	charge.start_charge()
	assert(charge.state == charge.State.PREPARING and not charger.can_move)
	global.game_paused = true
	charge._process(1.0)
	assert(is_equal_approx(charge.state_time,.6), "Pause freezes preparation")
	global.game_paused = false
	charge._process(.6)
	assert(charge.state == charge.State.CHARGING)
	var target = charge.charge_atk_position
	player.position = Vector2(0,400)
	charge._process(.1)
	assert(charge.charge_atk_position == target and charger.position.y == 0, "Charge keeps fixed trajectory")
	charge._process(2.0)
	assert(charge.state == charge.State.RECOVERING and not charger.can_move)
	charge._process(.4)
	assert(charge.state == charge.State.PURSUIT and charger.can_move)
	var shooter = load("res://scenes/units/enemies/enemy_shooter.tscn").instantiate()
	arena.add_child(shooter)
	shooter.set_process(false)
	var shooting = shooter.get_node("ShootingBehaviour")
	shooting.set_process(false)
	assert(shooting.projectile_count == 1)
	player.position = Vector2.ZERO
	shooter.position = Vector2(600,0)
	shooting._process(.01)
	assert(shooter.desired_direction.x < 0, "Far shooter approaches")
	shooter.position = Vector2(100,0)
	shooting._process(.01)
	assert(shooter.desired_direction.x > 0, "Near shooter retreats")
	shooter.position = Vector2(280,0)
	shooting.current_cooldown = 0
	shooting._process(.01)
	assert(shooting.state == shooting.State.MOVING and shooter.desired_direction.x > 0, "Shooter must reach its preferred range before preparing")
	shooter.position = Vector2(350,0)
	shooting.current_cooldown = 0
	shooting._process(.01)
	assert(shooting.state == shooting.State.PREPARING and not shooter.can_move)
	var before = get_nodes_in_group("projectiles").size()
	player.position = Vector2(300,0)
	shooting._process(.6)
	assert(shooting.state == shooting.State.MOVING and get_nodes_in_group("projectiles").size() == before, "Approaching cancels point-blank shot")
	player.position = Vector2.ZERO
	shooting.current_cooldown = 0
	shooting._process(.01)
	shooting._process(.6)
	assert(shooting.state == shooting.State.RECOVERING)
	assert(get_nodes_in_group("projectiles").size() == before + shooting.projectile_count)
	for projectile in get_nodes_in_group("projectiles"):
		assert(projectile.max_distance == shooting.projectile_range)
		assert(projectile.hitbox.damage == shooting.projectile_damage)
		projectile.queue_free()
	shooting._process(.35)
	assert(shooting.state == shooting.State.MOVING)
	# Per-group weights, zero-weight filtering, intervals and saturation semantics.
	var group = SpawnGroup.new()
	group.enemies.assign([load("res://resources/wave/enemies/chaser_mid.tres"),load("res://resources/wave/enemies/chaser_fast.tres")])
	group.weights.assign([0.0,1.0])
	for i in 100: assert(group.select_enemy().id == &"chaser_fast")
	group.start_second = 5
	group.interval = 3
	group.minimum_interval = .5
	group.interval_reduction = .1
	assert(group.interval_at(5) == 3 and group.interval_at(100) == .5)
	arena.queue_free()
	await process_frame
	print("PASS Charger preparation/pause/fixed line/recovery; Shooter approach/retreat/preferred range/windup/cancellation/single bullet/range/cooldown; local weights and interval floor")
	quit()
