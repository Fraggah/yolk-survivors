extends Node

signal on_create_block_text(unit: Node2D)
signal on_create_damage_text(unit: Node2D, info: HitboxComponent)

const FLASH_MATERIAL = preload("res://effects/flash_material.tres")
const FLOATING_TEXT_SCENE = preload("res://scenes/ui/floating_text/floating_text.tscn")

enum UpgradeTier {
	COMMON,
	RARE,
	EPIC,
	LEGENDARY
}

var player: Player

func get_chance_succes(chance: float) -> bool:
	var random = randf_range(0, 1)
	if random < chance:
		return true
	return false
