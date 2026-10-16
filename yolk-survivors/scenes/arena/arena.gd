extends Node2D
class_name Arena


@export var normal_color: Color
@export var block_color: Color
@export var critical_color: Color
@export var hp_reg_color: Color

@onready var wave_index_label: Label = %WaveIndexLabel
@onready var wave_timer_label: Label = %WaveTimerLabel
@onready var player_health_bar: HealthBar = $GameUI/PlayerHealthBar
@onready var experience_bar: HealthBar = $GameUI/ExperienceBar
@onready var spawner: Spawner = $Spawner
@onready var upgrade_panel: UpgradePanel = $GameUI/UpgradePanel
@onready var shop_panel: ShopPanel = %ShopPanel
@onready var coins_bag: CoinsBag = %CoinsBag
@onready var coocking_player: AudioStreamPlayer = $CoockingPlayer
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var final_screen: Control = $GameUI/FinalScreen
@onready var selection_panel: SelectionPanel = $GameUI/SelectionPanel
@onready var weapon_selection_panel: SelectionPanel = $GameUI/WeaponSelectionPanel
@onready var final_label: Label = %FinalLabel
@onready var level_panel: LevelPanel = $GameUI/LevelPanel
@onready var start_panel: StartPanel = $GameUI/StartPanel
@onready var options_panel: OptionsPanel = $GameUI/OptionsPanel
@onready var credits_panel: CreditsPanel = $GameUI/CreditsPanel
@onready var pause_panel: PausePanel = $GameUI/PausePanel
@onready var environment_controller: ArenaEnvironmentController = $Environment
@onready var stage_mechanics: StageMechanicsController = $StageMechanics


var gold_list: Array[Coins]

var in_arena := false
var wave_active := false
var defeat_in_progress := false
var unlock_modal_active := false
var last_warning_second := -1
var damage_feedback: CanvasLayer
var paused_intermission_panel: Control
var paused_intermission_focus: Control
var stress_test: Node
var projectile_pool: Node
var run_experience = preload("res://resources/run_experience.gd").new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	projectile_pool = load("res://scenes/projectiles/projectile_pool.gd").new()
	add_child(projectile_pool)
	stress_test = load("res://scenes/arena/stress_test.gd").new()
	add_child(stress_test)
	level_panel.on_stress_test_selected.connect(_on_stress_test_selected)
	damage_feedback = load("res://scenes/ui/player_damage_feedback.gd").new()
	add_child(damage_feedback)
	damage_feedback.defeat_finished.connect(_finish_defeat)
	run_experience.level_gained.connect(_on_experience_level_gained)
	run_experience.changed.connect(_update_experience_bar)
	_update_experience_bar()
	MenuInput.register_menus([pause_panel, options_panel, credits_panel, final_screen, level_panel, weapon_selection_panel, selection_panel, shop_panel, upgrade_panel, start_panel])
	Global.on_create_block_text.connect(on_create_block_text)
	Global.on_create_damage_text.connect(_on_create_damage_text)
	Global.on_create_heal_text.connect(_on_create_heal_text)
	Global.on_upgrade_selected.connect(_on_upgrade_selected)
	Global.on_level_selected.connect(_on_level_selected)
	Global.on_enemy_died.connect(_on_enemy_died)
	Global.on_player_died.connect(_on_player_died)
	var unlock_notice = load("res://scenes/ui/unlock_notice.gd").new()
	unlock_notice.name = "UnlockPresentation"
	add_child(unlock_notice)
	coocking_player.stream_paused = true
	spawner.on_wave_started.connect(_apply_wave_environment)
	spawner.on_wave_started.connect(_on_wave_started_sfx)
	stage_mechanics.setup(spawner, environment_controller)
	_apply_wave_environment(1)

func _apply_wave_environment(wave: int) -> void:
	last_warning_second = -1
	Progression.begin_wave()
	var environment := environment_controller.apply_wave(wave)
	if not environment: return
	spawner.arena_environment = environment
	$Camera2D.zoom = Vector2.ONE * environment.camera_zoom
	$Camera2D.world_bounds = Rect2(environment.background_offset - environment.background_size * 0.5, environment.background_size)
	if is_instance_valid(Global.player):
		Global.player.arena_environment = environment
		Global.player.global_position = environment.movement_bounds.get_center()
		player_health_bar.reset_damage_flash()
	if is_instance_valid(spawner.fueguito):
		spawner.fueguito.global_position = environment.clamp_position(spawner.fueguito.global_position)

