extends Unit
class_name Player

var move_dir: Vector2

@export var dash_duration := .5
@export var dash_speed_multi := 2.5
@export var dash_cooldown := 2.0

@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var trail: PlayerTrail = %Trail
@onready var weapons_container: WeaponsContainer = $Weapons
@onready var shadow: Sprite2D = $Visuals/Shadow


const HIT_INVULNERABILITY := 0.5
const LIFE_STEAL_INTERVAL := 0.1
var hit_invulnerability_left := 0.0
var life_steal_cooldown := 0.0
var is_dashing: bool
var current_weapons: Array[Weapon] = []
var arena_environment: ArenaEnvironment

func _ready() -> void:
	super._ready()
	dash_timer.wait_time = dash_duration
	dash_cooldown_timer.wait_time = dash_cooldown
	shadow.material.set_shader_parameter("outline_color", trail.default_color)

func _process(delta: float) -> void:
	if Global.game_paused: return
	
	hit_invulnerability_left = maxf(0.0, hit_invulnerability_left - delta)
	life_steal_cooldown = maxf(0.0, life_steal_cooldown - delta)
	move_dir = Input.get_vector("move_left","move_right","move_up","move_down")
	
	var current_velocity := move_dir * stats.speed
	if is_dashing:
		current_velocity *= dash_speed_multi

	
	position += current_velocity * delta
	if arena_environment:
		global_position = arena_environment.clamp_position(global_position)
	else:
		position.x = clamp(position.x, -1000, 1000)
		position.y = clamp(position.y, -500, 485)
	
	update_animations()
	update_rotation()
	
	if can_dash():
		start_dash()


func add_weapon(data: ItemWeapon) -> void:
	var weapon := data.scene.instantiate() as Weapon
	add_child(weapon)
	
	weapon.global_position = position
	weapon.setup_weapon(data)
	current_weapons.append(weapon)
	weapons_container.update_weapons_position(current_weapons)

func start_dash() -> void:
	is_dashing = true
	dash_timer.start()
	visuals.modulate.a = .9
	collision.set_deferred("disabled", true)
	trail.start_trail()
	shadow.material.set_shader_parameter("outline_color", Color(.0,.0,.0,.0))

func can_dash() -> bool:
	return not is_dashing and\
	dash_cooldown_timer.is_stopped() and\
	Input.is_action_just_pressed("dash") and\
	move_dir != Vector2.ZERO

func update_animations() -> void:
	if move_dir.length() > 0:
		anim_player.play("move")
	else:
		anim_player.play("idle")


func update_rotation() -> void:
	if move_dir == Vector2.ZERO:
		return
	
	if move_dir.x >= .1:
		visuals.scale = Vector2(-.5, .5)
	elif move_dir.x < 0:
		visuals.scale = Vector2(.5, .5)

func prepare_for_new_wave() -> void:
	hit_invulnerability_left = 0.0
	life_steal_cooldown = 0.0
	is_dashing = false
	dash_timer.stop()
	dash_cooldown_timer.stop()
	trail.trail_timer.stop()
	trail.is_active = false
	trail.clear_points()
	trail.points_array.clear()
	visuals.modulate.a = 1.0
	collision.set_deferred("disabled", false)
	shadow.material.set_shader_parameter("outline_color", trail.default_color)
	health_component.setup(stats)

func is_facing_right() -> bool:
	return visuals.scale.x == -.5

func _on_dash_timer_timeout() -> void:
	is_dashing = false
	visuals.modulate.a = 1
	#move_dir = Vector2.ZERO reset??
	dash_cooldown_timer.start()
	collision.set_deferred("disabled", false)
	#sprite_2d.material.set_shader_parameter("outline_color", outline_color)


func _on_hp_timer_timeout() -> void:
	if Global.game_paused: return
	if health_component.current_health <= 0 or health_component.current_health >= stats.health: return
	
	if health_component.current_health < stats.health:
		var heal := minf(stats.hp_regen, health_component.max_health - health_component.current_health)
		if heal <= 0.0: return
		health_component.heal(heal)
		Global.on_create_heal_text.emit(self, heal)


func _on_health_component_on_unit_died() -> void:
	Global.on_player_died.emit()
	print("final player") # se emite


func _on_dash_cooldown_timer_timeout() -> void:
	shadow.material.set_shader_parameter("outline_color", trail.default_color)

func _on_hurtbox_component_on_damage(hitbox: HitboxComponent) -> void:
	if Global.game_paused or is_dashing or hit_invulnerability_left > 0.0: return
	if receive_hit(hitbox): hit_invulnerability_left = HIT_INVULNERABILITY

func try_life_steal(chance: float) -> bool:
	if Global.game_paused or is_queued_for_deletion() or life_steal_cooldown > 0.0: return false
	if health_component.current_health <= 0.0 or health_component.current_health >= health_component.max_health: return false
	if not Global.get_chance_succes(clampf(chance, 0.0, 1.0)): return false
	var before := health_component.current_health
	health_component.heal(1.0)
	life_steal_cooldown = LIFE_STEAL_INTERVAL
	Global.on_create_heal_text.emit(self, health_component.current_health - before)
	return true
