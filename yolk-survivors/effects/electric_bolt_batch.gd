extends MultiMeshInstance2D
## One instance per aura/burst; all zigzag vertices are evaluated on the GPU.
const CAPACITY := 1024
var ray_count := 7
var segment_count := 3
var count := 0
var submitted_frame := -1
var buffer := PackedFloat32Array()
var capacity := CAPACITY

func configure(rays: int, burst: bool, instance_capacity: int = CAPACITY) -> void:
	capacity = maxi(1,instance_capacity)
	ray_count = maxi(1,rays)
	segment_count = 4 if burst else 3
	process_priority = 1001
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for ray in ray_count:
		for segment in segment_count:
			var first := vertices.size()
			for point in [Vector3(0,-0.5,0),Vector3(1,-0.5,0),Vector3(1,0.5,0),Vector3(0,0.5,0)]:
				vertices.append(point)
				uvs.append(Vector2(ray,segment))
			indices.append_array(PackedInt32Array([first,first+1,first+2,first,first+2,first+3]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	multimesh.use_colors = true
	multimesh.use_custom_data = true
	multimesh.mesh = mesh
	multimesh.instance_count = capacity
	multimesh.visible_instance_count = 0
	multimesh.custom_aabb = AABB(Vector3(-16384,-16384,-1),Vector3(32768,32768,2))
	buffer.resize(capacity*16)
	var shader_material := ShaderMaterial.new()
	shader_material.shader = preload("res://shaders/electric_bolts.gdshader")
	shader_material.set_shader_parameter("ray_count",float(ray_count))
	shader_material.set_shader_parameter("burst_mode",burst)
	material = shader_material

func submit_data(context: Node2D, center: Vector2, tint: Color, data: Color) -> void:
	var frame := Engine.get_process_frames()
	if submitted_frame!=frame:
		submitted_frame = frame
		count = 0
	if count>=capacity: return
	var world_transform := global_transform.affine_inverse()*context.global_transform
	world_transform.origin = world_transform*center
	var offset := count*16
	buffer[offset] = world_transform.x.x
	buffer[offset+1] = world_transform.y.x
	buffer[offset+3] = world_transform.origin.x
	buffer[offset+4] = world_transform.x.y
	buffer[offset+5] = world_transform.y.y
	buffer[offset+7] = world_transform.origin.y
	buffer[offset+8] = tint.r
	buffer[offset+9] = tint.g
	buffer[offset+10] = tint.b
	buffer[offset+11] = tint.a
	buffer[offset+12] = data.r
	buffer[offset+13] = data.g
	buffer[offset+14] = data.b
	buffer[offset+15] = data.a
	count += 1

func _process(_delta: float) -> void:
	if Global.game_paused: return
	if submitted_frame==Engine.get_process_frames():
		multimesh.buffer = buffer
		multimesh.visible_instance_count = count
	else:
		multimesh.visible_instance_count = 0

func clear() -> void:
	count = 0
	submitted_frame = -1
	multimesh.visible_instance_count = 0