func _process(_delta: float) -> void:
	if stress_test and stress_test.active:
		wave_index_label.text = "STRESS TEST"
		wave_timer_label.text = ""
		return
	player_health_bar.visible = in_arena and is_instance_valid(Global.player) and not final_screen.visible and not defeat_in_progress
	experience_bar.visible = player_health_bar.visible
	toggle_pause()
	if Global.game_paused: return
	wave_index_label.text = spawner.get_wave_text()
	wave_timer_label.text = spawner.get_wave_timer_text()
	var seconds_left := int(wave_timer_label.text)
	if wave_active and seconds_left >= 1 and seconds_left <= 5 and seconds_left != last_warning_second:
		last_warning_second = seconds_left
		SoundManager.play_sound(SoundManager.Sound.WAVE_FINAL_SECONDS)
	var timer_color: Color = UITheme.palette.health_fill if seconds_left <= 5 else UITheme.palette.hud_text
	if wave_timer_label.get_theme_color("font_color") != timer_color:
		wave_timer_label.add_theme_color_override("font_color",timer_color)

func _on_wave_started_sfx(_wave: int) -> void:
	SoundManager.play_sound(SoundManager.Sound.WAVE_START)

func create_floating_text(unit: Node2D) -> FloatingText:
	var instance = CombatTexts.acquire() as FloatingText
	var random_pos := randf_range(0, TAU) * 35
	var spawn_pos := unit.global_position + Vector2.RIGHT.rotated(random_pos)
	instance.global_position = spawn_pos
	return instance

func start_new_wave() -> void:
	Weapon.begin_damage_wave()
	Global.game_paused = false
	Global.player.prepare_for_new_wave()
	spawner.wave_index += 1
	spawner.start_wave()
	wave_active = not spawner.wave_timer.is_stopped()
	coocking_player.stream_paused = false


func show_upgrades() -> void:
	shop_panel.set_next_stage(environment_controller.prepare_wave(spawner.wave_index + 1), spawner.wave_index + 1)
	if run_experience.pending_levels.is_empty():
		shop_panel.load_shop(spawner.wave_index)
		shop_panel.show()
		return
	var earned_level: int = run_experience.pending_levels[0]
	upgrade_panel.load_upgrades(earned_level)
	upgrade_panel.get_node("HBoxContainer/VBoxContainer/Label").text = "Level %d\nChoose upgrade (%d remaining)" % [earned_level, run_experience.pending_levels.size()]
	upgrade_panel.show()

func _on_experience_level_gained(_level: int) -> void:
	if not is_instance_valid(Global.player): return
	var player = Global.player
	var previous_max: float = player.stats.health
	player.stats.apply_stat_change("health", 1.0)
	player.health_component.max_health = player.stats.health
	player.health_component.heal(maxf(0.0, player.stats.health - previous_max))

func _update_experience_bar() -> void:
	experience_bar.progress_bar.value = float(run_experience.experience) / run_experience.required_experience()
	experience_bar.health_value.text = "LV %d  %d / %d" % [run_experience.level, run_experience.experience, run_experience.required_experience()]
	experience_bar.health_value.add_theme_font_size_override("font_size", 22)


func spawn_coins(enemy: Enemy) -> void:
	var random_angle := randf_range(0, TAU)
	var offset := Vector2.RIGHT.rotated(random_angle) * 35
	var spawn_pos := enemy.global_position + offset
	spawn_yolk_at(spawn_pos, enemy.stats.coin_drop)

func spawn_yolk_at(spawn_pos: Vector2, value: int = 1) -> void:
	var instance := Global.COINS_SCENE.instantiate()
	gold_list.append(instance)

	instance.global_position = spawn_pos
	instance.value = value
	call_deferred("add_child", instance)

