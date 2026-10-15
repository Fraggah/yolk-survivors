extends Node2D
var radius := 120.0
var elapsed := 0.0
const DURATION := 0.125
var duration := DURATION
var color := Color("86a9be")
var ring_width := 2.0
var spark_width := 1.5
var spark_length := 10.0
var spark_count := 16
var ring_start_radius := 0.3
var spark_start_radius := 0.45
const DEFAULT_Y_RATIO := 0.55
@export_range(0.1, 1.0) var y_ratio := DEFAULT_Y_RATIO
@export_range(0.0, 1.0) var opacity := 0.3

static func contains_offset(offset: Vector2, area_radius: float, ratio: float = DEFAULT_Y_RATIO) -> bool:
	return Vector2(offset.x, offset.y / maxf(ratio, 0.01)).length_squared() <= area_radius * area_radius
func _ready() -> void:
	z_as_relative = false
	z_index = 0
func _process(delta: float) -> void:
	if Global.game_paused: return
	elapsed += delta
	if elapsed >= maxf(0.01, duration): queue_free()
	queue_redraw()
func _draw() -> void:
	var progress := clampf(elapsed / maxf(0.01, duration), 0.0, 1.0)
	var paint := color
	paint.a *= (1.0 - progress) * opacity
	var projection := Vector2(1.0, y_ratio)
	var ring := PackedVector2Array()
	for i in 49:
		ring.append(Vector2.from_angle(TAU * i / 48.0) * radius * lerpf(ring_start_radius, 1.0, progress) * projection)
	draw_polyline(ring, paint, ring_width, true)
	for i in spark_count:
		var direction := Vector2.from_angle(TAU * i / spark_count)
		var point := direction * radius * lerpf(spark_start_radius, 1.0, progress)
		draw_line(point * projection, (point - direction * spark_length) * projection, paint, spark_width, true)
