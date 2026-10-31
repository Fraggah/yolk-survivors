extends Node2D

# One shared draw node and a fixed particle pool, independent of hit frequency.
const MAX_PARTICLES := 128
const EMISSION_INTERVAL := 0.08
@export_range(32, 128, 8) var active_limit := 96
@export var gpu_animation := true
var cream_buffer := PackedFloat32Array()
var shell_buffer := PackedFloat32Array()
var buffers_dirty := false
var gpu_materials: Array[ShaderMaterial] = []
const CREAM := Color("fff7e6")
const SHELL := Color("ead6b5")
const OUTLINE := Color("695039")

var _particles: Array[Dictionary] = []
var _enemy_cooldowns: Dictionary = {}
var _time := 0.0
var active_count := 0
var cream_instances: MultiMesh
var shell_instances: MultiMesh

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	z_index = 8
	var quad := QuadMesh.new()
	quad.size = Vector2(2,2)
	cream_instances = _make_batch(quad,true)
	var polygon := ArrayMesh.new()
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([Vector3(-1,-0.5,0),Vector3(0.3,-0.9,0),Vector3(1,0.3,0),Vector3(-0.3,0.9,0)])
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0,1,2,0,2,3])
	polygon.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	shell_instances = _make_batch(polygon,false)
	for i in MAX_PARTICLES:
		_particles.append({"life": 0.0, "duration": 0.0, "position": Vector2.ZERO,
			"velocity": Vector2.ZERO, "size": 0.0, "angle": 0.0, "spin": 0.0, "shell": false})
	set_process(false)

func emit_hit(enemy_id: int, at: Vector2, direction: Vector2, critical: bool) -> void:
	if _time < float(_enemy_cooldowns.get(enemy_id, -1.0)): return
	_enemy_cooldowns[enemy_id] = _time + EMISSION_INTERVAL
	var drops := 4 if critical else randi_range(2, 3)
	var total := drops + (2 if critical else 1)
	var emitted := 0
	for slot in _particles.size():
		var particle: Dictionary = _particles[slot]
		if active_count >= active_limit: break
		if particle.life > 0.0: continue
		var shell := emitted >= drops
		particle.duration = randf_range(0.30, 0.40)
		particle.life = particle.duration
		particle.position = at + Vector2.from_angle(randf_range(-PI, PI)) * randf_range(4.0, 12.0)
		particle.velocity = direction.rotated(randf_range(-1.1, 1.1)) * randf_range(100.0, 190.0)
		particle.size = randf_range(4.5, 7.5) * (1.25 if critical else 1.0)
		particle.angle = randf_range(-PI, PI)
		particle.spin = randf_range(-12.0, 12.0)
		particle.shell = shell
		if gpu_animation: _write_particle(slot, particle)
		active_count += 1
		emitted += 1
		if emitted >= total: break
	set_process(active_count > 0)

func _process(delta: float) -> void:
	_time += delta
	for enemy_id in _enemy_cooldowns.keys():
		if float(_enemy_cooldowns[enemy_id]) <= _time: _enemy_cooldowns.erase(enemy_id)
	for particle in _particles:
		if particle.life <= 0.0: continue
		particle.life = maxf(0.0, particle.life - delta)
		if particle.life == 0.0:
			active_count -= 1
			continue
		if not gpu_animation:
			particle.position += particle.velocity * delta
			particle.velocity *= exp(-7.0 * delta)
			particle.angle += particle.spin * delta
	_update_instances()
	set_process(active_count > 0)

func _make_batch(mesh: Mesh, circular: bool) -> MultiMesh:
	var instances := MultiMesh.new()
	instances.transform_format = MultiMesh.TRANSFORM_2D
	instances.use_colors = true
	instances.use_custom_data = true
	instances.mesh = mesh
	instances.instance_count = MAX_PARTICLES*2
	instances.visible_instance_count = 0
	instances.custom_aabb = AABB(Vector3(-16384,-16384,-1),Vector3(32768,32768,2))
	var batch := MultiMeshInstance2D.new()
	batch.multimesh = instances
	if gpu_animation:
		var particle_material := ShaderMaterial.new()
		particle_material.shader = preload("res://shaders/hit_particle_batch.gdshader")
		particle_material.set_shader_parameter("circular", circular)
		batch.material = particle_material
		gpu_materials.append(particle_material)
		if circular: cream_buffer.resize(MAX_PARTICLES * 32)
		else: shell_buffer.resize(MAX_PARTICLES * 32)
	elif circular:
		var particle_material := ShaderMaterial.new()
		particle_material.shader = preload("res://shaders/mayonnaise_droplet.gdshader")
		batch.material = particle_material
	add_child(batch)
	return instances

