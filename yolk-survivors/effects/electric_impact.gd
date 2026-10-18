extends Node2D
## A detached impact burst survives the target's death. Purely visual.
var duration := 0.38
var elapsed := 0.0
var radius := 40.0
var ray_count := 7
var tint := Color("80dfff")
var glow := 1.0
var endpoints: Array[Vector2] = []

func configure(effect: StatusEffect, origin: Vector2, chain_endpoints: Array[Vector2]) -> void:
	global_position = origin
	duration = effect.electric_impact_duration
	radius = maxf(28.0, effect.chain_radius) * Global.GAME_ENTITY_SCALE * effect.electric_visual_scale
	ray_count = effect.electric_ray_count
	tint = effect.color
	glow = effect.electric_glow_strength
	for point in chain_endpoints: endpoints.append(point - origin)
	queue_redraw()

func _ready() -> void:
	add_to_group("projectiles")
	z_as_relative = true
	z_index = 0

func _process(delta: float) -> void:
	if Global.game_paused: return
	elapsed += delta
	if elapsed >= duration: queue_free()
	else: _submit_rays()

func _bolt(points: PackedVector2Array, alpha: float) -> void:
	# Chains belong to this impact's ground depth, not a foreground world batch.
	draw_polyline(points,Color(tint,alpha*0.08*glow),12.0,true)
	draw_polyline(points,Color(tint,alpha*0.3*glow),5.0,true)
	draw_polyline(points,Color(tint.lightened(0.65),alpha),1.5,true)

func _submit_rays() -> void:
	var progress := clampf(elapsed / duration, 0.0, 1.0)
	ElectricRays.submit_burst(self,radius,progress,elapsed,tint,glow,ray_count)
	queue_redraw()

func _draw() -> void:
	var progress := clampf(elapsed / duration, 0.0, 1.0)
	var alpha := (1.0 - progress) * (1.0 - progress)
	var seed_frame := floorf(elapsed * 35.0)
	for endpoint in endpoints:
		var normal := endpoint.orthogonal().normalized()
		var wobble := sin(seed_frame * 3.7) * 7.0
		_bolt(PackedVector2Array([Vector2.ZERO, endpoint * 0.25 + normal * wobble, endpoint * 0.5 - normal * wobble, endpoint * 0.75 + normal * wobble, endpoint]), alpha)
