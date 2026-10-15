extends Node2D
## Shared short-lived pool for wave retirement and tray impacts.
const MAX_PARTICLES := 4096
var particles: Array[Dictionary] = []

static func emit_at(context: Node, at: Vector2, impact: bool = false, footprint: Vector2 = Vector2.ZERO) -> void:
	var arena = context.get_tree().current_scene
	if not is_instance_valid(arena): return
	var emitter = arena.get_node_or_null("ArenaBursts")
	if not emitter:
		emitter = load("res://effects/arena_bursts.gd").new()
		emitter.name = "ArenaBursts"
		arena.add_child(emitter)
	emitter.emit_burst(at, impact, footprint)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_as_relative = false
	z_index = 8
	set_process(false)

func emit_burst(at: Vector2, impact: bool, footprint: Vector2 = Vector2.ZERO) -> void:
	var count := 28 if impact else 6
	for i in count:
		if particles.size() >= MAX_PARTICLES: break
		var angle := randf() * TAU
		var origin := at
		if impact and footprint.x > 0:
			var half := footprint * 0.5
			var edge := Vector2(-half.x if i%2 == 0 else half.x, randf_range(-half.y,half.y)) if i%4 < 2 else Vector2(randf_range(-half.x,half.x), -half.y if i%2 == 0 else half.y)
			origin += edge
			angle = edge.angle() + randf_range(-0.5,0.5)
		var velocity := Vector2.from_angle(angle) * randf_range(180,420) if impact else Vector2.from_angle(angle) * randf_range(45,95)
		if impact: velocity.y *= 0.55
		var duration := randf_range(0.28,0.48) if impact else randf_range(0.22,0.34)
		particles.append({"position":origin,"velocity":velocity,"life":duration,"duration":duration,"radius":randf_range(3,7),"impact":impact,"color":Color("fff2ce") if i%2 == 0 else Color("d7b477")})
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	for i in range(particles.size()-1,-1,-1):
		var p := particles[i]
		if Global.game_paused and p.impact: continue
		p.life -= delta
		if p.life <= 0:
			particles.remove_at(i)
			continue
		p.position += p.velocity * delta
		p.velocity *= exp(-5.0 * delta)
	queue_redraw()
	set_process(not particles.is_empty())

func _draw() -> void:
	for p in particles:
		var fade: float = clampf(p.life/p.duration,0,1)
		var color: Color = p.color
		color.a = fade
		var radius: float = p.radius * (0.4+0.6*fade)
		if p.impact:
			var direction: Vector2 = p.velocity.normalized()
			draw_line(p.position-direction*radius,p.position+direction*radius,color,4.0,true)
		else:
			draw_circle(p.position,radius,color,true,-1,true)

func clear_impacts() -> void:
	particles = particles.filter(func(p): return not p.impact)
	queue_redraw()
	set_process(not particles.is_empty())
