extends Resource
class_name UnitStats

enum UnitType {
	Player,
	Enemy
}

@export var name: String
@export var type: UnitType
@export var icon: Texture2D
@export var health := 1.0
@export var initial_health := 1.0
@export var health_increase_per_wave := 1.0
@export var damage := 1.0
@export var initial_damage := 1.0
@export var damage_increase_per_wave := 1.0
@export var speed := 300.0
@export var luck := 1.0
@export var initial_luck := 1.0
@export var block_chance := 0.0
@export var initial_block_chance := 0.0
@export var coin_drop := 1
@export var hp_regen := .0
@export var life_steal := .0
@export var harvesting := .0

func reset_player_stats() -> void:
	health = initial_health
	damage = initial_damage
	luck = initial_luck
	block_chance = initial_block_chance
	hp_regen = 0
	life_steal = 0
	harvesting = 0