func _write_particle(slot: int, particle: Dictionary) -> void:
	var selected := shell_buffer if particle.shell else cream_buffer
	var unused := cream_buffer if particle.shell else shell_buffer
	for layer in 2:
		var at := (slot * 2 + layer) * 16
		# Erase the previous occupant of this slot in the other shape batch.
		unused[at+11] = 0.0
		var radius: float = particle.size * (0.84 if layer else 1.0)
		var particle_angle: float = particle.angle if particle.shell else 0.0
		var axis := Vector2.from_angle(particle_angle) * radius
		selected[at] = axis.x
		selected[at+1] = -axis.y
		selected[at+3] = particle.position.x
		selected[at+4] = axis.y
		selected[at+5] = axis.x
		selected[at+7] = particle.position.y
		var tint := (SHELL if particle.shell else CREAM) if layer else OUTLINE
		selected[at+8] = tint.r
		selected[at+9] = tint.g
		selected[at+10] = tint.b
		selected[at+11] = particle.duration
		selected[at+12] = particle.velocity.x
		selected[at+13] = particle.velocity.y
		selected[at+14] = particle.spin if particle.shell else 0.0
		selected[at+15] = _time
	buffers_dirty = true

func _update_instances() -> void:
	if gpu_animation:
		if buffers_dirty:
			cream_instances.buffer = cream_buffer
			shell_instances.buffer = shell_buffer
			buffers_dirty = false
		for particle_material in gpu_materials: particle_material.set_shader_parameter("elapsed", _time)
		cream_instances.visible_instance_count = MAX_PARTICLES * 2 if active_count > 0 else 0
		shell_instances.visible_instance_count = MAX_PARTICLES * 2 if active_count > 0 else 0
		return
	var cream_count := 0
	var shell_count := 0
	for particle in _particles:
		if particle.life <= 0.0: continue
		var alpha := minf(1.0, particle.life / particle.duration * 2.0)
		var radius: float = particle.size * (0.65 + 0.35 * particle.life / particle.duration)
		if particle.shell:
			var particle_transform := Transform2D(particle.angle,Vector2.ONE*radius,0.0,particle.position)
			var index := shell_count*2
			shell_instances.set_instance_transform_2d(index,particle_transform)
			shell_instances.set_instance_color(index,Color(OUTLINE,alpha))
			shell_instances.set_instance_transform_2d(index+1,Transform2D(particle_transform.x*0.84,particle_transform.y*0.84,particle_transform.origin))
			shell_instances.set_instance_color(index+1,Color(SHELL,alpha))
			shell_count += 1
		else:
			var index := cream_count*2
			cream_instances.set_instance_transform_2d(index,Transform2D(0,Vector2.ONE*radius,0.0,particle.position))
			cream_instances.set_instance_color(index,Color(OUTLINE,alpha))
			cream_instances.set_instance_transform_2d(index+1,Transform2D(0,Vector2.ONE*maxf(0.5,radius-1.0),0.0,particle.position))
			cream_instances.set_instance_color(index+1,Color(CREAM,alpha))
			cream_count += 1
	cream_instances.visible_instance_count = cream_count*2
	shell_instances.visible_instance_count = shell_count*2

func clear() -> void:
	for particle in _particles: particle.life = 0.0
	_enemy_cooldowns.clear()
	if gpu_animation:
		cream_buffer.fill(0.0)
		shell_buffer.fill(0.0)
		buffers_dirty = true
	active_count = 0
	cream_instances.visible_instance_count = 0
	shell_instances.visible_instance_count = 0
	set_process(false)
