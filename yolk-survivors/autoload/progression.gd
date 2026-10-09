extends Node

signal progress_changed
signal unlock_earned(reward: String)

const SAVE_PATH := "user://progress.cfg"
const INITIAL_CHARACTERS := ["well_rounded"]
const INITIAL_WEAPONS := ["spatula", "b_knife", "knifer", "hydrant"]
const ACHIEVEMENT_IDS := ["tiny_egg", "hardboiled", "mutant", "vampire", "gambler", "scrapper", "glass_egg", "hoarder", "berserker", "wood_mace", "blender", "mitten", "corpse_l", "smasher"]

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
	if config.load(save_path) == OK:
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
	return stats != null and (stats.unlock_id.is_empty() or unlocked_characters.has(stats.unlock_id))

func is_weapon_unlocked(weapon: Resource) -> bool:
	return weapon != null and (weapon.unlock_id.is_empty() or unlocked_weapons.has(weapon.unlock_id))

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

func begin_wave() -> void:
	if run_active:
		wave_damaged = false
		wave_open = true

func record_damage() -> void:
	if run_active: wave_damaged = true

func finish_wave() -> void:
	if not run_active or not wave_open: return
	wave_open = false
	if not wave_damaged: record("flawless_waves", 1.0)
	save_progress()

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
