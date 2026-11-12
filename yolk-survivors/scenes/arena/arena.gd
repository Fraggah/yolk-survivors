extends Node2D
class_name Arena


@export var normal_color: Color
@export var block_color: Color
@export var critical_color: Color
@export var hp_reg_color: Color
## Maximum number of physical yolk pickups per wave, including pending spawns.
@export_range(1, 500) var yolk_pickup_limit := 60
## Temporary solo UI fixture; disable after testing consumable placement.
@export var test_tiny_egg_consumables := true

@onready var wave_index_label: Label = %WaveIndexLabel
@onready var wave_timer_label: Label = %WaveTimerLabel
@onready var player_health_bar: HealthBar = $GameUI/PlayerHealthBar
@onready var experience_bar: HealthBar = $GameUI/ExperienceBar
@onready var spawner: Spawner = $Spawner
@onready var upgrade_panel: UpgradePanel = $GameUI/UpgradePanel
@onready var shop_panel: ShopPanel = %ShopPanel
@onready var coins_bag: CoinsBag = %CoinsBag
@onready var coocking_player: AudioStreamPlayer = $CoockingPlayer
@onready var music_player = $MusicManager
@onready var final_screen: Control = $GameUI/FinalScreen
@onready var selection_panel: SelectionPanel = $GameUI/SelectionPanel
@onready var weapon_selection_panel: SelectionPanel = $GameUI/WeaponSelectionPanel
@onready var final_label: Label = $GameUI/FinalScreen/Panel/FinalLabel
@onready var level_panel: LevelPanel = $GameUI/LevelPanel
@onready var start_panel: StartPanel = $GameUI/StartPanel
@onready var options_panel: OptionsPanel = $GameUI/OptionsPanel
@onready var credits_panel: CreditsPanel = $GameUI/CreditsPanel
@onready var pause_panel: PausePanel = $GameUI/PausePanel
@onready var environment_controller: ArenaEnvironmentController = $Environment
@onready var stage_mechanics: StageMechanicsController = $StageMechanics


var gold_list: Array[Coins]
var _pending_yolk_value := 0
var _pending_yolk_position := Vector2.ZERO

var in_arena := false
var wave_active := false
var _bonus_upgrades_before_wave := false
var defeat_in_progress := false
var unlock_modal_active := false
var last_warning_second := -1
var damage_feedback: CanvasLayer
var paused_intermission_panel: Control
var paused_intermission_focus: Control
var boss_encounter: Node2D
var boss_test_mode := false
var boss_wave_active := false
var coop: Node
@onready var coop_selection: Node = $CoopSelection
var stress_test: Node
var incognito_rewards
var projectile_pool: Node
var run_experience = preload("res://resources/run_experience.gd").new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	coop=preload("res://scenes/coop/local_coop.tscn").instantiate()
	add_child(coop)
	coop_selection.setup(self)
	projectile_pool = load("res://scenes/projectiles/projectile_pool.gd").new()
	add_child(projectile_pool)
	stress_test = load("res://scenes/arena/stress_test.tscn").instantiate()
	add_child(stress_test)
	level_panel.setup_difficulties(spawner)
	level_panel.on_stress_test_selected.connect(_on_stress_test_selected)
	boss_encounter = load("res://scenes/bosses/boss_encounter.gd").new()
	add_child(boss_encounter)
	boss_encounter.defeated.connect(_on_boss_test_defeated, CONNECT_DEFERRED)
	level_panel.on_boss_test_selected.connect(_on_boss_test_selected)
	damage_feedback = load("res://scenes/ui/player_damage_feedback.tscn").instantiate()
	add_child(damage_feedback)
	damage_feedback.defeat_finished.connect(_finish_defeat)
	run_experience.level_gained.connect(_on_experience_level_gained)
	run_experience.changed.connect(_update_experience_bar)
	_update_experience_bar()
	incognito_rewards = load("res://scenes/ui/incognito_rewards.tscn").instantiate()
	incognito_rewards.arena = self
	$GameUI.add_child(incognito_rewards)
	incognito_rewards.resolved.connect(_continue_wave_rewards)
	MenuInput.register_menus([shop_panel.golden_animation, shop_panel.coin_animation, pause_panel, options_panel, credits_panel, final_screen, level_panel, weapon_selection_panel, selection_panel, incognito_rewards, shop_panel, upgrade_panel, start_panel])
	Global.on_create_block_text.connect(on_create_block_text)
	Global.on_create_damage_text.connect(_on_create_damage_text)
	Global.on_create_heal_text.connect(_on_create_heal_text)
	Global.on_upgrade_selected.connect(_on_upgrade_selected)
	Global.on_level_selected.connect(_on_level_selected)
	Global.on_enemy_died.connect(_on_enemy_died)
	Global.on_player_died.connect(_on_player_died)
	var unlock_notice = load("res://scenes/ui/unlock_notice.tscn").instantiate()
	unlock_notice.name = "UnlockPresentation"
	add_child(unlock_notice)
	coocking_player.stream_paused = true
	spawner.on_wave_started.connect(_apply_wave_environment)
	spawner.on_wave_started.connect(_on_wave_started_sfx)
	spawner.on_boss_wave_started.connect(_start_boss_wave)
	stage_mechanics.setup(spawner, environment_controller)
	_apply_wave_environment(1)
	_play_menu_music()

