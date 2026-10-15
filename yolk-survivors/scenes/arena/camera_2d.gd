extends Camera2D

var world_bounds := Rect2()
var shake_left := 0.0
var shake_length := 0.0
var shake_power := 0.0

func start_shake(strength: float, duration: float) -> void:
	shake_power = maxf(0, strength)
	shake_length = maxf(0.01, duration)
	shake_left = shake_length

func clear_shake() -> void:
	shake_left = 0
	offset = Vector2.ZERO

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _process(delta: float) -> void:
	if Global.game_paused: return
	if is_instance_valid(Global.player):
		global_position = Global.player.global_position
	if world_bounds.has_area():
		var half_view := get_viewport_rect().size / zoom * 0.5
		var min_center := world_bounds.position + half_view
		var max_center := world_bounds.end - half_view
		global_position.x = clampf(global_position.x, min_center.x, max_center.x) if min_center.x <= max_center.x else world_bounds.get_center().x
		global_position.y = clampf(global_position.y, min_center.y, max_center.y) if min_center.y <= max_center.y else world_bounds.get_center().y
	if shake_left > 0:
		shake_left = maxf(0, shake_left - delta)
		var phase := (shake_length - shake_left) * 80.0
		offset = Vector2(sin(phase), sin(phase * 1.37)) * shake_power * (shake_left / shake_length)
	else: offset = Vector2.ZERO
