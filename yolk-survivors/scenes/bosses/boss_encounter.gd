extends Node2D
## Shared encounter used by configured boss waves and the isolated test mode.
signal defeated
const PHASE_SECTIONS := [["Static lines","Fixed turrets","Hot zones + Fueguitos"],["Moving lines","Rotating turrets","Intensified lines"],["Complex lines","Combined turrets","Mixed mechanics"]]
enum State { STOPPED, INTRO, SECTION, WARNING, FALLING, VULNERABLE, COMPLETE, DEPARTURE, TAKEOFF }
var settings: Resource = preload("res://resources/bosses/salchichon.tres")
var arena
var area: ArenaEnvironment
var boss
var hud: Control
var phase := 0
var state := State.STOPPED
var active := false
var time_left := 0.0
var sections: Array[int] = []
var current_section := 0
var section_history: Array[int] = []
var section_runner: Node2D
var phase_hazard: Node2D
var departure_starts_phase := false
var landing_hit: HitboxComponent
var landing_warning: Polygon2D
var presentation_clock := 0.0
var jump_announced := false
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	z_index = -1
	set_process(false)
func start(context) -> void:
	stop()
	arena = context
	area = arena.environment_controller.apply_stage(settings.arena_stage)
	arena._configure_environment(area)
	arena.stage_mechanics.stop()
	arena.spawner.wave_timer.stop()
	arena.spawner.spawn_timer.stop()
	arena.spawner.clear_fueguito()
	if is_instance_valid(arena.environment_controller.debug_stage_selector): arena.environment_controller.debug_stage_selector.hide()
	if not is_instance_valid(hud):
		hud = load("res://scenes/bosses/boss_health_bar.gd").new()
		arena.get_node("GameUI").add_child(hud)
	hud.show()
	hud.hide_boss()
	boss = settings.boss_scene.instantiate()
	boss.stats = boss.stats.duplicate()
	boss.stats.health = settings.total_health
	boss.stats.damage = settings.contact_damage
	boss.stats.attack_effects = boss.stats.attack_effects.duplicate()
	boss.stats.attack_effects.append(preload("res://resources/bosses/boss_burning.tres"))
	arena.add_child(boss)
	boss.configure(settings, area.movement_bounds.get_center())
	arena.spawner.boss_enemies.append(boss)
	boss.health_component.on_health_changed.connect(_health_changed)
	boss.health_component.phase_floor_reached.connect(_phase_cleared)
	landing_hit = HitboxComponent.new()
	landing_hit.monitoring = false
	landing_hit.monitorable = false
	landing_hit.collision_layer = 0
	landing_hit.collision_mask = 0
	add_child(landing_hit)
	landing_hit.setup(settings.landing_damage,false,0,boss)
	landing_hit.grants_enemy_rewards = false
	landing_warning=preload("res://scenes/bosses/landing_warning.tscn").instantiate()
	add_child(landing_warning)
	landing_warning.hide()
	presentation_clock=0.0
	phase = 0
	section_history.clear()
	active = true
	set_process(true)
	state = State.INTRO
	time_left = settings.initial_wait_seconds
	if time_left <= 0: _begin_phase()
	_update_status()
func stop() -> void:
	if is_instance_valid(landing_warning): landing_warning.queue_free()
	landing_warning=null
	for effect in get_children():
		if effect.is_in_group("boss_landing_effects"): effect.queue_free()
	_clear_phase_hazard()
	_clear_section()
	active = false
	state = State.STOPPED
	set_process(false)
	if is_instance_valid(hud): hud.hide()
	if is_instance_valid(boss):
		if is_instance_valid(arena): arena.spawner.boss_enemies.erase(boss)
		boss.queue_free()
	boss = null
	if is_instance_valid(landing_hit): landing_hit.queue_free()
	landing_hit = null
	queue_redraw()
