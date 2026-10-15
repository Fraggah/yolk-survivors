extends Resource
class_name ArenaStage

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var vessel: Texture2D
@export var background_color := Color("c8b99e")
@export var vessel_size := Vector2(3000, 2000)
@export var vessel_offset := Vector2.ZERO
@export var play_area: ArenaEnvironment
@export var mechanic_scene: PackedScene
# Optional presentation material.
@export var background_material: Material
@export var vessel_material: Material

func is_valid() -> bool:
	return not id.is_empty() and not display_name.is_empty() and vessel != null and play_area != null and play_area.movement_bounds.has_area()
