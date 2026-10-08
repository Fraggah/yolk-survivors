extends Node2D
class_name Projectile

@export var hitbox: HitboxComponent

var velocity: Vector2
var max_distance := INF
var distance_travelled := 0.0

func _ready() -> void:
	scale *= Global.GAME_ENTITY_SCALE
	hitbox.enable()

func _process(delta: float) -> void:
	if Global.game_paused or is_queued_for_deletion(): return
	var movement := velocity * delta
	var remaining := maxf(0.0, max_distance - distance_travelled)
	var reached_limit := movement.length() >= remaining
	movement = movement.limit_length(remaining)
	global_position += movement
	distance_travelled += movement.length()
	if reached_limit:
		queue_free()
	

func setup_projectile(projectile_velocity: Vector2, damage: float, critical: bool, knockback: float, unit: Node2D, travel_range: float = INF) -> void:
	self.velocity = projectile_velocity
	max_distance = maxf(0.0, travel_range)
	distance_travelled = 0.0
	rotation = projectile_velocity.angle()
	hitbox.setup(damage, critical, knockback, unit)



func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_hitbox_component_on_hit_hurtbox(_hurtbox: HurtboxComponent) -> void:
	queue_free()
