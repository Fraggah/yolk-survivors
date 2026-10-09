extends Area2D
class_name Unit

@export var stats: UnitStats

@onready var visuals: Node2D = $Visuals
@onready var sprite: Sprite2D = %Sprite
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var health_component: HealthComponent = $HealthComponent
@onready var flash_timer: Timer = $FlashTimer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	scale *= Global.GAME_ENTITY_SCALE
	health_component.setup(stats)

func set_flash_material() -> void:
	sprite.material = Global.FLASH_MATERIAL
	flash_timer.start()


func _on_hurtbox_component_on_damage(hitbox: HitboxComponent) -> void:
	receive_hit(hitbox)

func receive_hit(hitbox: HitboxComponent) -> bool:
	if Global.game_paused or is_queued_for_deletion() or health_component.current_health <= 0.0:
		return false
	if not is_instance_valid(hitbox) or hitbox.damage <= 0.0: return false
	if Global.get_chance_succes(clampf(stats.block_chance / 100.0, 0.0, 1.0)):
		Global.on_create_block_text.emit(self)
		return false
	var before := health_component.current_health
	set_flash_material()
	health_component.take_damage(hitbox.damage)
	var dealt := before - health_component.current_health
	if dealt <= 0.0: return false
	SoundManager.play_sound(SoundManager.Sound.ENEMY_HIT)
	if not Global.game_paused: Global.on_create_damage_text.emit(self, hitbox)
	hitbox.report_damage(self, dealt)
	return true


func _on_flash_timer_timeout() -> void:
	sprite.material = null
