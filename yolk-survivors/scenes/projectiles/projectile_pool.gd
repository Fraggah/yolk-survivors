extends Node
## Cache, rather than a gameplay cap: overflow shots still spawn normally.
const DROP_SCENE := preload("res://scenes/projectiles/projectile_ketchup_drop.tscn")
const CAPACITY := 256
const PREWARM := 64
var available: Array[Projectile] = []
var leased: Dictionary = {}
var created := 0

func _ready() -> void:
	name = "ProjectilePool"
	add_to_group("projectile_pools")
	for i in PREWARM: available.append(_create())

func _create() -> Projectile:
	var projectile := DROP_SCENE.instantiate() as Projectile
	projectile.pool = self
	projectile.tree_exiting.connect(_on_projectile_exiting.bind(projectile),CONNECT_ONE_SHOT)
	add_child(projectile)
	projectile.deactivate()
	created += 1
	return projectile

func acquire_drop() -> Projectile:
	while not available.is_empty() and (not is_instance_valid(available.back()) or available.back().is_queued_for_deletion()):
		available.pop_back()
	if available.is_empty():
		if created<CAPACITY:
			available.append(_create())
		else:
			var overflow := DROP_SCENE.instantiate() as Projectile
			get_parent().add_child(overflow)
			return overflow
	var projectile: Projectile = available.pop_back()
	leased[projectile.get_instance_id()] = projectile
	projectile.activate()
	return projectile

func release(projectile) -> void:
	if not is_instance_valid(projectile): return
	if not leased.has(projectile.get_instance_id()): return
	leased.erase(projectile.get_instance_id())
	projectile.deactivate()
	available.append(projectile)

func clear() -> void:
	for projectile in leased.values(): release(projectile)

func _on_projectile_exiting(projectile: Projectile) -> void:
	leased.erase(projectile.get_instance_id())
	available.erase(projectile)
	created -= 1
