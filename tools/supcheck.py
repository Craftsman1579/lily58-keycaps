# Stuetze gegen Kappe (beide im Druck-System, STL): Teile, Bettkontakt, kleinster Abstand zur Kappe
# Aufruf: supcheck.py <stuetze.stl> <kappe.stl> <name>
import sys, math, collections


def load(p):
    P = [tuple(map(float, l.split()[1:])) for l in open(p).read().splitlines() if l.strip().startswith('vertex')]
    return [P[i:i+3] for i in range(0, len(P), 3)]


S, C, name = load(sys.argv[1]), load(sys.argv[2]), sys.argv[3]
# Teile der Stuetze
key = lambda p: tuple(round(c, 4) for c in p); par = {}
def f(x):
    while par.setdefault(x, x) != x: par[x] = par[par[x]]; x = par[x]
    return x
for t in S:
    a, b, c = map(key, t); par[f(b)] = f(a); par[f(c)] = f(a)
parts = len({f(key(t[0])) for t in S})
zmin = min(p[2] for t in S for p in t)
foot = sum(0.5*abs((b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0])) for a, b, c in S if max(a[2], b[2], c[2]) < 0.01)
# kleinster Abstand: Stuetzen-Punkte (inkl. Kantenmitten) gegen Kappen-Dreiecke im Rasterumkreis
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
cell = 1.0; grid = collections.defaultdict(list)
for t in C:
    lo = [math.floor(min(p[i] for p in t)/cell) for i in range(3)]; hi = [math.floor(max(p[i] for p in t)/cell) for i in range(3)]
    for i in range(lo[0], hi[0]+1):
        for j in range(lo[1], hi[1]+1):
            for k in range(lo[2], hi[2]+1): grid[(i, j, k)].append(t)
pts = set()
for a, b, c in S:
    pts.update([a, b, c, tuple((a[i]+b[i])/2 for i in range(3)), tuple((b[i]+c[i])/2 for i in range(3)), tuple((a[i]+c[i])/2 for i in range(3)), tuple((a[i]+b[i]+c[i])/3 for i in range(3))])
best = (9, None)
for p in pts:
    ci = [math.floor(p[i]/cell) for i in range(3)]
    for i in range(ci[0]-1, ci[0]+2):
        for j in range(ci[1]-1, ci[1]+2):
            for k in range(ci[2]-1, ci[2]+2):
                for t in grid.get((i, j, k), ()):
                    dd = pt_tri(p, *t)
                    if dd < best[0]: best = (dd, p)
print(f"{name:18s} Stuetze: {parts} Teil(e), tiefster Punkt z={zmin:+.3f}, Fussflaeche {foot:.1f} mm2, "
      f"kleinster Abstand zur Kappe {best[0]:.2f} mm bei z={best[1][2]:.2f}")
