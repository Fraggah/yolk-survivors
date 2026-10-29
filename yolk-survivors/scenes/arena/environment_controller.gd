extends Node2D
class_name ArenaEnvironmentController

@export var stages: Array[ArenaStage]
@export var debug_forced_stage := 0
## World-space breathing room around the playable area in full-arena view.
@export var overview_playable_margin := Vector2(140,160)
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
	_sync_debug_shop_visibility()
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
		var debug_layer=preload("res://scenes/arena/debug_stage_selector.tscn").instantiate()
		add_child(debug_layer)
		debug_stage_selector=debug_layer.get_node("Stages")
		debug_stage_selector.add_item("TEST: usar configuración de oleada")
		for stage in stages: debug_stage_selector.add_item("TEST: " + stage.display_name)
		debug_stage_selector.select(clampi(debug_forced_stage, 0, stages.size()))
		debug_stage_selector.tooltip_text = "Se aplica al iniciar la próxima oleada. No se guarda."
		debug_stage_selector.item_selected.connect(_on_debug_stage_selected)
		_bind_debug_shop_visibility.call_deferred()

func _bind_debug_shop_visibility() -> void:
	var arena=get_parent()
	arena.shop_panel.visibility_changed.connect(_sync_debug_shop_visibility)
	if arena.coop:
		arena.coop.screen.visibility_changed.connect(_sync_debug_shop_visibility)
		arena.coop.grids.visibility_changed.connect(_sync_debug_shop_visibility)
	_sync_debug_shop_visibility()

func _sync_debug_shop_visibility() -> void:
	if not is_instance_valid(debug_stage_selector): return
	var arena=get_parent()
	if not arena is Arena or arena.is_queued_for_deletion(): return
	var coop_shop: bool=arena.coop!=null and arena.coop.mode in ["shop","upgrades","rewards"] and arena.coop.screen.is_visible_in_tree()
	debug_stage_selector.visible=not arena.in_arena and not arena.wave_active and not (arena.coop and arena.coop.active) and not arena.shop_panel.is_visible_in_tree() and not coop_shop

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
	var wave_spawner = get_parent().get_node_or_null("Spawner")
	var wave_config = wave_spawner.wave_data_for(wave) if wave_spawner else null
	if wave_config and wave_config.has_boss_encounter():
		selected_stages[wave] = wave_config.boss_encounter.arena_stage
		return selected_stages[wave]
	if OS.is_debug_build() and debug_forced_stage > 0 and debug_forced_stage <= stages.size():
		selected_stages[wave] = stages[debug_forced_stage - 1]
		return selected_stages[wave]
	if selected_stages.has(wave): return selected_stages[wave]
	var eligible := stages.filter(func(stage): return stage != null and stage.is_valid())
	if eligible.is_empty(): return null
	var selected: ArenaStage
	if forced_stage != null and eligible.has(forced_stage):
		selected = forced_stage
	else:
		var spawner = get_parent().get_node_or_null("Spawner")
		var config = spawner.wave_data_for(wave) if spawner else null
		var mode: int = config.arena_mode if config else 0
		if mode == 1 and config.fixed_arena != null and config.fixed_arena.is_valid():
			selected = config.fixed_arena
		elif mode == 2:
			var specials := eligible.filter(func(stage): return stage.mechanic_scene != null)
			if not specials.is_empty(): selected = specials[stage_random.randi_range(0, specials.size()-1)]
		if selected == null:
			for stage in eligible:
				if stage.mechanic_scene == null:
					selected = stage
					break
	if selected == null: return null
	selected_stages[wave] = selected
	return selected

func apply_wave(wave: int) -> ArenaEnvironment:
	return apply_stage(prepare_wave(wave))

func overview_playable_bounds() -> Rect2:
	# Handles and other decorative extensions must not shift the gameplay center.
	var margin := overview_playable_margin.max(Vector2.ZERO)
	var framed := Rect2(current.movement_bounds.position-margin,current.movement_bounds.size+margin*2)
	if current_stage.vessel_body_rect.has_area():
		var pixels := current_stage.vessel_body_rect
		var body := vessel.global_transform * Rect2(vessel.get_rect().position+pixels.position,pixels.size)
		framed = framed.merge(body.grow(40))
	# Preserve the gameplay center even if a future sprite has an asymmetric rim.
	var center := current.movement_bounds.get_center()
	var half := (framed.position-center).abs().max((framed.end-center).abs())
	return Rect2(center-half,half*2)

func cover_camera_background(view: Rect2) -> void:
	if not current or not is_instance_valid(flat_background): return
	var base := Rect2(current.background_offset-current.background_size*0.5,current.background_size)
	var covered := base.merge(view)
	flat_background.position = to_local(covered.position)
	flat_background.size = covered.size

func apply_stage(stage: ArenaStage) -> ArenaEnvironment:
	current_stage = stage
	if not current_stage: return null
	current = current_stage.play_area
	if current_stage:
		flat_background.color = current_stage.background_color
		flat_background.material = current_stage.background_material
		flat_background.position = current.background_offset - current.background_size * 0.5
		flat_background.size = current.background_size
		vessel.texture = current_stage.vessel
		vessel.material = current_stage.vessel_material
		vessel.modulate = current_stage.get_meta("prototype_tint", Color.WHITE)
		vessel.position = current_stage.vessel_offset
		vessel.scale = current_stage.vessel_size / vessel.texture.get_size()
	return current
