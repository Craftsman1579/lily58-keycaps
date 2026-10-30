# Gruppen-STL: Kappen (>500 mm3) und Stuetzen (Rest) trennen; je Stuetze Bettkontakt und
# kleinster Abstand zu irgendeiner Kappe. Aufruf: grpsup.py <gruppe_body.stl> <name>
import sys, math, collections


def load(p):
    P = [tuple(map(float, l.split()[1:])) for l in open(p).read().splitlines() if l.strip().startswith('vertex')]
    return [P[i:i+3] for i in range(0, len(P), 3)]


def shells(T):
    key = lambda p: tuple(round(c, 4) for c in p); par = {}
    def f(x):
        while par.setdefault(x, x) != x: par[x] = par[par[x]]; x = par[x]
        return x
    for t in T:
        a, b, c = map(key, t); par[f(b)] = f(a); par[f(c)] = f(a)
    g = collections.defaultdict(list)
    for t in T: g[f(key(t[0]))].append(t)
    out = []
    for tris in g.values():
        v = sum((a[0]*(b[1]*c[2]-b[2]*c[1])-a[1]*(b[0]*c[2]-b[2]*c[0])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6 for a, b, c in tris)
        out.append((v, tris))
    return out


def pt_tri(p, a, b, c):
    ab = [b[i]-a[i] for i in range(3)]; ac = [c[i]-a[i] for i in range(3)]; ap = [p[i]-a[i] for i in range(3)]
    d = lambda u, v: u[0]*v[0]+u[1]*v[1]+u[2]*v[2]
    d1, d2 = d(ab, ap), d(ac, ap)
    if d1 <= 0 and d2 <= 0: return math.dist(p, a)
    bp = [p[i]-b[i] for i in range(3)]; d3, d4 = d(ab, bp), d(ac, bp)
    if d3 >= 0 and d4 <= d3: return math.dist(p, b)
    vc = d1*d4 - d3*d2
    if vc <= 0 and d1 >= 0 and d3 <= 0:
        v = d1/(d1-d3); return math.dist(p, [a[i]+v*ab[i] for i in range(3)])
    cp = [p[i]-c[i] for i in range(3)]; d5, d6 = d(ab, cp), d(ac, cp)
    if d6 >= 0 and d5 <= d6: return math.dist(p, c)
    vb = d5*d2 - d1*d6
    if vb <= 0 and d2 >= 0 and d6 <= 0:
        w = d2/(d2-d6); return math.dist(p, [a[i]+w*ac[i] for i in range(3)])
    va = d3*d6 - d5*d4
    if va <= 0 and (d4-d3) >= 0 and (d5-d6) >= 0:
        w = (d4-d3)/((d4-d3)+(d5-d6)); return math.dist(p, [b[i]+w*(c[i]-b[i]) for i in range(3)])
    den = 1/(va+vb+vc); v, w = vb*den, vc*den
    return math.dist(p, [a[i]+ab[i]*v+ac[i]*w for i in range(3)])


T = load(sys.argv[1]); name = sys.argv[2]
sh = shells(T)
caps = [t for v, t in sh if v > 500]
sups = [t for v, t in sh if 5 < v <= 500]
other = [v for v, t in sh if v <= 5]
cell = 1.0; grid = collections.defaultdict(list)
for cap in caps:
    for t in cap:
        lo = [math.floor(min(p[i] for p in t)/cell) for i in range(3)]; hi = [math.floor(max(p[i] for p in t)/cell) for i in range(3)]
        for i in range(lo[0], hi[0]+1):
            for j in range(lo[1], hi[1]+1):
                for k in range(lo[2], hi[2]+1): grid[(i, j, k)].append(t)
mind = 9; zmins = []; feet = []
for s in sups:
    zmins.append(min(p[2] for t in s for p in t))
    feet.append(sum(0.5*abs((b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0])) for a, b, c in s if max(a[2], b[2], c[2]) < 0.01))
    pts = set()
    for a, b, c in s:
        pts.update([a, b, c, tuple((a[i]+b[i]+c[i])/3 for i in range(3))])
    for p in pts:
        ci = [math.floor(p[i]/cell) for i in range(3)]
        for i in range(ci[0]-1, ci[0]+2):
            for j in range(ci[1]-1, ci[1]+2):
                for k in range(ci[2]-1, ci[2]+2):
                    for t in grid.get((i, j, k), ()):
                        mind = min(mind, pt_tri(p, *t))
print(f"{name:14s} Kappen {len(caps):2d} | Stuetzen {len(sups):2d} | Kleinteile {len(other)} | "
      f"Stuetzen-Fuss z {min(zmins):+.3f}..{max(zmins):+.3f}, Flaeche {min(feet):.1f}..{max(feet):.1f} mm2 | "
      f"kleinster Abstand Stuetze-Kappe {mind:.2f} mm")
