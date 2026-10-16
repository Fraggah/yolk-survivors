extends Area2D
class_name Unit

@export var stats: UnitStats
var last_hit_grants_rewards := true
var status_controller: Node2D
var status_movement_multiplier := 1.0

@onready var visuals: Node2D = $Visuals
@onready var sprite: Sprite2D = %Sprite
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var health_component: HealthComponent = $HealthComponent
@onready var flash_timer: Timer = $FlashTimer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	scale *= Global.GAME_ENTITY_SCALE
	sprite.z_as_relative = false
	sprite.z_index = 2
	var ground_shadow := get_node_or_null("Visuals/Shadow") as Sprite2D
	if ground_shadow:
		ground_shadow.z_as_relative = false
		ground_shadow.z_index = -1
	health_component.setup(stats)
	status_controller = load("res://effects/status_controller.gd").new()
	status_controller.name = "StatusController"
	add_child(status_controller)
	if self is Player: add_to_group("combat_players")

func get_status_movement_multiplier() -> float:
	return status_movement_multiplier

func immobilize_for(duration: float, source_stats: UnitStats = null) -> void:
	status_controller.add_slow(0.0, duration * (source_stats.get_effect_multiplier() * source_stats.effect_duration_multiplier() if source_stats else 1.0))

func set_flash_material() -> void:
	if sprite.material != Global.FLASH_MATERIAL:
		sprite.material = Global.FLASH_MATERIAL
	flash_timer.start()


func _on_hurtbox_component_on_damage(hitbox: HitboxComponent) -> void:
	receive_hit(hitbox)

func receive_hit(hitbox: HitboxComponent) -> bool:
	if Global.game_paused or is_queued_for_deletion() or health_component.current_health <= 0.0:
		return false
	if not is_instance_valid(hitbox) or hitbox.damage <= 0.0: return false
	var blocked := hitbox.can_be_blocked and Global.get_chance_succes(clampf(stats.block_chance / 100.0, 0.0, 1.0))
	if blocked:
		if self is Player: SoundManager.play_sound(SoundManager.Sound.HIT_BLOQUEADO_AL_PLAYER)
		Global.on_create_block_text.emit(self)
		if stats.block_effectiveness >= 100.0: return false
	if self is Player:
		hitbox.critical = false
		if hitbox.roll_critical_per_target: hitbox.damage = hitbox.base_damage
	else:
		hitbox.roll_target_critical()
	var before := health_component.current_health
	last_hit_grants_rewards = hitbox.grants_enemy_rewards
	set_flash_material()
	var incoming_damage := hitbox.damage * (stats.get_incoming_damage_multiplier() if self is Player else 1.0)
	if blocked: incoming_damage *= 1.0 - clampf(stats.block_effectiveness / 100.0, 0.0, 1.0)
	health_component.take_damage(incoming_damage)
	var dealt := before - health_component.current_health
	if dealt <= 0.0: return false
	SoundManager.play_sound(SoundManager.Sound.HIT_AL_PLAYER if self is Player else SoundManager.Sound.CRITICO_AL_ENEMIGO if hitbox.critical else SoundManager.Sound.HIT_AL_ENEMIGO)
	if not Global.game_paused: Global.on_create_damage_text.emit(self, hitbox)
	hitbox.report_damage(self, dealt)
	if not hitbox.is_status_damage and health_component.current_health > 0.0:
		for effect in hitbox.status_effects:
			if effect and Global.get_chance_succes(effect.chance):
				load("res://effects/status_controller.gd").apply_effect(self, effect, hitbox)
	return true


func _on_flash_timer_timeout() -> void:
	sprite.material = null
