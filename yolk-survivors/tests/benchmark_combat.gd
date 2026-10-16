extends SceneTree
var arena
var global
var player
var enemies=[]
var original_positions=[]
var results=[]
var enemy_count=500
var output_name="combat-benchmark.json"
var quick=false
var seconds=20.0
var warmup=5.0
var loadout="hydrant"
var capture_image=false
var combat_only=false
func _initialize(): call_deferred("run")
func percentile(values, fraction):
	var sorted=values.duplicate()
	sorted.sort()
	return sorted[mini(sorted.size()-1,int(sorted.size()*fraction))]
func run():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--enemies="): enemy_count=int(arg.get_slice("=",1))
		if arg.begins_with("--output="): output_name=arg.get_slice("=",1)
		if arg=="--quick": quick=true
		if arg.begins_with("--seconds="): seconds=float(arg.get_slice("=",1))
		if arg.begins_with("--warmup="): warmup=float(arg.get_slice("=",1))
		if arg.begins_with("--loadout="): loadout=arg.get_slice("=",1)
		if arg=="--capture": capture_image=true
		if arg=="--combat-only": combat_only=true
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps=0
	RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(),true)
	load("res://tests/progression_fixture.gd").prepare(root)
	arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=load("res://resources/items/weapons/range/hydrant/item_hydrant_1.tres")
	arena.start_panel.hide()
	arena.environment_controller.debug_forced_stage=1
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	arena.spawner.wave_timer.stop()
	arena.stage_mechanics.stop()
	player=global.player
	player.set_process(false)
	player.health_component.debug_invulnerable=true
	player.global_position=Vector2.ZERO
	for weapon in player.current_weapons: weapon.queue_free()
	player.current_weapons.clear()
	global.equipped_weapons.clear()
	seed(16062026)
	for i in enemy_count:
		var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
		enemy.stats=enemy.stats.duplicate()
		enemy.stats.block_chance=0
		arena.add_child(enemy)
		var angle=float(i)*2.399963
		var point=Vector2(cos(angle),sin(angle)*0.6)*lerpf(170.0,650.0,float(i)/maxf(1,enemy_count-1))
		enemy.global_position=point
		enemy.health_component.max_health=1000000
		enemy.health_component.current_health=1000000
		enemies.append(enemy)
		original_positions.append(point)
	await process_frame
	var scenarios=[{"name":"0_hydrant","count":0},{"name":"1_full","count":1},{"name":"6_full","count":6},{"name":"6_without_particles","count":6,"particles":false},{"name":"6_without_damage_ticks","count":6,"ticks":false},{"name":"6_beams_only","count":6,"particles":false,"ticks":false}]
	if quick: scenarios=scenarios.filter(func(s): return s.name in ["0_hydrant","6_full","6_beams_only"])
	if loadout!="hydrant": scenarios=scenarios.filter(func(s): return s.name in ["0_hydrant","6_full"])
	if combat_only: scenarios=scenarios.filter(func(s): return s.name=="6_full")
	for scenario in scenarios:
		for weapon in player.current_weapons: weapon.queue_free()
		player.current_weapons.clear()
		global.equipped_weapons.clear()
		for pool in get_nodes_in_group("mayonnaise_particles"): pool.clear()
		root.get_node("CombatTexts").clear()
		for text in get_nodes_in_group("combat_texts"): text.queue_free()
		for i in enemies.size():
			enemies[i].global_position=original_positions[i]
			enemies[i].reset_knockback()
		player.global_position=Vector2.ZERO
		await process_frame
		for i in scenario.count:
			var path="res://resources/items/weapons/range/hydrant/item_hydrant_1.tres"
			if loadout=="mixed":
				path=[path,"res://resources/items/weapons/range/knifer/item_knifer_1.tres","res://resources/items/weapons/range/smasher/item_smasher_1.tres","res://resources/items/weapons/range/the_bloody/item_bloody_1.tres","res://resources/items/weapons/range/corpse_l/item_corpse_l_1.tres","res://resources/items/weapons/melee/electric_knife/item_electric_knife_1.tres"][i]
			if loadout=="ricochet": path="res://resources/items/weapons/range/knifer/item_knifer_1.tres"
			if loadout=="electric": path="res://resources/items/weapons/melee/immersion_blender/item_immersion_blender_1.tres"
			if loadout=="bloody": path="res://resources/items/weapons/range/the_bloody/item_bloody_1.tres"
			if loadout=="corpse": path="res://resources/items/weapons/range/corpse_l/item_corpse_l_1.tres"
			var item=load(path).duplicate()
			item.stats=item.stats.duplicate(true)
			if not scenario.get("particles",true):
				item.stats.ranged_settings.stream_muzzle_particles=0
				item.stats.ranged_settings.stream_impact_particles=0
			player.add_weapon(item)
			player.current_weapons.back().set_process(false)
		if loadout!="hydrant":
			player.stats.bounces=6
			player.stats.piercing=2
		var samples=[]
		var weapon_us=0.0
		var draw_calls=0.0
		var max_particles=0
		var active_streams=0
		var physics_ms=0.0
		var gpu_ms=0.0
		var render_ms=0.0
		var physics_pairs=0.0
		var peak_projectiles=0
		var peak_texts=0
		var peak_electric_segments=0
		var peak_drops=0
		var last=Time.get_ticks_usec()
		var began=last
		while Time.get_ticks_usec()-began<int(seconds*1000000):
			await process_frame
			var now=Time.get_ticks_usec()
			var dt=float(now-last)/1000000.0
			last=now
			var elapsed=float(now-began)/1000000.0
			player.global_position=Vector2(sin(elapsed)*25,cos(elapsed)*15)
			var before=Time.get_ticks_usec()
			var active=0
			for weapon in player.current_weapons:
				if not scenario.get("ticks",true): weapon.weapon_behaviour.tick_left=1000000
				weapon._process(dt)
				if weapon.weapon_behaviour.has_method("update_stream") and weapon.weapon_behaviour.stream_active: active+=1
			var cost=Time.get_ticks_usec()-before
			if elapsed<warmup: continue
			samples.append(dt*1000)
			weapon_us+=cost
			active_streams+=active
			draw_calls+=Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
			gpu_ms+=RenderingServer.viewport_get_measured_render_time_gpu(root.get_viewport_rid())
			render_ms+=RenderingServer.viewport_get_measured_render_time_cpu(root.get_viewport_rid())
			physics_ms+=Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000
			physics_pairs+=Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS)
			var pool=arena.get_node_or_null("MayonnaiseParticles")
			if pool: max_particles=maxi(max_particles,pool.particles.size())
			peak_projectiles=maxi(peak_projectiles,get_nodes_in_group("projectiles").size())
			peak_texts=maxi(peak_texts,get_nodes_in_group("combat_texts").size())
			peak_electric_segments=maxi(peak_electric_segments,root.get_node("ElectricRays").active_segment_count())
			peak_drops=maxi(peak_drops,arena.projectile_pool.leased.size())
		var total=0.0
		for sample in samples: total+=sample
		var result={"scenario":scenario.name,"enemies":enemy_count,"frames":samples.size(),"average_fps":1000/(total/samples.size()),"mean_frame_ms":total/samples.size(),"p95_frame_ms":percentile(samples,0.95),"weapon_update_ms":weapon_us/samples.size()/1000,"mean_draw_calls":draw_calls/samples.size(),"physics_ms":physics_ms/samples.size(),"physics_pairs":physics_pairs/samples.size(),"peak_mayo_particles":max_particles,"mean_active_streams":float(active_streams)/samples.size()}
		results.append(result)
		result["loadout"] = loadout
		var slow_frames := 0
		for sample in samples:
			if sample>1000.0/30.0: slow_frames += 1
		result["frames_below_30_percent"] = 100.0*slow_frames/samples.size()
		result["p99_frame_ms"] = percentile(samples,0.99)
		result["max_frame_ms"] = samples.max()
		result["gpu_ms"] = gpu_ms/samples.size()
		result["render_cpu_ms"] = render_ms/samples.size()
		result["peak_projectiles"]=peak_projectiles
		result["peak_combat_texts"]=peak_texts
		result["peak_electric_segments"]=peak_electric_segments
		result["peak_pooled_drops"]=peak_drops
		var scripts={}
		for node in get_nodes_in_group("projectiles"):
			var key=node.get_script().resource_path.get_file()
			scripts[key]=int(scripts.get(key,0))+1
		result["final_projectile_types"]=scripts
		print(JSON.stringify(result))
		if capture_image and scenario.count>0:
			await RenderingServer.frame_post_draw
			var capture_path=output_name if output_name.is_absolute_path() else "user://"+output_name
			root.get_texture().get_image().save_png(capture_path.get_basename()+"-"+scenario.name+".png")
	var path=output_name if output_name.is_absolute_path() else "user://"+output_name
	var output=FileAccess.open(path,FileAccess.WRITE)
	output.store_string(JSON.stringify({"renderer":RenderingServer.get_current_rendering_method(),"gpu":RenderingServer.get_video_adapter_name(),"cpu":OS.get_processor_name(),"viewport":str(root.size),"case_seconds":seconds,"warmup_seconds":warmup,"results":results},"\t"))
	output.close()
	print("PASS combat benchmark completed: ",path)
	quit()
