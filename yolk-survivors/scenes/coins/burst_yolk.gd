extends "res://scenes/coins/coins.gd"
## A real one-yolk pickup. Scatter first, then use the ordinary collection path.
var launch_start := Vector2.ZERO
var launch_end := Vector2.ZERO
var launch_duration := 0.5
var launch_elapsed := 0.0
var launch_height := 60.0
var landed := false
var _rest_position := Vector2.ZERO

func launch(from: Vector2, to: Vector2, duration: float, height: float) -> void:
	launch_start=from
	launch_end=to
	launch_duration=maxf(0.1,duration)
	launch_height=maxf(0,height)
	global_position=from

func _ready() -> void:
	super._ready()
	_rest_position=sprite.position

func _try_spawn_attraction() -> void:
	# Spawn magnets are evaluated after landing, never in the explosion itself.
	if landed: super._try_spawn_attraction()

func can_merge_on_ground() -> bool:
	return landed and super.can_merge_on_ground()

func _on_area_entered(area: Area2D) -> void:
	if landed: super._on_area_entered(area)

func add_coins() -> void:
	if landed: super.add_coins()

func _process(delta: float) -> void:
	if is_queued_for_deletion(): return
	if flying_to_jar:
		super._process(delta)
		return
	if Global.game_paused: return
	if not landed:
		launch_elapsed+=maxf(0,delta)
		var progress:=clampf(launch_elapsed/launch_duration,0,1)
		var eased:=1.0-pow(1.0-progress,2.0)
		global_position=launch_start.lerp(launch_end,eased)
		var arc:=sin(PI*progress)
		sprite.position=_rest_position+Vector2(0,-arc*launch_height/maxf(0.001,absf(global_scale.y)))
		shadow.scale=shadow_base_scale*(1.0-0.35*arc)
		if progress>=1.0:
			landed=true
			sprite.position=_rest_position
			shadow.scale=shadow_base_scale
		return
	_try_spawn_attraction()
	super._process(delta)
