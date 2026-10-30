# Szenen fuer die README-Bilder: Satz in Lily58-Anordnung (mit/ohne Beschriftung) und Nahaufnahme.
# Aufruf: scene.py <des|kat> <caps-ordner (flache Kappen-STLs)> <raw-ordner (Legenden-3MF)> <ausgabe-ordner>
import sys, os

prof, caps, raw, out = sys.argv[1:5]
u = 19.05
stagger = [0, 0, 0.20, 0.32, 0.20, 0.10]        # Spaltenversatz (in u), links von aussen nach innen
X0 = 8.5                                        # linke Spalte der rechten Haelfte (in u)

def pos_left(c, r):  return (c, r + stagger[c])
def pos_right(c, r): return (X0 + c, r + stagger[5 - c])

thumbs_left  = [(2.6, -1.0), (3.6, -1.05), (4.6, -1.1), (6.0, -1.0)]     # Alt GUI Lower Space(1.5u)
thumbs_right = [(X0 - 1.0, -1.0), (X0 + 0.4, -1.1), (X0 + 1.4, -1.05), (X0 + 2.4, -1.0)]
if prof == 'des':
    rows = {'R1': 3, 'R2': 2, 'R3': 1, 'R4': 0}   # DES: R1 Zahlen ... R4 unten
    bottom, home, rot180 = 'R4', 'R3', 'R1'       # R1 wird um 180 Grad gedreht aufgesteckt
    wide_rot = 0                                  # DES-1.5u ist schon hochkant
else:
    rows = {'R4': 3, 'R3': 2, 'R2': 1, 'R1': 0}   # KAT: R4 Zahlen ... R1 unten
    bottom, home, rot180 = 'R1', 'R2', None
    wide_rot = 90                                 # KAT-1.5u ist quer gebaut, sitzt beim Lily58 hochkant

# (Kappe, Legende oder None, x, y, Drehung)
def layout(blank):
    keys = []
    for g, r in rows.items():
        rot = 180 if g == rot180 else 0
        for c in range(6):
            n = f'{g}_links_{c:02d}'
            keys.append((n, n, *pos_left(c, r), rot))
        right = [f'{g}_rechts_{i:02d}' for i in range(7 if g == bottom else 6)]
        if g == bottom:
            keys.append((right[0], right[0], X0 - 1, 0.5, 0))         # innere Taste rechts
            right = right[1:]
        for c, n in enumerate(right):
            keys.append((n, n, *pos_right(c, r), rot))
    keys.append((f'{bottom}_links_06', f'{bottom}_links_06', 6, 0.5, 0))   # innere Taste links
    for i, (x, y) in enumerate(thumbs_left):
        keys.append((f'Daumen_links_{i:02d}', f'Daumen_links_{i:02d}', x, y, wide_rot if i == 3 else 0))
    for i, (x, y) in enumerate(thumbs_right):
        keys.append((f'Daumen_rechts_{i:02d}', f'Daumen_rechts_{i:02d}', x, y, wide_rot if i == 0 else 0))
    if not blank:
        return keys
    res = []
    for n, l, x, y, rot in keys:
        if n.startswith('Daumen_links_'):    b = f'Daumen_leer_{int(n[-2:]):02d}'
        elif n.startswith('Daumen_rechts_'): b = f'Daumen_leer_{4 + int(n[-2:]):02d}'
        elif n == f'{home}_links_04':        b = 'Homing_leer_00'
        elif n == f'{home}_rechts_01':       b = 'Homing_leer_01'
        else:                                b = f'Ersatz_{n[:2]}_00'
        res.append((b, None, x, y, rot))
    return res

def scene(keys, path):
    with open(path, 'w') as f:
        for n, l, x, y, rot in keys:
            f.write(f'translate([{x*u:.2f},{y*u:.2f},0]) rotate([0,0,{rot}]) {{\n')
            f.write(f'  color("#2b2b2b") import("{caps}/{n}.stl");\n')
            if l and os.path.exists(f'{raw}/{l}_legends.3mf'):
                f.write(f'  color("#f2f2f2") import("{raw}/{l}_legends.3mf");\n')
            f.write('}\n')

scene(layout(False), f'{out}/set_labels.scad')
scene(layout(True), f'{out}/set_blank.scad')
first = list(rows)[0]
close = [(f'{first}_links_00', 0, 0, 180 if first == rot180 else 0), (f'{list(rows)[1]}_links_01', 1.15, 0, 0),
         (f'{home}_links_04', 2.3, 0, 0), ('Daumen_links_03', 3.55 if prof == 'des' else 3.75, 0, 0),
         ('Daumen_rechts_03', 4.8 if prof == 'des' else 5.2, 0, 0)]
scene([(n, n, x, y, rot) for n, x, y, rot in close], f'{out}/closeup.scad')
