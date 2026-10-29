extends Node2D
## Shared bounded instanced glow segments for all electrical status/burst effects.
const CAPACITY := 8192
@export var shared_batches := true
@export_range(16,512,16) var aura_capacity := 192
@export_range(8,256,8) var burst_capacity := 64
var instances: MultiMesh
var count := 0
var submitted_frame := -1
var buffer := PackedFloat32Array()
var bolt_batches: Dictionary = {}
var depth_batches: Array[WeakRef] = []

func _depth_batch(context: Node2D, rays: int, burst: bool):
	# A shared world batch cannot interleave with actors and columns. Keep one
	# tiny, reusable GPU batch inside each owner instead (one instance, no pool).
	var key := "DepthBolts_%s_%s" % [rays,int(burst)]
	var batch = context.get_node_or_null(key)
	if not batch:
		batch = preload("res://effects/electric_bolt_batch.gd").new()
		batch.name = key
		batch.configure(rays,burst,1)
		context.add_child(batch)
		if depth_batches.size()%64==0:
			depth_batches = depth_batches.filter(func(reference): return is_instance_valid(reference.get_ref()))
		depth_batches.append(weakref(batch))
	return batch

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
	var ray_material := ShaderMaterial.new()
	ray_material.shader = preload("res://shaders/electric_ray.gdshader")
	batch.material = ray_material
	add_child(batch)
	_get_bolt_batch(7,false)
	_get_bolt_batch(7,true)

func _get_bolt_batch(rays: int, burst: bool):
	var key := Vector2i(rays,1 if burst else 0)
	if not bolt_batches.has(key):
		var batch = preload("res://effects/electric_bolt_batch.gd").new()
		batch.configure(rays,burst,burst_capacity if burst else aura_capacity)
		add_child(batch)
		bolt_batches[key] = batch
	return bolt_batches[key]

func submit_aura(context: Node2D, center: Vector2, extent: Vector2, elapsed: float, left: float, tint: Color, glow: float, rays: int) -> void:
	if rays<=0: return
	var batch = _get_bolt_batch(rays,false) if shared_batches else _depth_batch(context,rays,false)
	batch.submit_data(context,center,Color(tint,minf(1.0,left/0.25)),Color(extent.x,extent.y,elapsed,glow))

func submit_burst(context: Node2D, radius: float, progress: float, elapsed: float, tint: Color, glow: float, rays: int) -> void:
	if rays<=0: return
	var batch = _get_bolt_batch(rays,true) if shared_batches else _depth_batch(context,rays,true)
	batch.submit_data(context,Vector2.ZERO,Color(tint,(1.0-progress)*(1.0-progress)),Color(radius,progress,elapsed,glow))

func active_segment_count() -> int:
	var total := instances.visible_instance_count
	for batch in bolt_batches.values():
		total += batch.multimesh.visible_instance_count*batch.ray_count*batch.segment_count
	depth_batches = depth_batches.filter(func(reference): return is_instance_valid(reference.get_ref()))
	for reference in depth_batches:
		var batch = reference.get_ref()
		total += batch.multimesh.visible_instance_count*batch.ray_count*batch.segment_count
	return total

func submit(context: Node2D, points: PackedVector2Array, tint: Color, width: float, glow: float) -> void:
	var frame := Engine.get_process_frames()
	if frame!=submitted_frame:
		count = 0
		submitted_frame = frame
	var world_transform := context.global_transform
	if points.size()<2: return
	var scaled_width := width*world_transform.x.length()
	var start := world_transform*points[0]
	for i in range(1,points.size()):
		if count>=CAPACITY: break
		var end := world_transform*points[i]
		var direction := end-start
		var length := direction.length()
		var size := Vector2(length+1.5,scaled_width)
		var axis := direction/maxf(0.00001,length)
		var segment_center := (start+end)*0.5
		var offset := count*16
		# MultiMesh 2D buffer: two padded matrix rows, color, custom data.
		buffer[offset] = axis.x*size.x
		buffer[offset+1] = -axis.y*size.y
		buffer[offset+3] = segment_center.x
		buffer[offset+4] = axis.y*size.x
		buffer[offset+5] = axis.x*size.y
		buffer[offset+7] = segment_center.y
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
	for reference in depth_batches:
		var batch = reference.get_ref()
		if is_instance_valid(batch): batch.clear()
	depth_batches = depth_batches.filter(func(reference): return is_instance_valid(reference.get_ref()))
