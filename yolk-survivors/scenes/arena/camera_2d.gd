extends Camera2D

@export var overview_padding := Vector2(32,32)
var overview_toggle_enabled := false
var overview := false
var follow_zoom := Vector2.ONE
var world_bounds := Rect2()
var overview_bounds := Rect2()
var shake_left := 0.0
var shake_length := 0.0
var shake_power := 0.0

func configure_view(bounds: Rect2, tracking_zoom: Vector2, allow_toggle: bool, full_arena_bounds := Rect2()) -> void:
	world_bounds = bounds
	overview_bounds = full_arena_bounds if full_arena_bounds.has_area() else bounds
	follow_zoom = tracking_zoom
	overview_toggle_enabled = allow_toggle
	overview = false
	zoom = follow_zoom
	clear_shake()
	reset_smoothing()

func _input(event: InputEvent) -> void:
	if not Global.coop_players.is_empty(): return
	if not overview_toggle_enabled or Global.game_paused: return
	var arena = get_parent()
	if not arena.in_arena: return
	var mouse: bool = event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_RIGHT and event.pressed
	var pad: bool = event is InputEventJoypadButton and event.button_index==JOY_BUTTON_RIGHT_SHOULDER and event.pressed
	if mouse or pad:
		toggle_view()
		get_viewport().set_input_as_handled()

func toggle_view() -> void:
	if not overview_toggle_enabled or not world_bounds.has_area(): return
	overview = not overview
	zoom = follow_zoom
	clear_shake()
	_process(0)
	reset_smoothing()
	force_update_scroll()

func start_shake(strength: float, duration: float) -> void:
	shake_power = maxf(0, strength)
	shake_length = maxf(0.01, duration)
	shake_left = shake_length

func laser_coverage_bounds() -> Rect2:
	var viewport_size := get_viewport_rect().size
	var available := (viewport_size-overview_padding).max(Vector2.ONE)
	var fit := minf(available.x/overview_bounds.size.x,available.y/overview_bounds.size.y)
	var overview_size := viewport_size/maxf(fit,0.001)
	var current_size := viewport_size/zoom
	return world_bounds.merge(Rect2(overview_bounds.get_center()-overview_size*0.5,overview_size)).merge(Rect2(global_position-current_size*0.5,current_size))

func clear_shake() -> void:
	shake_left = 0
	offset = Vector2.ZERO

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _process(delta: float) -> void:
	if Global.game_paused: return
	if overview:
		var available := (get_viewport_rect().size-overview_padding).max(Vector2.ONE)
		zoom = Vector2.ONE * minf(available.x/overview_bounds.size.x,available.y/overview_bounds.size.y)
		global_position = overview_bounds.get_center()
	elif is_instance_valid(Global.player):
		global_position = Global.player.global_position
	if world_bounds.has_area() and not overview:
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
	if overview_toggle_enabled:
		var half_view := get_viewport_rect().size / zoom * 0.5
		get_parent().environment_controller.cover_camera_background(Rect2(global_position-half_view,half_view*2).grow(32))
