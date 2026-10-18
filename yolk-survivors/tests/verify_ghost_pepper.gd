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
	var item=load("res://resources/items/weapons/spicy/item_ghost_pepper.tres").duplicate()
	item.stats=item.stats.duplicate(true)
	item.stats.crit_chance=0
	var weapon=item.scene.instantiate()
	player.add_child(weapon)
	weapon.setup_weapon(item)
	weapon.set_process(false)
	var behaviour=weapon.weapon_behaviour
	var config=item.stats.spicy_pattern
	player.global_position=player.arena_environment.movement_bounds.get_center()
	var reach=item.stats.max_range*global.GAME_ENTITY_SCALE
	seed(4821)
	var nearest=INF
	var farthest=0.0
	for index in 64:
		behaviour.execute_attack()
		var cloud=behaviour.owned.back().get_ref()
		cloud.set_process(false)
		var offset=cloud.global_position-player.global_position
		offset.y/=config.area_y_ratio
		assert(offset.length()<=reach+0.01,"Cloud appears within the local player oval")
		nearest=minf(nearest,offset.length())
		farthest=maxf(farthest,offset.length())
	assert(nearest<reach*0.35 and farthest>reach*0.75,"Spawn samples the local area, not one fixed distance")
	assert(behaviour.owned.size()==config.maximum_active)
	player.global_position+=Vector2(100,40)
	behaviour.execute_attack()
	var effect=behaviour.owned.back().get_ref()
	effect.set_process(false)
	var offset=effect.global_position-player.global_position
	offset.y/=config.area_y_ratio
	assert(offset.length()<=reach+0.01,"New clouds follow the current player position")
	assert(is_equal_approx(effect.radius,175*global.GAME_ENTITY_SCALE))
	assert(effect.cloud_visual.texture==config.cloud_texture)
	assert(effect.cloud_visual.puffs.multimesh.instance_count==config.cloud_layer_count)
	assert(effect.surface==null and effect.effect_material==null)
	assert(config.cloud_layer_count>=12 and config.cloud_puff_max_scale<0.6,"Fog is built from many small puffs, without a full-size dominant sprite")
	assert(effect.cloud_visual.puff_origins.size()==config.cloud_layer_count)
	var other=load("res://effects/ghost_cloud_visual.gd").new()
	other.configure(config,effect.radius,config.lifetime)
	assert(other.puff_origins!=effect.cloud_visual.puff_origins,"Separate clouds have different compositions")
	other.free()
	var target=enemy_at(effect.global_position)
	var outside=enemy_at(effect.global_position+Vector2(0,effect.radius*0.85))
	effect._process(0.1)
	assert(target.health_component.current_health<10000)
	assert(outside.health_component.current_health==10000)
	var point=effect.global_position
	player.global_position+=Vector2(30,0)
	effect._process(0.1)
	assert(effect.global_position==point,"Existing clouds remain at their spawn location")
	global.game_paused=true
	var time=effect.cloud_visual.elapsed
	effect._process(1)
	assert(effect.cloud_visual.elapsed==time)
	global.game_paused=false
	player.global_position=player.arena_environment.clamp_position(player.arena_environment.movement_bounds.end)
	for index in 20:
		behaviour.execute_attack()
		var cloud=behaviour.owned.back().get_ref()
		cloud.set_process(false)
		assert(cloud.global_position.is_equal_approx(player.arena_environment.clamp_position(cloud.global_position)))
		var relative=cloud.global_position-player.global_position
		relative.y/=config.area_y_ratio
		assert(relative.length()<=reach+0.01)
	behaviour.reset_attack()
	assert(behaviour.owned.is_empty())
	arena.queue_free()
	await process_frame
	print("PASS Ghost Pepper: local random oval, moving player, arena edges, larger area, cloud sprite layers, ground damage, pause and cleanup")
	quit()