func _apply_wave_environment(wave: int) -> void:
	last_warning_second = -1
	wave_index_label.show()
	wave_timer_label.show()
	Progression.begin_wave(Global.player)
	var environment := environment_controller.apply_wave(wave)
	_configure_environment(environment)

func _configure_environment(environment: ArenaEnvironment) -> void:
	if not environment: return
	spawner.arena_environment = environment
	$Camera2D.configure_view(Rect2(environment.background_offset - environment.background_size * 0.5, environment.background_size), Vector2.ONE * environment.camera_zoom, true, environment_controller.overview_playable_bounds())
	if is_instance_valid(Global.player):
		Global.player.arena_environment = environment
		Global.player.global_position = environment.movement_bounds.get_center()
		player_health_bar.reset_damage_flash()
	if is_instance_valid(spawner.fueguito):
		spawner.fueguito.global_position = environment.clamp_position(spawner.fueguito.global_position)
	if coop and coop.active: coop.configure_players()

func _process(_delta: float) -> void:
	if _pending_yolk_value > 0 and not Global.game_paused:
		var pending := _pending_yolk_value
		_pending_yolk_value = 0
		spawn_yolk_at(_pending_yolk_position, pending)
	if stress_test and stress_test.active:
		wave_index_label.text = "STRESS TEST"
		wave_timer_label.text = ""
		return
	toggle_pause()
	var intermission_ui: bool = shop_panel.is_visible_in_tree() or upgrade_panel.is_visible_in_tree() or incognito_rewards.is_visible_in_tree()
	player_health_bar.visible = not intermission_ui and not pause_panel.visible and in_arena and is_instance_valid(Global.player) and not final_screen.visible and not defeat_in_progress and not (coop and coop.active)
	experience_bar.visible = player_health_bar.visible
	if coop and coop.active: coins_bag.hide()
	if Global.game_paused: return
	if boss_test_mode or boss_wave_active:
		wave_index_label.hide()
		wave_timer_label.hide()
		return
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
	var wave = spawner.current_wave_data
	var is_boss: bool = wave != null and wave.has_boss_encounter()
	music_player.play_track(music_player.choose_music(wave, environment_controller.current_stage, is_boss), "boss" if is_boss else "wave")

func _play_menu_music() -> void:
	music_player.play_track(music_player.menu_music, "menu")

