# Wandstaerke ueber der flachen Auflageflaeche (erstes Material-Intervall ab Bett, entlang z)
import struct,sys,math
d=open(sys.argv[1],'rb').read(); P=[]
if d[:5]==b'solid': P=[tuple(map(float,l.split()[1:])) for l in d.decode().splitlines() if l.strip().startswith('vertex')]
else:
    n=struct.unpack('<I',d[80:84])[0]
    for i in range(n): f=struct.unpack('<12f',d[84+50*i:84+50*i+48]); P+=[f[3:6],f[6:9],f[9:12]]
T=[P[i:i+3] for i in range(0,len(P),3)]; zmin=min(p[2] for t in T for p in t); h=0.25; hits={}
for a,b,c in T:
    if min(a[2],b[2],c[2])>zmin+4: continue
    dd=(b[1]-c[1])*(a[0]-c[0])+(c[0]-b[0])*(a[1]-c[1])
    if abs(dd)<1e-12: continue
    for i in range(math.floor(min(a[0],b[0],c[0])/h),math.ceil(max(a[0],b[0],c[0])/h)+1):
        for j in range(math.floor(min(a[1],b[1],c[1])/h),math.ceil(max(a[1],b[1],c[1])/h)+1):
            x,y=i*h+h/2,j*h+h/3
            l1=((b[1]-c[1])*(x-c[0])+(c[0]-b[0])*(y-c[1]))/dd; l2=((c[1]-a[1])*(x-c[0])+(a[0]-c[0])*(y-c[1]))/dd; l3=1-l1-l2
            if min(l1,l2,l3)>=0: hits.setdefault((i,j),[]).append(l1*a[2]+l2*b[2]+l3*c[2])
area=0; th=[]
for z in hits.values():
    z=sorted(z)
    if z[0]-zmin<0.02:
        area+=h*h
        if len(z)>1: th.append(z[1]-z[0])
th.sort()
print(f"{sys.argv[2]}: Auflage flach {area:.0f} mm2 | Wand ueber Auflage min {th[0]:.2f} / 5%-Quantil {th[len(th)//20]:.2f} / median {th[len(th)//2]:.2f} mm")
