extends Node2D
class_name Arena

@export var normal_color: Color
@export var block_color: Color
@export var critical_color: Color
@export var hp_reg_color: Color

@onready var wave_index_label: Label = %WaveIndexLabel
@onready var wave_timer_label: Label = %WaveTimerLabel
@onready var spawner: Spawner = $Spawner
@onready var upgrade_panel: UpgradePanel = $GameUI/UpgradePanel
@onready var shop_panel: ShopPanel = %ShopPanel
@onready var coins_bag: CoinsBag = %CoinsBag
@onready var coocking_player: AudioStreamPlayer = $CoockingPlayer
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var instructions: Label = %Instructions
@onready var final_screen: Control = $GameUI/FinalScreen
@onready var selection_panel: SelectionPanel = $GameUI/SelectionPanel
@onready var final_label: Label = %FinalLabel
@onready var level_panel: LevelPanel = $GameUI/LevelPanel
@onready var start_panel: StartPanel = $GameUI/StartPanel
@onready var options_panel: OptionsPanel = $GameUI/OptionsPanel
@onready var credits_panel: CreditsPanel = $GameUI/CreditsPanel
@onready var pause_panel: PausePanel = $GameUI/PausePanel


var gold_list: Array[Coins]

var in_arena := false

func _ready() -> void:
	Global.on_create_block_text.connect(on_create_block_text)
	Global.on_create_damage_text.connect(_on_create_damage_text)
	Global.on_create_heal_text.connect(_on_create_heal_text)
	Global.on_upgrade_selected.connect(_on_upgrade_selected)
	Global.on_level_selected.connect(_on_level_selected)
	Global.on_enemy_died.connect(_on_enemy_died)
	Global.on_player_died.connect(_on_player_died)
	coocking_player.stream_paused = true

func _process(_delta: float) -> void:
	toggle_pause()
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
	coocking_player.stream_paused = false
	

func show_upgrades() -> void:
	Global.calculate_tier_probability(spawner.wave_index, Global.UPGRADE_PROBABILITY_CONFIG)
	upgrade_panel.load_upgrades(spawner.wave_index)
	upgrade_panel.show()

func spawn_coins(enemy: Enemy) -> void:
	var random_angle := randf_range(0, TAU)
	var offset := Vector2.RIGHT.rotated(random_angle) * 35
	var spawn_pos := enemy.global_position + offset
	
	var instance := Global.COINS_SCENE.instantiate()
	gold_list.append(instance)
	
	instance.global_position = spawn_pos
	instance.value = enemy.stats.coin_drop
	call_deferred("add_child", instance)

func clear_arena() -> void:
	if gold_list.size() > 0:
		var target_center_pos := coins_bag.global_position + coins_bag.size / 2
		for coin: Coins in gold_list:
			if is_instance_valid(coin):
				coin.set_collection_target(target_center_pos)
	
	gold_list.clear()
	spawner.clear_enemies()

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

func toggle_pause() -> void:
	if not in_arena: return
	if not Input.is_action_just_pressed("pause"): return
	Global.game_paused = !Global.game_paused
	pause_panel.visible = Global.game_paused
	spawner.wave_timer.paused = Global.game_paused
	spawner.spawn_timer.paused = Global.game_paused
	coocking_player.stream_paused = Global.game_paused
	music_player.stream_paused = Global.game_paused

func _on_spawner_on_wave_completed() -> void:
	if not Global.player: return
	Global.game_paused = true
	coocking_player.stream_paused = true
	clear_arena()
	wave_timer_label.text = str(0)
	await get_tree().create_timer(1).timeout
	Global.get_harvesting_coins()
	if spawner.wave_index == 10: # Hardcoding vibes XD
		final_label.text = "YOU WIN!"
		if Global.level_selected == Global.level_reached:
			if Global.level_reached < 5: Global.level_reached += 1
			level_panel.enable_buttons(Global.level_reached)
		coocking_player.stream_paused = true
		final_screen.show()
		Global.player.queue_free()
		Global.player = null
		return
	show_upgrades()
	spawner.clear_enemies()