func _begin_phase() -> void:
	if phase == 1 and settings.phase_two_fueguito_enabled:
		if not is_instance_valid(phase_hazard):
			phase_hazard = load("res://scenes/bosses/phase_fueguito.gd").new()
			add_child(phase_hazard)
			phase_hazard.setup(area,settings,boss)
	else:
		_clear_phase_hazard()
	sections.assign([0,1,2])
	sections.shuffle()
	if phase == 2:
		sections.erase(2)
		sections.append(2)
	if phase == 0 and settings.test_static_lines_first:
		sections.assign([0,1,2])
	if phase == 1 and settings.test_moving_lines_first:
		sections.assign([0,1,2])
	if phase == 2 and settings.test_complex_lines_first:
		sections.assign([0,1,2])
	_next_section()
func _next_section() -> void:
	_clear_section()
	if sections.is_empty():
		_begin_landing()
		return
	current_section = sections.pop_front()
	section_history.append(phase*3+current_section)
	state = State.SECTION
	time_left = settings.section_seconds
	boss.set_present(false)
	hud.hide_boss()
	if phase == 0 and current_section == 0:
		section_runner = load("res://scenes/bosses/static_fire_lines.gd").new()
		add_child(section_runner)
		section_runner.setup(area,settings,boss)
	elif phase == 0 and current_section == 1:
		section_runner = load("res://scenes/bosses/fixed_turrets.gd").new()
		add_child(section_runner)
		section_runner.setup(area,settings,boss)
	elif phase == 0 and current_section == 2:
		section_runner = load("res://scenes/bosses/hot_zones_fueguitos.gd").new()
		add_child(section_runner)
		section_runner.setup(area,settings,boss)
	elif phase == 1 and current_section == 0:
		section_runner = load("res://scenes/bosses/moving_fire_lines.gd").new()
		add_child(section_runner)
		section_runner.setup(area,settings,boss)
	elif phase == 1 and current_section == 1:
		section_runner = load("res://scenes/bosses/rotating_turrets.gd").new()
		add_child(section_runner)
		section_runner.setup(area,settings,boss)
	elif phase == 1 and current_section == 2:
		section_runner = load("res://scenes/bosses/intensified_fire_lines.gd").new()
		add_child(section_runner)
		section_runner.setup(area,settings,boss)
	elif phase == 2 and current_section == 0:
		section_runner = load("res://scenes/bosses/complex_fire_lines.gd").new()
		add_child(section_runner)
		section_runner.setup(area,settings,boss)
	elif phase == 2 and current_section == 1:
		section_runner = load("res://scenes/bosses/mobile_rotating_turrets.gd").new()
		add_child(section_runner)
		section_runner.setup(area,settings,boss)
	elif phase == 2 and current_section == 2:
		section_runner = load("res://scenes/bosses/mixed_mechanics.gd").new()
		add_child(section_runner)
		section_runner.setup(area,settings,boss)
	_update_status()
func _begin_landing() -> void:
	SoundManager.play_event("boss_fall_warning")
	state = State.WARNING
	time_left = settings.landing_warning_seconds
	boss.set_present(false)
	hud.hide_boss()
	_update_landing_warning()
	queue_redraw()
