import struct,sys
d=open(sys.argv[1],'rb').read(); P=[]
if d[:5]==b'solid': P=[tuple(map(float,l.split()[1:])) for l in d.decode().splitlines() if l.strip().startswith('vertex')]
else:
    n=struct.unpack('<I',d[80:84])[0]
    for i in range(n): f=struct.unpack('<12f',d[84+50*i:84+50*i+48]); P+=[f[3:6],f[6:9],f[9:12]]
key=lambda p: tuple(round(c,4) for c in p); par={}
def f(x):
    while par.setdefault(x,x)!=x: par[x]=par[par[x]]; x=par[x]
    return x
T=[P[i:i+3] for i in range(0,len(P),3)]
for t in T:
    a,b,c=map(key,t); par[f(b)]=f(a); par[f(c)]=f(a)
vol={}
for a,b,c in T:
    r=f(key(a)); vol[r]=vol.get(r,0)+(a[0]*(b[1]*c[2]-b[2]*c[1])-a[1]*(b[0]*c[2]-b[2]*c[0])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6
print(sys.argv[2]+": "+", ".join(("Koerper %+.1f" if v>0 else "Hohlraum %+.2f")%v for v in sorted(vol.values(),reverse=True))+" mm3")
