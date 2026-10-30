# Legendenmitte gegen Mitte der Oberkante (Randring um die Mulde), aus den aufrechten Einzelkappen.
# Randring: je 10-Grad-Segment um die Mitte der hoechste Punkt im aeusseren Bereich.
# DES: im System der Oberseite (Spiegelung, Verschiebung, Neigung aus destops.dat); KAT: von oben.
# Aufruf: legcenter3.py des|kat <raw-ordner> <jobs-ordner>
import sys, re, zipfile, glob, os, math

mode, raw, jobs = sys.argv[1:4]


def verts(p):
    z = zipfile.ZipFile(p)
    x = z.read([n for n in z.namelist() if n.endswith('.model')][0]).decode()
    return [tuple(map(float, v)) for v in re.findall(r'<vertex x="([^"]+)" y="([^"]+)" z="([^"]+)"', x)]


def rot_inv(v, ax, ay, az):
    x, y, z = v
    c, s = math.cos(math.radians(-az)), math.sin(math.radians(-az)); x, y = c*x - s*y, s*x + c*y
    c, s = math.cos(math.radians(-ay)), math.sin(math.radians(-ay)); x, z = c*x + s*z, -s*x + c*z
    c, s = math.cos(math.radians(-ax)), math.sin(math.radians(-ax)); y, z = c*y - s*z, s*y + c*z
    return (x, y, z)


def rim_center(P):
    # Punkte oberhalb der halben Hoehe, je Segment der hoechste Punkt unter den aeusseren 30 %
    zmid = (min(p[2] for p in P) + max(p[2] for p in P)) / 2
    bins = {}
    for p in P:
        if p[2] < zmid: continue
        a = int(math.degrees(math.atan2(p[1], p[0])) // 10)
        bins.setdefault(a, []).append(p)
    ring = []
    for pts in bins.values():
        rmax = max(math.hypot(p[0], p[1]) for p in pts)
        outer = [p for p in pts if math.hypot(p[0], p[1]) > 0.7 * rmax]
        ring.append(max(outer, key=lambda p: p[2]))
    return ((min(p[0] for p in ring) + max(p[0] for p in ring)) / 2,
            (min(p[1] for p in ring) + max(p[1] for p in ring)) / 2)


tops = {}
if mode == 'des':
    for line in open(os.path.join(os.path.dirname(__file__), 'destops.dat')):
        prof, k, cx, cy, h, ax, ay, az = line.split()
        tops[(prof, int(k))] = tuple(map(float, (cx, cy, h, ax, ay, az)))

worst = 0; rows = []
for leg in sorted(glob.glob(os.path.join(raw, '*_legends.3mf'))):
    name = os.path.basename(leg)[:-len('_legends.3mf')]
    L = verts(leg); B = verts(os.path.join(raw, name + '_body.3mf'))
    if mode == 'des':
        job = open(os.path.join(jobs, name + '.scad')).read()
        prof = re.search(r'include <des_(\w+)\.scad>', job).group(1)
        kid = int(re.search(r'des_cap\((\d+),', job).group(1))
        mir = int(re.search(r'mir=(\d)', job).group(1))
        cx, cy, h, ax, ay, az = tops[(prof, kid)]
        def local(v):
            x, y, z = v
            if mir: x = -x
            return rot_inv((x - cx, y - cy, z - h), ax, ay, az)
        B = [local(v) for v in B]; L = [local(v) for v in L]
    tcx, tcy = rim_center(B)
    lcx = (min(v[0] for v in L) + max(v[0] for v in L)) / 2
    lcy = (min(v[1] for v in L) + max(v[1] for v in L)) / 2
    dx, dy = lcx - tcx, lcy - tcy
    worst = max(worst, math.hypot(dx, dy))
    rows.append((name, dx, dy))
for name, dx, dy in rows:
    print(f"{name:18s} dx {dx:+.2f}  dy {dy:+.2f}" + ('  <-- versetzt' if math.hypot(dx, dy) > 0.15 else ''))
print(f"== {mode}: {len(rows)} Legenden, groesster Versatz {worst:.2f} mm")
