extends Resource
class_name ScheduledSpawn
## Literal, once-per-wave spawn. Never rolled by weight or multiplied by density.
@export var enemy: EnemyProfile
@export_range(0.0, 600.0, 0.1) var second := 0.0
@export_range(1, 500, 1) var count := 1
@export_enum("Anywhere", "Edges", "Interior") var spawn_zone := 0
@export_range(20.0, 1000.0, 5.0) var edge_width := 200.0
## Optional warning animation starts at Second; enemy appears when it finishes.
## Off means the enemy itself appears at Second (scheduler precision: 0.1 s).
@export var telegraph := false
