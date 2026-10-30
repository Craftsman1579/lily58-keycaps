# 3MF (indiziertes Netz): Kanten mit != 2 Dreiecken, degenerierte Dreiecke, Objekte
import zipfile,sys,re,collections
z=zipfile.ZipFile(sys.argv[1]); x=z.read([n for n in z.namelist() if n.endswith('.model')][0]).decode()
tot_bad=tot_deg=tot_tri=0; objs=0
for m in re.finditer(r'<mesh>(.*?)</mesh>', x, re.S):
    objs+=1; body=m.group(1)
    V=re.findall(r'<vertex x="([^"]+)" y="([^"]+)" z="([^"]+)"', body)
    T=[tuple(map(int,t)) for t in re.findall(r'<triangle v1="(\d+)" v2="(\d+)" v3="(\d+)"', body)]
    E=collections.Counter()
    for a,b,c in T:
        if len({a,b,c})<3 or len({V[a],V[b],V[c]})<3: tot_deg+=1; continue
        for u,v in ((a,b),(b,c),(c,a)): E[(min(u,v),max(u,v))]+=1
    tot_bad+=sum(1 for k in E.values() if k!=2); tot_tri+=len(T)
print(f"{sys.argv[1].split('/')[-1]:26s} Objekte {objs}  Dreiecke {tot_tri}  degeneriert {tot_deg}  nicht-mannigfaltige Kanten {tot_bad}")
