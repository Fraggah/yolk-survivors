extends Button
class_name SelectionCard

func _ready() -> void:
	portrait=get_node_or_null("Portrait")
	if not portrait:
		for child in get_children():
			if child is TextureRect: portrait=child; break
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	toggle_mode = true
	UITheme.style_slot(self)

const SILHOUETTE = preload("res://shaders/locked_silhouette.gdshader")
var portrait: TextureRect
var locked := false
var coop_highlights: Array[Color] = []

func set_coop_highlights(colors: Array[Color], force: bool = false) -> void:
	if not force and colors==coop_highlights: return
	coop_highlights=colors.duplicate()
	UITheme.style_slot(self,int(get_meta("ui_tier",0)))
	if colors.is_empty(): return
	# Match solo's hover fill, with the owning player's edge and number markers.
	var style: StyleBoxFlat=get_theme_stylebox("hover").duplicate()
	style.border_color=colors[0]
	style.set_border_width_all(maxi(3,UITheme.palette.focus_width))
	add_theme_stylebox_override("normal",style)

func set_icon(texture: Texture2D, icon_scale: float = 1.0) -> void:
	if not portrait: return
	icon = null
	portrait.texture = texture
	ItemBase.scale_icon(portrait, icon_scale)

func set_locked(value: bool) -> void:
	if locked == value: return
	locked = value
	toggle_mode = not value
	if value: set_pressed_no_signal(false)
	if portrait == null: return
	if value:
		var silhouette := ShaderMaterial.new()
		silhouette.shader = SILHOUETTE
		silhouette.set_shader_parameter("silhouette_color", UITheme.palette.muted)
		portrait.material = silhouette
	else:
		portrait.material = null


func _on_mouse_entered() -> void:
	if disabled or MenuInput.coop_mouse_blocked(): return
	SoundManager.play_sound(SoundManager.Sound.SELECTION_HOVER)


func _on_pressed() -> void:
	pass
