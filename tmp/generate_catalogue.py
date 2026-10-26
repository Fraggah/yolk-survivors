from pathlib import Path
import json,shutil
root=Path('yolk-survivors')
ready={13:'double_yolk',42:'butcher',57:'electric_stove',61:'wasabi',62:'extra_shell',69:'paste',72:'slippery_shell',75:'spark',79:'extra_slot',85:'guarana',86:'iron_apron',88:'overload',89:'reheated',91:'table_slam',96:'refrito',97:'reduction'}
concept=Path('documentacion-local/conceptos/items-v1')
lines=[l.split(' — ',1) for l in (concept/'catalogo-original.txt').read_text(encoding='utf-8').splitlines() if ' — ' in l and not l.startswith('ARMADOS:')]
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


