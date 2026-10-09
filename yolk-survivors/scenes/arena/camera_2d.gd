extends Camera2D

var world_bounds := Rect2()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _process(_delta: float) -> void:
	if is_instance_valid(Global.player):
		global_position = Global.player.global_position
	if world_bounds.has_area():
		var half_view := get_viewport_rect().size / zoom * 0.5
		var min_center := world_bounds.position + half_view
		var max_center := world_bounds.end - half_view
		global_position.x = clampf(global_position.x, min_center.x, max_center.x) if min_center.x <= max_center.x else world_bounds.get_center().x
		global_position.y = clampf(global_position.y, min_center.y, max_center.y) if min_center.y <= max_center.y else world_bounds.get_center().y
