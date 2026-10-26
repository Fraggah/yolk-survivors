extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var pop=load("res://scenes/bosses/sausage_turret.tscn").instantiate()
	root.add_child(pop)
	var base=pop.rest_sprite_scale
	assert(pop.get_node("Sprite").scale.x<base.x and pop.get_node("Sprite").scale.y<base.y)
	var footprint=pop.get_node("HitboxComponent/CollisionShape2D").shape.radius
	pop.animate_birth(pop.spawn_seconds*0.6)
	var ratio=pop.get_node("Sprite").scale/base
	assert(ratio.y>ratio.x and ratio.x>1)
	pop.animate_birth(pop.spawn_seconds)
	assert(pop.get_node("Sprite").scale.is_equal_approx(base))
	assert(pop.get_node("Sprite").position==Vector2.ZERO and pop.get_node("HitboxComponent/CollisionShape2D").shape.radius==footprint)
	pop.begin_retirement()
	assert(pop.retiring and pop.get_node("HitboxComponent").damage==0 and pop.get_node("HitboxComponent").collision_layer==0)
	pop.animate_retirement(pop.retire_seconds*0.22)
	var retire_peak=pop.get_node("Sprite").scale/base
	assert(retire_peak.y>retire_peak.x and retire_peak.x>1)
	pop.animate_retirement(pop.retire_seconds*0.8)
	assert(pop.get_node("Sprite").scale.y<base.y)
	var paused=pop.get_node("Sprite").scale
	var pause_global=root.get_node("Global")
	pause_global.game_paused=true
	pop._process(1)
	assert(pop.get_node("Sprite").scale==paused)
	pause_global.game_paused=false
	pop.animate_retirement(pop.retire_seconds)
	assert(pop.is_queued_for_deletion())
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	await process_frame
	var global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=arena.weapon_selection_panel.weapons_list[0]
	arena.start_panel.hide()
	arena.selection_panel.hide()
	arena.weapon_selection_panel.hide()
	arena._on_boss_test_selected()
	var encounter=arena.boss_encounter
	encounter.set_process(false)
	encounter.settings=encounter.settings.duplicate()
	encounter.settings.departure_wait_seconds=0
	encounter.settings.takeoff_anticipation_seconds=0
	encounter.settings.takeoff_jump_seconds=0
	encounter.settings=encounter.settings.duplicate()
	encounter.settings.test_static_lines_first=true
	encounter.settings.test_moving_lines_first=true
	encounter.settings.test_complex_lines_first=true
	encounter.settings=encounter.settings.duplicate()
	encounter.settings.phase_two_fueguito_enabled=false
	var player=global.player
	player.set_process(false)
	player.get_node("HPTimer").stop()
	player.is_dashing=true
	for weapon in player.current_weapons:
		weapon.set_process(false)
		weapon.cooldown_timer.stop()
	encounter._process(3.01)
	for phase in 2:
		for section in 3: encounter._process(30.01)
		encounter._process(encounter.settings.landing_warning_seconds+0.01)
		encounter._process(encounter.settings.fall_seconds+0.01)
		encounter.boss.health_component.take_damage(10000)
	encounter._process(30.01)
	encounter._process(30.01)
	assert(encounter.phase==2 and encounter.current_section==2)
	var section=encounter.section_runner
	section._clear_attack()
	section._clear_preview()
	# Exercise every mechanic and all handoff combinations deterministically.
	section.schedule.assign([0,1,2,3,0,2,1,0,3,2,0,2])
	section.history.clear()
	section.attack_index=-1
	section.advance(0)
	var kinds_seen={}
	for index in 12:
		section.advance(maxf(0,index*2.5-section.elapsed))
		assert(section.attack_index==index and section.history.size()==index+1)
		var kind=section.attack_kind
		kinds_seen[kind]=true
		if index>0: assert(not (section.history[index-1] in [1,3] and kind in [1,3]))
		var child=section.attack
		if kind==0:
			assert(child.attack_kind==0 and child.attack.lines.size()==20)
			assert(not child.attack.persistent_glow)
		elif kind==1:
			assert(child.attack_kind==1 and child.attack.barriers.size()==5)
			assert(child.attack.renderer.persistent_glow)
			assert(child.attack.arrows.markers().size()==1)
			var badge=child.attack.arrows.badges[0]
			assert(badge.visible and badge.get_meta("rest_scale")==Vector2(1.7,1.7))
			assert(badge.get_node("Background").color==Color(0.105,0.112,0.12,1))
			assert(badge.get_node("Arrow").material.shader==badge.get_node("Border").material.shader)
			assert(badge.get_node("Arrow").material.shader.resource_path=="res://shaders/warning_fire_color.gdshader")
		else:
			assert(child.config.rotating_turret_spawn_limit==1 and child.turrets.size()==1)
			assert(child.turrets[0].beams.stage==1,"Prepared turrets fire exactly at their slot boundary")
		section.advance(1.25)
		if kind==0:
			var line=child.attack.lines[0]
			assert(line.glow.visible and line.material.get_shader_parameter("flash")>0.9)
			var bright=line.glow.material.get_shader_parameter("intensity")
			assert(line.glow.material.get_shader_parameter("ripple_strength")==0)
			for frame in 12:
				child.attack.animate_lines(child.attack.elapsed+(frame+1)/60.0,1.0)
				var value=line.glow.material.get_shader_parameter("intensity")
				assert(value<=bright)
				bright=value
			child.attack.animate_lines(child.attack.elapsed+0.3,1.0)
			assert(line.glow.material.get_shader_parameter("intensity")<bright and line.material.get_shader_parameter("flash")==0)
		if kind==2:
			var turret=child.turrets[0]
			assert(turret.position==turret.body.position and not is_zero_approx(turret.angle-turret.base_angle))
			assert(is_zero_approx(turret.sprite.rotation) and is_zero_approx(turret.body.rotation))
			assert(turret.sprite.material.get_shader_parameter("phase")>0)
			var origin: Vector2=turret.body.get_node("RayOrigin").global_position
			for beam in turret.beams.lines:
				var background=Rect2(section.area.background_offset-section.area.background_size*0.5,section.area.background_size)
				assert(not background.grow(200).has_point(beam.start) and not background.grow(200).has_point(beam.end))
				assert(Geometry2D.get_closest_point_to_segment(origin,beam.start,beam.end).distance_to(origin)<0.01)
		elif kind==3:
			var turret=child.turrets[0]
			assert(turret.moving and turret.rotation_sign==0 and turret.position!=turret.path_start)
			assert(turret.angle==turret.base_angle)
		var before=section.elapsed
		if index==0:
			arena.set_wave_paused(true)
			section.advance(10)
			assert(section.elapsed==before and section.history.size()==1)
			arena.set_wave_paused(false)
		# Turret preview starts 1.2 s before the upcoming slot, without firing.
		if index<11 and section.schedule[index+1] in [2,3]:
			section.advance(0.1)
			assert(is_instance_valid(section.preview) and section.preview.turrets.size()==1)
			var incoming=section.preview
			assert(incoming.turrets[0].beams.stage==0)
			for line in incoming.turrets[0].beams.lines: assert(line.hit.damage==0 and not line.hit.status_effects.is_empty() and line.warning.visible)
			assert(incoming.turrets[0].beams.lines[0].warning.material.get_shader_parameter("phase")>=0)
			section.advance((index+1)*2.5-section.elapsed)
			assert(section.attack==incoming and section.attack.turrets[0].beams.stage==1)
	assert(kinds_seen.size()==4 and section.history.size()==12)
	var remaining=section.attack
	encounter.time_left=30-section.elapsed
	encounter._process(encounter.time_left)
	assert(not section.running and section.attack==null and section.preview==null)
	assert(not remaining.running and encounter.state==encounter.State.WARNING)
	assert(section.history.size()==12)
	var retiring=get_nodes_in_group("boss_retiring_turrets")
	assert(not retiring.is_empty())
	for body in retiring:
		assert(body.get_parent()==arena and body.retiring)
		assert(body.get_node("HitboxComponent").damage==0 and body.get_node("HitboxComponent").collision_layer==0)
	await process_frame
	assert(get_nodes_in_group("boss_hazards").is_empty())
	assert(get_nodes_in_group("boss_turret_indicators").is_empty() and get_nodes_in_group("boss_turret_paths").is_empty())
	# Test the real selector: 25% each when unrestricted; movement forces 0 or 2.
	var probe=load("res://scenes/bosses/mixed_mechanics.gd").new()
	probe.random.seed=42
	var counts=[0,0,0,0]
	for sample in 10000: counts[probe.roll_kind(-1)]+=1
	for count in counts: assert(count>2200 and count<2800)
	var previous=-1
	for sample in 10000:
		var kind=probe.roll_kind(previous)
		if previous in [1,3]: assert(kind in [0,2])
		previous=kind
	probe.free()
	arena.clear_arena()
	await process_frame
	arena.queue_free()
	await process_frame
	print("PASS final mix: phase 3 integration, 12 slots/2.5 s, all four reused mechanics, 25% selector, no consecutive movement, advance previews/seamless turrets, exclusive modes, pause and cleanup before landing")
	quit()
