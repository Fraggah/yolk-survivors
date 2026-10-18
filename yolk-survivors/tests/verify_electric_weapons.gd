extends SceneTree
var arena
var global
func _initialize(): call_deferred("verify")
func current_saw():
	for effect in get_nodes_in_group("projectiles"):
		if effect.get_script().resource_path.ends_with("electric_saw.gd") and not effect.is_queued_for_deletion(): return effect
	return null
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
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	var mini=load("res://resources/items/weapons/melee/immersion_blender/item_immersion_blender_1.tres")
	var knife=load("res://resources/items/weapons/melee/electric_knife/item_electric_knife_1.tres")
	global.main_weapon_selected=mini
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	var player=global.player
	player.set_process(false)
	player.global_position=Vector2.ZERO
	for family in [mini,knife]:
		var item=family
		for tier in 4:
			assert(item.item_tier==tier and arena.shop_panel.shop_items.has(item))
			assert(item.on_hit_effects.size()==1 and item.on_hit_effects[0].kind==1)
			if family==mini: assert(item.type==1 and item.stats.projectile_scene!=null)
			else: assert(item.type==0 and item.stats.melee_settings.hit_count==1)
			item=item.upgrade_to
		assert(item==null)
	var weapon=player.current_weapons[0]
	weapon.set_process(false)
	weapon.position=Vector2.ZERO
	weapon.rotation=0
	weapon.weapon_behaviour.create_projectile()
	var saw=current_saw()
	saw.set_process(false)
	assert(saw.get_script().resource_path.ends_with("electric_saw.gd"))
	assert(saw.velocity.x>0 and is_zero_approx(saw.velocity.y))
	assert(saw.hitbox.status_effects.has(mini.on_hit_effects[0]))
	saw.hitbox.critical_chance=0
	var enemy=enemy_at(saw.global_position)
	var neighbor=enemy_at(saw.global_position+Vector2(22,0))
	await physics_frame
	await physics_frame
	await process_frame
	assert(enemy.health_component.current_health<1000)
	assert(neighbor.health_component.current_health<1000,"Electricity propagates on saw impact")
	assert(enemy.get_status_movement_multiplier()==1 and neighbor.get_status_movement_multiplier()==1)
	assert(enemy.status_controller.lightning_left>1.0,"Sparks persist beyond the impact flash")
	var bursts=[]
	for effect in get_nodes_in_group("projectiles"):
		if effect.get_script().resource_path.ends_with("electric_impact.gd"): bursts.append(effect)
	assert(bursts.size()>=2,"Primary and secondary hits have outward impact bursts")
	var burst=bursts[0]
	burst.set_process(false)
	global.game_paused=true
	var old_elapsed=burst.elapsed
	burst._process(0.5)
	assert(burst.elapsed==old_elapsed)
	global.game_paused=false
	burst._process(burst.duration+0.01)
	assert(burst.is_queued_for_deletion())
	enemy.queue_free()
	neighbor.queue_free()
	await process_frame
	# Motion and spin freeze together, and range removes the projectile.
	weapon.weapon_behaviour.create_projectile()
	saw=current_saw()
	assert(saw.blade_radius==10.0 and saw.velocity.length()==1200.0)
	saw.set_process(false)
	var initial=saw.global_position
	global.game_paused=true
	saw._process(0.5)
	assert(saw.global_position==initial and saw.blade_angle==0)
	global.game_paused=false
	saw._process(0.02)
	assert(saw.blade_angle>0)
	saw._process(10)
	assert(saw.is_queued_for_deletion())
	var blade=knife.scene.instantiate()
	player.add_child(blade)
	blade.setup_weapon(knife)
	blade.set_process(false)
	blade.position=Vector2.ZERO
	blade.rotation=0
	var tuning=knife.stats.melee_settings
	var target_point=blade.to_global(Vector2(blade.atk_start_pos.x+knife.stats.max_range*tuning.reach_multiplier*0.65+14,0))
	enemy=enemy_at(target_point)
	neighbor=enemy_at(target_point+Vector2(20,0))
	blade.closest_target=enemy
	await physics_frame
	await physics_frame
	blade.weapon_behaviour.execute_attack()
	await create_timer(1.2).timeout
	assert(blade.weapon_behaviour.pulse_count==1)
	assert(enemy.health_component.current_health<1000,"Normal knife attack damages through its melee hitbox")
	assert(enemy.status_controller.lightning_left>0 and enemy.get_status_movement_multiplier()==1,"Knife electrifies without slowing")
	assert(neighbor.health_component.current_health<1000)
	assert(not blade.is_attacking)
	print("PASS electric weapons: four tiers, ranged saw impact/chain, melee knife, pause, spin, range and selection")
	quit()
