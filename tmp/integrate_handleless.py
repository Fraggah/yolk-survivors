from pathlib import Path
import re,json
root=Path('yolk-survivors')
# Visible old body bounds exclude the handles; new bounds exclude alpha/soft halo.
entries={
 'nonstick_pan':((303,97,1498,922),(199,87,1338,936),(3000,2000)),
 'cooking_pot':((126,38,1414,986),(122,37,1414,990),(3000,2000)),
 'deep_wok':((307,31,1451,966),(235,30,1303,971),(3900,2600)),
 'iron_griddle':((173,121,1369,899),(149,117,1387,898),(3000,2000)),
 'oven_tray':((99,96,1439,896),(98,96,1439,896),(3000,2000))}
manifest={}
for name,(old,new,old_size) in entries.items():
 p=root/'resources/environments/stages'/f'{name}.tres';s=p.read_text(encoding='utf-8-sig')
 vals=list(map(float,re.search(r'movement_bounds = Rect2\(([^)]+)\)',s).group(1).split(',')));center=(vals[0]+vals[2]/2,vals[1]+vals[3]/2)
 target=((old[2]-old[0])*old_size[0]/1536,(old[3]-old[1])*old_size[1]/1024)
 scale=(target[0]/(new[2]-new[0]),target[1]/(new[3]-new[1]))
 size=(1536*scale[0],1024*scale[1])
 offset=(center[0]-((new[0]+new[2])/2-768)*scale[0],center[1]-((new[1]+new[3])/2-512)*scale[1])
 s=re.sub(r'\[ext_resource type="Texture2D"[^\n]* id="2"\]',f'[ext_resource type="Texture2D" path="res://assets/environments/stages/{name}_no_handles.png" id="2"]',s)
 # Both geometry metadata and the stage share the same authored presentation values.
 s=re.sub(r'vessel_size = Vector2\([^)]+\)',f'vessel_size = Vector2({size[0]:.5f}, {size[1]:.5f})',s)
 s=re.sub(r'vessel_offset = Vector2\([^)]+\)',f'vessel_offset = Vector2({offset[0]:.5f}, {offset[1]:.5f})',s)
 s=s.replace('play_area = SubResource("PlayArea")',f'vessel_body_rect = Rect2({new[0]}, {new[1]}, {new[2]-new[0]}, {new[3]-new[1]})\nplay_area = SubResource("PlayArea")')
 p.write_text(s,encoding='utf-8')
 manifest[name]={'body_rect_px':new,'body_world_size':target,'vessel_size':size,'vessel_offset':offset,'playable_center':center}
 # Native importer settings, with fresh paths and no reused UID.
 original=(root/'assets/environments/stages'/f'{name}.png.import').read_text()
 fresh=re.sub(r'^uid=.*\n','',original,flags=re.M).replace(f'{name}.png',f'{name}_no_handles.png')
 fresh=re.sub(r'path="res://.godot/imported/[^\n]+\n','',fresh)
 fresh=re.sub(r'dest_files=\[[^\n]+\]\n','',fresh)
 fresh=fresh.replace('mipmaps/generate=false','mipmaps/generate=true')
 (root/'assets/environments/stages'/f'{name}_no_handles.png.import').write_text(fresh,encoding='utf-8')
(root/'docs/handleless_arena_alignment.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print('Updated five stage textures and saved body alignment in their .tres resources')
