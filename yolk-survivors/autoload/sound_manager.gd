extends Node

@export var stream_players: Array[AudioStreamPlayer]

@export_group("Menus e interfaz")
@export var ui_hover: AudioStream
@export var ui_accept: AudioStream
@export var ui_play: AudioStream
@export var ui_back: AudioStream
@export var selection_hover: AudioStream
@export var selection_accept: AudioStream
@export var selection_invalid: AudioStream
@export_group("Oleadas")
@export var wave_start: AudioStream
@export var wave_final_seconds: AudioStream
@export var wave_complete: AudioStream
@export var run_defeat: AudioStream
@export_group("Combate")
@export var hit_al_enemigo: AudioStream
@export var critico_al_enemigo: AudioStream
@export var hit_al_player: AudioStream
@export var hit_bloqueado_al_player: AudioStream
@export_group("Tienda")
@export var shop_reroll: AudioStream
@export var shop_lock: AudioStream
@export var shop_unlock: AudioStream
@export var shop_buy: AudioStream
@export var shop_no_money: AudioStream
@export var shop_sell: AudioStream
@export var shop_combine: AudioStream
@export_group("Desbloqueos")
@export var unlock_reveal: AudioStream
@export var unlock_sequence_start: AudioStream
@export var unlock_sequence_end: AudioStream
@export_group("Recoleccion")
@export var yolk_pickup: AudioStream
@export_group("Escenarios")
@export var fueguito: AudioStream
@export var bubble_explosion: AudioStream
@export var spatula_impact: AudioStream
@export_group("Armas - impactos especiales")
@export var plate_break: AudioStream
@export_group("Armas por defecto")
@export var default_ranged_attack: AudioStream
@export var default_melee_attack: AudioStream
@export_group("Jugador y recompensas")
@export var dash: AudioStream
@export var enemy_death: AudioStream
@export var yolker_burst: AudioStream
@export var incognito_confetti: AudioStream
@export var level_up: AudioStream
@export_group("Estados")
@export var burning_apply: AudioStream
@export var electric_apply: AudioStream
@export_group("Explosiones y ataques continuos")
@export var explosion: AudioStream
@export var default_continuous_attack: AudioStream
@export_group("Moneda de chocolate")
@export var coin_spin: AudioStream
@export var coin_reveal: AudioStream
@export var coin_win: AudioStream
@export var coin_lose: AudioStream
@export_group("Yema de oro y Rebozado")
@export var golden_anticipation: AudioStream
@export var golden_impact: AudioStream
@export var golden_reveal: AudioStream
@export var golden_success: AudioStream
@export var golden_broken: AudioStream
@export var breading_apply: AudioStream
@export_group("Boss")
@export var laser_warning: AudioStream
@export var laser_fire: AudioStream
@export var turret_spawn: AudioStream
@export var boss_jump: AudioStream
@export var boss_fall_warning: AudioStream
@export var boss_impact: AudioStream
@export_group("Fueguitos - todos los escenarios")
@export var fueguito_spawn: AudioStream
@export var fueguito_exit: AudioStream

@export_group("Limites")
@export_range(1, 16) var maximum_event_voices := 4
@export_range(-40.0, 6.0) var sfx_gain_db := 0.0
@export_group("Volumen por evento (dB)")
## Per-event trims, added to the global SFX gain without altering source files.
@export var event_gain_db: Dictionary = {}
var event_times: Dictionary = {}

var sfx_volume : float = 1.0
var music_volume : float = 1.0

var sfx_bus := AudioServer.get_bus_index("SFX")
var music_bus := AudioServer.get_bus_index("Music")

enum Sound {
	HIT_AL_ENEMIGO,
	FIRE,
	UI_CLICK,
	PUNCH,
	UI_HOVER,
	UI_ACCEPT,
	UI_PLAY,
	UI_BACK,
	SELECTION_HOVER,
	SELECTION_ACCEPT,
	SELECTION_INVALID,
	WAVE_START,
	WAVE_FINAL_SECONDS,
	WAVE_COMPLETE,
	RUN_DEFEAT,
	HIT_AL_PLAYER,
	HIT_BLOQUEADO_AL_PLAYER,
	CRITICO_AL_ENEMIGO,
	SHOP_REROLL,
	SHOP_LOCK,
	SHOP_UNLOCK,
	SHOP_BUY,
	SHOP_NO_MONEY,
	SHOP_SELL,
	SHOP_COMBINE,
	UNLOCK_REVEAL,
	UNLOCK_SEQUENCE_START,
	UNLOCK_SEQUENCE_END,
	YOLK_PICKUP,
	FUEGUITO,
	BUBBLE_EXPLOSION,
	SPATULA_IMPACT
}

var sound_event_keys := PackedStringArray()

