extends Node2D
## Shared bounded instanced glow segments for all electrical status/burst effects.
const CAPACITY := 8192
var instances: MultiMesh
var count := 0
var submitted_frame := -1
var buffer := PackedFloat32Array()
var bolt_batches: Dictionary = {}

func _ready() -> void:
	process_priority = 1000
	z_as_relative = false
	z_index = 3
	var mesh := QuadMesh.new()
	mesh.size = Vector2.ONE
	instances = MultiMesh.new()
	instances.transform_format = MultiMesh.TRANSFORM_2D
	instances.use_colors = true
	instances.use_custom_data = true
	instances.mesh = mesh
	instances.instance_count = CAPACITY
	instances.visible_instance_count = 0
	buffer.resize(CAPACITY*16)
	instances.custom_aabb = AABB(Vector3(-16384,-16384,-1),Vector3(32768,32768,2))
	var batch := MultiMeshInstance2D.new()
	batch.multimesh = instances
	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/electric_ray.gdshader")
	batch.material = material
	add_child(batch)
	_get_bolt_batch(7,false)
	_get_bolt_batch(7,true)

func _get_bolt_batch(rays: int, burst: bool):
	var key := Vector2i(rays,1 if burst else 0)
	if not bolt_batches.has(key):
		var batch = preload("res://effects/electric_bolt_batch.gd").new()
		batch.configure(rays,burst)
		add_child(batch)
		bolt_batches[key] = batch
	return bolt_batches[key]

func submit_aura(context: Node2D, center: Vector2, extent: Vector2, elapsed: float, left: float, tint: Color, glow: float, rays: int) -> void:
	if rays<=0: return
	_get_bolt_batch(rays,false).submit_data(context,center,Color(tint,minf(1.0,left/0.25)),Color(extent.x,extent.y,elapsed,glow))

func submit_burst(context: Node2D, radius: float, progress: float, elapsed: float, tint: Color, glow: float, rays: int) -> void:
	if rays<=0: return
	_get_bolt_batch(rays,true).submit_data(context,Vector2.ZERO,Color(tint,(1.0-progress)*(1.0-progress)),Color(radius,progress,elapsed,glow))

func active_segment_count() -> int:
	var total := instances.visible_instance_count
	for batch in bolt_batches.values():
		total += batch.multimesh.visible_instance_count*batch.ray_count*batch.segment_count
	return total

func submit(context: Node2D, points: PackedVector2Array, tint: Color, width: float, glow: float) -> void:
	var frame := Engine.get_process_frames()
	if frame!=submitted_frame:
		count = 0
		submitted_frame = frame
	var transform := context.global_transform
	if points.size()<2: return
	var scaled_width := width*transform.x.length()
	var start := transform*points[0]
	for i in range(1,points.size()):
		if count>=CAPACITY: break
		var end := transform*points[i]
		var direction := end-start
		var length := direction.length()
		var size := Vector2(length+1.5,scaled_width)
		var axis := direction/maxf(0.00001,length)
		var position := (start+end)*0.5
		var offset := count*16
		# MultiMesh 2D buffer: two padded matrix rows, color, custom data.
		buffer[offset] = axis.x*size.x
		buffer[offset+1] = -axis.y*size.y
		buffer[offset+3] = position.x
		buffer[offset+4] = axis.y*size.x
		buffer[offset+5] = axis.x*size.y
		buffer[offset+7] = position.y
		buffer[offset+8] = tint.r
		buffer[offset+9] = tint.g
		buffer[offset+10] = tint.b
		buffer[offset+11] = tint.a
		buffer[offset+12] = glow
		count += 1
		start = end

func _process(_delta: float) -> void:
	if Global.game_paused: return
	if submitted_frame==Engine.get_process_frames(): instances.buffer = buffer
	instances.visible_instance_count = count if submitted_frame==Engine.get_process_frames() else 0

func clear() -> void:
	count = 0
	submitted_frame = -1
	instances.visible_instance_count = 0
	for batch in bolt_batches.values(): batch.clear()
