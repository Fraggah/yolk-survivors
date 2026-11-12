extends Unit
class_name Player

var passive_items: Node
var coop_session: RefCounted

func get_weapon_limit() -> int:
	return Global.MAX_EQUIPPED_WEAPONS + (passive_items.weapon_slot_bonus() if is_instance_valid(passive_items) else 0)

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
const RECOVERY_STEP := 0.1
const REGEN_PER_POINT_PER_SECOND := 0.1
var _regen_credit := 0.0
var hit_invulnerability_left := 0.0
var life_steal_cooldown := 0.0
var is_dashing: bool
var current_weapons: Array[Weapon] = []
var arena_environment: ArenaEnvironment
var health_drain_per_second := 0.0
var max_health_drain_percent_per_second := 0.0
var _drain_elapsed := 0.0
var _effective_dash_cooldown := 2.0

func get_dash_cooldown() -> float:
	return maxf(0.05, maxf(0.05, dash_cooldown - passive_items.power("guarana")) * passive_items.last_bite_dash_multiplier)

func refresh_dash_cooldown() -> void:
	var updated := get_dash_cooldown()
	if is_equal_approx(updated, _effective_dash_cooldown): return
	if not dash_cooldown_timer.is_stopped():
		# Preserve recovery progress when crossing the HP threshold in either direction.
		dash_cooldown_timer.start(maxf(0.00001, dash_cooldown_timer.time_left * updated / _effective_dash_cooldown))
	_effective_dash_cooldown = updated

func refresh_equipment_modifiers() -> void:
	var combined: Dictionary = {}
	health_drain_per_second = 0.0
	max_health_drain_percent_per_second = 0.0
	for equipped in current_weapons:
		if not is_instance_valid(equipped) or equipped.is_queued_for_deletion(): continue
		var chili_factor: float = 1.0 + 0.1 * (passive_items.power("wasabi") if is_instance_valid(passive_items) and equipped.data.has_tag(ItemWeapon.Tag.CHILI) else 0)
		var chili_penalty: float = 1.0 + 0.1 * (passive_items.penalty_power("wasabi") if is_instance_valid(passive_items) and equipped.data.has_tag(ItemWeapon.Tag.CHILI) else 0)
		for key in equipped.data.final_stat_modifiers:
			combined[key] = float(combined.get(key, 0.0)) + float(equipped.data.final_stat_modifiers[key]) * (chili_factor if float(equipped.data.final_stat_modifiers[key]) > 0.0 else chili_penalty)
		health_drain_per_second += equipped.data.health_drain_per_second * chili_penalty
		max_health_drain_percent_per_second += equipped.data.max_health_drain_percent_per_second * chili_penalty
	if health_drain_per_second <= 0.0 and max_health_drain_percent_per_second <= 0.0: _drain_elapsed = 0.0
	stats.chili_crit_enabled = is_instance_valid(passive_items) and passive_items.count("pepper") > 0
	stats.set_final_modifiers(combined)
	if is_instance_valid(passive_items): passive_items.refresh_last_bite()

func _ready() -> void:
	stats = stats.get_passive_preview()
	super._ready()
	passive_items = load("res://scenes/units/players/passive_items.gd").new()
	passive_items.player = self
	add_child(passive_items)
	health_component.on_health_changed.connect(passive_items.refresh_last_bite)
	Global.on_enemy_died.connect(passive_items.enemy_killed)
	health_component.on_unit_hit.connect(Progression.record_damage)
	stats.stats_changed.connect(Progression.check_stats.bind(stats))
	stats.stats_changed.connect(_sync_max_health)
	dash_timer.wait_time = dash_duration
	dash_cooldown_timer.wait_time = dash_cooldown
	_effective_dash_cooldown = get_dash_cooldown()
	shadow.material.set_shader_parameter("outline_color", trail.default_color)

func _sync_max_health() -> void:
	health_component.max_health = maxf(1.0, stats.health)
	health_component.current_health = minf(health_component.current_health, health_component.max_health)
	health_component.on_health_changed.emit(health_component.current_health, health_component.max_health)

