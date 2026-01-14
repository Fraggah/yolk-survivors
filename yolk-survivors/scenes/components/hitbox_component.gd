extends Area2D
class_name HitboxComponent

signal on_hit_hurtbox(hurtbox: HurtboxComponent)

var damage := 1.0
var critical := false
var knockback_power := 0.0
var source: Node2D
@export var bb: CollisionShape2D

func enable() -> void:
	set_deferred("monitoring", true)
	bb.disabled = false
	print("Hitbox: activada")

func disable() -> void:
	set_deferred("monitoring", false)
	bb.disabled = true
	print("Hitbox: desactivada")

func setup(p_damage: float, p_critical: bool, p_knockback: float, p_source: Node2D) -> void:
	damage = p_damage
	critical = p_critical
	knockback_power = p_knockback
	source = p_source


func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		SoundManager.play_sound(SoundManager.Sound.ENEMY_HIT)
		on_hit_hurtbox.emit(area)
