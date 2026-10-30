# Schnitt bei z, dann Kreuzungen entlang Linien -> Luft-Intervalle im Stem
import struct,sys
d=open(sys.argv[1],'rb').read(); P=[]
if d[:5]==b'solid': P=[tuple(map(float,l.split()[1:])) for l in d.decode().splitlines() if l.strip().startswith('vertex')]
else:
    n=struct.unpack('<I',d[80:84])[0]
    for i in range(n): f=struct.unpack('<12f',d[84+50*i:84+50*i+48]); P+=[f[3:6],f[6:9],f[9:12]]
zc=float(sys.argv[2]); seg=[]
for i in range(0,len(P),3):
    t=P[i:i+3]; q=[]
    for a,b in ((t[0],t[1]),(t[1],t[2]),(t[2],t[0])):
        if (a[2]-zc)*(b[2]-zc)<0:
            s=(zc-a[2])/(b[2]-a[2]); q.append((a[0]+s*(b[0]-a[0]),a[1]+s*(b[1]-a[1])))
    if len(q)==2: seg.append(q)
def hits(axis,c):  # Linie: axis=0 -> y=c, Kreuzungen in x
    o=1-axis; r=[]
    for (p,q) in seg:
        if (p[o]-c)*(q[o]-c)<0:
            s=(c-p[o])/(q[o]-p[o]); v=p[axis]+s*(q[axis]-p[axis])
            if abs(v)<3.2: r.append(round(v,2))
    return sorted(r)
print(f"{sys.argv[3]}: entlang x (y=0): {hits(0,0.0)}  entlang y (x=0): {hits(1,0.0)}")
print(f"   quer durch x-Arm (x=1.5): {hits(1,1.5)}   quer durch y-Arm (y=1.5): {hits(0,1.5)}")
