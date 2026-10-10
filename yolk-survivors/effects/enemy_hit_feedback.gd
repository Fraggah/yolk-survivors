extends Node2D

# One shared draw node and a fixed particle pool, independent of hit frequency.
const MAX_PARTICLES := 128
const EMISSION_INTERVAL := 0.08
const CREAM := Color("fff7e6")
const SHELL := Color("ead6b5")
const OUTLINE := Color("695039")

var _particles: Array[Dictionary] = []
var _enemy_cooldowns: Dictionary = {}
var _time := 0.0
var active_count := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	z_index = 8
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
	for particle in _particles:
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
		active_count += 1
		emitted += 1
		if emitted >= total: break
	set_process(active_count > 0)
	queue_redraw()

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
		particle.position += particle.velocity * delta
		particle.velocity *= exp(-7.0 * delta)
		particle.angle += particle.spin * delta
	queue_redraw()
	set_process(active_count > 0)

func _draw() -> void:
	for particle in _particles:
		if particle.life <= 0.0: continue
		var alpha := minf(1.0, particle.life / particle.duration * 2.0)
		var radius: float = particle.size * (0.65 + 0.35 * particle.life / particle.duration)
		if particle.shell:
			var points := PackedVector2Array()
			for point in [Vector2(-1,-0.5), Vector2(0.3,-0.9), Vector2(1,0.3), Vector2(-0.3,0.9)]:
				points.append(particle.position + point.rotated(particle.angle) * radius)
			draw_colored_polygon(points, Color(SHELL, alpha))
			points.append(points[0])
			draw_polyline(points, Color(OUTLINE, alpha), 1.2, true)
		else:
			draw_circle(particle.position, radius, Color(OUTLINE, alpha), true, -1.0, true)
			draw_circle(particle.position, maxf(0.5, radius - 1.0), Color(CREAM, alpha), true, -1.0, true)

func clear() -> void:
	for particle in _particles: particle.life = 0.0
	_enemy_cooldowns.clear()
	active_count = 0
	set_process(false)
	queue_redraw()
