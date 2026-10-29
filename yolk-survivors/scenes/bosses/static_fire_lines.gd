extends Node2D
## Fixed lines only. Shared fire hitboxes apply the boss attack effects.
class LineVisual extends Node2D:
	var length := 100.0
	var width := 24.0
	var warning_progress := 0.0
	var phase := 0.0
	var mode := 0

var area: ArenaEnvironment
var config: Resource
var source: Node2D
var elapsed := 0.0
var pattern_index := -1
var stage := -1 # 0 warning, 1 active, 2 rest
var lines: Array[Dictionary] = []
var running := false
var persistent_glow := false
var active_started_at := -1.0
var current_label := ""

func setup(geometry: ArenaEnvironment, settings: Resource, damage_source: Node2D) -> void:
	area = geometry
	config = settings
	source = damage_source
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("boss_hazards")
	running = true
	advance(0)

func advance(delta: float) -> void:
	if not running or Global.game_paused: return
	elapsed += maxf(0,delta)
	if elapsed >= config.section_seconds:
		stop()
		return
	var cycle: float = config.line_warning_seconds + config.line_active_seconds + config.line_rest_seconds
	if config.static_line_patterns.is_empty() or cycle <= 0: return
	var index: int = int(floor(elapsed/cycle)) % config.static_line_patterns.size()
	var local_time := fposmod(elapsed,cycle)
	if index != pattern_index:
		_clear_lines()
		pattern_index = index
		stage = -1
		_build_pattern(config.static_line_patterns[index])
	var next_stage := 0 if local_time < config.line_warning_seconds else 1 if local_time < config.line_warning_seconds+config.line_active_seconds else 2
	set_line_stage(next_stage)
	animate_lines(elapsed,clampf(local_time/config.line_warning_seconds,0,1))

## Shared by the fixed turret emitters, using the same warnings and hitboxes.
func set_line_stage(next_stage: int) -> void:
	if next_stage == stage: return
	stage = next_stage
	if stage in [0,1]: SoundManager.play_event("laser_warning" if stage==0 else "laser_fire")
	if stage==1: active_started_at = -1.0
	for line in lines:
		line.visual.mode = stage
		line.visual.visible = stage != 2
		line.fire.visible = stage == 1
		if stage==1:
			# Set the peak before the first visible frame; no fade-in.
			line.material.set_shader_parameter("flash",0.0 if persistent_glow else 1.0)
			line.glow.material.set_shader_parameter("intensity",config.laser_glow_strength if persistent_glow else config.laser_glow_strength*0.65+config.laser_flash_strength)
		line.glow.visible = stage == 1
		line.warning.visible = stage == 0
		line.hit.damage = config.line_damage if stage == 1 else 0.0
		line.hit.base_damage = line.hit.damage
		line.hit.collision_layer = 4 if stage == 1 else 0
		line.shape.set_deferred("disabled",stage != 1)

func animate_lines(clock: float, warning_progress: float) -> void:
	if stage==1 and active_started_at<0: active_started_at=clock
	var flash := pow(maxf(0.0,1.0-(clock-active_started_at)/config.laser_flash_seconds),2.0) if stage==1 and not persistent_glow else 0.0
	for line in lines:
		line.visual.warning_progress = warning_progress
		line.visual.queue_redraw()
		line.warning.scale = Vector2(line.visual.length,line.visual.width)
		line.warning.material.set_shader_parameter("phase",clock)
		line.warning.material.set_shader_parameter("warning_progress",warning_progress)
		line.warning.material.set_shader_parameter("world_length",line.visual.length)
		line.material.set_shader_parameter("phase",clock)
		line.material.set_shader_parameter("flash",flash)
		line.glow.scale=Vector2(line.visual.length,line.visual.width*4.0)
		line.glow.material.set_shader_parameter("phase",clock if persistent_glow else 0.0)
		line.glow.material.set_shader_parameter("ripple_strength",0.06 if persistent_glow else 0.0)
		line.glow.material.set_shader_parameter("world_length",line.visual.length)
		line.glow.material.set_shader_parameter("intensity",config.laser_glow_strength*(1.0 if persistent_glow else 0.65)+config.laser_flash_strength*flash)

