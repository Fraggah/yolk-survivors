extends Area2D
class_name Coins

@export var move_speed := 1000.0
@export var collect_distance := 15.0
@export var attraction_distance := 195.0
@export_range(0.0, 0.15, 0.01) var squash_amount := 0.05
@export_range(0.5, 3.0, 0.1) var squash_period := 1.4
@export_range(0.2, 0.9, 0.05) var jar_flight_duration := 0.65

@onready var sprite: Sprite2D = $Sprite2D
@onready var shadow: Sprite2D = $Shadow
var sprite_base_scale: Vector2
var shadow_base_scale: Vector2
var squash_phase := 0.0

var value := 1
var target_pos: Vector2
var collected: bool
var jar_target: Control
var flying_to_jar := false
var flight_start_screen: Vector2
var flight_elapsed := 0.0
var awarded := false
var spawn_attraction_checked := false
var magnet_target: Player
var magnet_attracted := false
var merge_scale := 1.0
var merge_pulse := 0.0

func can_merge_on_ground() -> bool:
	return not collected and not awarded and not flying_to_jar and not is_queued_for_deletion()

func merge_yolks(amount: int) -> void:
	value += amount
	merge_scale = 1.0 + minf(0.65, 0.12 * log(float(value)) / log(2.0))
	merge_pulse = 0.18

func _try_spawn_attraction() -> void:
	if spawn_attraction_checked: return
	spawn_attraction_checked = true
	if flying_to_jar: return
	var activated: Array[Player]=[]
	for player in Global.live_players():
		if is_instance_valid(player.passive_items) and player.passive_items.should_attract_spawned_yolk():
			activated.append(player)
	if not activated.is_empty():
		magnet_target=activated.pick_random()
		magnet_attracted=true
		collected=true

func _pickup_target() -> Player:
	if magnet_attracted:
		if is_instance_valid(magnet_target) and not magnet_target.is_queued_for_deletion() and magnet_target.health_component.current_health>0: return magnet_target
		magnet_target=Global.nearest_player(global_position)
		return magnet_target
	return Global.nearest_player(global_position)

func _process(delta: float) -> void:
	var started := Time.get_ticks_usec() if FireContacts.profile_enabled else 0
	_advance_pickup(delta)
	FireContacts.finish_profile("yolk_updates",started)

func _advance_pickup(delta: float) -> void:
	if is_queued_for_deletion(): return
	if flying_to_jar:
		animate_jar_flight(delta)
		return
	if Global.game_paused: return
	squash_phase = fmod(squash_phase + delta * TAU / squash_period, TAU)
	var stretch := 1.0 + sin(squash_phase) * squash_amount
	merge_pulse = move_toward(merge_pulse, 0.0, delta)
	var growth := merge_scale * (1.0 + merge_pulse)
	sprite.scale = sprite_base_scale * growth * Vector2(stretch, 1.0 / stretch)
	if merge_scale > 1.0:
		shadow.scale = shadow_base_scale * growth
	var target:=_pickup_target()
	if not is_instance_valid(target): return
	if not collected and global_position.distance_squared_to(target.global_position) <= pow(target.stats.get_pickup_distance(attraction_distance), 2): collected = true
	if not collected: return
	target_pos = target.global_position
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
	shadow.hide()
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
	SoundManager.play_sound(SoundManager.Sound.YOLK_PICKUP)
	var coop=get_tree().current_scene.get("coop") if get_tree().current_scene else null
	var bonus: int = coop.collect_yolk(value) if coop and coop.active else Global.collect_yolk(value)
	if (not coop or not coop.active) and is_instance_valid(Global.nearest_player(global_position)) and is_instance_valid(Global.nearest_player(global_position).passive_items):
		Global.nearest_player(global_position).passive_items.on_yolks_collected(maxi(0, value) + bonus)
	if bonus > 0:
		var text := CombatTexts.acquire() as FloatingText
		text.global_position = global_position
		text.setup_text("×2" if bonus == value else "+%d" % bonus, Color("ffd34e"))
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area == Global.nearest_player(global_position) and not flying_to_jar and not Global.game_paused and global_position.distance_to(area.global_position) <= Global.nearest_player(global_position).stats.get_pickup_distance(attraction_distance):
		collected = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("yolks")
	sprite.z_as_relative = false
	# Pickups stay on the floor, below the Y-sorted actors (Z = 0).
	sprite.z_index = -1
	shadow.z_as_relative = false
	shadow.z_index = -2
	scale *= Global.GAME_ENTITY_SCALE
	sprite_base_scale = sprite.scale
	shadow_base_scale = shadow.scale
	squash_phase = randf() * TAU
	_try_spawn_attraction()
