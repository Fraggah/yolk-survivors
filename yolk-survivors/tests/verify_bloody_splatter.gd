extends SceneTree
var arena
var player
var global
func _initialize(): call_deferred("verify")
func enemy_at(point):
	var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	enemy.stats=enemy.stats.duplicate()
	enemy.stats.block_chance=0
	arena.add_child(enemy)
	enemy.global_position=point
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.can_move=false
	enemy.health_component.max_health=1000
	enemy.health_component.current_health=1000
	return enemy
func drops():
	var result=[]
	for node in get_nodes_in_group("projectiles"):
		if node.get_script().resource_path.ends_with("ketchup_drop.gd") and not node.is_queued_for_deletion(): result.append(node)
	return result
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	global=root.get_node("Global")
	var item=load("res://resources/items/weapons/range/the_bloody/item_bloody_1.tres")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=item
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	player=global.player
	player.set_process(false)
	var weapon=player.current_weapons[0]
	weapon.set_process(false)
	var current=item
	for tier in 4:
		assert(current.stats.ranged_settings.splatter_count==3)
		assert(current.stats.ranged_settings.splatter_damage_multiplier==0.25)
		assert(current.stats.ranged_settings.splatter_range_multiplier>=0)
		assert(current.stats.projectile_scene.resource_path.ends_with("projectile_ketchup_capsule.tscn"))
		current=current.upgrade_to
	weapon.weapon_behaviour.create_projectile()
	var capsule=get_nodes_in_group("projectiles")[0]
	capsule.set_process(false)
	capsule.hitbox.critical_chance=0
	# Slow test droplets so short travel does not expire between physics assertions.
	capsule.effects=capsule.effects.duplicate()
	capsule.effects.splatter_speed=100
	var expected_range=capsule.max_distance*capsule.effects.splatter_range_multiplier
	var incoming=capsule.velocity
	var target=enemy_at(capsule.global_position)
	await physics_frame
	await physics_frame
	await process_frame
	var spawned=drops()
	assert(spawned.size()==3,"Confirmed capsule collision creates exactly three droplets")
	var original_hp=target.health_component.current_health
	assert(is_equal_approx(original_hp,1000-item.get_effective_damage(player.stats)))
	for drop in spawned:
		drop.set_process(false)
		assert(is_equal_approx(drop.hitbox.damage,item.get_effective_damage(player.stats)*0.25))
		assert(is_equal_approx(drop.max_distance,expected_range))
		assert(drop.velocity.dot(incoming)>0,"Splatter travels behind target in incoming shot direction")
		assert(drop.hitbox.weapon_damage_record==weapon.damage_record)
		assert(not drop.hitbox.roll_critical_per_target)
		# Re-overlapping the struck target neither deals damage nor consumes a drop.
		target.get_node("HurtboxComponent")._on_area_entered(drop.hitbox)
		drop._on_hitbox_component_on_hit_hurtbox(target.get_node("HurtboxComponent"))
		assert(not drop.is_queued_for_deletion())
	assert(target.health_component.current_health==original_hp)
	# A real secondary overlap deals one quarter damage and cannot spawn more drops.
	var drop=spawned[1]
	var secondary=enemy_at(Vector2(300,100))
	drop.global_position=secondary.get_aim_position()
	var quarter=drop.hitbox.damage
	await physics_frame
	await physics_frame
	await process_frame
	assert(is_equal_approx(secondary.health_component.current_health,1000-quarter))
	assert(drops().size()==2)
	for node in drops(): node.queue_free()
	await process_frame
	# Critical damage is inherited once; lethal hits still splatter.
	var critical=item.stats.projectile_scene.instantiate()
	root.add_child(critical)
	critical.set_process(false)
	critical.setup_projectile(Vector2(1000,0),40,true,0,player,400)
	critical.configure_effects(item.stats.ranged_settings)
	var lethal=enemy_at(Vector2(700,300))
	lethal.health_component.current_health=1
	lethal.receive_hit(critical.hitbox)
	await process_frame
	assert(drops().size()==3)
	for child in drops():
		assert(child.hitbox.damage==10 and child.hitbox.critical)
		assert(is_equal_approx(child.max_distance,400*item.stats.ranged_settings.splatter_range_multiplier))
	critical.queue_free()
	var remaining=drops()[0]
	remaining.set_process(false)
	global.game_paused=true
	var start=remaining.position
	remaining._process(1)
	assert(remaining.position==start)
	global.game_paused=false
	remaining._process(100)
	assert(not remaining.leased and not remaining.visible and not remaining.is_in_group("projectiles"))
	print("PASS Bloody: confirmed capsule impact, three rear droplets, quarter damage, no self-hit/recursion, critical/lethal impact, pause and range")
	quit()