func _on_upgrade_selected() -> void:
	upgrade_panel.hide()
	shop_panel.load_shop(spawner.wave_index)
	shop_panel.show()
	

func _on_shop_panel_on_shop_next_wave() -> void:
	shop_panel.hide()
	Global.game_paused = false
	start_new_wave()

func _on_enemy_died(enemy: Enemy) -> void:
	var instance := Global.FRIED_SCENE.instantiate()
	add_child(instance)
	instance.global_position = enemy.global_position
	spawn_coins(enemy)

func _on_selection_panel_on_selection_completed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	level_panel.show()
	selection_panel.hide()

func _on_level_selected(level: int) -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	var player := Global.get_selected_player()
	spawner.reset_enemies_stats()
	add_child(player)
	player.add_weapon(Global.main_weapon_selected)
	shop_panel.create_item_weapon(Global.main_weapon_selected)
	Global.equipped_weapons.append(Global.main_weapon_selected)
	coocking_player.stream_paused = false
	spawner.wave_timer.paused = false
	spawner.spawn_timer.paused = false
	spawner.start_wave()
	show_controls()
	Global.game_paused = false
	Global.level_selected = level
	spawner.difficult_index = level
	Global.coins = 10
	in_arena = true
	level_panel.hide()

func show_controls() -> void:
	instructions.show()
	await get_tree().create_timer(3).timeout
	var tween := create_tween()
	tween.tween_property(instructions,"modulate:a", 0, 3)
	await tween.finished
	instructions.hide()

func _on_player_died() -> void:
	spawner.spawn_timer.stop()
	Global.game_paused = true
	clear_arena()
	final_label.text = "YOU LOOSE!"
	coocking_player.stream_paused = true
	final_screen.show()

func _on_final_button_pressed() -> void:
	in_arena = false
	spawner.wave_index = 1
	Global.coins = 10
	Global.main_player_selected = null
	Global.main_weapon_selected = null
	Global.selected_weapon = null
	Global.equipped_weapons.clear()
	shop_panel.clear_items()
	final_screen.hide()
	clear_arena()
	Global.game_paused = true
	selection_panel.show()

func _on_start_panel_on_credits_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	start_panel.hide()
	credits_panel.show()

func _on_start_panel_on_options_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	start_panel.hide()
	options_panel.show()

func _on_start_panel_on_play_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	start_panel.hide()
	selection_panel.show()


func _on_options_panel_on_options_exited() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	options_panel.hide()
	start_panel.show()

func _on_credits_panel_on_credits_exited() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	credits_panel.hide()
	start_panel.show()


func _on_level_panel_on_level_selection_exited() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	level_panel.hide()
	selection_panel.show()


func _on_selection_panel_on_level_select_exited() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	selection_panel.hide()
	start_panel.show()


func _on_pause_panel_on_exit_pressed() -> void:
	in_arena = false
	spawner.wave_index = 1
	Global.coins = 10
	Global.main_player_selected = null
	Global.main_weapon_selected = null
	Global.selected_weapon = null
	Global.equipped_weapons.clear()
	shop_panel.clear_items()
	final_screen.hide()
	clear_arena()
	Global.player.queue_free()
	Global.player = null
	Global.game_paused = true
	start_panel.show()
	music_player.stop()
	music_player.play()
	pause_panel.hide()


func _on_pause_panel_on_return_pressed() -> void:
	Global.game_paused = !Global.game_paused
	pause_panel.visible = Global.game_paused
	spawner.wave_timer.paused = Global.game_paused
	spawner.spawn_timer.paused = Global.game_paused
	coocking_player.stream_paused = Global.game_paused
	music_player.stream_paused = Global.game_paused


func _on_start_panel_on_exit_pressed() -> void:
	#podria guardar los datos aca tambien.. pero perderia un poco de sentido el boton de guardado
	get_tree().quit()
	


func _on_options_panel_on_load_game() -> void:
	level_panel.enable_buttons(Global.level_reached)
