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
	var item=load("res://resources/items/weapons/spicy/item_carolina_reaper.tres").duplicate()
	item.stats=item.stats.duplicate(true)
	item.stats.crit_chance=0
	var weapon=item.scene.instantiate()
	player.add_child(weapon)
	weapon.setup_weapon(item)
	weapon.set_process(false)
	var effect=load("res://effects/spicy_pattern_effect.gd").new()
	effect.configure(weapon,item.stats.spicy_pattern,Vector2(0,200))
	arena.add_child(effect)
	effect.set_process(false)
	effect.velocity=Vector2.ZERO
	var base=enemy_at(effect.global_position)
	var upper=enemy_at(effect.global_position-Vector2(0,effect.radius*4))
	var outside=enemy_at(effect.global_position+Vector2(effect.radius*2.5,0))
	var fringe=enemy_at(effect.global_position+Vector2(effect.radius*1.45,0))
	effect._process(0.2)
	assert(base.health_component.current_health<10000 and base.has_node("FireVisual"))
	assert(upper.health_component.current_health==10000 and not upper.has_node("FireVisual"),"Upper column is purely visual")
	assert(outside.health_component.current_health==10000,"Ground footprint stays confined to its oval")
	assert(fringe.health_component.current_health<10000,"Impact extends a little outside the widest painted column")
	var crossing=enemy_at(effect.global_position+Vector2(effect.radius*2.5,0))
	effect._process(0.01)
	assert(crossing.health_component.current_health==10000)
	crossing.global_position.x-=effect.radius*5
	effect._process(0.01)
	assert(crossing.health_component.current_health<10000,"Fast crossing between damage ticks still hits")
	var crossed_health=crossing.health_component.current_health
	crossing.global_position=effect.global_position
	effect._process(0.01)
	assert(crossing.health_component.current_health==crossed_health,"Per-enemy cooldown prevents frame-rate-dependent damage")
	var moving=enemy_at(effect.global_position+Vector2(effect.radius*2.5,0))
	effect._process(0.01)
	var before_move=effect.global_position
	effect.global_position.x+=effect.radius*5
	effect._update_column_contacts(before_move)
	assert(moving.health_component.current_health<10000,"Moving column also sweeps its contact area")
	effect.global_position=before_move
	assert(effect.surface==null and effect.effect_material==null)
	var visual=effect.column_visual
	assert(is_equal_approx(visual._width_at_height(0),1.0),"Tornado keeps the same ground width and damage footprint")
	var flare_height=effect.settings.column_flare_height*global.GAME_ENTITY_SCALE
	assert(visual._width_at_height(flare_height*0.5)>1.0)
	assert(is_equal_approx(visual._width_at_height(flare_height),effect.settings.column_top_width_multiplier))
	assert(visual.fill_material.get_shader_parameter("top_width_multiplier")==effect.settings.column_top_width_multiplier)
	assert(visual.heat_material.get_shader_parameter("top_width_multiplier")==effect.settings.column_top_width_multiplier)
	assert(visual.rings.multimesh.instance_count>2)
	assert(visual.ring_texture==effect.settings.column_ring_texture, "Column uses the approved painted ring sprite")
	assert(visual.ring_material.get_shader_parameter("ring_texture")==visual.ring_texture)
	assert(visual.fill_sprite.texture==effect.settings.column_fill_texture)
	assert(visual.fill_material.get_shader_parameter("opacity")>=0.95,"Column body is nearly opaque")
	assert(effect.settings.column_ring_height_scale>1.0)
	assert(visual.contact_sprite.texture==effect.settings.column_contact_texture)
	assert(visual.contact_glow.texture==visual.contact_sprite.texture)
	assert(visual.contact_glow.material==visual.contact_material)
	assert(visual.contact_glow.scale.x>visual.contact_sprite.scale.x and visual.contact_glow.self_modulate.a<0.5)
	assert(visual.contact_glow.get_index()<visual.contact_sprite.get_index())
	assert(visual.contact_material.get_shader_parameter("front_start")>=0.5,"Only the foreground half of the contact ring is shown")
	for index in visual.base_flames.multimesh.instance_count:
		var flame_transform=visual.base_flames.multimesh.get_instance_transform_2d(index)
		assert(flame_transform.origin.y+flame_transform.get_scale().y*0.5>=0,"No rear contact flames are drawn over the column")
	assert(visual.heat_surface.size.x>effect.radius*2,"Heat haze extends beyond the fire sides")
	assert(not visual.heat_surface.z_as_relative)
	for fire_layer in [visual.fill_sprite,visual.rings,visual.base_flames,visual.contact_sprite,visual.contact_sparks,visual.embers]:
		assert(fire_layer.z_as_relative and fire_layer.z_index == 0 and visual.heat_surface.z_index<fire_layer.z_index,"All refraction is drawn before every fire column, so overlap cannot erase a body")
	assert(visual.heat_material.get_shader_parameter("strength_pixels")>0)
	assert(visual.contact_sparks.multimesh.instance_count==effect.settings.column_contact_spark_count)
	assert(visual.contact_spark_seeds.size()==effect.settings.column_contact_spark_count)
	var old_transform=root.canvas_transform
	root.canvas_transform=Transform2D(0,Vector2(0,1200))
	visual.update_visual(effect.elapsed)
	var tall=visual.column_height
	var fill_top=visual.fill_sprite.position.y-visual.fill_sprite.texture.get_height()*visual.fill_sprite.scale.y*0.5
	assert(is_equal_approx(fill_top,-tall),"One sprite fills the entire visible column height")
	assert(is_equal_approx(tall,effect.settings.column_height*global.GAME_ENTITY_SCALE),"Column has finite world height")
	root.canvas_transform=Transform2D(0,Vector2(0,1800))
	visual.update_visual(effect.elapsed)
	assert(is_equal_approx(visual.column_height,tall),"Camera changes never stretch the tornado")
	root.canvas_transform=old_transform
	var time=visual.elapsed
	global.game_paused=true
	effect._process(1)
	assert(visual.elapsed==time)
	assert(visual.heat_material.get_shader_parameter("elapsed")==time)
	global.game_paused=false
	assert(get_nodes_in_group("reaper_trails").is_empty(),"Stationary columns do not accumulate patches")
	var trail_start=effect.global_position
	var spacing=effect.settings.column_trail_spacing*global.GAME_ENTITY_SCALE
	effect.global_position+=Vector2(spacing*3.1,0)
	effect._leave_column_trail(trail_start,weapon)
	var patches=get_nodes_in_group("reaper_trails")
	assert(patches.size()==3,"Moving column lays evenly spaced short fire patches")
	for patch in patches:
		patch.set_process(false)
		assert(is_equal_approx(patch.radius,effect.radius*effect.settings.column_fill_width*0.5*effect.settings.column_trail_radius_multiplier))
		assert(is_equal_approx(patch.trail_lifetime,1.1*effect.duration_multiplier))
		assert(is_equal_approx(patch.hit.damage,effect.hit.damage*effect.settings.column_trail_damage_multiplier))
		assert(patch.trail_entries[0].record==weapon.damage_record)
		for child in patch.trail_visual.get_children():
			if child is CanvasItem: assert(child.z_index==-1)
	var trail_target=enemy_at(patches[0].global_position+Vector2(patches[0].radius*0.85,0))
	patches[0]._process(0.01)
	assert(trail_target.health_component.current_health<10000 and trail_target.has_node("FireVisual"),"Wide trail deals damage and burns enemies near its outer edge")
	assert(patches[0].hit.status_effects[0].get_meta("stack_id")==patches[1].hit.status_effects[0].get_meta("stack_id"),"Overlapping patches share the weapon burn instead of stacking new sources")
	patches[0]._process(patches[0].trail_lifetime)
	assert(patches[0].is_queued_for_deletion(),"Short trail fades and cleans up promptly")
	effect.velocity=Vector2(100,0)
	var point=effect.global_position
	effect._process(0.1)
	assert(effect.global_position.x>point.x)
	effect._process(30.0)
	assert(not effect.is_queued_for_deletion(),"Reaper persists instead of expiring")
	assert(visual.fill_material.get_shader_parameter("fade")>0.99,"Permanent fire never fades out")
	arena.queue_free()
	await process_frame
	print("PASS Reaper columns: damage/burn only on ground oval, repeated fire rings, camera height, pause, movement and cleanup")
	quit()