func _start_boss_wave(settings: Resource) -> void:
	boss_wave_active = true
	boss_encounter.settings = settings
	boss_encounter.start(self)
	wave_active = true

func create_floating_text(unit: Node2D) -> FloatingText:
	var instance = CombatTexts.acquire() as FloatingText
	var random_pos := randf_range(0, TAU) * 35
	var spawn_pos := unit.global_position + Vector2.RIGHT.rotated(random_pos)
	instance.global_position = spawn_pos
	return instance

func start_new_wave() -> void:
	# Also discard text queued or created during the intermission before resuming animations.
	CombatTexts.clear()
	Weapon.begin_damage_wave()
	Global.game_paused = false
	Global.player.prepare_for_new_wave()
	spawner.wave_index += 1
	spawner.start_wave()
	wave_active = boss_wave_active or not spawner.wave_timer.is_stopped()
	coocking_player.stream_paused = false


func show_upgrades() -> void:
	if not incognito_rewards.pending.is_empty():
		incognito_rewards.open_next()
		return
	if _bonus_upgrades_before_wave and run_experience.pending_levels.is_empty():
		_bonus_upgrades_before_wave = false
		start_new_wave()
		return
	shop_panel.set_next_stage(environment_controller.prepare_wave(spawner.wave_index + 1), spawner.wave_index + 1)
	if run_experience.pending_levels.is_empty():
		shop_panel.set_pending_level_rewards(0)
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
	SoundManager.play_event("level_up")
	player.passive_items.on_level_gained()
	var previous_max: float = player.stats.health
	player.stats.apply_stat_change("health", 1.0)
	player.health_component.max_health = player.stats.health
	player.health_component.heal(maxf(0.0, player.stats.health - previous_max))

func _update_experience_bar() -> void:
	experience_bar.progress_bar.value = float(run_experience.experience) / run_experience.required_experience()
	experience_bar.health_value.text = "LV %d  %d / %d" % [run_experience.level, run_experience.experience, run_experience.required_experience()]
	shop_panel.set_pending_level_rewards(run_experience.pending_levels.size())


func spawn_coins(enemy: Enemy) -> void:
	var random_angle := randf_range(0, TAU)
	var offset := Vector2.RIGHT.rotated(random_angle) * 35
	var spawn_pos := enemy.global_position + offset
	var reward: int = enemy.roll_yolk_reward() if enemy.has_method("roll_yolk_reward") else enemy.stats.coin_drop
	if reward > 0 and is_instance_valid(Global.player):
		var chance: float = 0.02 * Global.player.passive_items.power("double_yolk")
		if coop and coop.active:
			chance=0.0
			for session in coop.sessions: chance+=0.02*session.actor.passive_items.power("double_yolk")/coop.sessions.size()
		reward += floori(chance) + (1 if randf() < fposmod(chance, 1.0) else 0)
	if enemy.has_method("roll_yolk_reward"):
		SoundManager.play_event("yolker_burst")
		spawn_yolk_burst(spawn_pos,reward,enemy.burst_min_distance,enemy.burst_max_distance,enemy.burst_flight_duration)
	else:
		spawn_yolk_at(spawn_pos, reward)

