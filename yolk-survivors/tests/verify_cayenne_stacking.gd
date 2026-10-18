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
	var item=load("res://resources/items/weapons/spicy/item_cayenne.tres")
	# Replace the starting weapon using the normal equipment path.
	for old in player.current_weapons: old.queue_free()
	player.current_weapons.clear()
	player.add_weapon(item)
	player.add_weapon(item.upgrade_to)
	var first=player.current_weapons[0]
	var second=player.current_weapons[1]
	first.set_process(false)
	second.set_process(false)
	var primary=first.weapon_behaviour
	var follower=second.weapon_behaviour
	assert(not follower.can_execute_attack())
	primary.execute_attack()
	follower.execute_attack()
	player.global_position+=Vector2(100,0)
	primary.execute_attack()
	follower.execute_attack()
	assert(primary.owned.size()==1 and follower.owned.is_empty(), "Only one shared trail is spawned")
	var patch=primary.owned[0].get_ref()
	patch.set_process(false)
	patch.hit.critical_chance=0
	var first_damage=item.get_effective_damage(player.stats)
	var second_damage=second.data.get_effective_damage(player.stats)
	assert(is_equal_approx(patch.hit.base_damage,first_damage+second_damage))
	var target=enemy_at(patch.global_position)
	var hp=target.health_component.current_health
	patch._process(0.01)
	assert(is_equal_approx(target.health_component.current_health,hp-first_damage-second_damage))
	assert(is_equal_approx(first.damage_record.wave_damage,first_damage))
	assert(is_equal_approx(second.damage_record.wave_damage,second_damage))
	var burns=target.get_children().filter(func(node): return node.get_script()==load("res://effects/fire_status.gd"))
	assert(burns.size()==1, "One burn combines both cayennes")
	var burn=burns[0]
	burn.set_process(false)
	var expected_fire=(item.on_hit_effects[0].damage+second.data.on_hit_effects[0].damage)*player.stats.get_effect_multiplier()*player.stats.final_multiplier("damage_percent")
	assert(is_equal_approx(burn.hit.base_damage,expected_fire))
	burn.hit.critical_chance=0
	burn._process(burn.interval)
	assert(is_equal_approx(first.damage_record.wave_damage,first_damage+expected_fire*0.5))
	assert(is_equal_approx(second.damage_record.wave_damage,second_damage+expected_fire*0.5))
	# A later shared patch refreshes the existing burn instead of adding another.
	var next=load("res://effects/spicy_pattern_effect.gd").new()
	next.configure(first,item.stats.spicy_pattern,target.global_position)
	arena.add_child(next)
	next.set_process(false)
	next.hit.critical_chance=0
	next._process(0.01)
	assert(target.get_children().filter(func(node): return node.get_script()==load("res://effects/fire_status.gd")).size()==1)
	assert(target.get_node("FireVisual").sources.size()==1)
	# Each patch keeps all radii and lifetimes, independent of the first copy.
	assert(second.data.stats.spicy_pattern.lifetime>first.data.stats.spicy_pattern.lifetime)
	var scale=global.GAME_ENTITY_SCALE*player.stats.get_area_radius_multiplier()
	var outer_target=enemy_at(patch.global_position+Vector2((first.data.stats.spicy_pattern.radius+second.data.stats.spicy_pattern.radius)*0.5*scale,0))
	patch._damage(patch.radius)
	assert(is_equal_approx(outer_target.health_component.current_health,10000-second_damage))
	assert(is_equal_approx(patch.hit.base_damage,second_damage))
	var outer_burn=outer_target.get_children().filter(func(node): return node.get_script()==load("res://effects/fire_status.gd"))[0]
	outer_burn.set_process(false)
	assert(outer_burn.contributions.size()==1)
	patch.elapsed=first.data.stats.spicy_pattern.lifetime*player.stats.effect_duration_multiplier()+0.01
	var before_hp=target.health_component.current_health
	patch._damage(patch.radius)
	assert(is_equal_approx(target.health_component.current_health,before_hp-second_damage))
	assert(not patch.is_queued_for_deletion())
	patch._update_visual()
	assert(patch.trail_visual.coverage_entries.size()==2)
	# Burn contributions expire independently and still share a single node/clock.
	burn.contributions[first.get_instance_id()].remaining=0.1
	burn.contributions[second.get_instance_id()].remaining=1.0
	burn._refresh_contributions()
	burn.tick_left=0.2
	burn._process(0.2)
	assert(burn.contributions.size()==1 and burn.contributions.has(second.get_instance_id()))
	assert(is_equal_approx(burn.hit.base_damage,expected_fire*0.5))
	patch.elapsed=patch.trail_lifetime-0.01
	patch._process(0.02)
	assert(patch.is_queued_for_deletion())
	# Removing the leader transfers future trail creation to the surviving weapon.
	player.current_weapons.erase(first)
	first.queue_free()
	player.refresh_equipment_modifiers()
	assert(follower.can_execute_attack())
	follower.execute_attack()
	player.global_position+=Vector2(100,0)
	follower.execute_attack()
	assert(follower.owned.size()==1)
	var surviving=follower.owned[0].get_ref()
	assert(is_equal_approx(surviving.hit.base_damage,second.data.get_effective_damage(player.stats)))
	arena.queue_free()
	await process_frame
	print("PASS Shared cayenne: one trail, mixed-tier summed damage, one burn, per-copy records and leader removal")
	quit()