func _process(delta: float) -> void:
	if Global.game_paused: return

	if (health_drain_per_second > 0.0 or max_health_drain_percent_per_second > 0.0) and health_component.current_health > 0.0:
		_drain_elapsed += delta
		while _drain_elapsed >= 1.0 and health_component.current_health > 0.0:
			_drain_elapsed -= 1.0
			# Use current maximum HP each tick, preserving fractional life costs.
			health_component.take_damage(health_drain_per_second+health_component.max_health*max_health_drain_percent_per_second/100.0)
	hit_invulnerability_left = maxf(0.0, hit_invulnerability_left - delta)
	life_steal_cooldown = maxf(0.0, life_steal_cooldown - delta)
	move_dir = coop_session.poll_movement() if coop_session else Input.get_vector("move_left","move_right","move_up","move_down")

	var current_velocity := move_dir * stats.get_player_movement_speed() * get_status_movement_multiplier()
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
	if not Global.is_valid_starting_weapon(data) or not Progression.is_weapon_unlocked(data) or not stats.can_use_weapon(data): return
	if current_weapons.size() >= get_weapon_limit(): return
	var weapon := data.scene.instantiate() as Weapon
	add_child(weapon)

	weapon.global_position = position
	weapon.setup_weapon(data)
	current_weapons.append(weapon)
	refresh_equipment_modifiers()
	weapons_container.update_weapons_position(current_weapons)

func start_dash() -> void:
	SoundManager.play_event("dash")
	is_dashing = true
	dash_timer.start()
	visuals.modulate.a = .9
	collision.set_deferred("disabled", true)
	trail.start_trail()
	shadow.material.set_shader_parameter("outline_color", Color(.0,.0,.0,.0))

func can_dash() -> bool:
	var requested: bool = coop_session.dash_requested if coop_session else Input.is_action_just_pressed("dash")
	if coop_session: coop_session.dash_requested = false
	return not is_dashing and\
	dash_cooldown_timer.is_stopped() and\
	requested and\
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
	_regen_credit = 0.0
	passive_items.begin_wave()
	_drain_elapsed = 0.0
	status_controller.clear()
	flash_timer.stop()
	sprite.material = null
	for weapon in current_weapons:
		weapon.weapon_behaviour.reset_attack()
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
	_effective_dash_cooldown = get_dash_cooldown()
	dash_cooldown_timer.start(_effective_dash_cooldown)
	collision.set_deferred("disabled", false)
	#sprite_2d.material.set_shader_parameter("outline_color", outline_color)


func _on_hp_timer_timeout() -> void:
	_update_regeneration($HPTimer.wait_time)

func _update_regeneration(delta: float) -> void:
	if Global.game_paused: return
	passive_items.refresh_burning_regen()
	if is_queued_for_deletion() or health_component.current_health <= 0.0 or health_component.current_health >= health_component.max_health or stats.hp_regen <= 0.0:
		_regen_credit = 0.0
		if health_component.current_health<=0.0 or health_component.current_health>=health_component.max_health: health_component.healing_credit=0.0
		return
	# One point = 0.1 HP/s. Accrue fractions without banking healing while full/dead.
	_regen_credit += maxf(0.0, delta) * stats.hp_regen * REGEN_PER_POINT_PER_SECOND
	while health_component.current_health < health_component.max_health:
		var amount := minf(RECOVERY_STEP, health_component.max_health-health_component.current_health)
		if _regen_credit + 0.00000001 < amount: break
		_regen_credit = maxf(0.0, _regen_credit-amount)
		var before := health_component.current_health
		health_component.heal(amount)
		var healed := health_component.current_health-before
		if healed > 0.0: Global.on_create_heal_text.emit(self, healed)
		if health_component.current_health >= health_component.max_health:
			_regen_credit = 0.0
			break


func _on_health_component_on_unit_died() -> void:
	if coop_session:
		get_tree().current_scene.coop.player_down(self)
		return
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
	# Chance improves reliability, never the amount recovered by a single hit.
	chance = clampf(chance, 0.0, 1.0)
	if not Global.get_chance_succes(chance): return false
	var before := health_component.current_health
	health_component.heal(RECOVERY_STEP)
	life_steal_cooldown = LIFE_STEAL_INTERVAL
	var healed := health_component.current_health-before
	if healed>0.0: Global.on_create_heal_text.emit(self, healed)
	return true