func spawn_yolk_burst(origin: Vector2, count: int, minimum_distance: float = 150.0, maximum_distance: float = 320.0, duration: float = 0.5) -> void:
	if count <= 0: return
	var geometry := spawner.arena_environment
	if geometry: origin=geometry.clamp_position(origin)
	var slots := _available_yolk_slots()
	if slots < count:
		slots += _compact_yolks_near(origin, count - slots)
	var pieces := mini(count, slots)
	var visual = null
	if pieces < count:
		visual = preload("res://scenes/coins/yolk_burst_visual.tscn").instantiate()
		visual.position = to_local(origin)
	for index in count:
		var angle := TAU*float(index)/count+randf_range(-0.1,0.1)
		var distance := randf_range(maxf(0,minimum_distance),maxf(minimum_distance,maximum_distance))
		var destination := origin+Vector2.from_angle(angle)*distance
		if geometry: destination=geometry.clamp_position(destination)
		var flight_time := maxf(0.1, duration * randf_range(0.85, 1.15))
		var height := randf_range(40, 85)
		if index >= pieces:
			var offset: Vector2 = to_local(destination) - visual.position
			visual.arcs.append(Vector4(offset.x, offset.y, flight_time, height))
			visual.lifetime = maxf(visual.lifetime, flight_time)
			continue
		var pickup := load("res://scenes/coins/burst_yolk.tscn").instantiate() as Coins
		pickup.value=1
		pickup.launch(origin, destination, flight_time, height)
		gold_list.append(pickup)
		call_deferred("add_child",pickup)
	if visual: call_deferred("add_child", visual)
	_merge_or_hold_yolks(origin, count - pieces)

func _compact_yolks_near(origin: Vector2, needed: int) -> int:
	var resting: Array[Coins] = []
	for pickup in gold_list:
		if pickup.is_inside_tree() and pickup.can_merge_on_ground(): resting.append(pickup)
	if resting.size() < 2: return 0
	resting.sort_custom(func(a: Coins, b: Coins) -> bool:
		return a.global_position.distance_squared_to(origin) < b.global_position.distance_squared_to(origin))
	var freed := mini(needed, resting.size() - 1)
	var merged_value := 0
	for index in range(1, freed + 1):
		var pickup := resting[index]
		merged_value += pickup.value
		gold_list.erase(pickup)
		pickup.hide()
		pickup.queue_free()
	resting[0].merge_yolks(merged_value)
	return freed

func spawn_yolk_at(spawn_pos: Vector2, value: int = 1) -> void:
	if value <= 0: return
	var pieces := mini(value, _available_yolk_slots())
	var geometry := spawner.arena_environment
	var angle_offset := randf_range(0.0, TAU) if pieces > 1 else 0.0
	for index in pieces:
		var point := spawn_pos
		if pieces > 1:
			point += Vector2.from_angle(angle_offset + TAU * float(index) / pieces) * 22.0
			if geometry: point = geometry.clamp_position(point)
		var pickup := Global.COINS_SCENE.instantiate() as Coins
		pickup.position = to_local(point)
		gold_list.append(pickup)
		call_deferred("add_child", pickup)
	_merge_or_hold_yolks(spawn_pos, value - pieces)

func _available_yolk_slots() -> int:
	for index in range(gold_list.size() - 1, -1, -1):
		var pickup := gold_list[index]
		if not is_instance_valid(pickup) or pickup.is_queued_for_deletion():
			gold_list.remove_at(index)
	return maxi(0, yolk_pickup_limit - gold_list.size())

func _merge_or_hold_yolks(point: Vector2, amount: int) -> void:
	if amount <= 0: return
	var closest: Coins
	var best_distance := INF
	for pickup in gold_list:
		if not pickup.can_merge_on_ground(): continue
		var position_world := pickup.global_position if pickup.is_inside_tree() else to_global(pickup.position)
		var distance := point.distance_squared_to(position_world)
		if distance < best_distance:
			closest = pickup
			best_distance = distance
	if closest:
		closest.merge_yolks(amount)
	else:
		# All pickups are moving. Retry as soon as one lands or frees a slot.
		if _pending_yolk_value == 0: _pending_yolk_position = point
		_pending_yolk_value += amount

func uncollected_yolk_value() -> int:
	var total := _pending_yolk_value
	for pickup in gold_list:
		if is_instance_valid(pickup) and not pickup.is_queued_for_deletion() and not pickup.awarded:
			total += maxi(0, pickup.value)
	return total

