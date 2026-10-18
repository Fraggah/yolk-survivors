extends SceneTree
var arena
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
	enemy.health_component.current_health=1000
	enemy.health_component.max_health=1000
	return enemy
func get_egg():
	for node in get_nodes_in_group("projectiles"):
		if node.get_script().resource_path.ends_with("corpse_egg.gd") and not node.is_queued_for_deletion(): return node
	return null
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	global=root.get_node("Global")
	var item=load("res://resources/items/weapons/range/corpse_l/item_corpse_l_1.tres")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=item
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	arena.stage_mechanics.stop()
	var player=global.player
	player.set_process(false)
	player.global_position=Vector2.ZERO
	var weapon=player.current_weapons[0]
	weapon.set_process(false)
	weapon.position=Vector2.ZERO
	var current=item
	for tier in 4:
		assert(current.type==1 and current.item_type==0)
		assert(current.has_tag(current.Tag.EXPLOSIVE))
		assert(current.stats.ranged_settings.fuse==0.3 and current.stats.ranged_settings.explosion_radius==80)
		assert(current.stats.ranged_settings.bonus_yolks==1)
		current=current.upgrade_to
	var target=enemy_at(Vector2(220,0))
	weapon.closest_target=target
	weapon.rotation=1.0
	weapon.weapon_behaviour.create_projectile()
	var egg=get_egg()
	egg.set_process(false)
	egg.hitbox.critical_chance=0
	assert(egg.rotation==0 and egg.landing_point==Vector2(220,0))
	assert(egg.hitbox.collision_layer==0 and egg.hitbox.collision_mask==0)
	var snapshot=egg.landing_point
	target.global_position=Vector2(400,0)
	var inside=enemy_at(Vector2(800,0))
	var outside=enemy_at(Vector2(800,100))
	egg._process(egg.flight_time*0.5)
	assert(not egg.landed and egg.rotation==0)
	assert(egg.egg.position.y<0)
	var start=egg.global_position
	global.game_paused=true
	egg._process(5)
	assert(egg.global_position==start)
	global.game_paused=false
	egg._process(egg.flight_time-egg.flight_elapsed+0.00001)
	assert(egg.landed and egg.global_position==snapshot and egg.egg.position==Vector2.ZERO)
	inside.global_position=snapshot+Vector2(20,0)
	outside.global_position=snapshot+Vector2(0,100)
	await physics_frame
	await physics_frame
	assert(target.health_component.current_health==1000 and inside.health_component.current_health==1000,"No contact damage during travel or landing")
	global.game_paused=true
	var fuse=egg.fuse_left
	egg._process(5)
	assert(egg.fuse_left==fuse)
	global.game_paused=false
	egg._process(0.09)
	assert(egg.egg.position==Vector2.ZERO and egg.egg.modulate==Color.WHITE,"First 0.1 seconds remain still")
	egg._process(0.035)
	assert(not egg.egg.position.is_zero_approx(),"Last 0.2 seconds vibrate")
	assert(egg.global_position==snapshot and egg.rotation==0,"Shake moves the sprite only")
	global.game_paused=true
	var shake_position=egg.egg.position
	egg._process(1)
	assert(egg.egg.position==shake_position)
	global.game_paused=false
	egg._process(0.165)
	assert(not egg.exploded)
	var yolks_before=arena.gold_list.size()
	egg._process(0.02)
	assert(egg.exploded and egg.is_queued_for_deletion())
	assert(is_equal_approx(inside.health_component.current_health,1000-item.get_effective_damage(player.stats)))
	assert(target.health_component.current_health==1000 and outside.health_component.current_health==1000,"Oval blast and fixed landing position")
	assert(arena.gold_list.size()==yolks_before+1)
	var yolk=arena.gold_list.back()
	assert(yolk.value==1 and yolk.global_position==snapshot)
	egg.detonate()
	assert(arena.gold_list.size()==yolks_before+1,"One bonus yolk per shot, never per enemy hit")
	await process_frame
	yolk.set_process(false)
	# Contact pushes without damage, then a short fall precedes the existing fuse.
	inside.global_position=Vector2(-800,0)
	outside.global_position=Vector2(-800,100)
	var contact_enemy=enemy_at(Vector2(650,250))
	await physics_frame
	await physics_frame
	weapon.closest_target=contact_enemy
	weapon.weapon_behaviour.create_projectile()
	var contact_egg=get_egg()
	contact_egg.set_process(false)
	contact_egg.hitbox.critical_chance=0
	contact_egg._process(contact_egg.flight_time)
	assert(contact_egg.contact_target_id==contact_enemy.get_instance_id())
	assert(contact_egg.falling and not contact_egg.landed)
	assert(contact_enemy.health_component.current_health==1000,"Impact is push only")
	assert(contact_enemy.knockback_power>0 and contact_enemy.knockback_dir.dot(contact_egg.velocity)>0)
	contact_egg._process(contact_egg.settings.egg_fall_duration)
	assert(contact_egg.landed and is_equal_approx(contact_egg.fuse_left,0.3))
	contact_egg._process(0.09)
	assert(contact_egg.egg.position==Vector2.ZERO)
	contact_egg._process(0.04)
	assert(not contact_egg.egg.position.is_zero_approx() and contact_enemy.health_component.current_health==1000)
	contact_egg._process(0.18)
	assert(contact_egg.exploded and contact_enemy.health_component.current_health<1000)
	await process_frame
	# Area stat applies to the explosion, independently of its flight destination.
	player.stats.apply_stat_change("area_of_effect",100)
	weapon.closest_target=target
	weapon.weapon_behaviour.create_projectile()
	egg=get_egg()
	egg.set_process(false)
	egg._process(egg.flight_time+egg.settings.egg_fall_duration+0.301)
	var blast=null
	for effect in get_nodes_in_group("projectiles"):
		if effect.get_script().resource_path.ends_with("ranged_area_effect.gd") and not effect.is_queued_for_deletion(): blast=effect
	assert(blast!=null)
	assert(is_equal_approx(blast.radius,item.stats.ranged_settings.explosion_radius*global.GAME_ENTITY_SCALE*player.stats.get_area_radius_multiplier()))
	await process_frame
	arena.clear_arena()
	await process_frame
	assert(get_nodes_in_group("projectiles").is_empty())
	assert(get_nodes_in_group("yolks").is_empty())
	print("PASS Corpse Launcher: target snapshot, horizontal flight, no contact damage, landing fuse/pause, oval AoE, one extra yolk and cleanup")
	quit()
