extends Sprite2D
class_name FriedUnit

@export var variants: Array[Texture2D] = []
# Same footprint as the previous 150px texture, independent of source resolution.
@export var drawing_width := 150.0
static var _texture_regions: Dictionary = {}

func _on_timer_timeout() -> void:
	queue_free()

func _ready() -> void:
	if not variants.is_empty():
		texture = variants.pick_random()
	if texture:
		region_enabled = true
		var texture_id := texture.get_instance_id()
		if not _texture_regions.has(texture_id):
			_texture_regions[texture_id] = texture.get_image().get_used_rect()
		region_rect = _texture_regions[texture_id]
		if region_rect.size.x > 0:
			scale *= drawing_width / region_rect.size.x
	scale *= Global.GAME_ENTITY_SCALE
