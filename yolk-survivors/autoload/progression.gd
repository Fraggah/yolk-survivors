extends Node

signal progress_changed
signal unlock_earned(reward: String)

const SAVE_PATH := "user://progress.cfg"
const INITIAL_CHARACTERS := ["well_rounded"]
const INITIAL_WEAPONS := ["spatula", "b_knife"]
const ACHIEVEMENT_IDS := ["demo_tiny_egg", "demo_hardboiled", "mutant", "scrapper", "demo_glass_egg", "carving_fork", "frying_pan", "bloody", "toothpick_shotgun", "grater", "spark_lighter", "bell_pepper", "demo_mitten", "pressure_cooker", "fusilli_launcher"]

var save_path := SAVE_PATH
var achievements: Array[Resource] = []
var completed: Array[String] = []
var counters: Dictionary = {}
var unlocked_characters: Array[String] = []
var unlocked_weapons: Array[String] = []
var run_active := false
var current_character := ""
var wave_damaged := false
var wave_open := false
var dirty := false
var save_delay := 0.0
var testing_unlock_override := -1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for id in ACHIEVEMENT_IDS:
		achievements.append(load("res://resources/unlocks/%s.tres" % id))
	load_progress()

func _process(delta: float) -> void:
	if not dirty: return
	save_delay -= delta
	if save_delay <= 0.0: save_progress()

func _exit_tree() -> void:
	if dirty: save_progress()

func load_progress() -> void:
	completed.clear()
	counters.clear()
	var config := ConfigFile.new()
	testing_unlock_override = -1
	if config.load(save_path) == OK:
		testing_unlock_override = int(config.get_value("testing", "unlock_override", -1))
		Global.level_reached = clampi(int(config.get_value("progress", "difficulty", 0)), 0, 5)
		var saved = config.get_value("progress", "completed", [])
		if saved is Array or saved is PackedStringArray:
			for id in saved:
				if id is String and not completed.has(id): completed.append(id)
		var saved_counters = config.get_value("progress", "counters", {})
		if saved_counters is Dictionary:
			for key in saved_counters:
				var value = saved_counters[key]
				if key is String and (value is int or value is float) and is_finite(float(value)):
					counters[key] = maxf(0.0, float(value))
	_rebuild_unlocks()
	dirty = false
	progress_changed.emit()

func save_progress() -> bool:
	var config := ConfigFile.new()
	config.set_value("progress", "version", 1)
	config.set_value("progress", "completed", completed)
	config.set_value("progress", "counters", counters)
	config.set_value("progress", "difficulty", Global.level_reached)
	config.set_value("testing", "unlock_override", testing_unlock_override)
	var error := config.save(save_path + ".tmp")
	if error == OK: error = DirAccess.rename_absolute(save_path + ".tmp", save_path)
	if error != OK:
		push_warning("Could not save unlock progress: %s" % error)
		save_delay = 5.0
		return false
	dirty = false
	return true

func _rebuild_unlocks() -> void:
	unlocked_characters.assign(INITIAL_CHARACTERS)
	unlocked_weapons.assign(INITIAL_WEAPONS)
	for achievement in achievements:
		if not completed.has(achievement.id): continue
		for id in achievement.reward_characters:
			if not unlocked_characters.has(id): unlocked_characters.append(id)
		for id in achievement.reward_weapons:
			if not unlocked_weapons.has(id): unlocked_weapons.append(id)

func is_character_unlocked(stats: Resource) -> bool:
	return stats != null and (_testing_unlocks_enabled() or unlocked_characters.has(stats.unlock_id))

func is_weapon_unlocked(weapon: Resource) -> bool:
	return weapon != null and (_testing_unlocks_enabled() or unlocked_weapons.has(weapon.unlock_id))

func is_passive_unlocked(item: ItemPassive) -> bool:
	return item != null and (_testing_unlocks_enabled() or item.unlocked_by_default)

func _testing_unlocks_enabled() -> bool:
	# Temporary access for playtesting; does not mark achievements as completed.
	if testing_unlock_override >= 0: return testing_unlock_override == 1
	return bool(ProjectSettings.get_setting("yolk/testing/unlock_characters_and_weapons", false))

