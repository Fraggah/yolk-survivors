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
	for old in player.current_weapons: old.queue_free()
	player.current_weapons.clear()
	var base=load("res://resources/items/weapons/chili/scotch_bonnet/item_scotch_bonnet.tres")
	var weapon=null
	for copies in range(1,4):
		player.add_weapon(base)
		weapon=player.current_weapons[0]
		for equipped in player.current_weapons: equipped.set_process(false)
		var reach=weapon.weapon_behaviour.get_mine_spawn_radius()
		assert(is_equal_approx(reach,550*global.GAME_ENTITY_SCALE*(1.0+0.2*(copies-1))))
	player.global_position=player.arena_environment.movement_bounds.get_center()
	seed(1589)
	var farthest=0.0
	for index in 32:
		weapon.weapon_behaviour.execute_attack()
		var mine=weapon.weapon_behaviour.owned.back().get_ref()
		mine.set_process(false)
		var offset=mine.global_position-player.global_position
		offset.y/=mine.settings.area_y_ratio
		assert(offset.length()<=weapon.weapon_behaviour.get_mine_spawn_radius()+0.01)
		farthest=maxf(farthest,offset.length())
	assert(farthest>550*global.GAME_ENTITY_SCALE,"Extra copies allow a wider placement area")
	var mine=weapon.weapon_behaviour.owned.back().get_ref()
	assert(mine.effect_material==null and mine.surface==null,"No idle aura or glow")
	var sprite=mine.mine_sprite
	assert(sprite.region_enabled and sprite.texture==mine.settings.mine_texture)
	assert(sprite.region_rect==mine.settings.mine_texture_rect,"Dedicated sprite is shown intact, without cutting the body in half")
	assert(sprite.offset.y==-sprite.region_rect.size.y,"Cut edge is planted on the floor")
	assert(sprite.material==null)
	assert(mine.settings.mine_visual_width>30)
	var initial_scale=sprite.scale
	mine._process(0.15)
	assert(sprite.scale!=initial_scale,"Mine squashes and stretches")
	var target=enemy_at(mine.global_position)
	var outside=enemy_at(mine.global_position+Vector2(0,mine.radius))
	var hp=target.health_component.current_health
	mine._process(mine.settings.arming_time*0.4)
	assert(not mine.detonated and target.health_component.current_health==hp)
	mine._process(mine.settings.arming_time)
	assert(mine.detonated and target.health_component.current_health<hp)
	assert(not sprite.visible and mine.mine_visual.blast.visible)
	assert(outside.health_component.current_health==10000)
	var after=target.health_component.current_health
	mine._process(0.02)
	assert(target.health_component.current_health==after,"Explosion damages only once")
	global.game_paused=true
	var time=mine.elapsed
	mine._process(1)
	assert(mine.elapsed==time)
	global.game_paused=false
	assert(mine.settings.wave_duration<=0.2)
	mine._process(mine.settings.wave_duration)
	assert(mine.is_queued_for_deletion(),"Blast is short, not a slow wave")
	var tier=base
	var previous_damage=0.0
	var previous_radius=0.0
	var previous_cooldown=INF
	while tier:
		assert(tier.stats.damage>previous_damage and tier.stats.spicy_pattern.radius>previous_radius and tier.stats.cooldown<previous_cooldown)
		previous_damage=tier.stats.damage
		previous_radius=tier.stats.spicy_pattern.radius
		previous_cooldown=tier.stats.cooldown
		tier=tier.upgrade_to
	var removed=player.current_weapons.pop_back()
	removed.queue_free()
	assert(is_equal_approx(weapon.weapon_behaviour.get_mine_spawn_radius(),550*global.GAME_ENTITY_SCALE*1.2))
	arena.queue_free()
	await process_frame
	print("PASS Scotch Bonnet: wide local placement, copy growth/removal, buried half sprite, no halo, squash/stretch, fast single oval blast, pause and tier progression")
	quit()