func clear_arena(bank_yolks: bool = false) -> void:
	CombatTexts.clear()
	ElectricRays.clear()
	projectile_pool.clear()
	if stress_test and stress_test.active: stress_test.stop()
	for attack in get_tree().get_nodes_in_group("continuous_attacks"): attack.reset_attack()
	for pool in get_tree().get_nodes_in_group("mayonnaise_particles"): pool.clear()
	for controller in get_tree().get_nodes_in_group("status_controllers"): controller.clear()
	EnemyHitFeedback.clear()
	for text in get_tree().get_nodes_in_group("combat_texts"):
		text.hide()
		text.queue_free()
	# Player projectiles live under the root, enemy projectiles under Arena.
	# A shared group clears both when the wave/run ends, including while paused.
	for projectile in get_tree().get_nodes_in_group("projectiles"):
		projectile.hide()
		projectile.queue_free()
	# Replace (never accumulate) the old unused bonus with this wave's base drops.
	Global.yolk_reserve = 0
	for coin in gold_list:
		if not is_instance_valid(coin) or coin.is_queued_for_deletion(): continue
		if bank_yolks:
			Global.yolk_reserve += maxi(0, coin.value)
			coin.call_deferred("fly_to_jar", coins_bag.jar_icon)
		else:
			coin.queue_free()
	if not bank_yolks:
		# Includes flights already removed from gold_list by a previous wave end.
		for coin in get_tree().get_nodes_in_group("yolks"):
			coin.queue_free()

	gold_list.clear()
	spawner.clear_enemies()

func on_create_block_text(unit: Node2D) -> void:
	var text := create_floating_text(unit)
	text.setup_text("Blocked", block_color)

func _on_create_damage_text(unit: Node2D, hitbox: HitboxComponent) -> void:
	var color := critical_color if hitbox.critical else normal_color
	var displayed_damage: float = hitbox.damage * (unit.stats.get_incoming_damage_multiplier() if unit is Player else 1.0)
	CombatTexts.queue_damage(unit, displayed_damage, color, hitbox.critical)

func _on_create_heal_text(unit: Node2D, value: float) -> void:
	var text := create_floating_text(unit)
	text.setup_text("+ %s" % ItemWeapon.format_number(value), hp_reg_color)

func toggle_pause() -> void:
	if unlock_modal_active: return
	if not in_arena or defeat_in_progress: return
	if not Input.is_action_just_pressed("pause"): return
	set_wave_paused(not pause_panel.visible)

func set_wave_paused(paused: bool) -> void:
	if unlock_modal_active or defeat_in_progress: return
	if not in_arena: return
	if not wave_active:
		if paused:
			if pause_panel.visible: return
			var panel: Control = shop_panel if shop_panel.visible else upgrade_panel if upgrade_panel.visible else null
			if not panel: return
			paused_intermission_focus = get_viewport().gui_get_focus_owner()
			paused_intermission_panel = panel
			panel.hide()
			pause_panel.show()
			music_player.stream_paused = true
		elif is_instance_valid(paused_intermission_panel):
			pause_panel.hide()
			paused_intermission_panel.show()
			if is_instance_valid(paused_intermission_focus): paused_intermission_focus.grab_focus()
			paused_intermission_panel = null
			paused_intermission_focus = null
			music_player.stream_paused = false
		Global.game_paused = true
		return
	Global.game_paused = paused
	pause_panel.visible = paused
	spawner.wave_timer.paused = paused
	spawner.spawn_timer.paused = paused
	coocking_player.stream_paused = paused
	music_player.stream_paused = paused

func _on_spawner_on_wave_completed() -> void:
	if stress_test and stress_test.active: return
	SoundManager.play_sound(SoundManager.Sound.WAVE_COMPLETE)
	Weapon.finish_damage_wave()
	wave_active = false
	if not Global.player: return
	Progression.finish_wave()
	Global.game_paused = true
	coocking_player.stream_paused = true
	clear_arena(spawner.wave_index < spawner.last_wave_number())
	if spawner.wave_index < spawner.last_wave_number():
		shop_panel.set_next_stage(environment_controller.prepare_wave(spawner.wave_index + 1), spawner.wave_index + 1)
	wave_timer_label.text = str(0)
	await get_tree().create_timer(1).timeout
	Global.get_harvesting_coins()
	if spawner.wave_index >= spawner.last_wave_number():
		Progression.end_run(true)
		spawner.clear_fueguito()
		final_label.text = "YOU WIN!"
		if Global.level_selected == Global.level_reached:
			if Global.level_reached < 5: Global.level_reached += 1
			level_panel.enable_buttons(Global.level_reached)
		Progression.save_progress()
		coocking_player.stream_paused = true
		final_screen.show()
		Global.player.queue_free()
		Global.player = null
		return
	upgrade_panel.begin_wave_rewards(spawner.wave_index)
	show_upgrades()
	spawner.clear_enemies()

