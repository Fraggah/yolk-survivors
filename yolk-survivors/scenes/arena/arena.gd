extends Node2D
class_name Arena

@export var player: Player
@export var normal_color: Color
@export var block_color: Color
@export var critical_color: Color
@export var hp_reg_color: Color

@onready var wave_index_label: Label = %WaveIndexLabel
@onready var wave_timer_label: Label = %WaveTimerLabel
@onready var spawner: Spawner = $Spawner
@onready var upgrade_panel: UpgradePanel = $GameUI/UpgradePanel


func _ready() -> void:
	Global.player = player
	Global.on_create_block_text.connect(on_create_block_text)
	Global.on_create_damage_text.connect(_on_create_damage_text)
	Global.on_create_heal_text.connect(_on_create_heal_text)
	Global.on_upgrade_selected.connect(_on_upgrade_selected)
	
	spawner.start_wave()

func _process(delta: float) -> void:
	if Global.game_paused: return
	wave_index_label.text = spawner.get_wave_text()
	wave_timer_label.text = spawner.get_wave_timer_text()

func create_floating_text(unit: Node2D) -> FloatingText:
	var instance := Global.FLOATING_TEXT_SCENE.instantiate() as FloatingText
	get_tree().root.add_child(instance)
	var random_pos := randf_range(0, TAU) * 35
	var spawn_pos := unit.global_position + Vector2.RIGHT.rotated(random_pos)
	instance.global_position = spawn_pos
	return instance

func start_new_wave() -> void:
	Global.game_paused = false
	Global.player.upgrade_player_for_new_wave()
	spawner.wave_index += 1
	spawner.start_wave()
	

func show_upgrades() -> void:
	upgrade_panel.show()

func on_create_block_text(unit: Node2D) -> void:
	var text := create_floating_text(unit)
	text.setup_text("Blocked", block_color)

func _on_create_damage_text(unit: Node2D, hitbox: HitboxComponent) -> void:
	var text := create_floating_text(unit)
	var color := critical_color if hitbox.critical else normal_color
	text.setup_text(str(hitbox.damage), color)

func _on_create_heal_text(unit: Node2D, value: float) -> void:
	var text := create_floating_text(unit)
	text.setup_text("+ %d" % value, hp_reg_color)

func _on_spawner_on_wave_completed() -> void:
	if not Global.player: return
	
	await get_tree().create_timer(1).timeout
	show_upgrades()

func _on_upgrade_selected() -> void:
	upgrade_panel.hide()
	start_new_wave()