func clear_arena(bank_yolks: bool = false, jar_target: Control = null) -> void:
	boss_wave_active = false
	for visual in get_tree().get_nodes_in_group("yolk_burst_visuals"):
		visual.queue_free()
	if is_instance_valid(boss_encounter): boss_encounter.stop()
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
		if projectile is CanvasItem: projectile.hide()
		projectile.queue_free()
	# Replace (never accumulate) the old unused bonus with this wave's base drops.
	Global.yolk_reserve = uncollected_yolk_value() if bank_yolks else 0
	_pending_yolk_value = 0
	for coin in gold_list:
		if not is_instance_valid(coin) or coin.is_queued_for_deletion(): continue
		if bank_yolks:
			coin.call_deferred("fly_to_jar", jar_target if is_instance_valid(jar_target) else coins_bag.jar_icon)
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
	if unit.has_meta("last_boss_damage"): displayed_damage = float(unit.get_meta("last_boss_damage"))
	CombatTexts.queue_damage(unit, displayed_damage, color, hitbox.critical)

func _on_create_heal_text(unit: Node2D, value: float) -> void:
	var text := create_floating_text(unit)
	text.setup_text("+ %d" % ceili(value), hp_reg_color)

func toggle_pause() -> void:
	if coop and coop.active: return
	if is_instance_valid(shop_panel.golden_animation) and shop_panel.golden_animation.visible: return
	if is_instance_valid(shop_panel.coin_animation) and shop_panel.coin_animation.visible: return
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
			var panel: Control = null
			if shop_panel.visible:
				panel = shop_panel
			elif incognito_rewards.visible:
				panel = incognito_rewards
			elif upgrade_panel.visible:
				panel = upgrade_panel
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
	if coop and coop.active:
		if boss_wave_active: return
		coop.wave_completed()
		return
	if boss_test_mode: return
	if boss_wave_active: return
	if stress_test and stress_test.active: return
	SoundManager.play_sound(SoundManager.Sound.WAVE_COMPLETE)
	Weapon.finish_damage_wave()
	wave_active = false
	if not Global.player: return
	Progression.finish_wave(spawner.wave_index, Global.player)
	Global.game_paused = true
	coocking_player.stream_paused = true
	if spawner.wave_index >= spawner.last_wave_number(): _play_menu_music()
	else: music_player.play_track(music_player.shop_music, "shop")
	clear_arena(spawner.wave_index < spawner.last_wave_number())
	if spawner.wave_index < spawner.last_wave_number():
		shop_panel.set_next_stage(environment_controller.prepare_wave(spawner.wave_index + 1), spawner.wave_index + 1)
	wave_timer_label.text = str(0)
	await get_tree().create_timer(1).timeout
	Global.get_harvesting_coins()
	if is_instance_valid(Global.player): Global.player.passive_items.finish_wave()
	_continue_wave_rewards()

func _continue_wave_rewards() -> void:
	if not is_instance_valid(Global.player) or defeat_in_progress: return
	if incognito_rewards.open_next(): return
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
	shop_panel.set_pending_level_rewards(run_experience.pending_levels.size())
	show_upgrades()


func _on_shop_panel_on_shop_next_wave() -> void:
	shop_panel.hide()
	if not run_experience.pending_levels.is_empty():
		Global.game_paused = true
		_bonus_upgrades_before_wave = true
		show_upgrades()
		return
	Global.game_paused = false
	start_new_wave()

func _on_enemy_died(enemy: Enemy) -> void:
	if coop and coop.active:
		coop.enemy_died(enemy)
		return
	if not wave_active or not is_instance_valid(Global.player): return
	if enemy.get_meta("stage_hazard", false): return
	if enemy.has_meta("kill_reward_processed"): return
	enemy.set_meta("kill_reward_processed", true)
	var instance := Global.FRIED_SCENE.instantiate()
	add_child(instance)
	instance.global_position = enemy.global_position
	if not enemy.last_hit_grants_rewards: return
	if not stress_test.active: run_experience.add_experience(enemy.stats.experience_reward, Global.player.stats.experience_gain)
	Progression.record("kills", 1.0)
	if enemy.get_meta("incognito_reward",false):
		play_incognito_death(enemy)
		incognito_rewards.enqueue_drop(Global.player,spawner.wave_index)
	else:
		spawn_coins(enemy)

