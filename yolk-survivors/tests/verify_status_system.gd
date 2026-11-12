extends SceneTree
func _initialize(): call_deferred("verify")
func enemy_at(arena, point):
	var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	enemy.stats=enemy.stats.duplicate()
	enemy.stats.block_chance=0
	arena.add_child(enemy)
	enemy.global_position=point
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.health_component.max_health=1000
	enemy.health_component.current_health=1000
	return enemy
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=load("res://resources/items/weapons/range/knifer/item_knifer_1.tres")
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	var player=global.player
	player.set_process(false)
	for weapon in player.current_weapons: weapon.set_process(false)
	player.stats.block_chance=100
	player.stats.block_effectiveness=50
	player.stats.armor=0
	player.health_component.max_health=1000
	player.health_component.current_health=1000
	var contact=load("res://scenes/components/hitbox_component.tscn").instantiate()
	arena.add_child(contact)
	contact.setup(10,false,0,null)
	assert(player.receive_hit(contact))
	assert(player.health_component.current_health==995)
	player.stats.armor=10
	player.receive_hit(contact)
	assert(is_equal_approx(player.health_component.current_health,991.875))
	player.stats.block_chance=0
	player.stats.armor=0
	player.stats.effects=100
	player.stats.fire_tick_speed=100
	var fire=load("res://resources/statuses/fueguito_fire.tres").duplicate()
	fire.damage=2
	fire.duration=1
	fire.tick_interval=0.5
	var victim=enemy_at(arena,Vector2(1000,0))
	contact.setup(1,false,0,player)
	contact.status_effects.assign([fire])
	assert(victim.receive_hit(contact))
	var burns=victim.get_children().filter(func(node): return node.get_script()==load("res://effects/fire_status.gd"))
	assert(burns.size()==1)
	var burn=burns[0]
	burn.set_process(false)
	assert(is_equal_approx(burn.interval,0.25) and is_equal_approx(burn.hit.base_damage,4))
	global.game_paused=true
	burn._process(0.5)
	assert(victim.health_component.current_health==999)
	global.game_paused=false
	for tick in 4: burn._process(0.25)
	assert(victim.health_component.current_health==983 and burn.is_queued_for_deletion())
	var near=enemy_at(arena,Vector2(1090,0))
	var far=enemy_at(arena,Vector2(1180,0))
	var electric=load("res://resources/statuses/electricity_default.tres").duplicate()
	electric.chain_radius=65 # 130 world units at current entity scale.
	contact.status_effects.assign([electric])
	assert(victim.receive_hit(contact))
	assert(victim.health_component.current_health==976)
	assert(near.health_component.current_health==994)
	assert(far.health_component.current_health==1000, "Secondary target cannot extend the chain")
	assert(is_equal_approx(victim.get_status_movement_multiplier(),1.0))
	assert(is_equal_approx(victim.status_controller.lightning_left,3))
	global.game_paused=true
	victim.status_controller._process(2)
	assert(is_equal_approx(victim.status_controller.lightning_left,3))
	global.game_paused=false
	victim.status_controller._process(3)
	assert(victim.get_status_movement_multiplier()==1)
	victim.status_controller.add_slow(0.5,1.0)
	victim.status_controller.add_slow(0.2,0.1)
	victim.status_controller.add_slow(0.5,0.5)
	assert(victim.status_controller.slows.size()==2 and victim.get_status_movement_multiplier()==0.2)
	victim.status_controller._process(0.11)
	assert(victim.get_status_movement_multiplier()==0.5,"Cached movement restores the surviving weaker slow")
	victim.status_controller.clear()
	assert(victim.get_status_movement_multiplier()==1)
	# Enemy effects work on player and do not inherit player's offensive Effects stat.
	contact.setup(1,false,0,near)
	contact.status_effects.assign([electric])
	var hp=player.health_component.current_health
	player.receive_hit(contact)
	assert(player.health_component.current_health==hp-4)
	assert(is_equal_approx(player.get_status_movement_multiplier(),1.0))
	player.status_controller.clear()
	contact.status_effects.assign([fire])
	player.receive_hit(contact)
	var player_burns=player.get_children().filter(func(node): return node.get_script()==load("res://effects/fire_status.gd"))
	assert(player_burns.size()==1)
	player.hit_invulnerability_left=0.5
	hp=player.health_component.current_health
	player_burns[0]._process(0.5)
	assert(player.health_component.current_health==hp-2)
	player.stats.area_of_effect=300
	assert(player.stats.get_area_radius_multiplier()==2)
	var item=load("res://resources/items/weapons/chili/bell_pepper/item_bell_pepper.tres")
	assert(item.get_effective_damage(player.stats)==10)
	player.stats.critical_multiplier=50
	assert(is_equal_approx(global.main_weapon_selected.get_effective_critical_multiplier(player.stats),3))
	var ids={}
	for upgrade in arena.upgrade_panel.upgrades:
		assert(upgrade.stat_id!="fire_tick_speed")
		ids[upgrade.stat_id]=ids.get(upgrade.stat_id,0)+1
	for stat in ["area_of_effect","critical_multiplier","block_effectiveness","effects"]: assert(ids[stat]==4)
	var passive=load("res://resources/items/passives/item_passive.gd").new()
	passive.add_stats_id="fire_tick_speed"
	passive.add_value=25
	passive.on_hit_effects.assign([electric])
	passive.apply_passive_values()
	assert(player.stats.fire_tick_speed==25 and player.stats.attack_effects.has(electric))
	assert(global.main_player_selected.attack_effects.is_empty(), "Run items must not mutate the character resource")
	player.immobilize_for(1,player.stats)
	assert(player.get_status_movement_multiplier()==0)
	player.prepare_for_new_wave()
	assert(player.get_status_movement_multiplier()==1)
	var hazard=load("res://scenes/units/enemies/enemy_fueguito.tscn").instantiate()
	arena.add_child(hazard)
	assert(hazard.contact_hitbox.status_effects.has(load("res://resources/statuses/fueguito_fire.tres")))
	global.game_paused=true
	arena.clear_arena()
	await process_frame
	assert(get_nodes_in_group("projectiles").is_empty())
	print("PASS partial block/armor, Effects damage/duration, fire ticks/player/enemy/pause, one-hop electricity, AoE, crit multiplier, item-only tick speed, upgrades and wave cleanup")
	quit()
