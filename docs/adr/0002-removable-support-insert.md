# 0002 – Removable support insert standing on the bed

- **Status:** accepted (tested: "support was perfect, came off perfectly")
- **Decided by:** owner (support must stand on the build plate, not inside the cap), derived (design)

## Context

In the sideways pose the stem lies horizontally inside the cap and rises by about 17° towards the
opening, so its whole underside is an overhang. The cap's own side wall lies between the stem and
the bed, so a vertical support column from the bed cannot reach the stem. Earlier versions used the
keycap_playground's built-in fin (`STEM_SIDE_SUPPORTS`) and later a fin fused between stem and wall;
both stayed inside the cap and had to be broken out. The owner asked for a support that stands on the
build plate instead.

## Decision

`stem_support()` in `stemsupport.scad` (written by `write_stemsupport` in the script) adds a separate
part per cap, in the upright key frame:

- **Foot:** in front of the open bottom of the cap (key z ∈ [−3, −0.3]), its bed face lies in the
  extended chord plane; tapers from the fin width (1.2 mm) to 5 mm at the bed.
- **Fin:** 1.2 mm thick, from the foot through the opening under the stem along its full length.
- **Clearances:** 0.2 mm to the stem (stem radius 2.85 + 0.2), about 0.3 mm to the walls, ceiling
  lowered 0.3 mm, fin ends at `H − 3.2` (above that lies the dish).
- The cavity is computed as `hull(cap) − cap`, minus a 0.9 mm band at the hull boundary (thin shells
  outside concave DES walls), scaled by 0.955 in x/y for the wall gap. The lowered-ceiling copy is
  additionally scaled by 0.99 so vertical inner walls never coincide (see ADR 0009).
- The playground's built-in support is switched off, the DES fused fin was removed. KAT also lost
  its stem lining (see ADR 0009), which removed enclosed voids the cavity method picked up.

## Consequences

- The support never touches the cap; it slides out of the opening after printing.
- The fin's first layer bridges ~0.3 mm above the inner wall (normal support z-gap behaviour).
- Slicer supports must be off.
- The modes `test`, `kat-test` (old) and `all` (DSA) predate this; only `kat-all`, `kat-test` (fit
  test) and `des-all`/`des-test` use the insert.
