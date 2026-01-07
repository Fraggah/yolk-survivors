extends Area2D
class_name Unit

@export var stats: UnitStats

@onready var visuals: Node2D = $Visuals
@onready var sprite: Sprite2D = %Sprite
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var health_component: HealthComponent = $HealthComponent
@onready var flash_timer: Timer = $FlashTimer

func _ready() -> void:
	health_component.setup(stats)

func set_flash_material() -> void:
	sprite.material = Global.FLASH_MATERIAL
	flash_timer.start()


func _on_hurtbox_component_on_damage(hitbox: HitboxComponent) -> void:
	if health_component.current_health <= 0: return
	
	set_flash_material()
	health_component.take_damage(hitbox.damage)
	print("%s: %d" % [name, health_component.current_health])


func _on_flash_timer_timeout() -> void:
	sprite.material = null
