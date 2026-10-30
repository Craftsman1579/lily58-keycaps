# ASCII-STL -> Binaer-STL (float32, wie ein Slicer die ASCII-Werte ohnehin einliest).
# Aufruf: stl2bin.py <ein.stl> <aus.stl>
import struct, sys

src, dst = sys.argv[1:3]
tris = []
normal = None
verts = []
for line in open(src):
    w = line.split()
    if not w:
        continue
    if w[0] == 'facet':
        normal = tuple(map(float, w[2:5])); verts = []
    elif w[0] == 'vertex':
        verts.append(tuple(map(float, w[1:4])))
    elif w[0] == 'endfacet':
        tris.append((normal, verts))
with open(dst, 'wb') as f:
    f.write(b'lily58-keycaps'.ljust(80, b' '))
    f.write(struct.pack('<I', len(tris)))
    for n, v in tris:
        f.write(struct.pack('<12fH', *n, *v[0], *v[1], *v[2], 0))
print(f"{dst.split('/')[-1]}: {len(tris)} Dreiecke")
