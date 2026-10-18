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
	var item=load("res://resources/items/weapons/spicy/item_jalapeno.tres")
	for old in player.current_weapons: old.queue_free()
	player.current_weapons.clear()
	player.add_weapon(item)
	player.add_weapon(item.upgrade_to.upgrade_to)
	player.add_weapon(item.upgrade_to)
	var amounts=[]
	var total=0.0
	for equipped in player.current_weapons:
		equipped.set_process(false)
		equipped.data=equipped.data.duplicate()
		equipped.data.stats=equipped.data.stats.duplicate()
		equipped.data.stats.crit_chance=0
		equipped.weapon_behaviour._process(0.1)
		var amount=equipped.data.get_effective_damage(player.stats)
		amounts.append(amount)
		total+=amount
	var first=player.current_weapons[0]
	var second=player.current_weapons[1]
	var third=player.current_weapons[2]
	assert(first.weapon_behaviour.aura.visible)
	assert(not second.weapon_behaviour.aura.visible and not third.weapon_behaviour.aura.visible)
	assert(first.can_use_weapon() and not second.can_use_weapon() and not third.can_use_weapon())
	var radius=first.data.stats.max_range*global.GAME_ENTITY_SCALE*player.stats.get_area_radius_multiplier()
	var target=enemy_at(player.global_position+Vector2(radius*0.8,0))
	var outside=enemy_at(player.global_position+Vector2(0,radius*0.8))
	var events=[0]
	global.on_create_damage_text.connect(func(victim,_hit):
		if victim==target: events[0]+=1
	)
	var hp=target.health_component.current_health
	first.weapon_behaviour.execute_attack()
	assert(is_equal_approx(target.health_component.current_health,hp-total))
	assert(outside.health_component.current_health==10000)
	assert(events[0]==1, "One hit and feedback event carries the combined damage")
	for i in 3:
		assert(is_equal_approx(player.current_weapons[i].damage_record.wave_damage,amounts[i]))
	second.weapon_behaviour.execute_attack()
	third.weapon_behaviour.execute_attack()
	assert(events[0]==1 and is_equal_approx(target.health_component.current_health,hp-total))
	# Only the higher tiers reach the outer bands, regardless of equipment order.
	var scale=global.GAME_ENTITY_SCALE*player.stats.get_area_radius_multiplier()
	var middle=enemy_at(player.global_position+Vector2((first.data.stats.max_range+third.data.stats.max_range)*0.5*scale,0))
	var outer=enemy_at(player.global_position+Vector2((third.data.stats.max_range+second.data.stats.max_range)*0.5*scale,0))
	var before_records=[]
	for equipped in player.current_weapons: before_records.append(equipped.damage_record.wave_damage)
	first.weapon_behaviour.execute_attack()
	assert(is_equal_approx(middle.health_component.current_health,10000-amounts[1]-amounts[2]))
	assert(is_equal_approx(outer.health_component.current_health,10000-amounts[1]))
	assert(is_equal_approx(first.damage_record.wave_damage-before_records[0],amounts[0]))
	assert(is_equal_approx(second.damage_record.wave_damage-before_records[1],amounts[1]*3))
	assert(is_equal_approx(third.damage_record.wave_damage-before_records[2],amounts[2]*2))
	assert(is_equal_approx(first.weapon_behaviour.surface.size.x,second.data.stats.max_range*scale*2))
	# Removing the first copy leaves a single aura and re-evaluates contributions.
	player.current_weapons.erase(first)
	first.queue_free()
	player.refresh_equipment_modifiers()
	second.weapon_behaviour._process(0.1)
	third.weapon_behaviour._process(0.1)
	assert(second.weapon_behaviour.aura.visible and not third.weapon_behaviour.aura.visible)
	assert(second.can_use_weapon() and not third.can_use_weapon())
	var before=target.health_component.current_health
	var expected=second.data.get_effective_damage(player.stats)+third.data.get_effective_damage(player.stats)
	second.weapon_behaviour.execute_attack()
	assert(is_equal_approx(target.health_component.current_health,before-expected))
	player.prepare_for_new_wave()
	assert(second.weapon_behaviour.elapsed==0)
	arena.queue_free()
	await process_frame
	print("PASS Shared jalapeno I+III+II: one visible aura, summed single hit, per-copy damage, oval and leader transfer")
	quit()