func _process(delta: float) -> void:
	if not active or Global.game_paused: return
	presentation_clock+=delta
	if is_instance_valid(phase_hazard): phase_hazard.advance(delta)
	var section_delta := minf(delta,maxf(0,time_left))
	time_left -= delta
	match state:
		State.INTRO:
			if time_left <= 0: _begin_phase()
		State.SECTION:
			if is_instance_valid(section_runner): section_runner.advance(section_delta)
			if time_left<=0: _next_section()
		State.WARNING:
			if time_left<=0:
				state = State.FALLING
				time_left = settings.fall_seconds
				boss.show()
				boss.set_fall_offset(settings.fall_height)
		State.FALLING:
			var progress := clampf(1.0-time_left/settings.fall_seconds,0,1)
			boss.set_fall_offset(settings.fall_height*(1.0-progress*progress))
			if time_left<=0: _land()
		State.VULNERABLE:
			if time_left<=0:
				boss.set_present(false)
				hud.hide_boss()
				sections.assign([randi_range(0,2)])
				_begin_departure(false)
		State.TAKEOFF:
			var age: float = settings.takeoff_anticipation_seconds+settings.takeoff_jump_seconds-maxf(0,time_left)
			if age<settings.takeoff_anticipation_seconds:
				var progress: float = smoothstep(0,1,age/maxf(0.001,settings.takeoff_anticipation_seconds))
				boss.set_takeoff_pose(1.0-settings.takeoff_compression*progress,0)
			else:
				var progress: float = clampf((age-settings.takeoff_anticipation_seconds)/maxf(0.001,settings.takeoff_jump_seconds),0,1)
				if not jump_announced:
					jump_announced=true
					SoundManager.play_event("boss_jump")
				var stretch: float = lerpf(1.0-settings.takeoff_compression,1.1,smoothstep(0,0.3,progress))
				boss.set_takeoff_pose(stretch,settings.takeoff_height*progress*progress)
			if time_left<=0: _finish_takeoff()
		State.DEPARTURE:
			if time_left<=0:
				if departure_starts_phase: _begin_phase()
				else: _next_section()
	_update_landing_warning()
	_update_status()
	queue_redraw()
func _begin_departure(next_phase: bool) -> void:
	departure_starts_phase = next_phase
	state = State.TAKEOFF
	jump_announced=false
	time_left = settings.takeoff_anticipation_seconds+settings.takeoff_jump_seconds
	_clear_section()
	_clear_phase_hazard()
	boss.set_present(false)
	boss.show()
	boss.set_takeoff_pose(1,0)
	if time_left<=0: _finish_takeoff()

func _finish_takeoff() -> void:
	boss.set_takeoff_pose(1,0)
	boss.takeoff_active=false
	boss.hide()
	state=State.DEPARTURE
	time_left=settings.departure_wait_seconds
	if time_left<=0:
		if departure_starts_phase: _begin_phase()
		else: _next_section()

func _land() -> void:
	SoundManager.play_event("boss_impact")
	landing_warning.hide()
	_clear_phase_hazard()
	boss.set_fall_offset(0)
	boss.play_landing_squash()
	var blast: Node2D = preload("res://scenes/bosses/landing_blast.tscn").instantiate()
	blast.visual_radius=landing_radius()*settings.landing_visual_radius_multiplier
	blast.y_ratio=landing_y_ratio()
	blast.position=to_local(landing_center())
	add_child(blast)
	state = State.VULNERABLE
	time_left = settings.vulnerable_seconds
	boss.health_component.open_window(phase)
	boss.set_present(true)
	hud.show_boss(settings.boss_name,boss.health_component.current_health,settings.total_health)
	var circle := ConvexPolygonShape2D.new()
	var points := PackedVector2Array()
	for index in 64:
		points.append(Vector2(cos(TAU*index/64.0),sin(TAU*index/64.0)*landing_y_ratio())*landing_radius())
	circle.points=points
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = Transform2D(0,landing_center())
	query.collision_mask = 32
	query.collide_with_areas = true
	query.collide_with_bodies = false
	for hit in get_world_2d().direct_space_state.intersect_shape(query):
		if hit.collider is HurtboxComponent and hit.collider.owner is Player:
			hit.collider.owner._on_hurtbox_component_on_damage(landing_hit)
	arena.get_node("Camera2D").start_shake(5,0.15)
func landing_radius() -> float:
	return boss.shadow_world_rect().size.x*0.5*settings.landing_radius_multiplier
func landing_y_ratio() -> float:
	var size: Vector2 = boss.shadow_world_rect().size
	return size.y/maxf(size.x,0.001)
func landing_center() -> Vector2:
	return boss.shadow_world_rect().get_center()
func _health_changed(current: float, maximum: float) -> void:
	if is_instance_valid(hud):
		hud.bar.max_value = maximum
		hud.bar.value = current
