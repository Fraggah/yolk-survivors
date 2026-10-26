from pathlib import Path
import os,subprocess
p=Path('yolk-survivors/scenes/weapons/range/mayonnaise_stream.gd')
current=p.read_bytes()
try:
 s=current.decode('utf-8').replace('\r\n','\n').replace('\n\t\tSoundManager.set_weapon_loop(weapon,true)','').replace('\n\tSoundManager.set_weapon_loop(weapon,false)','')
 p.write_text(s,encoding='utf-8')
 env=os.environ.copy();env['APPDATA']=str(Path('tmp').resolve())
 info=subprocess.STARTUPINFO();info.dwFlags|=subprocess.STARTF_USESHOWWINDOW;info.wShowWindow=0
 with open('tmp/hydrant-without-new-audio.log','w') as out,open('tmp/hydrant-without-new-audio-errors.log','w') as err:
  try: subprocess.run(['C:/Godot_v4.4.1-stable_win64.exe','--path','yolk-survivors','--rendering-method','gl_compatibility','--script','res://tests/verify_hydrant_stream.gd'],stdout=out,stderr=err,env=env,startupinfo=info,timeout=18)
  except subprocess.TimeoutExpired: pass
finally:
 p.write_bytes(current)
print(Path('tmp/hydrant-without-new-audio-errors.log').read_text())