func _on_upgrade_selected() -> void:
	if not upgrade_panel.visible or run_experience.pending_levels.is_empty(): return
	upgrade_panel.hide()
	run_experience.pending_levels.pop_front()
	show_upgrades()


func _on_shop_panel_on_shop_next_wave() -> void:
	shop_panel.hide()
	Global.game_paused = false
	start_new_wave()

func _on_enemy_died(enemy: Enemy) -> void:
	if not wave_active or not is_instance_valid(Global.player): return
	if enemy.get_meta("stage_hazard", false): return
	if enemy.has_meta("kill_reward_processed"): return
	enemy.set_meta("kill_reward_processed", true)
	var instance := Global.FRIED_SCENE.instantiate()
	add_child(instance)
	instance.global_position = enemy.global_position
	if not enemy.last_hit_grants_rewards: return
	if not stress_test.active: run_experience.add_experience(enemy.stats.experience_reward)
	Progression.record("kills", 1.0)
	spawn_coins(enemy)

func _on_selection_panel_on_selection_completed() -> void:
	await selection_panel.animate_character_to_weapons()
	selection_panel.hide()
	weapon_selection_panel.show()
	weapon_selection_panel.reveal_weapon_roster()

func _on_weapon_selection_completed() -> void:
	weapon_selection_panel.hide()
	level_panel.show()

func _on_weapon_selection_exited() -> void:
	weapon_selection_panel.hide()
	selection_panel.show()

func _on_stress_test_selected(population: int = 1000) -> void:
	if in_arena: return
	stress_test.target_population = population
	_on_level_selected(0,true)

func _on_level_selected(level: int, stress_mode: bool = false) -> void:
	# Ignore repeated confirmation and refuse an incomplete/invalid loadout.
	if in_arena: return
	var starting_weapons := Global.get_starting_weapons()
	if starting_weapons.is_empty() and not Global.is_empty_preview_loadout(): return
	if stress_mode:
		if starting_weapons.is_empty(): return
		var selected: ItemWeapon = Global.main_weapon_selected if Global.is_valid_starting_weapon(Global.main_weapon_selected) else starting_weapons[0]
		starting_weapons.clear()
		for i in Global.MAX_EQUIPPED_WEAPONS: starting_weapons.append(selected)
		Progression.end_run()
	Global.yolk_reserve = 0
	run_experience.reset()
	Weapon.damage_records.clear()
	var player := Global.get_selected_player()
	_reset_damage_feedback()
	level = spawner.DIFFICULTY_RULES.normalize_level(level)
	Global.level_selected = level
	environment_controller.reset_stage_selection()
	spawner.reset_run(level)
	add_child(player)
	player.get_node("HealthBar").hide()
	player.health_component.on_health_changed.connect(player_health_bar._on_health_component_on_health_changed)
	player.health_component.on_health_changed.connect(damage_feedback.update_health)
	player.health_component.on_unit_hit.connect(player_health_bar.flash_damage)
	damage_feedback.update_health(player.health_component.current_health, player.health_component.max_health)
	player_health_bar._on_health_component_on_health_changed(player.health_component.current_health, player.health_component.max_health)
	if not stress_mode: Progression.begin_run(player.stats.unlock_id, player.stats)
	Global.equipped_weapons.clear()
	shop_panel.reset_offers()
	shop_panel.clear_items()
	for weapon in starting_weapons:
		player.add_weapon(weapon)
		shop_panel.create_item_weapon(weapon)
		Global.equipped_weapons.append(weapon)
	coocking_player.stream_paused = false
	spawner.wave_timer.paused = false
	spawner.spawn_timer.paused = false
	spawner.start_wave()
	wave_active = not spawner.wave_timer.is_stopped()
	Global.game_paused = false
	Global.coins = Global.STARTING_COINS
	in_arena = true
	level_panel.hide()
	if stress_mode:
		stress_test.start(self)
		wave_active = true

