extends ItemBase
class_name ItemWeapon

enum Type {
	MELEE,
	RANGE
}

@export var type: Type
@export var scene: PackedScene
@export var stats: WeaponStats
@export var upgrade_to: ItemWeapon
