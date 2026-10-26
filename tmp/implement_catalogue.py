from pathlib import Path
import re,json,shutil
root=Path('yolk-survivors')
def edit(path,old,new):
 p=root/path;s=p.read_text(encoding='utf-8');assert old in s,(path,old);p.write_text(s.replace(old,new),encoding='utf-8')
edit(Path('scenes/units/players/player.gd'),'var move_dir: Vector2','var passive_items: Node\n\nfunc get_weapon_limit() -> int:\n\treturn mini(9, Global.MAX_EQUIPPED_WEAPONS + (passive_items.count("extra_slot") if is_instance_valid(passive_items) else 0))\n\nvar move_dir: Vector2')
edit(Path('scenes/units/players/player.gd'),'\tsuper._ready()','\tsuper._ready()\n\tpassive_items = preload("res://scenes/units/players/passive_items.gd").new()\n\tpassive_items.player = self\n\tadd_child(passive_items)')
edit(Path('scenes/units/players/player.gd'),'current_weapons.size() >= Global.MAX_EQUIPPED_WEAPONS','current_weapons.size() >= get_weapon_limit()')
edit(Path('scenes/units/players/player.gd'),'func prepare_for_new_wave() -> void:','func prepare_for_new_wave() -> void:\n\tpassive_items.begin_wave()')
edit(Path('scenes/units/players/player.gd'),'\tdash_cooldown_timer.start()','\tdash_cooldown_timer.start(maxf(0.05, dash_cooldown - passive_items.count("guarana")))')
edit(Path('scenes/units/players/player.gd'),'\tstats.set_final_modifiers(combined)','\tvar wasabi := 1.0 + 0.1 * (passive_items.count("wasabi") if is_instance_valid(passive_items) else 0)\n\tfor key in combined: combined[key] *= wasabi\n\tstats.set_final_modifiers(combined)')
edit(Path('resources/unit_stats.gd'),'var final_stat_modifiers: Dictionary = {}','var infernal_reduction := false\nvar final_stat_modifiers: Dictionary = {}')
edit(Path('resources/unit_stats.gd'),'\t_apply_final_modifiers()','\tif infernal_reduction:\n\t\teffects += melee_damage + ranged_damage\n\t\tmelee_damage = 0.0\n\t\tranged_damage = 0.0\n\t_apply_final_modifiers()')
edit(Path('scenes/components/health_component.gd'),'\tcurrent_health -= value','\tif owner is Player and is_instance_valid(owner.passive_items) and value >= current_health and owner.passive_items.prevent_lethal():\n\t\tcurrent_health = minf(1.0, max_health)\n\t\ton_health_changed.emit(current_health, max_health)\n\t\treturn\n\tcurrent_health -= value')
edit(Path('scenes/units/unit.gd'),'\t\tGlobal.on_create_block_text.emit(self)','\t\tGlobal.on_create_block_text.emit(self)\n\t\tif self is Player and is_instance_valid(passive_items): passive_items.on_block()')
edit(Path('scenes/units/unit.gd'),'\tif blocked: incoming_damage *=','\tif self is Enemy and hitbox.source is Player:\n\t\tvar items = hitbox.source.passive_items\n\t\tif hitbox.critical and has_status(State.SHOKED): incoming_damage *= 1.0 + 0.5 * items.count("electric_stove")\n\t\tif hitbox.launch_on_hit and items.count("table_slam") > 0: incoming_damage *= 1.0 + hitbox.source.stats.block_effectiveness / 100.0 * items.count("table_slam")\n\t\tif hitbox.critical and has_status(State.SLOW) and items.count("paste") > 0: immobilize_for(1.0)\n\tif blocked: incoming_damage *=')
edit(Path('scenes/arena/arena.gd'),'spawn_yolk_at(spawn_pos, enemy.stats.coin_drop)','var reward := enemy.stats.coin_drop\n\tif reward > 0 and is_instance_valid(Global.player):\n\t\tvar chance: float = 0.02 * Global.player.passive_items.count("double_yolk")\n\t\treward += floori(chance) + (1 if randf() < fposmod(chance, 1.0) else 0)\n\tspawn_yolk_at(spawn_pos, reward)')
edit(Path('scenes/ui/shop/shop_panel.gd'),'func _ready() -> void:','func _ready() -> void:\n\tshop_items = shop_items.filter(func(item): return not item is ItemPassive)\n\tshop_items.append_array(preload("res://resources/items/passives/catalogue.gd").items())')
edit(Path('scenes/ui/shop/shop_panel.gd'),'\t\tif item == null: continue','\t\tif item == null: continue\n\t\tif item is ItemPassive and item.get_script() == preload("res://resources/items/passives/catalogue_passive.gd") and is_instance_valid(Global.player) and not item.available_for(Global.player): continue')
edit(Path('scenes/ui/shop/shop_panel.gd'),'Global.equipped_weapons.size() >= Global.MAX_EQUIPPED_WEAPONS','Global.equipped_weapons.size() >= Global.player.get_weapon_limit()')
edit(Path('scenes/ui/shop/shop_panel.gd'),'return ItemBase.ECONOMY_RULES.reroll_price(shop_wave, reroll_count)','var discount := 0.1 * Global.player.passive_items.count("butcher") if is_instance_valid(Global.player) else 0.0\n\treturn maxi(0, floori(ItemBase.ECONOMY_RULES.reroll_price(shop_wave, reroll_count) * maxf(0.0, 1.0-discount)))')
p=root/'effects/status_controller.gd';s=p.read_text(encoding='utf-8')
s=s.replace('\tif effect.kind == StatusEffect.Kind.FIRE:\n\t\tvar source_id', '\tif target is Player and is_instance_valid(target.passive_items):\n\t\ttarget.passive_items.on_status_applied(effect.kind, target.has_status(Unit.State.BURNING if effect.kind == StatusEffect.Kind.FIRE else Unit.State.SHOKED))\n\tif effect.kind == StatusEffect.Kind.FIRE:\n\t\tvar source_id',1)
s=s.replace('\tvar radius := effect.chain_radius', '\tvar chain_limit := effect.maximum_chain_targets + (template.source.passive_items.count("spark") if template.source is Player else 0)\n\tvar radius := effect.chain_radius')
s=s.replace('effect.maximum_chain_targets > 0','chain_limit > 0').replace('target.get_instance_id(),effect.maximum_chain_targets','target.get_instance_id(),chain_limit').replace('neighbors.size() > effect.maximum_chain_targets: neighbors.resize(effect.maximum_chain_targets)','neighbors.size() > chain_limit: neighbors.resize(chain_limit)')
p.write_text(s,encoding='utf-8')
ready={13:'double_yolk',42:'butcher',57:'electric_stove',61:'wasabi',62:'extra_shell',69:'paste',72:'slippery_shell',75:'spark',79:'extra_slot',85:'guarana',86:'iron_apron',88:'overload',89:'reheated',91:'table_slam',96:'refrito',97:'reduction'}
concept=Path('documentacion-local/conceptos/items-v1')
lines=[l.split(' — ',1) for l in (concept/'catalogo-original.txt').read_text(encoding='utf-8').splitlines() if ' — ' in l]
assert len(lines)==100,len(lines)
out=root/'resources/items/passives/catalogue';out.mkdir(parents=True,exist_ok=True)
icons=root/'assets/sprites/Items/Catalogue';icons.mkdir(parents=True,exist_ok=True)
pending=[]
for i,(name,desc) in enumerate(lines,1):
 folder=next(concept.glob(f'{i:03d}-*')); png=next(folder.glob('*-v1.png'));shutil.copy2(png,icons/f'{i:03d}.png')
 tier=0 if i<=37 else 1 if i<=73 else 2 if i<=91 else 3
 reason='' if i in ready else ('Faltan magnitudes numéricas de los modificadores.' if i<=56 or i in [58,59,60,68,70,71,73] else 'Falta cerrar parámetros, reglas o selección interactiva del efecto.')
 pending.append(f'| {i:03d} | {name} | '+('Implementado' if i in ready else reason)+' |')
 def q(v):return json.dumps(v,ensure_ascii=False)
 text='[gd_resource type="Resource" script_class="" load_steps=3 format=3]\n\n[ext_resource type="Script" path="res://resources/items/passives/catalogue_passive.gd" id="1"]\n[ext_resource type="Texture2D" path="res://assets/sprites/Items/Catalogue/%03d.png" id="2"]\n\n[resource]\n'%i
 text+='script = ExtResource("1")\nitem_name = '+q(name)+'\nitem_icon = ExtResource("2")\nitem_type = 2\nitem_tier = '+str(tier)+'\nitem_cost = '+str([10,25,50,80][tier])+'\ncatalogue_id = '+str(i)+'\ndescription = '+q(desc.replace('Picantes','Chilis'))+'\neffect_key = '+q(ready.get(i,''))+'\nready_for_shop = '+str(i in ready).lower()+'\npending_reason = '+q(reason)+'\n'
 (out/f'item_{i:03d}.tres').write_text(text,encoding='utf-8')
(root/'docs/item_catalogue_status.md').write_text('# Catálogo de pasivos\n\nPrecios base iniciales editables por rareza: 10/25/50/80. Copias suman efectos. Pendientes excluidos de tienda; recursos e iconos preparados.\n\n| ID | Ítem | Estado |\n|---|---|---|\n'+'\n'.join(pending),encoding='utf-8')
print('100 recursos, 16 efectos iniciales.')