func debug_reset_progress() -> bool:
	if not OS.is_debug_build() or run_active: return false
	completed.clear()
	counters.clear()
	testing_unlock_override = 0
	Global.level_reached = 0
	Global.level_selected = 0
	return _finish_debug_progress_change()

func debug_unlock_all() -> bool:
	if not OS.is_debug_build() or run_active: return false
	completed.assign(ACHIEVEMENT_IDS)
	testing_unlock_override = 1
	Global.level_reached = 5
	return _finish_debug_progress_change()

func _finish_debug_progress_change() -> bool:
	wave_open = false
	wave_damaged = false
	current_character = ""
	_rebuild_unlocks()
	dirty = true
	var saved := save_progress()
	progress_changed.emit()
	return saved

func requirement_for(id: String, character: bool) -> String:
	for achievement in achievements:
		var rewards: PackedStringArray = achievement.reward_characters if character else achievement.reward_weapons
		if not rewards.has(id): continue
		var progress := minf(float(counters.get(achievement.metric, 0.0)), achievement.goal)
		return "%s\n\nProgress: %s / %s" % [achievement.requirement, _number(progress), _number(achievement.goal)]
	return "Available in a future update."

func begin_run(character: String, stats: Resource) -> void:
	run_active = true
	current_character = character
	wave_damaged = false
	wave_open = false
	check_stats(stats)

func begin_wave(player: Player = null) -> void:
	if run_active:
		wave_damaged = false
		wave_open = true
		if is_instance_valid(player):
			for weapon in player.current_weapons:
				if weapon.data.has_tag(ItemWeapon.Tag.MELEE):
					_record_peak("wave_start_melee_tier", weapon.data.item_tier + 1)

func record_damage() -> void:
	if run_active: wave_damaged = true

func finish_wave(wave: int = 0, player: Player = null) -> void:
	if not run_active or not wave_open: return
	wave_open = false
	if not wave_damaged: record("flawless_waves", 1.0)
	if not wave_damaged: _record_peak("flawless_wave", wave)
	_record_peak("wave", wave)
	if is_instance_valid(player):
		_record_peak("wave_end_speed", player.stats.speed)
		for weapon in player.current_weapons:
			if not weapon.data.unlock_id.is_empty():
				_record_peak("wave_with:" + weapon.data.unlock_id, wave)
	save_progress()

func record_boss_victory(difficulty: int, player: Player) -> void:
	if not run_active or not is_instance_valid(player): return
	record("boss:%d" % difficulty, 1.0)
	var health_percent := player.health_component.current_health / maxf(1.0, player.health_component.max_health) * 100.0
	_record_peak("boss_health:%d:%s" % [difficulty, current_character], health_percent)

func _record_peak(metric: String, value: float) -> void:
	if value <= float(counters.get(metric, 0.0)): return
	counters[metric] = value
	_changed()

func end_run(won: bool = false) -> void:
	if not run_active: return
	if won: record("win:" + current_character, 1.0)
	run_active = false
	wave_open = false
	current_character = ""
	if dirty: save_progress()

func record(metric: String, amount: float) -> void:
	if not run_active or amount <= 0.0: return
	counters[metric] = float(counters.get(metric, 0.0)) + amount
	_changed()

func check_stats(stats: Resource) -> void:
	if not run_active or stats == null: return
	var changed := false
	for achievement in achievements:
		if not achievement.metric.begins_with("stat:"): continue
		var value := float(stats.get(achievement.metric.trim_prefix("stat:")))
		if value > float(counters.get(achievement.metric, 0.0)):
			counters[achievement.metric] = value
			changed = true
	if changed: _changed()

func _changed() -> void:
	dirty = true
	save_delay = 0.75
	var rewards: Array[String] = []
	for achievement in achievements:
		if completed.has(achievement.id): continue
		if float(counters.get(achievement.metric, 0.0)) >= achievement.goal:
			completed.append(achievement.id)
			rewards.append(achievement.reward_label)
	if not rewards.is_empty():
		_rebuild_unlocks()
		save_progress()
		for reward in rewards: unlock_earned.emit(reward)
	progress_changed.emit()

static func _number(value: float) -> String:
	return ("%.2f" % value).trim_suffix("0").trim_suffix("0").trim_suffix(".")
