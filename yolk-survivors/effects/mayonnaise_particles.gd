extends Node2D
## Reusable particles plus one instanced draw for every stream's droplets.
const MAX_PARTICLES := 1800
var particles: Array[Dictionary] = []
var free_particles: Array[Dictionary] = []
var instances: MultiMesh
var batch: MultiMeshInstance2D

static func emit_at(context: Node, point: Vector2, direction: Vector2, settings: RangedSettings, impact: bool) -> void:
	var arena := context.get_tree().current_scene
	if not is_instance_valid(arena): return
	var pool = arena.get_node_or_null("MayonnaiseParticles")
	if not pool:
		pool = load("res://effects/mayonnaise_particles.gd").new()
		pool.name = "MayonnaiseParticles"
		arena.add_child(pool)
	pool.emit_splash(point, direction, settings, impact)

func _ready() -> void:
	add_to_group("mayonnaise_particles")
	z_as_relative = false
	z_index = 3
	for i in MAX_PARTICLES: free_particles.append({})
	var mesh := QuadMesh.new()
	mesh.size = Vector2.ONE
	instances = MultiMesh.new()
	instances.transform_format = MultiMesh.TRANSFORM_2D
	instances.use_colors = true
	instances.mesh = mesh
	# Border, body and highlight keep the previous layered droplet appearance,
	# but all layers of all droplets share one material and one MultiMesh.
	instances.instance_count = MAX_PARTICLES * 3
	instances.visible_instance_count = 0
	instances.custom_aabb = AABB(Vector3(-16384,-16384,-1),Vector3(32768,32768,2))
	batch = MultiMeshInstance2D.new()
	batch.multimesh = instances
	var shader_material := ShaderMaterial.new()
	shader_material.shader = preload("res://shaders/mayonnaise_droplet.gdshader")
	batch.material = shader_material
	add_child(batch)
	set_process(false)

func emit_splash(point: Vector2, direction: Vector2, settings: RangedSettings, impact: bool) -> void:
	var count := settings.stream_impact_particles if impact else settings.stream_muzzle_particles
	for i in count:
		if particles.size() >= MAX_PARTICLES: break
		var angle := direction.angle() + (PI if impact else 0.0) + randf_range(-1.35, 1.35)
		var speed := settings.stream_particle_speed * Global.GAME_ENTITY_SCALE * randf_range(0.4, 1.35)
		var velocity := Vector2.from_angle(angle) * speed
		velocity.y *= 0.6
		var life := settings.stream_particle_lifetime * randf_range(0.65, 1.15)
		var particle: Dictionary = free_particles.pop_back()
		particle.position = point + Vector2(randf_range(-3,3),randf_range(-2,2))
		particle.velocity = velocity
		particle.life = life
		particle.duration = life
		particle.radius = randf_range(1.2,2.7)*Global.GAME_ENTITY_SCALE
		particle.body = settings.stream_color
		particle.core = settings.stream_core_color
		particle.edge = settings.stream_edge_color
		particle.impact = impact
		particles.append(particle)
	set_process(not particles.is_empty())

func clear() -> void:
	free_particles.append_array(particles)
	particles.clear()
	instances.visible_instance_count = 0
	set_process(false)

func _process(delta: float) -> void:
	if Global.game_paused: return
	for i in range(particles.size()-1,-1,-1):
		var particle := particles[i]
		particle.life -= delta
		if particle.life <= 0.0:
			free_particles.append(particle)
			# Swap-remove avoids shifting every following particle on expiry.
			particles[i] = particles.back()
			particles.pop_back()
			continue
		particle.position += particle.velocity * delta
		particle.velocity *= exp(-3.0 * delta)
		particle.velocity.y += 180.0 * delta
	_update_instances()
	set_process(not particles.is_empty())

func _update_instances() -> void:
	for i in particles.size():
		var particle := particles[i]
		var fade := clampf(particle.life / minf(0.12, particle.duration),0.0,1.0)
		var radius: float = particle.radius * (0.55+0.45*fade)
		var velocity: Vector2 = particle.velocity
		var particle_transform := Transform2D(velocity.angle(),Vector2(radius*2.0*1.35,radius*2.0*0.8),0.0,particle.position)
		var index := i * 3
		instances.set_instance_transform_2d(index,particle_transform)
		instances.set_instance_color(index,Color(particle.edge,fade))
		instances.set_instance_transform_2d(index+1,Transform2D(particle_transform.x*0.78,particle_transform.y*0.78,particle_transform.origin))
		instances.set_instance_color(index+1,Color(particle.body,fade))
		instances.set_instance_transform_2d(index+2,Transform2D(particle_transform.x*0.35,particle_transform.y*0.35,particle_transform*Vector2(-0.08,-0.1)))
		instances.set_instance_color(index+2,Color(particle.core,fade))
	instances.visible_instance_count = particles.size() * 3
