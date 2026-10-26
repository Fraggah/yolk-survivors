from pathlib import Path
r=Path('yolk-survivors')
def edit(p,a,b):
 p=r/p;s=p.read_text(encoding='utf-8-sig');assert a in s,p;p.write_text(s.replace(a,b),encoding='utf-8')
edit(Path('resources/unit_stats.gd'),'var infernal_reduction := false','var energy_shakes := 0\nvar infernal_reduction := false')
edit(Path('resources/unit_stats.gd'),'\tif infernal_reduction:','\tif energy_shakes > 0:\n\t\tvar base_speed: float = _base_stat_values.get("speed", speed)\n\t\tattack_speed += maxf(0.0, (speed / maxf(1.0, base_speed) - 1.0) * 100.0) * 2.0 * energy_shakes\n\tif infernal_reduction:')
edit(Path('scenes/units/players/passive_items.gd'),'var kills := 0','var kills := 0\nvar force_horde := false')
edit(Path('scenes/units/players/passive_items.gd'),'\t\t"refrito":','\t\t"energy_shake":\n\t\t\tplayer.stats.energy_shakes += 1\n\t\t\tplayer.stats.apply_stat_change("speed", 0)\n\t\t"horde": force_horde = true\n\t\t"refrito":')
edit(Path('scenes/arena/spawner.gd'),'\tcurrent_wave_data = find_wave_data()','\tcurrent_wave_data = find_wave_data()\n\tif is_instance_valid(Global.player) and Global.player.passive_items.force_horde:\n\t\tfor wave in waves_data:\n\t\t\tif wave and wave.wave_type == WaveData.WaveType.HORDE:\n\t\t\t\tcurrent_wave_data = wave.duplicate()\n\t\t\t\tcurrent_wave_data.number = wave_index\n\t\t\t\tbreak\n\t\tGlobal.player.passive_items.force_horde = false')
for i,key in {83:'horde',90:'energy_shake'}.items():
 p=r/f'resources/items/passives/catalogue/item_{i:03d}.tres';s=p.read_text(encoding='utf-8').replace('effect_key = ""',f'effect_key = "{key}"').replace('ready_for_shop = false','ready_for_shop = true');p.write_text(s,encoding='utf-8')
# Invalid pending item cannot be bought through a stale or external offer.
edit(Path('scenes/ui/shop/shop_panel.gd'),'\tif not item or not is_instance_valid(Global.player): return false','\tif not item or not is_instance_valid(Global.player): return false\n\tif item is ItemPassive and item.get_script().resource_path == "res://resources/items/passives/catalogue_passive.gd" and not item.available_for(Global.player): return false')
# Test current catalogue.
edit(Path('tests/verify_catalogue_passives.gd'),'catalogue.size() == 23','catalogue.size() == 25')
# Resource ownership must not share the character passive array with roster resources.
edit(Path('resources/unit_stats.gd'),'\tvar preview := duplicate() as UnitStats','\tvar preview := duplicate() as UnitStats\n\tpreview.character_passives = character_passives.duplicate()\n\tpreview.energy_shakes = energy_shakes\n\tpreview.infernal_reduction = infernal_reduction')

