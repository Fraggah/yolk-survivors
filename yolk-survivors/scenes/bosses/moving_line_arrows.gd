extends Control
var section: Node2D
var badges: Array[Node2D] = []
const BADGE_SCENE = preload("res://scenes/bosses/moving_line_arrow_badge.tscn")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_to_group("boss_moving_line_arrows")

func markers() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not is_instance_valid(section) or not section.running or section.stage != 0: return result
	var viewport_size := get_viewport_rect().size
	var center := viewport_size*0.5
	var safe := Rect2(Vector2(104,180),viewport_size-Vector2(208,396))
	var canvas := get_viewport().get_canvas_transform()
	for direction in section.warning_directions:
		var forward: Vector2 = canvas.basis_xform(direction).normalized()
		var incoming := -forward
		var distance := INF
		if incoming.x > 0.00001: distance = minf(distance,(safe.end.x-center.x)/incoming.x)
		elif incoming.x < -0.00001: distance = minf(distance,(safe.position.x-center.x)/incoming.x)
		if incoming.y > 0.00001: distance = minf(distance,(safe.end.y-center.y)/incoming.y)
		elif incoming.y < -0.00001: distance = minf(distance,(safe.position.y-center.y)/incoming.y)
		result.append({"point":center+incoming*distance,"direction":forward})
	return result

func _process(_delta: float) -> void:
	if not Global.game_paused: refresh()

func refresh() -> void:
	var entries := markers()
	while badges.size()<entries.size():
		var badge: Node2D = BADGE_SCENE.instantiate()
		badge.set_meta("rest_scale",badge.scale)
		add_child(badge)
		badges.append(badge)
	for index in badges.size():
		var badge := badges[index]
		badge.visible = index<entries.size()
		if not badge.visible: continue
		var marker: Dictionary = entries[index]
		badge.position = marker.point
		badge.rotation = marker.direction.angle()
		badge.scale = badge.get_meta("rest_scale")*(1.0+0.08*sin(section.elapsed*22))
		badge.get_node("Arrow").material.set_shader_parameter("phase",section.elapsed)
		badge.get_node("Border").material.set_shader_parameter("phase",section.elapsed)
