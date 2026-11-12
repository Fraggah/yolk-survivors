extends SceneTree
func _initialize(): call_deferred("verify")
func enemy_at(arena, point):
	var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	enemy.stats=enemy.stats.duplicate()
	enemy.stats.block_chance=0
	arena.add_child(enemy)
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.health_component.current_health=100
	enemy.health_component.max_health=100
	enemy.global_position=point
	return enemy
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	var item=load("res://resources/items/weapons/chili/jalapeno/item_jalapeno.tres")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=item
	assert(arena.shop_panel.shop_items.has(item))
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	var player=global.player
	player.set_process(false)
	var pepper=player.current_weapons[0]
	pepper.set_process(false)
	var behaviour=pepper.weapon_behaviour
	var radius=item.stats.max_range*global.GAME_ENTITY_SCALE
	var horizontal=enemy_at(arena,player.global_position+Vector2(radius*0.8,0))
	var vertical=enemy_at(arena,player.global_position+Vector2(0,radius*0.8))
	var inside=enemy_at(arena,player.global_position+Vector2(0,radius*0.3))
	assert(pepper.can_use_weapon())
	pepper.use_weapon()
	assert(horizontal.health_component.current_health==97)
	assert(inside.health_component.current_health==97)
	assert(vertical.health_component.current_health==100, "Oval, not circular damage")
	assert(not pepper.can_use_weapon())
	assert(pepper.damage_record.wave_damage==6)
	player.global_position+=Vector2(radius*3.0,0)
	behaviour._process(0.1)
	assert(behaviour.aura.global_position==player.global_position)
	assert(is_equal_approx(behaviour.surface.size.y/behaviour.surface.size.x,0.6))
	var elapsed=behaviour.elapsed
	global.game_paused=true
	behaviour._process(1)
	assert(behaviour.elapsed==elapsed)
	global.game_paused=false
	behaviour.execute_attack()
	assert(horizontal.health_component.current_health==97, "Aura follows player, not previous location")
	player.add_weapon(item)
	assert(player.current_weapons.size()==2)
	var second=player.current_weapons[1]
	second.set_process(false)
	assert(not second.can_use_weapon(), "Extra jalapeno contributes damage without independent attacks")
	second.weapon_behaviour.execute_attack()
	assert(second.cooldown_timer.is_stopped())
	player.prepare_for_new_wave()
	assert(behaviour.elapsed==0 and pepper.cooldown_timer.is_stopped())
	print("PASS Jalapeño oval damage, player-centered moving aura, cooldown, pause, copies, damage tracking and wave reset")
	quit()