func _ready() -> void:
	for key in Sound.keys(): sound_event_keys.append(key.to_lower())
	sound_event_keys[Sound.UI_CLICK] = "ui_accept"
	sound_event_keys[Sound.FIRE] = "default_ranged_attack"
	sound_event_keys[Sound.PUNCH] = "default_melee_attack"
	# Menu clicks must remain audible while the gameplay tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	sfx_bus = AudioServer.get_bus_index("SFX")
	music_bus = AudioServer.get_bus_index("Music")
	for player in stream_players:
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		player.bus = &"SFX"
	get_tree().node_added.connect(_node_added)
	call_deferred("_scan_buttons",get_tree().root)

func set_sfx_volume(value: float) -> void:
	sfx_volume = value
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))

func set_music_volume(value: float) -> void:
	music_volume = value
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))

func play_sound(type: int) -> void:
	var key: String = sound_event_keys[type]
	play_stream(get(key) as AudioStream, key)

func play_stream(audio: AudioStream, event: String = "weapon_attack") -> void:
	if not audio: return
	var now := Time.get_ticks_msec()
	if now - int(event_times.get(event,-1000)) < 40: return
	var voices := 0
	for player in stream_players:
		if player.playing and player.get_meta("sfx_event","") == event: voices += 1
	if voices >= maximum_event_voices: return
	var player := get_free_stream_player()
	if not player: return
	event_times[event] = now
	player.set_meta("sfx_event",event)
	player.stream_paused = false
	player.volume_db = sfx_gain_db + float(event_gain_db.get(event,0.0))
	player.bus = &"SFX"
	player.stream = audio
	player.pitch_scale = 1.0 if event.begins_with("ui_") or event.begins_with("selection_") else randf_range(0.95,1.05)
	player.play()

## New semantic events use the Inspector field name; empty slots are silent.
func play_event(event: String) -> void:
	var audio := get(event) as AudioStream
	if event == "fueguito_spawn" and not audio: audio = fueguito
	play_stream(audio,event)

func set_weapon_loop(weapon: Weapon, active: bool) -> void:
	var player := weapon.get_node_or_null("ContinuousAudio") as AudioStreamPlayer
	if not active:
		if player: player.active = false; player.stop()
		return
	var audio: AudioStream = weapon.continuous_sound if weapon.continuous_sound else default_continuous_attack
	if not audio: return
	if not player:
		player = AudioStreamPlayer.new()
		player.set_script(preload("res://autoload/continuous_weapon_audio.gd"))
		player.name = "ContinuousAudio"
		player.bus = &"SFX"
		weapon.add_child(player)
	player.stream = audio
	player.volume_db = sfx_gain_db
	player.active = true

func play_weapon_attack(weapon: Weapon) -> void:
	var audio: AudioStream = weapon.attack_sound
	if not audio: audio = default_melee_attack if weapon.data.has_tag(ItemWeapon.Tag.MELEE) else default_ranged_attack
	play_stream(audio,"weapon:" + weapon.scene_file_path)

func _node_added(node: Node) -> void:
	if node is Button: call_deferred("_hook_button_id",node.get_instance_id())

func _hook_button_id(id: int) -> void:
	var button=instance_from_id(id)
	if is_instance_valid(button) and button is Button: _hook_button(button)

func _hook_button(button: Button) -> void:
	if not is_instance_valid(button) or button.has_meta("sfx_hooked"): return
	button.set_meta("sfx_hooked",true)
	if button is SelectionCard:
		button.focus_entered.connect(func():
			if MenuInput.gamepad_active: play_sound(Sound.SELECTION_HOVER))
		return
	button.mouse_entered.connect(func():
		if not button.disabled: play_sound(Sound.UI_HOVER))
	button.focus_entered.connect(func():
		if MenuInput.gamepad_active and not button.disabled: play_sound(Sound.UI_HOVER))
	if button.get_meta("sfx_manual",false): return
	if button.text.to_upper() == "BACK":
		button.pressed.connect(play_sound.bind(Sound.UI_BACK))
		return
	var ancestor := button.get_parent()
	while ancestor:
		if ancestor is ShopCard or ancestor is ShopPanel or ancestor is UpgradeCard or ancestor is UpgradePanel: return
		ancestor = ancestor.get_parent()
	if button is ItemCard: return
	var name_lower := String(button.name).to_lower()
	var event := Sound.UI_PLAY if name_lower == "playbutton" else Sound.UI_BACK if "back" in name_lower or "return" in name_lower or "exit" in name_lower else Sound.UI_ACCEPT
	button.pressed.connect(play_sound.bind(event))

func get_free_stream_player() -> AudioStreamPlayer:
	for stream: AudioStreamPlayer in stream_players:
		if not stream.playing:
			return stream
	
	return null

func _scan_buttons(node: Node) -> void:
	if node is Button: _hook_button(node)
	for child in node.get_children(): _scan_buttons(child)
