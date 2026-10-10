extends Control
class_name HealthBar

@export var use_ui_palette := false
@export var back_color: Color
@export var fill_color: Color

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var health_value: Label = %HealthValue

func _ready() -> void:
	if use_ui_palette:
		UITheme.palette_changed.connect(_apply_ui_palette)
		_apply_ui_palette()
		return
	var back_style := progress_bar.get_theme_stylebox("background").duplicate()
	back_style.bg_color = back_color
	
	var fill_style := progress_bar.get_theme_stylebox("fill").duplicate()
	fill_style.bg_color = fill_color
	
	progress_bar.add_theme_stylebox_override("background", back_style)
	progress_bar.add_theme_stylebox_override("fill", fill_style)

func _apply_ui_palette() -> void:
	var palette = UITheme.palette
	progress_bar.add_theme_stylebox_override("background", UITheme.box(palette.text, palette.hud_text, 24, 5))
	var fill_style := UITheme.box(palette.health_fill, palette.hud_text, 24, 0)
	progress_bar.add_theme_stylebox_override("fill", fill_style)
	var outline_panel := progress_bar.get_node_or_null("Outline") as Panel
	if not outline_panel:
		outline_panel = Panel.new()
		outline_panel.name = "Outline"
		outline_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		progress_bar.add_child(outline_panel)
		outline_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		progress_bar.move_child(outline_panel, 0)
	outline_panel.add_theme_stylebox_override("panel", UITheme.box(Color.TRANSPARENT, palette.hud_text, 24, 5))
	health_value.add_theme_color_override("font_color", palette.hud_text)
	health_value.add_theme_constant_override("outline_size", 0)

func update_bar(value: float, health: float) -> void:
	progress_bar.value = value
	health_value.text = str(health)


func _on_health_component_on_health_changed(current: float, hp_max: float) -> void:
	var value := current / hp_max
	update_bar(value, current)