func play_incognito_death(enemy: Enemy) -> void:
	SoundManager.play_event("incognito_confetti")
	var confetti := Node2D.new()
	confetti.set_script(load("res://effects/incognito_confetti.gd"))
	confetti.position = to_local(enemy.global_position)
	confetti.origin = to_local(enemy.sprite.to_global(Vector2.ZERO)) - confetti.position
	add_child(confetti)

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

func _on_boss_test_selected() -> void:
	_on_level_selected(0, false, true)

func _on_level_selected(level: int, stress_mode: bool = false, boss_mode: bool = false) -> void:
	if coop_selection.enabled and not stress_mode and not boss_mode:
		coop_selection.start_difficulty(level)
		return
	# Ignore repeated confirmation and refuse an incomplete/invalid loadout.
	if in_arena: return
	boss_test_mode = boss_mode
	var starting_weapons := Global.get_starting_weapons()
	if starting_weapons.is_empty() and not Global.is_empty_preview_loadout(): return
	if stress_mode:
		if starting_weapons.is_empty(): return
		var selected: ItemWeapon = Global.main_weapon_selected if Global.is_valid_starting_weapon(Global.main_weapon_selected) else starting_weapons[0]
		starting_weapons.clear()
		for i in Global.MAX_EQUIPPED_WEAPONS: starting_weapons.append(selected)
		Progression.end_run()
	Global.yolk_reserve = 0
	_bonus_upgrades_before_wave = false
	run_experience.reset()
	Weapon.damage_records.clear()
	var player := Global.get_selected_player()
	if boss_mode:
		Progression.end_run()
		player.stats.apply_stat_change("health", boss_encounter.settings.test_health - player.stats.health)
		player.stats.apply_stat_change("hp_regen", boss_encounter.settings.test_regen - player.stats.hp_regen)
		player.stats.apply_stat_change("armor", boss_encounter.settings.test_armor - player.stats.armor)
		player.stats.apply_stat_change("block_chance", boss_encounter.settings.test_block_chance - player.stats.block_chance)
		player.stats.apply_stat_change("life_steal", boss_encounter.settings.test_life_steal - player.stats.life_steal)
	_reset_damage_feedback()
	level = spawner.normalize_difficulty(level)
	Global.level_selected = level
	environment_controller.reset_stage_selection()
	incognito_rewards.reset()
	spawner.reset_run(level)
	add_child(player)
	if test_tiny_egg_consumables and player.stats.name=="Tiny Egg" and not stress_mode and not boss_mode:
		player.passive_items.golden_yolks=2
		player.passive_items.breading_charges=2
	if boss_mode:
		player.stats.apply_stat_change("ranged_damage", boss_encounter.settings.test_ranged_damage - player.stats.ranged_damage)
		var damage_adjustment: float = boss_encounter.settings.test_damage_percent - player.stats.damage_percent
		if damage_adjustment>0:
			damage_adjustment /= maxf(0.0001,player.stats.get_stat_gain_multiplier("damage_percent"))
		player.stats.apply_stat_change("damage_percent", damage_adjustment)
	player.get_node("HealthBar").hide()
	player.health_component.on_health_changed.connect(player_health_bar._on_health_component_on_health_changed)
	player.health_component.on_health_changed.connect(damage_feedback.update_health)
	player.health_component.on_unit_hit.connect(player_health_bar.flash_damage)
	damage_feedback.update_health(player.health_component.current_health, player.health_component.max_health)
	player_health_bar._on_health_component_on_health_changed(player.health_component.current_health, player.health_component.max_health)
	if not stress_mode and not boss_mode: Progression.begin_run(player.stats.unlock_id, player.stats)
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
	if boss_mode:
		boss_encounter.start(self)
		music_player.play_track(music_player.choose_music(null, boss_encounter.settings.arena_stage, true), "boss")
	else: spawner.start_wave()
	wave_active = boss_mode or boss_wave_active or not spawner.wave_timer.is_stopped()
	Global.game_paused = false
	Global.coins = Global.STARTING_COINS
	in_arena = true
	level_panel.hide()
	if stress_mode:
		stress_test.start(self)
		wave_active = true

