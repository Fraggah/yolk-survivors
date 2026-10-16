extends SceneTree
func _initialize(): call_deferred("verify")
func close(a, b): assert(is_equal_approx(a, b), "%s != %s" % [a,b])
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=load("res://resources/items/weapons/spicy/item_bell_pepper.tres")
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	var player=global.player
	player.set_process(false)
	var stats=player.stats
	var pepper=global.main_weapon_selected
	close(stats.final_multiplier("damage_percent"),0.9)
	player.add_weapon(pepper)
	close(stats.final_multiplier("damage_percent"),0.8)
	close(stats.luck,stats.unmodified_stat("luck")*1.2)
	stats.apply_stat_change("damage_percent",100)
	var raw_damage=stats.unmodified_stat("damage_percent")
	close(stats.damage_percent,((1+raw_damage/100)*0.8-1)*100)
	close(pepper.get_effective_damage(stats),pepper.stats.damage*(1+raw_damage/100)*0.8)
	for i in 5: player.refresh_equipment_modifiers()
	close(stats.damage_percent,((1+raw_damage/100)*0.8-1)*100)
	stats.apply_stat_change("luck",10)
	close(stats.luck,stats.unmodified_stat("luck")*1.2)
	var removed=player.current_weapons.pop_back()
	removed.queue_free()
	player.refresh_equipment_modifiers()
	close(stats.final_multiplier("damage_percent"),0.9)
	for weapon in player.current_weapons: weapon.queue_free()
	player.current_weapons.clear()
	player.refresh_equipment_modifiers()
	close(stats.damage_percent,raw_damage)
	# Final effective metrics work from zero bonus and include intrinsic weapon crit.
	stats.set_final_modifiers({"area_of_effect":20,"fire_tick_speed":20,"attack_speed":10,"critical_chance":-20,"critical_multiplier":-5,"slow_strength":10,"effect_duration":10,"knockback":-10})
	close(stats.get_area_radius_multiplier(),sqrt(1.2))
	close(stats.get_fire_interval(1),1/1.2)
	close(pepper.get_effective_cooldown(stats),pepper.stats.cooldown/1.1)
	close(pepper.get_effective_critical_chance(stats),pepper.stats.crit_chance*0.8)
	close(stats.effective_slow(0.7),0.67)
	close(stats.effect_duration_multiplier(),1.1)
	var hit=load("res://scenes/components/hitbox_component.gd").new()
	hit.setup(1,false,10,player)
	close(hit.knockback_power,9)
	hit.free()
	stats.set_final_modifiers({})
	# Spawn scaling is the final layer after wave/profile growth.
	var profile=load("res://resources/wave/enemies/chaser_mid.tres")
	var enemy=profile.scene.instantiate()
	var base_speed=enemy.stats.speed
	stats.set_final_modifiers({"enemy_speed":10,"enemy_count":10})
	arena.spawner.prepare_enemy(enemy,profile)
	close(enemy.stats.speed,base_speed*arena.spawner.current_wave_data.speed_multiplier*1.1)
	enemy.free()
	stats.set_final_modifiers({})
	player.add_weapon(load("res://resources/items/weapons/spicy/item_carolina_reaper.tres"))
	player.add_weapon(load("res://resources/items/weapons/spicy/item_carolina_reaper.tres"))
	close(stats.final_multiplier("damage_percent"),1.1)
	close(player.health_drain_per_second,2)
	stats.armor=1000
	stats.block_chance=100
	player.health_component.current_health=20
	global.game_paused=true
	player._process(1)
	close(player.health_component.current_health,20)
	global.game_paused=false
	player._process(1)
	close(player.health_component.current_health,18)
	player.prepare_for_new_wave()
	close(player._drain_elapsed,0)
	# Every catalogue entry carries its editable modifier configuration.
	for id in ["bell_pepper","jalapeno","habanero","cayenne","poblano","carolina_reaper","ghost_pepper","aji_amarillo","scotch_bonnet","rocoto"]:
		var item=load("res://resources/items/weapons/spicy/item_%s.tres" % id)
		assert(not item.final_stat_modifiers.is_empty())
		assert(not "pending" in item.get_description())
	print("PASS spicy final modifiers: additive copies, effective totals, stable recalculation, removal, statuses and paused HP cost")
	quit()