func _build_pattern(pattern: Resource) -> void:
	current_label = pattern.label
	var bounds := area.movement_bounds
	var background := preload("res://scenes/bosses/laser_bounds.gd").for_view(area,get_viewport(),config.laser_end_overscan)
	var horizontal: Array[float] = []
	var vertical: Array[float] = []
	for fraction in pattern.horizontal_positions:
		horizontal.append(lerpf(bounds.position.y,bounds.end.y,clampf(fraction,0,1)))
	for fraction in pattern.vertical_positions:
		vertical.append(lerpf(bounds.position.x,bounds.end.x,clampf(fraction,0,1)))
	# Replace the nearest stripe, keeping the configured count and a fixed warning.
	if config.line_target_player and is_instance_valid(Global.nearest_player(area.movement_bounds.get_center())):
		var target := Global.nearest_player(area.movement_bounds.get_center()).global_position
		var nearest := INF
		var chosen := -1
		var use_horizontal := true
		for i in horizontal.size():
			if absf(horizontal[i]-target.y) < nearest:
				nearest = absf(horizontal[i]-target.y)
				chosen = i
		for i in vertical.size():
			if absf(vertical[i]-target.x) < nearest:
				nearest = absf(vertical[i]-target.x)
				chosen = i
				use_horizontal = false
		if chosen >= 0:
			if use_horizontal: horizontal[chosen] = target.y
			else: vertical[chosen] = target.x
	for y in horizontal:
		_add_segment(Vector2(background.position.x,y),Vector2(background.end.x,y))
	for x in vertical:
		_add_segment(Vector2(x,background.position.y),Vector2(x,background.end.y))

func _add_segment(start: Vector2, end: Vector2) -> void:
	var length := start.distance_to(end)
	if length <= 0.1: return
	var visual := LineVisual.new()
	visual.length = length
	visual.width = config.line_width
	visual.position = start.lerp(end,0.5)
	visual.rotation = start.angle_to_point(end)
	add_child(visual)
	var glow: Polygon2D = preload("res://scenes/bosses/fire_line_glow.tscn").instantiate()
	glow.scale=Vector2(length,config.line_width*4.0)
	glow.hide()
	visual.add_child(glow)
	var warning: Polygon2D = preload("res://scenes/bosses/fire_line_warning.tscn").instantiate()
	warning.scale = Vector2(length,config.line_width)
	warning.material.set_shader_parameter("world_length",length)
	visual.add_child(warning)
	var fire := Polygon2D.new()
	var half := Vector2(length*0.5,config.line_width)
	fire.polygon = PackedVector2Array([Vector2(-half.x,-half.y),Vector2(half.x,-half.y),Vector2(half.x,half.y),Vector2(-half.x,half.y)])
	fire.uv = PackedVector2Array([Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,1)])
	# A 1x1 white texture makes the supplied UVs independent from polygon size.
	var image := Image.create(1,1,false,Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	fire.texture = ImageTexture.create_from_image(image)
	var line_material := ShaderMaterial.new()
	line_material.shader = preload("res://shaders/boss_fire_line.gdshader")
	line_material.set_shader_parameter("world_length",length)
	fire.material = line_material
	fire.hide()
	visual.add_child(fire)
	var hit := HitboxComponent.new()
	hit.monitoring = false
	hit.collision_layer = 0
	hit.collision_mask = 0
	hit.continuous_contact = true
	hit.grants_enemy_rewards = false
	visual.add_child(hit)
	hit.setup(0,false,0,source)
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(length,config.line_width)
	shape.disabled = true
	hit.add_child(shape)
	lines.append({"visual":visual,"fire":fire,"warning":warning,"glow":glow,"hit":hit,"shape":shape,"material":line_material,"start":start,"end":end})

func _clear_lines() -> void:
	for line in lines:
		line.hit.damage = 0
		line.hit.base_damage = 0
		line.hit.collision_layer = 0
		line.shape.set_deferred("disabled",true)
		line.visual.hide()
		line.visual.queue_free()
	lines.clear()

func stop() -> void:
	running = false
	_clear_lines()
	hide()
