from pathlib import Path
r=Path('yolk-survivors')
def edit(p,a,b):
 p=r/p;s=p.read_text(encoding='utf-8-sig');assert a in s,p;p.write_text(s.replace(a,b),encoding='utf-8')
edit(Path('scenes/units/players/passive_items.gd'),'var extra_shell_used := false','var extra_shell_used := false\nvar kills := 0\nconst PRIMARY = preload("res://scenes/ui/stats/stats_container.gd").PRIMARY')
edit(Path('scenes/units/players/passive_items.gd'),'\t\t"reduction":','\t\t"grocery": redistribute(50, 40)\n\t\t"reduction":')
edit(Path('scenes/units/players/passive_items.gd'),'\textra_shell_used = false\n\t_clear_slip()','\textra_shell_used = false\n\t_clear_slip()')
p=r/'scenes/units/players/passive_items.gd'
s=p.read_text(encoding='utf-8')+'''
func redistribute(gain: int, loss: int) -> void:
 var chosen: String = PRIMARY.pick_random()
 player.stats.apply_stat_change(chosen, gain)
 var others: Array = PRIMARY.filter(func(stat): return stat != chosen)
 for point in loss:
  player.stats.apply_stat_change(others.pick_random(), -1.0)

func finish_wave() -> void:
 for copy in count("lunchbox"): redistribute(5, 3)

func enemy_killed(enemy: Enemy) -> void:
 if not enemy.last_hit_grants_rewards: return
 kills += 1
 if kills % 100 != 0 or count("printer") == 0: return
 var candidates: Array = []
 for item in preload("res://resources/items/passives/catalogue.gd").items():
  if item.item_tier == Global.UpgradeTier.COMMON and count(item.effect_key) > 0: candidates.append(item)
 if candidates.is_empty(): return
 for copy in count("printer"):
  var item: ItemPassive = candidates.pick_random()
  var arena = get_tree().current_scene
  if arena is Arena: arena.shop_panel._on_item_purchased(item)
'''
p.write_text(s,encoding='utf-8')
edit(Path('scenes/units/players/player.gd'),'\tadd_child(passive_items)','\tadd_child(passive_items)\n\tGlobal.on_enemy_died.connect(passive_items.enemy_killed)')
edit(Path('scenes/arena/arena.gd'),'\tGlobal.get_harvesting_coins()','\tGlobal.get_harvesting_coins()\n\tif is_instance_valid(Global.player): Global.player.passive_items.finish_wave()')
# Stage consumables overwrite the prepared next-wave choice and refresh preview.
edit(Path('scenes/units/players/passive_items.gd'),'\t\t"grocery": redistribute(50, 40)','\t\t"grocery": redistribute(50, 40)\n\t\t"stage_pan", "stage_pot", "stage_oven", "stage_wok":\n\t\t\tvar arena = get_tree().current_scene\n\t\t\tif arena is Arena:\n\t\t\t\tvar stage_ids := {"stage_pan":"nonstick_pan", "stage_pot":"cooking_pot", "stage_oven":"oven_tray", "stage_wok":"deep_wok"}\n\t\t\t\tvar stage = load("res://resources/environments/stages/%s.tres" % stage_ids[key])\n\t\t\t\tvar wave: int = arena.spawner.wave_index + 1\n\t\t\t\tarena.environment_controller.selected_stages[wave] = stage\n\t\t\t\tarena.shop_panel.set_next_stage(stage, wave)')
for i,key in {64:'stage_pan',65:'stage_pot',66:'stage_oven',67:'stage_wok',80:'lunchbox',87:'printer',92:'grocery'}.items():
 p=r/f'resources/items/passives/catalogue/item_{i:03d}.tres';s=p.read_text(encoding='utf-8');s=s.replace('effect_key = ""',f'effect_key = "{key}"').replace('ready_for_shop = false','ready_for_shop = true');s=__import__('re').sub(r'pending_reason = .*','pending_reason = ""',s);p.write_text(s,encoding='utf-8')

