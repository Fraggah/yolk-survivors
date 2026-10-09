extends Button
class_name SelectionCard

func _ready() -> void:
	toggle_mode = true
	SlotSelectionStyle.apply(self, Global.COMMON_STYLE)

const SILHOUETTE = preload("res://shaders/locked_silhouette.gdshader")
var portrait: TextureRect
var locked := false

func set_icon(texture: Texture2D) -> void:
	# Only the portrait receives the shader, keeping slot and focus colors intact.
	if portrait == null:
		portrait = TextureRect.new()
		portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		portrait.offset_left = 8.0
		portrait.offset_top = 8.0
		portrait.offset_right = -8.0
		portrait.offset_bottom = -8.0
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(portrait)
	icon = null
	portrait.texture = texture

func set_locked(value: bool) -> void:
	if locked == value: return
	locked = value
	toggle_mode = not value
	if value: set_pressed_no_signal(false)
	if portrait == null: return
	if value:
		var silhouette := ShaderMaterial.new()
		silhouette.shader = SILHOUETTE
		portrait.material = silhouette
	else:
		portrait.material = null


func _on_mouse_entered() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)


func _on_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
