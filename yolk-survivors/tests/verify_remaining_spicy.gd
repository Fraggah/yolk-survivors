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
	var ids=["cayenne","poblano","carolina_reaper","ghost_pepper","aji_amarillo","scotch_bonnet","rocoto"]
	for id in ids:
		player.global_position=Vector2.ZERO
		global.game_paused=false
		var item=load("res://resources/items/weapons/chili/%s/item_%s.tres"% [id, id])
		assert(not item.selection_only and arena.shop_panel.shop_items.has(item))
		var data=item.duplicate()
		data.stats=item.stats.duplicate(true)
		data.stats.crit_chance=0
		var weapon=data.scene.instantiate()
		player.add_child(weapon)
		weapon.setup_weapon(data)
		weapon.set_process(false)
		var behaviour=weapon.weapon_behaviour
		var settings=data.stats.spicy_pattern
		assert(weapon.targets.is_empty() and weapon.can_use_weapon())
		seed(321)
		behaviour.execute_attack()
		if id=="cayenne":
			assert(behaviour.owned.is_empty(), "No fire while standing still")
			player.global_position+=Vector2(100,0)
			assert(behaviour.can_execute_attack())
			behaviour.execute_attack()
			assert(behaviour.owned.size()==1 and not behaviour.can_execute_attack())
		if id=="aji_amarillo":
			var first=get_nodes_in_group("projectiles").back()
			behaviour.execute_attack()
			var second=get_nodes_in_group("projectiles").back()
			assert(is_equal_approx(wrapf(second.velocity.angle()-first.velocity.angle(),0,TAU),deg_to_rad(settings.spiral_step_degrees)))
			assert(is_equal_approx(first.velocity.length(),data.stats.projectile_speed))
		else:
			assert(behaviour.owned.size()==settings.count)
			var effect=behaviour.owned[0].get_ref()
			effect.set_process(false)
			assert(is_equal_approx(effect.radius,settings.radius*global.GAME_ENTITY_SCALE))
			if id=="poblano":
				effect._process(0)
				assert(not weapon.sprite_2d.visible and not behaviour.can_execute_attack())
				assert(effect.global_position.distance_to(player.global_position)>0)
			var point=effect.global_position
			if id=="carolina_reaper": point+=effect.velocity*0.01
			var target=enemy_at(point)
			var initial=target.health_component.current_health
			if id=="scotch_bonnet":
				effect._process(settings.arming_time*0.5)
				assert(target.health_component.current_health==initial and not effect.detonated)
				effect._process(settings.arming_time*0.6)
				assert(effect.detonated and target.health_component.current_health==initial-data.stats.damage)
				effect._process(0.01)
				assert(target.health_component.current_health==initial-data.stats.damage, "Mine detonates once")
			elif id=="rocoto":
				target.global_position=point+Vector2(effect.radius*0.5,0)
				effect._process(settings.wave_duration*0.6)
				assert(target.health_component.current_health==initial-data.stats.damage)
				effect._process(settings.wave_duration*0.1)
				assert(target.health_component.current_health==initial-data.stats.damage, "Wave hits each enemy only once")
			else:
				effect.tick_left=0
				effect._process(0.01)
				assert(target.health_component.current_health<initial,id+" damage")
				if id=="carolina_reaper": assert(effect.global_position!=point-effect.velocity*0.01)
				if id in ["cayenne","carolina_reaper"]:
					assert(target.get_children().any(func(node): return node.get_script()==load("res://effects/fire_status.gd")))
			var elapsed=effect.elapsed
			var position_before=effect.global_position
			var health=target.health_component.current_health
			global.game_paused=true
			effect._process(1)
			assert(effect.elapsed==elapsed and effect.global_position==position_before and target.health_component.current_health==health)
			global.game_paused=false
			if id in ["ghost_pepper","scotch_bonnet"]:
				settings.maximum_active=2
				for count in 4: behaviour.execute_attack()
				assert(behaviour.owned.size()==2, "Bound active persistent effects")
			if id=="poblano":
				var other=data.scene.instantiate()
				player.add_child(other)
				other.setup_weapon(data)
				other.set_process(false)
				other.weapon_behaviour.execute_attack()
				assert(other.weapon_behaviour.owned.size()==1)
				other.weapon_behaviour.reset_attack()
				other.queue_free()
		behaviour.reset_attack()
		assert(weapon.sprite_2d.visible)
		weapon.queue_free()
		global.game_paused=true
		arena.clear_arena()
		await process_frame
		assert(get_nodes_in_group("projectiles").is_empty(),id+" wave cleanup")
	print("PASS seven unique spicy patterns: moving-only trail, orbit/copies, moving fire columns, clouds, spiral seeds, armed single-detonation mines, one-hit wave, pause, limits and cleanup")
	quit()
