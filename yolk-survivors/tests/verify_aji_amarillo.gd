extends SceneTree
var arena
var global
var player
func _initialize(): call_deferred("verify")
func enemy_at(point):
	var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	enemy.stats=enemy.stats.duplicate()
	enemy.stats.block_chance=0
	arena.add_child(enemy)
	enemy.global_position=point
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.health_component.max_health=10000
	enemy.health_component.current_health=10000
	return enemy
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=load("res://resources/items/weapons/range/knifer/item_knifer_1.tres")
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	player=global.player
	player.set_process(false)
	player.health_component.debug_invulnerable=true
	for weapon in player.current_weapons: weapon.set_process(false)
	for old in player.current_weapons: old.queue_free()
	player.current_weapons.clear()
	var base=load("res://resources/items/weapons/spicy/item_aji_amarillo.tres")
	for count in range(1,7):
		var item=base if count%2 else base.upgrade_to.upgrade_to
		player.add_weapon(item)
		for equipped in player.current_weapons:
			equipped.set_process(false)
			equipped.weapon_behaviour.reset_attack()
		var angles=[]
		for equipped in player.current_weapons:
			equipped.weapon_behaviour.execute_attack()
			var projectile=get_nodes_in_group("projectiles").back()
			angles.append(wrapf(projectile.velocity.angle(),0,TAU))
		for index in count:
			assert(is_equal_approx(wrapf(angles[index]-angles[0],0,TAU),TAU*index/count),"Copies divide the circle equally, including mixed tiers")
		# Rotation progresses by the original step while retaining equal separation.
		for index in count:
			player.current_weapons[index].weapon_behaviour.execute_attack()
			var projectile=get_nodes_in_group("projectiles").back()
			assert(is_equal_approx(wrapf(projectile.velocity.angle()-angles[index],0,TAU),deg_to_rad(item.stats.spicy_pattern.spiral_step_degrees)))
	# Removing a copy recomputes the angular distribution after the normal reset.
	var removed=player.current_weapons.pop_back()
	removed.queue_free()
	for equipped in player.current_weapons: equipped.weapon_behaviour.reset_attack()
	var first_angle=0.0
	for index in player.current_weapons.size():
		player.current_weapons[index].weapon_behaviour.execute_attack()
		var projectile=get_nodes_in_group("projectiles").back()
		if index==0: first_angle=projectile.velocity.angle()
		assert(is_equal_approx(wrapf(projectile.velocity.angle()-first_angle,0,TAU),TAU*index/player.current_weapons.size()))
	player.stats.damage_percent=0
	player.stats.effects=0
	player.stats.ranged_damage=0
	player.stats.melee_damage=0
	var baseline=base.get_effective_damage(player.stats)
	player.stats.ranged_damage=10
	assert(is_equal_approx(base.get_effective_damage(player.stats),baseline+10))
	player.stats.melee_damage=200
	assert(is_equal_approx(base.get_effective_damage(player.stats),baseline+10),"Aji does not scale from melee damage")
	assert(base.type==2)
	assert(base.get_damage_description(player.stats).contains("damage_ranged.svg"))
	var tier=base
	while tier:
		assert(tier.stats.damage_scaling==1.0 and tier.damage_scaling_stat==2)
		tier=tier.upgrade_to
	var bell=load("res://resources/items/weapons/spicy/item_bell_pepper.tres")
	assert(bell.get_damage_scaling_stat_id().is_empty())
	player.stats.ranged_damage=0
	var bell_damage=bell.get_effective_damage(player.stats)
	player.stats.ranged_damage=10
	assert(bell.get_effective_damage(player.stats)==bell_damage,"Other peppers retain their original scaling")
	arena.queue_free()
	await process_frame
	print("PASS Aji Amarillo: 1-6 evenly spaced spiral copies, mixed tiers, rotation, removal/reset, ranged scaling, category and description")
	quit()
