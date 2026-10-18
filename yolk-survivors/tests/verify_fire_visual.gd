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
	var target=enemy_at(arena,player.global_position+Vector2(150,0))
	var template=load("res://scenes/components/hitbox_component.tscn").instantiate()
	arena.add_child(template)
	template.setup(1,false,0,player)
	var effect=load("res://resources/status_effect.gd").new()
	effect.duration=2
	var fire=load("res://effects/fire_status.gd")
	for unit in [target,player]:
		fire.apply(unit,"BurnA",template,effect)
		fire.apply(unit,"BurnB",template,effect)
		var visual=unit.get_node("FireVisual")
		visual.set_process(false)
		visual._process(0.1)
		assert(visual.sources.size()==2)
		assert(visual.settings.coverage>1 and visual.settings.ember_count>0)
		assert(visual.flames.multimesh.instance_count==visual.settings.flame_count)
		assert(visual.flames.get_parent()==unit.sprite)
		assert(visual.background_flame.get_parent()==unit.sprite)
		assert(unit.sprite.z_index == visual.background_flame.z_index and visual.flames.z_index == 0)
		assert(visual.background_flame.get_index() < visual.flames.get_index())
		assert(not visual.is_set_as_top_level())
		assert(visual.background_flame.multimesh.instance_count==1)
		assert(visual.settings.background_flame_opacity < visual.settings.flame_opacity)
		var sprite_position=unit.sprite.position
		var sprite_scale=unit.sprite.scale
		var sprite_rotation=unit.sprite.rotation
		var anchor=Vector2(5,-10)
		var before_hop=visual.flames.to_global(anchor)
		unit.sprite.position+=Vector2(10,-20)
		unit.sprite.scale*=Vector2(0.8,1.2)
		unit.sprite.rotation+=0.2
		assert(not visual.flames.to_global(anchor).is_equal_approx(before_hop))
		assert(visual.flames.to_global(anchor).is_equal_approx(unit.sprite.to_global(visual.flames.transform*anchor)), "Flames follow animated transform immediately, without a process-frame lag")
		unit.sprite.position=sprite_position
		unit.sprite.scale=sprite_scale
		unit.sprite.rotation=sprite_rotation
		var size=visual.surface.size
		assert(size.x>0 and size.y>0)
		unit.sprite.scale.x*=-1
		visual._process(0.1)
		assert(visual.surface.size.is_equal_approx(size), "Facing does not mirror or shrink fire")
		var time=visual.elapsed
		global.game_paused=true
		visual._process(1)
		assert(visual.elapsed==time)
		global.game_paused=false
		unit.get_node("BurnA").remaining=0
		visual._process(0.1)
		assert(visual.sources.size()==1 and not visual.is_queued_for_deletion())
		unit.get_node("BurnB").remaining=0
		visual._process(0.3)
		assert(visual.is_queued_for_deletion())
		fire.apply(unit,"BurnC",template,effect)
		assert(unit.get_node("FireVisual")!=visual, "Reapplication during fade expiry creates fresh visual")
	for node in get_nodes_in_group("projectiles"): node.queue_free()
	await process_frame
	assert(get_nodes_in_group("projectiles").is_empty())
	arena.queue_free()
	await process_frame
	print("PASS shared fire visuals on player/enemy, two sources, facing, pause, expiry, reapply and wave cleanup")
	quit()
