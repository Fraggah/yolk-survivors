from pathlib import Path
import re
root=Path('yolk-survivors')
p=root/'autoload/sound_manager.gd';s=p.read_text(encoding='utf-8-sig');s,n=re.subn(r'(@export var \w+: AudioStream) = preload\([^\n]+\)',r'\1',s);p.write_text(s,encoding='utf-8');print('Defaults cleared:',n)
p=root/'autoload/sound_manager.tscn';s=p.read_text();ids=re.findall(r'\[ext_resource type="AudioStream"[^\n]* id="([^"]+)"\]',s)
s=re.sub(r'^\[ext_resource type="AudioStream"[^\n]*\]\n','',s,flags=re.M)
for rid in ids:s=re.sub(r'^\w+ = ExtResource\("'+re.escape(rid)+r'"\)\n','',s,flags=re.M)
s=re.sub(r'load_steps=\d+','load_steps=2',s);p.write_text(s,encoding='utf-8');print('Scene audio resources cleared:',len(ids))
count=0
for p in root.rglob('*.tscn'):
 if '.godot' in p.parts:continue
 s=p.read_text(encoding='utf-8-sig');updated,n=re.subn(r'^(attack_sound|impact_sound|continuous_sound) = .+\n','',s,flags=re.M)
 if n:p.write_text(updated,encoding='utf-8');count+=n
print('Weapon overrides cleared:',count)
p=root/'docs/sfx_events.md';s=p.read_text(encoding='utf-8-sig');s=s.replace('Los campos nuevos quedan vacíos: un campo vacío no reproduce audio. Se conservan las asignaciones anteriores.','Todos los campos de SFX quedan vacíos, incluidos los anteriores: un campo vacío no reproduce audio. Las conexiones y los archivos de audio se conservan.');p.write_text(s,encoding='utf-8')