func _on_player_died() -> void:
	if defeat_in_progress or not is_instance_valid(Global.player): return
	defeat_in_progress = true
	SoundManager.play_sound(SoundManager.Sound.RUN_DEFEAT)
	var screen_position := Global.player.get_global_transform_with_canvas().origin
	var corpse_size: float = 110.0 * $Camera2D.zoom.x
	Global.player.hide()
	Weapon.finish_damage_wave()
	Progression.end_run()
	Global.player = null
	Global.yolk_reserve = 0
	wave_active = false
	spawner.wave_timer.stop()
	spawner.clear_fueguito()
	spawner.spawn_timer.stop()
	Global.game_paused = true
	for enemy in spawner.spawned_enemies + spawner.special_enemies + spawner.boss_enemies:
		if is_instance_valid(enemy): enemy.process_mode = Node.PROCESS_MODE_DISABLED
	stage_mechanics.process_mode = Node.PROCESS_MODE_DISABLED
	$Camera2D.clear_shake()
	wave_index_label.hide()
	wave_timer_label.hide()
	coins_bag.hide()
	if is_instance_valid(environment_controller.debug_stage_selector): environment_controller.debug_stage_selector.hide()
	pause_panel.hide()
	coocking_player.stream_paused = true
	damage_feedback.begin_defeat(screen_position, corpse_size)

func _finish_defeat() -> void:
	if not defeat_in_progress: return
	clear_arena()
	final_label.text = "YOU LOSE!"
	final_label.add_theme_color_override("font_color", UITheme.palette.hud_text)
	$GameUI.layer = 3
	final_screen.get_node("Panel").add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	final_label.offset_top = -235
	final_label.offset_bottom = -112
	final_screen.get_node("Panel/FinalButton").offset_top = 112
	final_screen.get_node("Panel/FinalButton").offset_bottom = 232
	final_screen.show()

func _reset_damage_feedback() -> void:
	defeat_in_progress = false
	damage_feedback.reset()
	stage_mechanics.process_mode = Node.PROCESS_MODE_INHERIT
	$GameUI.layer = 1
	final_screen.get_node("Panel").remove_theme_stylebox_override("panel")
	final_label.remove_theme_color_override("font_color")
	final_label.offset_top = -140
	final_label.offset_bottom = -16.75
	final_screen.get_node("Panel/FinalButton").offset_top = 10
	final_screen.get_node("Panel/FinalButton").offset_bottom = 130
	wave_index_label.show()
	wave_timer_label.show()
	coins_bag.show()
	if is_instance_valid(environment_controller.debug_stage_selector): environment_controller.debug_stage_selector.show()

func _on_final_button_pressed() -> void:
	_reset_damage_feedback()
	wave_active = false
	spawner.clear_fueguito()
	_apply_wave_environment(1)
	in_arena = false
	spawner.wave_index = 1
	Global.coins = Global.STARTING_COINS
	Global.main_player_selected = null
	Global.main_weapon_selected = null
	Global.selected_weapon = null
	Global.equipped_weapons.clear()
	shop_panel.reset_offers()
	shop_panel.clear_items()
	final_screen.hide()
	clear_arena()
	Global.game_paused = true
	selection_panel.show()

func _on_start_panel_on_credits_pressed() -> void:
	start_panel.hide()
	credits_panel.show()

func _on_start_panel_on_options_pressed() -> void:
	start_panel.hide()
	options_panel.show()

func _on_start_panel_on_play_pressed() -> void:
	start_panel.hide()
	selection_panel.show()


func _on_options_panel_on_options_exited() -> void:
	options_panel.hide()
	start_panel.show()

func _on_credits_panel_on_credits_exited() -> void:
	credits_panel.hide()
	start_panel.show()


func _on_level_panel_on_level_selection_exited() -> void:
	level_panel.hide()
	weapon_selection_panel.show()


func _on_selection_panel_on_level_select_exited() -> void:
	selection_panel.hide()
	start_panel.show()


func _on_pause_panel_on_exit_pressed() -> void:
	paused_intermission_panel = null
	paused_intermission_focus = null
	shop_panel.hide()
	upgrade_panel.hide()
	Weapon.finish_damage_wave()
	Progression.end_run()
	wave_active = false
	spawner.wave_timer.stop()
	spawner.spawn_timer.stop()
	spawner.clear_fueguito()
	_apply_wave_environment(1)
	in_arena = false
	spawner.wave_index = 1
	Global.coins = Global.STARTING_COINS
	Global.main_player_selected = null
	Global.main_weapon_selected = null
	Global.selected_weapon = null
	Global.equipped_weapons.clear()
	shop_panel.reset_offers()
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
	set_wave_paused(false)


func _on_start_panel_on_exit_pressed() -> void:
	#podria guardar los datos aca tambien.. pero perderia un poco de sentido el boton de guardado
	get_tree().quit()



func _on_options_panel_on_load_game() -> void:
	level_panel.enable_buttons(Global.level_reached)
