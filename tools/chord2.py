# Winkel aus der Silhouette (x-z-Projektion) der aufrechten Kappe: Sehne untere Randecke -> obere Seitenkante (+x-Seite)
import struct,sys,math
d=open(sys.argv[1],'rb').read(); P=[]
if d[:5]==b'solid': P=[tuple(map(float,l.split()[1:])) for l in d.decode().splitlines() if l.strip().startswith('vertex')]
else:
    n=struct.unpack('<I',d[80:84])[0]
    for i in range(n): f=struct.unpack('<12f',d[84+50*i:84+50*i+48]); P+=[f[3:6],f[6:9],f[9:12]]
S=-1 if len(sys.argv)>3 and sys.argv[3]=="L" else 1
pts=sorted(set((round(S*p[0],4),round(p[2],4)) for p in P))
def cross(o,a,b): return (a[0]-o[0])*(b[1]-o[1])-(a[1]-o[1])*(b[0]-o[0])
lo=[];up=[]
for p in pts:
    while len(lo)>=2 and cross(lo[-2],lo[-1],p)<=0: lo.pop()
    lo.append(p)
for p in reversed(pts):
    while len(up)>=2 and cross(up[-2],up[-1],p)<=0: up.pop()
    up.append(p)
hull=lo[:-1]+up[:-1]   # gegen Uhrzeigersinn
zmin=min(p[1] for p in pts)
# untere rechte Ecke: groesstes x auf Bodenhoehe
i0=max((i for i,p in enumerate(hull) if p[1]<zmin+0.2), key=lambda i:hull[i][0])
# entlang der Huelle nach oben laufen, bis die Kante flacher als 45 Grad wird
i=i0; n=len(hull)
while True:
    a,b=hull[i%n],hull[(i+1)%n]
    if b[1]-a[1] < abs(b[0]-a[0]): break
    i+=1
bot,top=hull[i0],hull[i%n]
dx,dz=bot[0]-top[0],top[1]-bot[1]
ang=90+math.degrees(math.atan2(dx,dz))
# max. Abweichung der Seitenwand von der Sehne (Woelbung)
seg=[hull[k%n] for k in range(i0,i+1)]
L=math.hypot(dx,dz); bulge=max(abs((p[0]-bot[0])*dz+(p[1]-bot[1])*dx)/L for p in seg)
print(f"{sys.argv[2]}: xb {bot[0]:.3f} zb {bot[1]:.3f} xt {top[0]:.3f} zt {top[1]:.3f}  Winkel {ang:.2f}  Woelbung {bulge:.2f}")
