extends Node2D
class_name ArenaEnvironmentController

@export var stages: Array[ArenaStage]
@export var debug_forced_stage := 0
var debug_stage_selector: OptionButton
@onready var background: Sprite2D = $BG
@onready var vessel: Sprite2D = $Vessel
var current: ArenaEnvironment
var current_stage: ArenaStage
var selected_stages: Dictionary = {}
var flat_background: ColorRect
var stage_random := RandomNumberGenerator.new()
var background_phase := 0.0

func _process(delta: float) -> void:
	background_phase += delta
	if flat_background and flat_background.material is ShaderMaterial:
		flat_background.material.set_shader_parameter("phase", background_phase)

func _ready() -> void:
	stage_random.randomize()
	flat_background = ColorRect.new()
	flat_background.name = "WorldBackground"
	flat_background.z_index = -100
	flat_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flat_background)
	background.hide()
	if OS.is_debug_build():
		var debug_layer := CanvasLayer.new()
		debug_layer.layer = 100
		add_child(debug_layer)
		debug_stage_selector = OptionButton.new()
		debug_layer.add_child(debug_stage_selector)
		debug_stage_selector.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
		debug_stage_selector.offset_left = 16
		debug_stage_selector.offset_top = -48
		debug_stage_selector.offset_right = 370
		debug_stage_selector.offset_bottom = -10
		debug_stage_selector.add_item("TEST: escenario aleatorio")
		for stage in stages: debug_stage_selector.add_item("TEST: " + stage.display_name)
		debug_stage_selector.select(clampi(debug_forced_stage, 0, stages.size()))
		debug_stage_selector.tooltip_text = "Se aplica al iniciar la próxima oleada. No se guarda."
		debug_stage_selector.item_selected.connect(_on_debug_stage_selected)

func _on_debug_stage_selected(index: int) -> void:
	debug_forced_stage = index
	var arena = get_parent()
	if arena and arena.in_arena and not arena.wave_active:
		var next_wave: int = arena.spawner.wave_index + 1
		selected_stages.erase(next_wave)
		arena.shop_panel.set_next_stage(prepare_wave(next_wave), next_wave)

func reset_stage_selection() -> void:
	selected_stages.clear()
	current_stage = null

func prepare_wave(wave: int, forced_stage: ArenaStage = null) -> ArenaStage:
	if OS.is_debug_build() and debug_forced_stage > 0 and debug_forced_stage <= stages.size():
		selected_stages[wave] = stages[debug_forced_stage - 1]
		return selected_stages[wave]
	if selected_stages.has(wave): return selected_stages[wave]
	var eligible := stages.filter(func(stage): return stage != null and stage.is_valid())
	if eligible.is_empty(): return null
	var selected: ArenaStage = forced_stage if forced_stage != null and eligible.has(forced_stage) else eligible[stage_random.randi_range(0, eligible.size() - 1)]
	selected_stages[wave] = selected
	return selected

func apply_wave(wave: int) -> ArenaEnvironment:
	current_stage = prepare_wave(wave)
	if not current_stage: return null
	current = current_stage.play_area
	if current_stage:
		flat_background.color = current_stage.background_color
		flat_background.material = current_stage.background_material
		flat_background.position = current.background_offset - current.background_size * 0.5
		flat_background.size = current.background_size
		vessel.texture = current_stage.vessel
		vessel.material = current_stage.vessel_material
		vessel.position = current_stage.vessel_offset
		vessel.scale = current_stage.vessel_size / vessel.texture.get_size()
	return current
