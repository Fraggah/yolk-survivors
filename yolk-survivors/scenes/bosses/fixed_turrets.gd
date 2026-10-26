extends Node2D
## Indestructible mechanisms: no enemy group or hurtbox, only contact hitboxes.
var area: ArenaEnvironment
var config: Resource
var source: Node2D
var elapsed := 0.0
var last_batch := -1
var running := false
var turrets: Array[Dictionary] = []
var indicators: Control
var beam_config: Resource
var ray_offset := Vector2.ZERO
var contact_radius := 42.0

func setup(geometry: ArenaEnvironment, settings: Resource, damage_source: Node2D) -> void:
	area = geometry
	config = settings
	source = damage_source
	var template: Node2D = config.turret_scene.instantiate()
	ray_offset = template.get_node("RayOrigin").position
	contact_radius = template.get_node("HitboxComponent/CollisionShape2D").shape.radius
	template.free()
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("boss_hazards")
	beam_config = config.duplicate()
	beam_config.line_width = config.turret_line_width
	beam_config.line_damage = config.turret_line_damage
	indicators = load("res://scenes/bosses/turret_edge_indicators.gd").new()
	indicators.section = self
	# Reuse the encounter HUD's CanvasLayer; positions are viewport coordinates.
	source.get_parent().get_node("GameUI").add_child(indicators)
	running = true
	advance(0)

func advance(delta: float) -> void:
	if not running or Global.game_paused: return
	elapsed += maxf(0,delta)
	if elapsed >= config.section_seconds:
		stop()
		return
	# Remove expired batches before creating replacements: never one frame of 9.
	for turret in turrets.duplicate():
		if elapsed-turret.born >= config.turret_lifetime:
			_remove_turret(turret)
	var batch := int(floor(elapsed/config.turret_batch_interval))
	if batch > last_batch:
		# A long frame may skip births that would already have expired.
		for index in range(last_batch+1,batch+1):
			var born: float = index*config.turret_batch_interval
			if elapsed-born < config.turret_lifetime: _spawn_batch(index,born)
		last_batch = batch
	for turret in turrets:
		var age: float = elapsed-turret.born
		# One warning at birth; firing stays uninterrupted until this turret expires.
		var mode := 0 if age < config.turret_warning_seconds else 1
		turret.beams.set_line_stage(mode)
		turret.beams.animate_lines(age,clampf(age/config.turret_warning_seconds,0,1))
		# Small breathing animation; the collision footprint stays constant.
		turret.body.animate_birth(age)
		_animate_band(turret,age,mode)
	indicators.queue_redraw()

func _spawn_batch(batch: int, born: float) -> void:
	if config.turret_positions.is_empty(): return
	for slot in 3:
		var fraction: Vector2 = config.turret_positions[(batch*3+slot)%config.turret_positions.size()]
		var position_world := area.clamp_position(area.movement_bounds.position+area.movement_bounds.size*fraction)
		var diagonal := (batch+slot)%2==1
		if slot == 0 and config.turret_target_player and is_instance_valid(Global.nearest_player(area.movement_bounds.get_center())):
			position_world = _aimed_position(position_world,diagonal,Global.nearest_player(area.movement_bounds.get_center()).global_position-ray_offset)
		_spawn_turret(position_world,diagonal,born)

## Reposition along one fixed beam axis rather than rotating the +/x pattern.
## Once the preview exists, neither the turret nor its beams track the player.
func _aimed_position(planned: Vector2, diagonal: bool, target: Vector2) -> Vector2:
	var best := _safe_spawn_position(planned)
	var best_distance := INF
	var clearance: float = maxf(contact_radius+config.turret_line_width,config.turret_spawn_min_distance+ray_offset.length())
	var angle := PI*0.25 if diagonal else 0.0
	for offset in [0.0,PI*0.5]:
		var direction := Vector2.from_angle(angle+offset)
		var projection := (planned-target).dot(direction)
		for distance in [projection,maxf(clearance,projection),minf(-clearance,projection)]:
			var candidate: Vector2 = target+direction*distance
			if not area.clamp_position(candidate).is_equal_approx(candidate):
				# Clip along the same axis, preserving alignment at rounded corners.
				var inside := target
				var outside := candidate
				for iteration in 24:
					var middle := inside.lerp(outside,0.5)
					if area.clamp_position(middle).is_equal_approx(middle): inside = middle
					else: outside = middle
				candidate = inside
			if candidate.distance_to(target) < clearance-0.01: continue
			if not _spawn_is_safe(candidate): continue
			var score := candidate.distance_squared_to(planned)
			if score < best_distance:
				best_distance = score
				best = candidate
	return best

