extends SceneTree
var arena
func _initialize(): call_deferred("verify")
func enemy_at(point):
	var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	enemy.stats=enemy.stats.duplicate()
	enemy.stats.block_chance=0
	arena.add_child(enemy)
	enemy.global_position=point
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.can_move=false
	enemy.health_component.max_health=1000
	enemy.health_component.current_health=1000
	return enemy
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	var item=load("res://resources/items/weapons/range/hydrant/item_hydrant_1.tres")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=item
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	arena.stage_mechanics.stop()
	var player=global.player
	player.set_process(false)
	player.global_position=Vector2.ZERO
	var weapon=player.current_weapons[0]
	weapon.set_process(false)
	weapon.position=Vector2.ZERO
	weapon.data=item.duplicate()
	weapon.data.stats=item.stats.duplicate(true)
	weapon.data.stats.damage=10
	weapon.data.stats.cooldown=0.1
	weapon.data.stats.crit_chance=0
	weapon.data.stats.knockback=0
	var tier=item
	for index in 4:
		assert(tier.stats.projectile_scene==null and tier.stats.ranged_settings.stream_width>0)
		tier=tier.upgrade_to
	var first=enemy_at(Vector2(180,0))
	var second=enemy_at(Vector2(300,0))
	var side=enemy_at(Vector2(180,120))
	for enemy in [first,second,side]: weapon._on_range_area_area_entered(enemy)
	await physics_frame
	await physics_frame
	weapon._process(0)
	var stream=weapon.weapon_behaviour
	assert(stream.stream_active and stream.line.visible and weapon.is_attacking)
	var feet=first.get_node("HurtboxComponent/CollisionShape2D").global_position
	assert(first.get_aim_position().is_equal_approx(feet))
	assert(stream.stream_end.distance_to(feet)<0.01,"Stream must end on the floor collision, not the Area2D origin")
	assert(absf(angle_difference(weapon.rotation,weapon.global_position.angle_to_point(feet)))<0.001)
	if OS.get_cmdline_user_args().has("--capture"):
		arena.start_panel.hide(); arena.selection_panel.hide(); arena.weapon_selection_panel.hide()
		var camera=arena.get_node("Camera2D")
		camera.set_process(false)
		camera.global_position=Vector2(80,0)
		camera.zoom=Vector2.ONE*3
		camera.force_update_scroll()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/hydrant-foot-aim.png"))
	assert(stream.line.points.size()>2 and stream.line.material!=null,"Viscous strand uses curved geometry and shaded center/edges")
	var pool=arena.get_node("MayonnaiseParticles")
	assert(pool.particles.any(func(p): return p.impact))
	assert(pool.particles.any(func(p): return not p.impact))
	assert(first.health_component.current_health==990)
	assert(second.health_component.current_health==1000 and side.health_component.current_health==1000)
	assert(get_nodes_in_group("projectiles").is_empty(),"Continuous stream emits no bullet nodes")
	weapon._process(0.04)
	assert(first.health_component.current_health==990)
	weapon._process(0.061)
	assert(first.health_component.current_health==980,"Repeated damage uses cooldown interval")
	global.game_paused=true
	var time_left=stream.tick_left
	var particle_position=pool.particles[0].position
	pool._process(1)
	assert(pool.particles[0].position==particle_position)
	weapon._process(2)
	assert(first.health_component.current_health==980 and stream.tick_left==time_left)
	global.game_paused=false
	# Align a second enemy behind the first relative to the actual muzzle.
	var muzzle=stream.muzzle.global_position
	second.global_position=first.global_position+(first.global_position-muzzle).normalized()*100
	await physics_frame
	await physics_frame
	player.stats.piercing=1
	stream.tick_left=0
	weapon._process(0)
	assert(first.health_component.current_health==970 and second.health_component.current_health==990)
	assert(is_equal_approx(weapon.damage_record.wave_damage,40))
	# Losing targets stops the stream; re-entry starts immediately.
	for enemy in [first,second,side]: enemy.global_position=Vector2(2000,1000)
	weapon._process(0)
	assert(not stream.stream_active and not stream.line.visible)
	first.global_position=Vector2(180,0)
	await physics_frame
	await physics_frame
	weapon._process(0)
	assert(stream.stream_active and first.health_component.current_health==960)
	arena.clear_arena()
	assert(not stream.stream_active and not stream.line.visible and not weapon.is_attacking)
	assert(pool.particles.is_empty(),"Wave cleanup clears mayonnaise splashes")
	player.prepare_for_new_wave()
	assert(stream.tick_left==0)
	print("PASS Hydrant: continuous trace, real damage ticks, first-target blocking, piercing, no bullets, pause, retarget and wave reset")
	quit()
