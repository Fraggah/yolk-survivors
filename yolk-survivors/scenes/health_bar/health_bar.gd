extends Control
class_name HealthBar

@export var use_ui_palette := false
@export var experience_bar := false
@export var back_color: Color
@export var fill_color: Color
@export_range(0.05, 1.0) var damage_flash_duration := 0.28
var flash_left := 0.0
var clipped_fill: ColorRect
var displayed_health := 0.0
var displayed_ratio := 0.0

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var health_value: Label = %HealthValue

func _ready() -> void:
	clipped_fill=$ProgressBar/ClippedFill
	clipped_fill.visible=use_ui_palette
	$ProgressBar/Outline.visible=use_ui_palette
	progress_bar.resized.connect(_sync_clipped_fill)
	progress_bar.value_changed.connect(func(_value): _sync_clipped_fill())
	set_process(false)
	visibility_changed.connect(_refresh_health_label)
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
	var palette=UITheme.palette
	var background=progress_bar.get_theme_stylebox("background").duplicate()
	background.bg_color=palette.text
	progress_bar.add_theme_stylebox_override("background",background)
	var fill=progress_bar.get_theme_stylebox("fill").duplicate()
	fill.bg_color=Color.TRANSPARENT
	progress_bar.add_theme_stylebox_override("fill",fill)
	clipped_fill.material.set_shader_parameter("fill_color",palette.experience_fill if experience_bar else palette.health_fill)
	var outline=$ProgressBar/Outline.get_theme_stylebox("panel").duplicate()
	outline.border_color=palette.hud_text
	$ProgressBar/Outline.add_theme_stylebox_override("panel",outline)
	_sync_clipped_fill()
	health_value.add_theme_color_override("font_color",palette.hud_text)

func _sync_clipped_fill() -> void:
	if not clipped_fill: return
	clipped_fill.material.set_shader_parameter("bar_size", progress_bar.size)
	clipped_fill.material.set_shader_parameter("ratio", progress_bar.ratio)

func update_bar(value: float, health: float) -> void:
	displayed_ratio = value
	displayed_health = health
	if not is_visible_in_tree(): return
	progress_bar.value = value
	_refresh_health_label()

func _refresh_health_label() -> void:
	if is_visible_in_tree() and is_instance_valid(progress_bar): progress_bar.value = displayed_ratio
	if experience_bar: return # Experience text is supplied by its owning HUD.
	if is_visible_in_tree() and is_instance_valid(health_value):
		health_value.text = str(ceili(displayed_health))

func flash_damage() -> void:
	if experience_bar: return
	flash_left = damage_flash_duration
	set_process(true)

func reset_damage_flash() -> void:
	flash_left = 0.0
	set_process(false)
	if use_ui_palette:
		_apply_ui_palette()
	else:
		(progress_bar.get_theme_stylebox("fill") as StyleBoxFlat).bg_color = fill_color

func _process(delta: float) -> void:
	if flash_left <= 0.0: return
	flash_left = maxf(0.0, flash_left - delta)
	if flash_left<=0.0: set_process(false)
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
