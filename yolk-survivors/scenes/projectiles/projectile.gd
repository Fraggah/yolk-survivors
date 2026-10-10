extends Node2D
class_name Projectile

@export var hitbox: HitboxComponent

var velocity: Vector2
var max_distance := INF
var distance_travelled := 0.0
var remaining_piercing := 0
var remaining_bounces := 0
var hit_targets: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("projectiles")
	scale *= Global.GAME_ENTITY_SCALE
	hitbox.hit_once_per_activation = true
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


func _on_hitbox_component_on_hit_hurtbox(hurtbox: HurtboxComponent) -> void:
	if is_queued_for_deletion() or Global.game_paused: return
	var target_id := hurtbox.get_instance_id()
	if hit_targets.has(target_id): return
	hit_targets[target_id] = true
	if remaining_bounces > 0:
		var candidates: Array[Node2D] = []
		for enemy in get_tree().get_nodes_in_group("combat_enemies"):
			if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.is_retiring or enemy.health_component.current_health <= 0.0: continue
			var enemy_hurtbox := enemy.get_node("HurtboxComponent")
			if hit_targets.has(enemy_hurtbox.get_instance_id()): continue
			candidates.append(enemy)
		if not candidates.is_empty():
			var target: Node2D = candidates.pick_random()
			velocity = global_position.direction_to(target.global_position) * velocity.length()
			rotation = velocity.angle()
			remaining_bounces -= 1
			# The initial shot respects weapon range; bounce legs can reach their target.
			max_distance = INF
			return
	if remaining_piercing > 0:
		remaining_piercing -= 1
		return
	queue_free()
