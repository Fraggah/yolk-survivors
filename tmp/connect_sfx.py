from pathlib import Path
root=Path('yolk-survivors')
def edit(path,old,new):
 p=root/path;s=p.read_text(encoding='utf-8-sig');assert old in s,(path,old[:60]);p.write_text(s.replace(old,new),encoding='utf-8')
fields={'Jugador y recompensas':['dash','enemy_death','yolker_burst','incognito_confetti','level_up'],'Estados':['burning_apply','electric_apply'],'Explosiones y ataques continuos':['explosion','default_continuous_attack'],'Moneda de chocolate':['coin_spin','coin_reveal','coin_win','coin_lose'],'Yema de oro y Rebozado':['golden_anticipation','golden_impact','golden_reveal','golden_success','golden_broken','breading_apply'],'Boss':['laser_warning','laser_fire','turret_spawn','boss_jump','boss_fall_warning','boss_impact'],'Fueguitos - todos los escenarios':['fueguito_spawn','fueguito_exit']}
block='\n'.join('@export_group("'+g+'")\n'+'\n'.join('@export var '+f+': AudioStream' for f in fs) for g,fs in fields.items())+'\n'
edit('autoload/sound_manager.gd','@export_group("Limites")',block+'\n@export_group("Limites")')
edit('autoload/sound_manager.gd','func play_weapon_attack(weapon: Weapon) -> void:', '''## New semantic events use the Inspector field name; empty slots are silent.
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

func play_weapon_attack(weapon: Weapon) -> void:''')
(root/'autoload/continuous_weapon_audio.gd').write_text('''extends AudioStreamPlayer
## Owned by the weapon: never survives selling, death or arena cleanup.
var active := false
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
func _process(_delta: float) -> void:
	if not active:
		stop()
		return
	stream_paused = Global.game_paused
	if not Global.game_paused and not playing: play()
''',encoding='utf-8')
edit('scenes/weapons/weapon.gd','@export var attack_sound: AudioStream','@export var attack_sound: AudioStream\n@export var impact_sound: AudioStream\n@export var continuous_sound: AudioStream')
edit('scenes/weapons/weapon.gd','\tcollision.shape = collision.shape.duplicate()','\tdamage_record["impact_sound"] = impact_sound\n\tdamage_record["impact_event"] = "weapon_impact:"+scene_file_path\n\tcollision.shape = collision.shape.duplicate()')
edit('scenes/components/hitbox_component.gd','\tdamage_dealt.emit(target, amount)','\tif not is_status_damage and target is Enemy:\n\t\tSoundManager.play_stream(weapon_damage_record.get("impact_sound"),weapon_damage_record.get("impact_event","weapon_impact"))\n\tdamage_dealt.emit(target, amount)')
edit('scenes/weapons/range/mayonnaise_stream.gd','\tif Global.game_paused: return','\tif Global.game_paused: return',) # managed loop pauses independently
edit('scenes/weapons/range/mayonnaise_stream.gd','\t\tSoundManager.play_weapon_attack(weapon)','\t\tSoundManager.play_weapon_attack(weapon)\n\t\tSoundManager.set_weapon_loop(weapon,true)')
edit('scenes/weapons/range/mayonnaise_stream.gd','func _stop_stream() -> void:\n','func _stop_stream() -> void:\n\tSoundManager.set_weapon_loop(weapon,false)\n')
edit('scenes/units/players/player.gd','func start_dash() -> void:\n','func start_dash() -> void:\n\tSoundManager.play_event("dash")\n')
edit('scenes/units/enemies/enemy.gd','func _on_health_component_on_unit_died() -> void:\n','func _on_health_component_on_unit_died() -> void:\n\tSoundManager.play_event("enemy_death")\n')
edit('scenes/arena/arena.gd','\tplayer.passive_items.on_level_gained()','\tSoundManager.play_event("level_up")\n\tplayer.passive_items.on_level_gained()')
edit('scenes/arena/arena.gd','\tif enemy.has_method("roll_yolk_reward"):\n','\tif enemy.has_method("roll_yolk_reward"):\n\t\tSoundManager.play_event("yolker_burst")\n')
edit('scenes/arena/arena.gd','\tif enemy.get_meta("incognito_reward",false):\n','\tif enemy.get_meta("incognito_reward",false):\n\t\tSoundManager.play_event("incognito_confetti")\n')
edit('effects/fire_status.gd','\tif not was_burning and burn.remaining > 0.0:\n','\tif not was_burning and burn.remaining > 0.0:\n\t\tSoundManager.play_event("burning_apply")\n')
edit('effects/status_controller.gd','\tcontroller.lightning_left = maxf(controller.lightning_left, status_duration)','\tif status_duration>0 and controller.lightning_left<=0: SoundManager.play_event("electric_apply")\n\tcontroller.lightning_left = maxf(controller.lightning_left, status_duration)')
edit('effects/spicy_explosion.gd','\tdetonated = true','\tdetonated = true\n\tSoundManager.play_event("explosion")')
edit('effects/scotch_mine_visual.gd','\tdetonated = true','\tdetonated = true\n\tSoundManager.play_event("explosion")')
edit('scenes/projectiles/ranged_area_effect.gd','\tis_pit = pit','\tis_pit = pit\n\tif not pit: SoundManager.play_event("explosion")')
edit('scenes/ui/shop/shop_panel.gd','\tmanager.breading_charges -= 1','\tmanager.breading_charges -= 1\n\tSoundManager.play_event("breading_apply")')
edit('scenes/units/enemies/fueguito.gd','\tsuper._ready()','\tsuper._ready()\n\tSoundManager.play_event("fueguito_spawn")')
edit('scenes/units/enemies/fueguito.gd','func destroy_enemy() -> void:', '''var exit_announced := false
func announce_exit() -> void:
	if exit_announced: return
	exit_announced = true
	SoundManager.play_event("fueguito_exit")

func _exit_tree() -> void:
	if is_instance_valid(get_tree().current_scene) and not get_tree().current_scene.is_queued_for_deletion(): announce_exit()

func destroy_enemy() -> void:''')
edit('scenes/arena/mechanics/pan_mechanic.gd','\tSoundManager.play_sound(SoundManager.Sound.FUEGUITO)\n','')
edit('scenes/arena/mechanics/pan_mechanic.gd','\t\tcreate_flare(enemy.global_position)','\t\tif enemy.has_method("announce_exit"): enemy.announce_exit()\n\t\tcreate_flare(enemy.global_position)')
edit('scenes/arena/mechanics/pan_mechanic.gd','\t\tif is_instance_valid(enemy):\n','\t\tif is_instance_valid(enemy):\n\t\t\tif enemy.has_method("announce_exit"): enemy.announce_exit()\n')
edit('scenes/bosses/hot_zones_fueguitos.gd','\t\tif is_instance_valid(enemy):\n','\t\tif is_instance_valid(enemy):\n\t\t\tif enemy.has_method("announce_exit"): enemy.announce_exit()\n')
edit('scenes/bosses/sausage_turret.gd','\trest_sprite_scale=$Sprite.scale','\tSoundManager.play_event("turret_spawn")\n\trest_sprite_scale=$Sprite.scale')
edit('scenes/bosses/boss_encounter.gd','func _begin_landing() -> void:\n','func _begin_landing() -> void:\n\tSoundManager.play_event("boss_fall_warning")\n')
edit('scenes/bosses/boss_encounter.gd','func _land() -> void:\n','func _land() -> void:\n\tSoundManager.play_event("boss_impact")\n')
edit('scenes/bosses/boss_encounter.gd','\tstate = State.TAKEOFF','\tstate = State.TAKEOFF\n\tSoundManager.play_event("boss_jump")')
edit('scenes/bosses/static_fire_lines.gd','\tstage = next_stage','\tstage = next_stage\n\tif stage in [0,1]: SoundManager.play_event("laser_warning" if stage==0 else "laser_fire")')
# The coin and golden reveals share visuals but have independent audio timelines.
edit('scenes/ui/shop/chocolate_coin_reveal.gd','var revealed := false','var revealed := false\nvar spin_announced := false')
edit('scenes/ui/shop/chocolate_coin_reveal.gd','\trevealed = false','\trevealed = false\n\tspin_announced = false')
edit('scenes/ui/shop/chocolate_coin_reveal.gd','\telapsed += delta','\telapsed += delta\n\tif elapsed>=0.7 and not spin_announced:\n\t\tspin_announced=true\n\t\tSoundManager.play_event("coin_spin")')
edit('scenes/ui/shop/chocolate_coin_reveal.gd','\t\t\trevealed = true','\t\t\trevealed = true\n\t\t\tSoundManager.play_event("coin_reveal")\n\t\t\tSoundManager.play_event("coin_win" if won else "coin_lose")')
edit('scenes/ui/shop/golden_yolk_reveal.gd','func play_upgrade(original: ItemBase, replacement: ItemBase, outcome: float) -> void:', 'var impact_announced := false\n\nfunc play_upgrade(original: ItemBase, replacement: ItemBase, outcome: float) -> void:')
edit('scenes/ui/shop/golden_yolk_reveal.gd','\tsource_item = original','\tSoundManager.play_event("golden_anticipation")\n\timpact_announced=false\n\tsource_item = original')
edit('scenes/ui/shop/golden_yolk_reveal.gd','\telapsed += delta','\telapsed += delta\n\tif elapsed>=1.12 and not impact_announced:\n\t\timpact_announced=true\n\t\tSoundManager.play_event("golden_impact")')
edit('scenes/ui/shop/golden_yolk_reveal.gd','\tvar success := improved_item != null','\tvar success := improved_item != null\n\tSoundManager.play_event("golden_reveal")\n\tSoundManager.play_event("golden_success" if success else "golden_broken")')
print('Audio event hooks written')
