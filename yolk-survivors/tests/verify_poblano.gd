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
	var item=load("res://resources/items/weapons/chili/poblano/item_poblano.tres").duplicate()
	item.stats=item.stats.duplicate(true)
	item.stats.crit_chance=0
	var weapon=item.scene.instantiate()
	player.add_child(weapon)
	weapon.setup_weapon(item)
	weapon.set_process(false)
	weapon.weapon_behaviour.execute_attack()
	var effect=weapon.weapon_behaviour.owned[0].get_ref()
	effect.set_process(false)
	player.global_position=Vector2.ZERO
	effect.orbit_previous_center=player.global_position+effect.settings.orbit_center_offset*global.GAME_ENTITY_SCALE
	effect.orbit_angle=0
	effect._process(0)
	assert(effect.global_position.y<player.global_position.y,"Orbit is lifted around the body")
	assert(effect.settings.radius==50,"Contact footprint is enlarged")
	# Hit in the middle of a half-turn even though neither endpoint touches it.
	var center=effect.orbit_previous_center
	var target=enemy_at(center+Vector2(0,effect.orbit_radius*effect.settings.area_y_ratio))
	var shape=target.get_node("HurtboxComponent/CollisionShape2D")
	target.global_position+=center+Vector2(0,effect.orbit_radius*effect.settings.area_y_ratio)-shape.global_position
	var outside=enemy_at(center+Vector2(0,500))
	effect._process(PI/effect.settings.orbit_speed)
	assert(is_equal_approx(target.health_component.current_health,10000-item.get_effective_damage(player.stats)),"Swept contact catches the arc between frames")
	assert(outside.health_component.current_health==10000)
	# A stationary overlap hits immediately, then respects its per-enemy interval.
	var touching=enemy_at(effect.global_position)
	touching.global_position+=effect.global_position-touching.get_node("HurtboxComponent/CollisionShape2D").global_position
	effect._process(0)
	var hp=touching.health_component.current_health
	assert(hp<10000)
	effect._process(0)
	assert(touching.health_component.current_health==hp)
	# Attack speed changes the existing orbiter immediately, not just its spawn timer.
	player.stats.attack_speed=0
	var angle=effect.orbit_angle
	effect._process(0.1)
	var normal=wrapf(effect.orbit_angle-angle,0,TAU)
	player.stats.attack_speed=100
	angle=effect.orbit_angle
	effect._process(0.1)
	assert(is_equal_approx(wrapf(effect.orbit_angle-angle,0,TAU),normal*2))
	player.stats.attack_speed=-100
	angle=effect.orbit_angle
	effect._process(0.1)
	assert(is_equal_approx(wrapf(effect.orbit_angle-angle,0,TAU),normal*0.5))
	var tier=load("res://resources/items/weapons/chili/poblano/item_poblano.tres")
	var previous_speed=0.0
	while tier:
		assert(tier.stats.spicy_pattern.orbit_speed>previous_speed)
		previous_speed=tier.stats.spicy_pattern.orbit_speed
		tier=tier.upgrade_to
	global.game_paused=true
	var point=effect.global_position
	angle=effect.orbit_angle
	effect._process(1)
	assert(effect.global_position==point and effect.orbit_angle==angle)
	global.game_paused=false
	player.global_position+=Vector2(30,20)
	effect._process(0)
	assert(effect.orbit_previous_center==player.global_position+effect.settings.orbit_center_offset*global.GAME_ENTITY_SCALE)
	weapon.weapon_behaviour.reset_attack()
	assert(effect.is_queued_for_deletion() and weapon.sprite_2d.visible)
	arena.queue_free()
	await process_frame
	print("PASS Poblano: raised orbit, enlarged hurtbox contact, swept arc, per-enemy cooldown, attack speed, tiers, pause and cleanup")
	quit()
