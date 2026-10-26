from pathlib import Path
import os,subprocess
root=Path('yolk-survivors');paths=['scenes/units/enemies/enemy.gd','scenes/weapons/weapon.gd','scenes/weapons/melee/catalogue_melee_behaviour.gd'];saved={n:(root/n).read_bytes() for n in paths}
try:
 for name,raw in saved.items():
  s=raw.decode('utf-8').replace('\r\n','\n')
  if name.endswith('enemy.gd'):
   a=s.index('\t# Scale both parts of authored collision offsets together.');b=s.index('\tfor path in ["CollisionShape2D"',a);s=s[:a]+s[b:]
  else:s=s.replace('closest_target.get_aim_position()','closest_target.global_position')
  (root/name).write_bytes(s.encode('utf-8'))
 env=os.environ.copy();env['APPDATA']=str(Path('tmp').resolve());info=subprocess.STARTUPINFO();info.dwFlags|=subprocess.STARTF_USESHOWWINDOW;info.wShowWindow=0
 with open('tmp/melee-before-aim.log','w') as out,open('tmp/melee-before-aim-errors.log','w') as err:
  try:subprocess.run(['C:/Godot_v4.4.1-stable_win64.exe','--path','yolk-survivors','--rendering-method','gl_compatibility','--script','res://tests/verify_catalogue_melee.gd'],stdout=out,stderr=err,env=env,startupinfo=info,timeout=18)
  except subprocess.TimeoutExpired:pass
finally:
 for name,raw in saved.items():(root/name).write_bytes(raw)
print(Path('tmp/melee-before-aim.log').read_text()[-300:]);print(Path('tmp/melee-before-aim-errors.log').read_text()[-800:])
