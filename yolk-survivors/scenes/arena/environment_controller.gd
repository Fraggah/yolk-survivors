extends Node2D
class_name ArenaEnvironmentController

@export var environments: Array[ArenaEnvironment]
@onready var background: Sprite2D = $BG
@onready var vessel: Sprite2D = $Vessel
var current: ArenaEnvironment

func apply_wave(wave: int) -> ArenaEnvironment:
	var selected: ArenaEnvironment
	for environment in environments:
		if environment.first_wave <= wave and (not selected or environment.first_wave > selected.first_wave):
			selected = environment
	if not selected: return null
	if current != selected:
		current = selected
		background.texture = current.background
		background.position = current.background_offset
		background.scale = current.background_size / background.texture.get_size()
		vessel.texture = current.vessel
		vessel.position = current.vessel_offset
		vessel.scale = current.vessel_size / vessel.texture.get_size()
	return current
