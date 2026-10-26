extends "res://scenes/bosses/fixed_turrets.gd"
## Previews overlap the previous attack; firing changes on the interval boundary.
func setup(geometry: ArenaEnvironment, settings: Resource, damage_source: Node2D) -> void:
	var rotating := settings.duplicate()
	rotating.turret_batch_interval = settings.rotating_turret_interval
	rotating.turret_lifetime = settings.rotating_turret_lifetime
	rotating.turret_warning_seconds = settings.rotating_turret_warning_seconds
	super.setup(geometry,rotating,damage_source)

func _spawn_batch(batch: int, born: float) -> void:
	if config.turret_positions.is_empty(): return
	var sequence: int = batch+config.rotating_turret_sequence_offset
	var fraction: Vector2 = config.turret_positions[sequence%config.turret_positions.size()]
	var point := area.clamp_position(area.movement_bounds.position+area.movement_bounds.size*fraction)
	var diagonal := sequence%2==1
	if config.turret_target_player and is_instance_valid(Global.nearest_player(area.movement_bounds.get_center())):
		point = _aimed_position(point,diagonal,Global.nearest_player(area.movement_bounds.get_center()).global_position-ray_offset)
	_spawn_turret(point,diagonal,born)
	var turret: Dictionary = turrets.back()
	turret.base_angle = PI*0.25 if diagonal else 0.0
	turret.rotation_sign = 1.0 if sequence%2==0 else -1.0
	turret.angle = turret.base_angle
	turret.firing_at = config.turret_warning_seconds if batch == 0 else batch*config.rotating_turret_interval
	turret.expires_at = batch*config.rotating_turret_interval+config.rotating_turret_lifetime
	var cue = load("res://scenes/bosses/turret_rotation_cue.gd").new()
	cue.radius = config.turret_visual_height*0.6
	cue.position = turret.body.get_node("RayOrigin").position
	turret.body.add_child(cue)
	turret.cue = cue

func advance(delta: float) -> void:
	if not running or Global.game_paused: return
	elapsed += maxf(0,delta)
	if elapsed >= config.section_seconds-0.0000001:
		stop()
		return
	for turret in turrets.duplicate():
		if elapsed >= turret.expires_at-0.0000001: _remove_turret(turret)
	while true:
		var batch := last_batch+1
		var firing_at: float = batch*config.rotating_turret_interval
		var preview_at: float = maxf(0,firing_at-config.turret_warning_seconds)
		if config.rotating_turret_spawn_limit > 0 and batch >= config.rotating_turret_spawn_limit: break
		if firing_at >= config.section_seconds or preview_at > elapsed+0.0000001: break
		if firing_at+config.rotating_turret_lifetime > elapsed+0.0000001: _spawn_batch(batch,preview_at)
		last_batch = batch
	for turret in turrets:
		var age: float = elapsed-turret.born
		turret.beams.set_line_stage(0 if elapsed < turret.firing_at-0.0000001 else 1)
		turret.beams.animate_lines(age,clampf(age/config.turret_warning_seconds,0,1))
		turret.body.animate_birth(age)
		var spinning_age := maxf(0,elapsed-turret.firing_at)
		var turn: float = turret.rotation_sign*deg_to_rad(config.rotating_turret_degrees_per_second)*spinning_age
		turret.angle = turret.base_angle+turn
		_animate_band(turret,age,turret.beams.stage)
		turret.cue.angle = turret.angle
		turret.cue.turn = turret.rotation_sign
		turret.cue.firing = turret.beams.stage==1
		turret.cue.queue_redraw()
		_update_motion(turret,spinning_age)
		for index in 2:
			var direction := Vector2.from_angle(turret.angle+index*PI*0.5)
			var origin: Vector2 = turret.body.get_node("RayOrigin").global_position
			var start := _edge(origin,-direction)
			var end := _edge(origin,direction)
			var line: Dictionary = turret.beams.lines[index]
			line.start = start
			line.end = end
			var length := start.distance_to(end)
			line.visual.position = start.lerp(end,0.5)
			line.visual.rotation = start.angle_to_point(end)
			line.visual.length = length
			line.glow.scale.x = length
			line.glow.material.set_shader_parameter("world_length",length)
			line.warning.scale.x = length
			line.warning.material.set_shader_parameter("world_length",length)
			var half: Vector2 = Vector2(length*0.5,config.turret_line_width)
			line.fire.polygon = PackedVector2Array([Vector2(-half.x,-half.y),Vector2(half.x,-half.y),Vector2(half.x,half.y),Vector2(-half.x,half.y)])
			line.shape.shape.size = Vector2(length,config.turret_line_width)
			line.material.set_shader_parameter("world_length",length)


	indicators.queue_redraw()

func _update_motion(_turret: Dictionary, _spinning_age: float) -> void:
	pass
