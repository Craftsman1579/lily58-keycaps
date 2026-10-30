# 0001 – Print caps sideways with flattened side walls

- **Status:** accepted
- **Decided by:** owner (sideways printing, flat sides), derived (cut geometry and print angle)

## Context

Printed upright, the curved dish of a sculpted cap shows every layer as a ring, and the stem's layer
lines run across the stem, which is where it breaks when the cap is pulled. Lying on its side, the
top is built from vertical contours (smooth) and the layers run along the stem (strong). But the side
walls of DSA, KAT and DES caps are curved (bulge 0.45–1.0 mm), so a cap lying on its side only
touches the bed along a narrow strip (≈ 20 mm²).

## Decision

- Print every cap on its side (`+x` side of the upright cap down).
- Cut **both** side walls (left and right) flat along a plane through the bottom rim corner
  `(xb, zb)` and the top edge `(xt, zt)` of the upright silhouette ("chord"). The owner asked for
  flat sides and chose left *and* right so the caps stay symmetric.
- The print angle is derived from the same chord, `a = 90 + atan2(xb - xt, zt - zb)`, so the flat
  face lies exactly on the bed. Each cap is lifted so its flat face is at z = 0
  (`xb·sin(a) − zb·cos(a)`), which also aligns caps of different heights in one group.
- Chords are measured once per cap shape on the upright render (convex hull of the x–z silhouette,
  `tools/chord2.py`) and hard-coded in the script (`kat_row`, `des_shape`). Asymmetric DES thumb caps
  have separate left/right chords.
- The cut also trims 0.02 mm off the rim so the cut plane never coincides with rim geometry.

## Consequences

- Contact area 80–240 mm² per cap; no brim needed.
- The walls get thinner where the bulge was (DES 2.0 mm → ≥ 1.0 mm, KAT 1.8 mm → ≥ 1.0 mm).
- Chords must be re-measured when a profile's shape parameters, resolution (`fn`, `layers`) or key
  width change (e.g. the 1.5u keys have their own chord).
- Earlier approaches that were dropped: fixed angle 112.4° with curved sides (DSA), angle sweep by
  contact area (unreliable for KAT because the rim touched first).