func _on_player_died() -> void:
	if is_instance_valid(boss_encounter): boss_encounter.stop()
	incognito_rewards.reset()
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
	for enemy in spawner.spawned_enemies + spawner.special_enemies + spawner.boss_enemies + spawner.reward_enemies:
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
	_play_menu_music()
	clear_arena()
	final_screen.set_defeat(true)
	final_label=final_screen.get_node("Defeat/Label")
	final_label.text = "YOU LOSE!"
	final_label.add_theme_color_override("font_color", UITheme.palette.hud_text)
	$GameUI.layer = 3
	final_screen.show()

func _reset_damage_feedback() -> void:
	defeat_in_progress = false
	damage_feedback.reset()
	stage_mechanics.process_mode = Node.PROCESS_MODE_INHERIT
	$GameUI.layer = 1
	final_screen.set_defeat(false)
	final_label=final_screen.get_node("Panel/FinalLabel")
	final_label.remove_theme_color_override("font_color")
	wave_index_label.show()
	wave_timer_label.show()
	coins_bag.show()
	if is_instance_valid(environment_controller.debug_stage_selector): environment_controller.debug_stage_selector.show()

func _on_final_button_pressed() -> void:
	_play_menu_music()
	boss_test_mode = false
	incognito_rewards.reset()
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
	if coop_selection.enabled:
		coop_selection.back_to_weapons()
		return
	level_panel.hide()
	weapon_selection_panel.show()


func _on_selection_panel_on_level_select_exited() -> void:
	if coop_selection.enabled: coop_selection.disable()
	selection_panel.hide()
	start_panel.show()


func _on_pause_panel_on_exit_pressed() -> void:
	if coop and coop.active:
		coop.stop()
		return
	boss_test_mode = false
	incognito_rewards.reset()
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
	_play_menu_music()
	pause_panel.hide()


func _on_pause_panel_on_return_pressed() -> void:
	if coop and coop.active:
		coop._set_paused(false)
		return
	set_wave_paused(false)


func _on_start_panel_on_exit_pressed() -> void:
	#podria guardar los datos aca tambien.. pero perderia un poco de sentido el boton de guardado
	get_tree().quit()



func rewind_upcoming_waves(amount: int) -> int:
	var previous_next := spawner.wave_index + 1
	spawner.wave_index = maxi(0, spawner.wave_index - maxi(0, amount))
	var next_wave := spawner.wave_index + 1
	shop_panel.set_next_stage(environment_controller.prepare_wave(next_wave), next_wave)
	shop_panel.set_pending_level_rewards(run_experience.pending_levels.size())
	return previous_next - next_wave

func _on_boss_test_defeated() -> void:
	if coop and coop.active:
		coop.wave_completed()
		return
	if defeat_in_progress or not is_instance_valid(Global.player): return
	if boss_wave_active:
		Progression.record_boss_victory(Global.level_selected, Global.player)
		boss_wave_active = false
		_on_spawner_on_wave_completed()
		return
	if not boss_test_mode: return
	_play_menu_music()
	wave_active = false
	Global.game_paused = true
	Weapon.finish_damage_wave()
	clear_arena()
	coocking_player.stream_paused = true
	final_label.text = "BOSS TEST COMPLETE!"
	final_screen.show()
	if is_instance_valid(Global.player): Global.player.queue_free()
	Global.player = null
