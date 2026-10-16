extends WeaponBehaviour
## Continuous hitscan stream. Weapon cooldown is the damage tick interval.
@onready var muzzle: Marker2D = %Muzzle
var line: Line2D
var hit: HitboxComponent
var tick_left := 0.0
var stream_active := false
var current_targets: Array[Enemy] = []
var stream_start := Vector2.ZERO
var stream_end := Vector2.ZERO
var flow_phase := 0.0
var particle_left := 0.0
var stream_material: ShaderMaterial
var trace_shape := CapsuleShape2D.new()
var trace_query := PhysicsShapeQueryParameters2D.new()

func _ready() -> void:
	trace_query.shape = trace_shape
	trace_query.collision_mask = 8
	trace_query.collide_with_areas = true
	trace_query.collide_with_bodies = false
	add_to_group("continuous_attacks")
	line = Line2D.new()
	line.z_index = 2
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.antialiased = true
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color.WHITE,Color.WHITE])
	var white_texture := GradientTexture2D.new()
	white_texture.gradient = gradient
	white_texture.width = 8
	white_texture.height = 8
	line.texture = white_texture
	line.texture_mode = Line2D.LINE_TEXTURE_STRETCH
	stream_material = ShaderMaterial.new()
	stream_material.shader = preload("res://shaders/mayonnaise_stream.gdshader")
	line.material = stream_material
	add_child(line)
	line.hide()
	hit = HitboxComponent.new()
	hit.collision_layer = 0
	hit.collision_mask = 0
	hit.monitoring = false
	add_child(hit)

func update_stream(delta: float, has_target: bool) -> void:
	if Global.game_paused: return
	if not has_target or weapon.data == null or weapon.data.stats.ranged_settings == null:
		_stop_stream()
		return
	if not stream_active:
		stream_active = true
		tick_left = 0.0
		SoundManager.play_weapon_attack(weapon)
	weapon.is_attacking = true
	flow_phase += delta * weapon.data.stats.ranged_settings.stream_flow_speed
	_update_trace()
	line.show()
	_emit_particles(delta)
	tick_left -= delta
	var ticks := 0
	while tick_left <= 0.0 and ticks < 4:
		_damage_tick()
		tick_left += weapon.get_effective_cooldown()
		ticks += 1
	if tick_left < 0.0: tick_left = 0.0

func _update_trace() -> void:
	stream_start = muzzle.global_position
	var target_hurtbox := weapon.closest_target.get_node("HurtboxComponent") as HurtboxComponent
	var direction := stream_start.direction_to(target_hurtbox.global_position)
	if direction.is_zero_approx(): direction = Vector2.RIGHT.rotated(weapon.rotation)
	var length := weapon.data.stats.max_range * absf(weapon.collision.global_scale.x)
	var width := weapon.data.stats.ranged_settings.stream_width * Global.GAME_ENTITY_SCALE
	var count := 1 + weapon.data.get_effective_piercing(weapon.get_parent().stats)
	# Without piercing the chosen target already bounds the first-hit search.
	# Querying behind it needlessly includes the whole packed horde.
	if count == 1: length = minf(length,stream_start.distance_to(target_hurtbox.global_position))
	stream_end = stream_start + direction * length
	trace_shape.radius = width * 0.5
	trace_shape.height = length + width
	trace_query.transform = Transform2D(direction.angle() + PI * 0.5, stream_start + direction * length * 0.5)
	current_targets.clear()
	var distances: Array[float] = []
	var closest: Enemy
	var closest_distance := INF
	for result in get_world_2d().direct_space_state.intersect_shape(trace_query, 256):
		var hurtbox = result.collider
		if not hurtbox is HurtboxComponent: continue
		var enemy = hurtbox.owner
		if not enemy is Enemy or not enemy.targetable or enemy.is_retiring or enemy.is_queued_for_deletion() or enemy.health_component.current_health <= 0: continue
		if count == 1:
			var distance := stream_start.distance_squared_to(hurtbox.global_position)
			if distance<closest_distance:
				closest_distance = distance
				closest = enemy
			continue
		if current_targets.has(enemy): continue
		var distance := stream_start.distance_squared_to(hurtbox.global_position)
		var insertion := distances.bsearch(distance)
		if insertion>=count: continue
		distances.insert(insertion,distance)
		current_targets.insert(insertion,enemy)
		if current_targets.size()>count:
			current_targets.pop_back()
			distances.pop_back()
	if count == 1:
		if is_instance_valid(closest): current_targets.append(closest)
	if current_targets.size() > count: current_targets.resize(count)
	if not current_targets.is_empty():
		var last: Enemy = current_targets.back()
		var distance: float = (last.get_node("HurtboxComponent").global_position - stream_start).dot(direction)
		stream_end = stream_start + direction * clampf(distance, 0.0, length)
	line.width = weapon.data.stats.ranged_settings.stream_width
	line.default_color = weapon.data.stats.ranged_settings.stream_color
	var config := weapon.data.stats.ranged_settings
	var local_start := to_local(stream_start)
	var local_end := to_local(stream_end)
	var side := (local_end-local_start).normalized().orthogonal()
	var strand_length := local_start.distance_to(local_end)
	var points := PackedVector2Array()
	var segments := maxi(6,ceili(strand_length/10.0))
	for i in range(segments+1):
		var t := float(i)/segments
		var wobble := (sin(t*strand_length*0.12-flow_phase)*0.7+sin(t*strand_length*0.23-flow_phase*1.3)*0.3)*sin(t*PI)
		points.append(local_start.lerp(local_end,t)+side*wobble*minf(config.stream_wobble,config.stream_width*0.2))
	line.points = points
	stream_material.set_shader_parameter("phase",flow_phase)
	stream_material.set_shader_parameter("strand_length",strand_length)
	stream_material.set_shader_parameter("mayo_color",config.stream_color)
	stream_material.set_shader_parameter("core_color",config.stream_core_color)
	stream_material.set_shader_parameter("edge_color",config.stream_edge_color)

func _emit_particles(delta: float) -> void:
	particle_left -= delta
	if particle_left > 0.0: return
	var config := weapon.data.stats.ranged_settings
	particle_left = config.stream_particle_interval
	var direction := stream_start.direction_to(stream_end)
	var particles = load("res://effects/mayonnaise_particles.gd")
	particles.emit_at(self,stream_start,direction,config,false)
	for enemy in current_targets:
		var point: Vector2 = enemy.get_node("HurtboxComponent").global_position
		particles.emit_at(self,point,direction,config,true)

func _damage_tick() -> void:
	hit.status_effects.clear()
	hit.setup(get_base_damage(), false, weapon.data.stats.knockback, weapon.get_parent())
	configure_hit_criticals(hit)
	hit.life_steal_chance = get_life_steal_chance()
	hit.weapon_damage_record = weapon.damage_record
	for enemy in current_targets:
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.health_component.current_health <= 0: continue
		enemy._on_hurtbox_component_on_damage(hit)

func _stop_stream() -> void:
	stream_active = false
	weapon.is_attacking = false
	tick_left = 0.0
	particle_left = 0.0
	current_targets.clear()
	line.hide()

func reset_attack() -> void:
	_stop_stream()
	super.reset_attack()
