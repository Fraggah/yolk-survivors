extends Resource
class_name SpawnGroup
## A timed stream. Weights apply only to this group's explicit allow-list.
@export var label := "Group"
@export var enemies: Array[EnemyProfile] = []
## Relative weights: same index as Enemies. Zero disables; missing entries use 1.
@export var weights: Array[float] = []
enum SpawnZone { ANYWHERE, EDGES, INTERIOR }
@export var spawn_zone := SpawnZone.ANYWHERE
## Width of the band measured inward from the actual arena boundary.
@export_range(20.0, 1000.0, 5.0) var edge_width := 200.0
@export_range(0.0, 180.0) var start_second := 0.0
@export_range(0.05, 60.0) var interval := 1.0
@export_range(1, 100) var minimum_count := 1
@export_range(1, 100) var maximum_count := 1
@export var repetitions := -1
@export var duration := -1.0
@export_range(0.0, 1.0) var activation_probability := 1.0
@export_range(0.0, 5.0) var interval_reduction := 0.0
@export_range(0.05, 60.0) var minimum_interval := 0.25
@export var priority := 0
## Failed admissions retry at the next interval, never in a catch-up burst.
@export var guaranteed := false
## Schools use literal member counts, independent of crowd multipliers.
@export var school := false
@export_range(0.0, 1.0) var school_probability := 0.0
@export var affected_by_density := true
@export_range(0.0, 500.0) var school_radius := 140.0

func select_enemy() -> EnemyProfile:
	var total := 0.0
	for i in enemies.size():
		if enemies[i] and enemies[i].is_valid(): total += maxf(0.0, weights[i] if i < weights.size() else 1.0)
	if total <= 0.0: return null
	var roll := randf() * total
	for i in enemies.size():
		if not enemies[i] or not enemies[i].is_valid(): continue
		var weight := maxf(0.0, weights[i] if i < weights.size() else 1.0)
		roll -= weight
		if weight > 0.0 and roll < 0.0: return enemies[i]
	return null

func interval_at(elapsed: float) -> float:
	return maxf(minimum_interval, interval - maxf(0.0, elapsed - start_second) * interval_reduction)
