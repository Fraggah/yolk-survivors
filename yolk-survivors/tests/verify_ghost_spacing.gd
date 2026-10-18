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
	var base=load("res://resources/items/weapons/spicy/item_ghost_pepper.tres")
	var weapons=[]
	player.global_position=player.arena_environment.movement_bounds.get_center()
	for index in 6:
		var original=base if index%2==0 else base.upgrade_to.upgrade_to
		var item=original.duplicate()
		item.stats=original.stats.duplicate(true)
		var weapon=item.scene.instantiate()
		player.add_child(weapon)
		weapon.setup_weapon(item)
		weapon.set_process(false)
		weapons.append(weapon)
		# Force the same random sequence: the second copy must reject the first point.
		seed(7281)
		weapon.weapon_behaviour.execute_attack()
		assert(weapon.weapon_behaviour.owned.size()==1)
		var cloud=weapon.weapon_behaviour.owned[0].get_ref()
		cloud.set_process(false)
		for previous in range(index):
			var other=weapons[previous].weapon_behaviour.owned[0].get_ref()
			var offset=cloud.global_position-other.global_position
			offset.y/=cloud.settings.area_y_ratio
			assert(offset.length()>0.01,"Different copies cannot reuse the same center even on the same frame")
			if index==1:
				var minimum=cloud.settings.cloud_min_separation*(cloud.radius+other.radius)*0.5
				assert(offset.length()+0.01>=minimum,"Two clouds maintain their configured spacing")
	for weapon in weapons: weapon.weapon_behaviour.reset_attack()
	# A corner can crowd clouds; overlap is allowed but coincident centers are not.
	player.global_position=player.arena_environment.clamp_position(player.arena_environment.movement_bounds.end)
	var centers=[]
	for weapon in weapons:
		seed(2421)
		weapon.weapon_behaviour.execute_attack()
		assert(weapon.weapon_behaviour.owned.size()==1)
		var cloud=weapon.weapon_behaviour.owned[0].get_ref()
		cloud.set_process(false)
		for point in centers: assert(cloud.global_position.distance_to(point)>0.01)
		centers.append(cloud.global_position)
		assert(cloud.global_position.is_equal_approx(player.arena_environment.clamp_position(cloud.global_position)))
	for weapon in weapons: weapon.weapon_behaviour.reset_attack()
	# With no placement space, skip instead of stacking two clouds on the player.
	var leader=weapons[0]
	leader.data.stats.max_range=0
	leader.weapon_behaviour.execute_attack()
	assert(leader.weapon_behaviour.owned.size()==1)
	leader.weapon_behaviour.execute_attack()
	assert(leader.weapon_behaviour.owned.size()==1)
	arena.queue_free()
	await process_frame
	print("PASS Ghost Pepper spacing: simultaneous copies, repeated random seeds, mixed tiers, crowded corners, queued cleanup and zero-space fallback")
	quit()