func _spawn_is_safe(point: Vector2) -> bool:
	return Global.players_clear_of(point,config.turret_spawn_min_distance-0.01)

func _safe_spawn_position(planned: Vector2) -> Vector2:
	if _spawn_is_safe(planned): return planned
	var best := planned
	var score := INF
	# Search around the player, then across the arena as a fallback near corners.
	for ring in [1.01,1.5,2.0]:
		for index in 32:
			var candidate := area.clamp_position(Global.nearest_player(area.movement_bounds.get_center()).global_position+Vector2.from_angle(TAU*index/32.0)*config.turret_spawn_min_distance*ring)
			if _spawn_is_safe(candidate) and candidate.distance_squared_to(planned)<score:
				best=candidate
				score=candidate.distance_squared_to(planned)
	if score<INF: return best
	for x in 17:
		for y in 17:
			var candidate := area.clamp_position(area.movement_bounds.position+area.movement_bounds.size*Vector2(x/16.0,y/16.0))
			if _spawn_is_safe(candidate) and candidate.distance_squared_to(planned)<score:
				best=candidate
				score=candidate.distance_squared_to(planned)
	return best

func _spawn_turret(position_world: Vector2, diagonal: bool, born: float) -> void:
	# Shared by fixed, rotating, moving and mixed attacks, including non-aimed births.
	position_world = _safe_spawn_position(position_world)
	var body: Node2D = config.turret_scene.instantiate()
	body.position = position_world
	add_child(body)
	var sprite := body.get_node("Sprite") as Sprite2D
	var rest_scale: Vector2 = body.rest_sprite_scale
	var contact := body.get_node("HitboxComponent") as HitboxComponent
	contact.continuous_contact = true
	contact.grants_enemy_rewards = false
	contact.setup(config.turret_contact_damage,false,0,source)
	var shape := contact.get_node("CollisionShape2D") as CollisionShape2D
	var beams = load("res://scenes/bosses/static_fire_lines.gd").new()
	beams.persistent_glow = true
	beams.area = area
	beams.config = beam_config
	beams.source = source
	add_child(beams)
	var angle := PI*0.25 if diagonal else 0.0
	for offset in [0.0,PI*0.5]:
		var direction := Vector2.from_angle(angle+offset)
		beams._add_segment(_edge(body.get_node("RayOrigin").global_position,-direction),_edge(body.get_node("RayOrigin").global_position,direction))
	turrets.append({"body":body,"sprite":sprite,"rest_scale":rest_scale,"contact":contact,"shape":shape,"beams":beams,"born":born,"diagonal":diagonal,"position":position_world})

func _edge(origin: Vector2, direction: Vector2) -> Vector2:
	var bounds := preload("res://scenes/bosses/laser_bounds.gd").for_view(area,get_viewport(),config.laser_end_overscan)
	var distance := INF
	if direction.x > 0.00001: distance = minf(distance,(bounds.end.x-origin.x)/direction.x)
	elif direction.x < -0.00001: distance = minf(distance,(bounds.position.x-origin.x)/direction.x)
	if direction.y > 0.00001: distance = minf(distance,(bounds.end.y-origin.y)/direction.y)
	elif direction.y < -0.00001: distance = minf(distance,(bounds.position.y-origin.y)/direction.y)
	return origin+direction*maxf(0,distance)

func _remove_turret(turret: Dictionary) -> void:
	turret.contact.damage = 0
	turret.contact.base_damage = 0
	turret.contact.collision_layer = 0
	turret.shape.set_deferred("disabled",true)
	turret.beams.stop()
	turret.beams.queue_free()
	# Visual retirement outlives the section; hazards already stopped above.
	turret.body.reparent(source.get_parent(),true)
	turret.body.begin_retirement()
	turrets.erase(turret)

func stop() -> void:
	running = false
	for turret in turrets.duplicate(): _remove_turret(turret)
	if is_instance_valid(indicators):
		indicators.hide()
		indicators.queue_free()
	indicators = null
	hide()

func _exit_tree() -> void:
	# The indicators live in the HUD, so also handle unexpected parent removal.
	if is_instance_valid(indicators): indicators.queue_free()

func _animate_band(turret: Dictionary, age: float, mode: int) -> void:
	turret.sprite.material.set_shader_parameter("phase",age)
	turret.sprite.material.set_shader_parameter("firing",float(mode==1))
