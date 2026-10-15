extends Control
class_name HealthBar

@export var use_ui_palette := false
@export var experience_bar := false
@export var back_color: Color
@export var fill_color: Color
@export_range(0.05, 1.0) var damage_flash_duration := 0.28
var flash_left := 0.0
var clipped_fill: ColorRect

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
	var fill_style := UITheme.box(Color.TRANSPARENT, Color.TRANSPARENT, 24, 0)
	progress_bar.add_theme_stylebox_override("fill", fill_style)
	if not clipped_fill:
		clipped_fill = ColorRect.new()
		clipped_fill.name = "ClippedFill"
		clipped_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var fill_material := ShaderMaterial.new()
		fill_material.shader = preload("res://scenes/health_bar/rounded_fill.gdshader")
		clipped_fill.material = fill_material
		progress_bar.add_child(clipped_fill)
		clipped_fill.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		progress_bar.resized.connect(_sync_clipped_fill)
		progress_bar.value_changed.connect(func(_value): _sync_clipped_fill())
	clipped_fill.material.set_shader_parameter("fill_color", palette.experience_fill if experience_bar else palette.health_fill)
	_sync_clipped_fill()
	var outline_panel := progress_bar.get_node_or_null("Outline") as Panel
	if not outline_panel:
		outline_panel = Panel.new()
		outline_panel.name = "Outline"
		outline_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		progress_bar.add_child(outline_panel)
		outline_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		progress_bar.move_child(outline_panel, 0)
	outline_panel.add_theme_stylebox_override("panel", UITheme.box(Color.TRANSPARENT, palette.hud_text, 24, 5))
	progress_bar.move_child(clipped_fill, 0)
	health_value.add_theme_color_override("font_color", palette.hud_text)
	health_value.add_theme_constant_override("outline_size", 0)

func _sync_clipped_fill() -> void:
	if not clipped_fill: return
	clipped_fill.material.set_shader_parameter("bar_size", progress_bar.size)
	clipped_fill.material.set_shader_parameter("ratio", progress_bar.ratio)

func update_bar(value: float, health: float) -> void:
	progress_bar.value = value
	health_value.text = ItemWeapon.format_number(health)

func flash_damage() -> void:
	if experience_bar: return
	flash_left = damage_flash_duration

func reset_damage_flash() -> void:
	flash_left = 0.0
	if use_ui_palette:
		_apply_ui_palette()
	else:
		(progress_bar.get_theme_stylebox("fill") as StyleBoxFlat).bg_color = fill_color

func _process(delta: float) -> void:
	if flash_left <= 0.0: return
	flash_left = maxf(0.0, flash_left - delta)
	var style := progress_bar.get_theme_stylebox("fill") as StyleBoxFlat
	var base: Color = UITheme.palette.health_fill if use_ui_palette else fill_color
	var flash_color := base.lerp(UITheme.palette.hud_text, flash_left / damage_flash_duration)
	if clipped_fill: clipped_fill.material.set_shader_parameter("fill_color", flash_color)
	else: style.bg_color = flash_color
	var outline := progress_bar.get_node_or_null("Outline") as Panel
	if outline:
		(outline.get_theme_stylebox("panel") as StyleBoxFlat).border_color = UITheme.palette.hud_text.lerp(base, flash_left / damage_flash_duration)


func _on_health_component_on_health_changed(current: float, hp_max: float) -> void:
	var value := current / hp_max
	update_bar(value, current)
