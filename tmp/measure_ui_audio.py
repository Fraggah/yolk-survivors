import wave, numpy as np, json
from pathlib import Path
for p in Path('yolk-survivors/assets/audio/SFX').glob('UI_*.wav'):
 try:
  with wave.open(str(p)) as w:
   rate=w.getframerate();channels=w.getnchannels();width=w.getsampwidth();raw=w.readframes(w.getnframes())
  if width==2:a=np.frombuffer(raw,dtype='<i2').astype(float)/32768
  elif width==3:
   b=np.frombuffer(raw,dtype=np.uint8).reshape(-1,3);v=b[:,0].astype(np.int32)|(b[:,1].astype(np.int32)<<8)|(b[:,2].astype(np.int32)<<16);a=((v^8388608)-8388608)/8388608
  elif width==4:a=np.frombuffer(raw,dtype='<i4').astype(float)/2147483648
  else:raise ValueError(width)
  a=a.reshape(-1,channels);e=np.mean(a*a,axis=1);block=max(1,int(rate*.05));windows=np.array([np.mean(e[i:i+block]) for i in range(0,len(e),block)]);active=windows[windows>max(windows.max()*0.01,1e-9)]
  print(json.dumps(dict(file=p.name,seconds=len(a)/rate,peak_db=round(20*np.log10(max(np.max(np.abs(a)),1e-9)),2),active_rms_db=round(10*np.log10(np.mean(active)),2),strong_rms_db=round(10*np.log10(np.percentile(active,80)),2))))
 except Exception as ex:print(p.name,str(ex))
