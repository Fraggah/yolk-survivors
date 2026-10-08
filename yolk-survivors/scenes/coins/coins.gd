extends Area2D
class_name Coins

@export var move_speed := 1000.0
@export var collect_distance := 15.0
@export_range(0.0, 0.15, 0.01) var squash_amount := 0.05
@export_range(0.5, 3.0, 0.1) var squash_period := 1.4
@export_range(0.2, 0.9, 0.05) var jar_flight_duration := 0.65

@onready var sprite: Sprite2D = $Sprite2D
var sprite_base_scale: Vector2
var squash_phase := 0.0

var value := 1
var target_pos: Vector2
var collected: bool
var jar_target: Control
var flying_to_jar := false
var flight_start_screen: Vector2
var flight_elapsed := 0.0
var awarded := false

func _process(delta: float) -> void:
	if is_queued_for_deletion(): return
	if flying_to_jar:
		animate_jar_flight(delta)
		return
	if Global.game_paused: return
	squash_phase = fmod(squash_phase + delta * TAU / squash_period, TAU)
	var stretch := 1.0 + sin(squash_phase) * squash_amount
	sprite.scale = sprite_base_scale * Vector2(stretch, 1.0 / stretch)
	if not collected or not is_instance_valid(Global.player): return
	target_pos = Global.player.global_position
	global_position = global_position.move_toward(target_pos, move_speed * delta)
	if global_position.distance_squared_to(target_pos) < collect_distance * collect_distance:
		add_coins()

func fly_to_jar(target: Control) -> void:
	if is_queued_for_deletion(): return
	jar_target = target
	flying_to_jar = true
	collected = false
	flight_elapsed = 0.0
	# Capture the visible sprite's center, not the Area2D's offset origin.
	flight_start_screen = sprite.get_global_transform_with_canvas().origin
	$Shadow.hide()
	set_deferred("monitoring", false)

func animate_jar_flight(delta: float) -> void:
	if not is_instance_valid(jar_target):
		queue_free()
		return
	flight_elapsed += delta
	var progress := clampf(flight_elapsed / jar_flight_duration, 0.0, 1.0)
	var eased := progress * progress * (3.0 - 2.0 * progress)
	var jar_center_screen := jar_target.get_global_transform_with_canvas() * (jar_target.size * 0.5)
	var center_screen := flight_start_screen.lerp(jar_center_screen, eased)
	var center_world := get_canvas_transform().affine_inverse() * center_screen
	global_position = center_world - (sprite.global_position - global_position)
	if progress >= 1.0:
		# Reserve was banked at wave end; arrival never pays spendable currency.
		queue_free()

func add_coins() -> void:
	if awarded or flying_to_jar or Global.game_paused or is_queued_for_deletion(): return
	awarded = true
	var bonus := Global.collect_yolk(value)
	if bonus > 0:
		var text := Global.FLOATING_TEXT_SCENE.instantiate() as FloatingText
		get_tree().root.add_child(text)
		text.global_position = global_position
		text.setup_text("×2" if bonus == value else "+%d" % bonus, Color("ffd34e"))
	queue_free()

func _on_area_entered(_area: Area2D) -> void:
	if not flying_to_jar and not Global.game_paused:
		collected = true

func _ready() -> void:
	add_to_group("yolks")
	scale *= Global.GAME_ENTITY_SCALE
	sprite_base_scale = sprite.scale
	squash_phase = randf() * TAU
