# Slicer-Import nachstellen: ASCII-STL -> float32, exakt gleiche Punkte verschmelzen
import struct,sys,collections
d=open(sys.argv[1],'rb').read()
f32=lambda s: struct.unpack('<f',struct.pack('<f',float(s)))[0]
P=[tuple(f32(c) for c in l.split()[1:]) for l in d.decode().splitlines() if l.strip().startswith('vertex')]
E=collections.Counter(); deg=0
for i in range(0,len(P),3):
    a,b,c=P[i:i+3]
    if a==b or b==c or a==c: deg+=1; continue
    for u,v in ((a,b),(b,c),(c,a)): E[tuple(sorted((u,v)))]+=1
bad=sum(1 for k in E.values() if k!=2)
print(f"{sys.argv[2]:34s} degeneriert {deg:3d}  nicht-mannigfaltige Kanten {bad}")