func _phase_cleared() -> void:
	if not active or state != State.VULNERABLE: return
	boss.set_present(false)
	hud.hide_boss()
	if phase < 2:
		phase += 1
		_begin_departure(true)
	else:
		state = State.COMPLETE
		active = false
		set_process(false)
		hud.status.text = "BOSS DEFEATED — TEST COMPLETE" if arena.boss_test_mode else "BOSS DEFEATED"
		queue_redraw()
		defeated.emit()
func _update_status() -> void:
	if not is_instance_valid(hud): return
	if not arena.boss_test_mode:
		var title := "%s · PHASE %d/3" % [settings.boss_name,phase+1]
		match state:
			State.INTRO: hud.status.text = "%s · STARTING IN %.1f s" % [title,maxf(0,time_left)]
			State.WARNING,State.FALLING: hud.status.text = "%s · LEAVE THE MARKED ZONE" % title
			State.VULNERABLE: hud.status.text = "%s · VULNERABLE" % title
			_: hud.status.text = title
		return
	var prefix := "BOSS TEST · PHASE %d/3" % (phase+1)
	match state:
		State.TAKEOFF: hud.status.text = "%s · BOSS LEAVING" % prefix
		State.DEPARTURE: hud.status.text = "%s · NEXT ATTACK IN %.1f s" % [prefix,maxf(0,time_left)]
		State.INTRO: hud.status.text = "BOSS TEST · STARTING IN %.1f s" % maxf(0,time_left)
		State.SECTION:
			if current_section == 1 and phase in [0,1,2] and is_instance_valid(section_runner):
				var turret_label: String = ["FIXED TURRETS","ROTATING TURRETS","MIXED TURRETS"][phase]
				hud.status.text = "%s · %s · %d · %.1f s" % [prefix,turret_label,section_runner.turrets.size(),maxf(0,time_left)]
			elif current_section == 2 and phase == 0 and is_instance_valid(section_runner):
				hud.status.text = "%s · HOT ZONES %d · FUEGUITOS %d · %.1f s" % [prefix,section_runner.zones().size(),section_runner.hazards.size(),maxf(0,time_left)]
			elif phase == 1 and current_section == 0 and is_instance_valid(section_runner):
				var mode: String = ["WARNING","ACTIVE","REST"][maxi(0,section_runner.stage)]
				hud.status.text = "%s · MOVING LINES %d · %s · %.1f s" % [prefix,section_runner.attack_index+1,mode,maxf(0,time_left)]
			elif is_instance_valid(section_runner):
				var mode: String = ["WARNING","ACTIVE","REST"][maxi(0,section_runner.stage)]
				hud.status.text = "%s · %s · %s · %.1f s" % [prefix,section_runner.current_label,mode,maxf(0,time_left)]
			else:
				hud.status.text = "%s · SIMULATED: %s · %.1f s" % [prefix,PHASE_SECTIONS[phase][current_section],maxf(0,time_left)]
		State.WARNING,State.FALLING: hud.status.text = "%s · LANDING — LEAVE THE MARKED ZONE" % prefix
		State.VULNERABLE: hud.status.text = "%s · VULNERABLE · %.1f s" % [prefix,maxf(0,time_left)]
func _update_landing_warning() -> void:
	if not is_instance_valid(landing_warning): return
	landing_warning.visible=active and state in [State.WARNING,State.FALLING]
	if not landing_warning.visible: return
	landing_warning.global_position=landing_center()
	landing_warning.scale=Vector2(landing_radius()*2,landing_radius()*2*landing_y_ratio())
	landing_warning.material.set_shader_parameter("phase",presentation_clock)
	landing_warning.material.set_shader_parameter("world_length",landing_radius()*2)
	landing_warning.material.set_shader_parameter("warning_progress",clampf(1-time_left/settings.landing_warning_seconds,0,1) if state==State.WARNING else 1.0)

func _clear_section() -> void:
	if is_instance_valid(section_runner):
		section_runner.stop()
		section_runner.queue_free()
	section_runner = null

func _clear_phase_hazard() -> void:
	if is_instance_valid(phase_hazard):
		phase_hazard.stop()
		phase_hazard.queue_free()
	phase_hazard = null
