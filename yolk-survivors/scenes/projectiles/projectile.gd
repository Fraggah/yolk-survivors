extends Node2D
class_name Projectile

@export var hitbox: HitboxComponent

var velocity: Vector2
var max_distance := INF
var distance_travelled := 0.0
var remaining_piercing := 0
var unlimited_piercing := false
var remaining_bounces := 0
var hit_targets: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("projectiles")
	scale *= Global.GAME_ENTITY_SCALE
	hitbox.hit_once_per_activation = true
	hitbox.projectile = self
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
		finish()

func finish() -> void:
	queue_free()

func claim_contact(hurtbox: HurtboxComponent) -> bool:
	var id := hurtbox.get_instance_id()
	# Either Area may report first. Resolve the lifetime/bounce budget once,
	# but allow the final accepted contact to deliver damage before retirement.
	if hit_targets.has(id): return true
	if is_queued_for_deletion(): return false
	_on_hitbox_component_on_hit_hurtbox(hurtbox)
	return hit_targets.has(id)


func setup_projectile(projectile_velocity: Vector2, damage: float, critical: bool, knockback: float, unit: Node2D, travel_range: float = INF) -> void:
	self.velocity = projectile_velocity
	max_distance = maxf(0.0, travel_range)
	distance_travelled = 0.0
	rotation = projectile_velocity.angle()
	hitbox.setup(damage, critical, knockback, unit)



func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	finish()


func _on_hitbox_component_on_hit_hurtbox(hurtbox: HurtboxComponent) -> void:
	if is_queued_for_deletion() or Global.game_paused: return
	var target_id := hurtbox.get_instance_id()
	if hit_targets.has(target_id): return
	hit_targets[target_id] = true
	if unlimited_piercing: return
	if remaining_bounces > 0:
		var target: Node2D = EnemyCrowd.random_target(hit_targets)
		if target:
			velocity = global_position.direction_to((target as Unit).get_aim_position()) * velocity.length()
			rotation = velocity.angle()
			remaining_bounces -= 1
			# The initial shot respects weapon range; bounce legs can reach their target.
			max_distance = INF
			return
	if remaining_piercing > 0:
		remaining_piercing -= 1
		return
	finish()
