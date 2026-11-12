extends SceneTree
func _initialize(): call_deferred("verify")
func make_enemy(arena, point):
	var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	enemy.stats=enemy.stats.duplicate()
	enemy.stats.block_chance=0
	arena.add_child(enemy)
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.health_component.current_health=1000
	enemy.health_component.max_health=1000
	enemy.global_position=point
	return enemy
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	var item=load("res://resources/items/weapons/chili/habanero/item_habanero.tres")
	assert(not item.selection_only and item.type==2)
	assert(arena.shop_panel.shop_items.has(item))
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=item
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	var player=global.player
	player.set_process(false)
	player.health_component.debug_invulnerable=true
	var weapon=player.current_weapons[0]
	weapon.set_process(false)
	assert(weapon.can_use_weapon() and weapon.targets.is_empty())
	seed(12345)
	weapon.use_weapon()
	var blasts=get_nodes_in_group("projectiles")
	assert(blasts.size()==1 and not weapon.can_use_weapon())
	weapon.weapon_behaviour.set_process(false)
	for blast in blasts:
		blast.set_process(false)
		assert(not blast.detonated)
	var blast=blasts[0]
	var settings=item.stats.spicy_explosion_settings
	var inside=make_enemy(arena,blast.global_position+Vector2(blast.radius*0.8,0))
	var outside=make_enemy(arena,blast.global_position+Vector2(0,blast.radius*0.8))
	blast.hit.critical_chance=0
	blast._process(settings.anticipation*0.5)
	assert(inside.health_component.current_health==1000)
	global.game_paused=true
	blast._process(1)
	assert(not blast.detonated)
	global.game_paused=false
	blast._process(settings.anticipation*0.5)
	assert(blast.detonated)
	assert(inside.health_component.current_health==992)
	assert(outside.health_component.current_health==1000)
	var key="HabaneroBurn_%s"%weapon.get_instance_id()
	var burn=inside.get_node(key)
	burn.set_process(false)
	global.game_paused=true
	var life=burn.remaining
	burn._process(1)
	assert(burn.remaining==life and inside.health_component.current_health==992)
	global.game_paused=false
	inside.global_position+=Vector2(500,0)
	burn._process(0.5)
	assert(is_equal_approx(inside.health_component.current_health,989.2), "Burn follows enemy outside blast")
	var remaining_tick=burn.tick_left
	load("res://effects/spicy_burn.gd").apply(inside,weapon.get_instance_id(),blast.hit,settings)
	assert(inside.get_node(key)==burn and burn.tick_left==remaining_tick)
	assert(burn.remaining==3)
	for tick in 6: burn._process(0.5)
	assert(burn.is_queued_for_deletion())
	assert(is_equal_approx(inside.health_component.current_health,972.4))
	assert(is_equal_approx(weapon.damage_record.wave_damage,27.6))
	load("res://effects/spicy_burn.gd").apply(inside,weapon.get_instance_id(),blast.hit,settings)
	assert(inside.get_node(key)!=burn and not inside.get_node(key).is_queued_for_deletion(), "Reapply on expiry frame creates a fresh burn")
	player.add_weapon(item)
	var second=player.current_weapons[1]
	second.set_process(false)
	second.use_weapon()
	assert(second.cooldown_timer.time_left>0)
	load("res://effects/spicy_burn.gd").apply(outside,weapon.get_instance_id(),blast.hit,settings)
	load("res://effects/spicy_burn.gd").apply(outside,second.get_instance_id(),blast.hit,settings)
	assert(outside.has_node("HabaneroBurn_%s"%weapon.get_instance_id()))
	assert(outside.has_node("HabaneroBurn_%s"%second.get_instance_id()))
	# Effects participate in the same wave cleanup as existing projectiles.
	for effect in get_nodes_in_group("projectiles"): effect.queue_free()
	await process_frame
	assert(get_nodes_in_group("projectiles").is_empty())
	print("PASS Habanero autonomous explosions, anticipation, oval damage, burn ticks/expiry/refresh, independent copies, tracking, pause and cleanup")
	quit()
