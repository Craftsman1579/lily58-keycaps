# 0009 – Meshes must survive slicer import without errors

- **Status:** accepted
- **Decided by:** derived (after Bambu Studio reported non-manifold edges on `R2_links`)

## Context

Bambu Studio reads ASCII STL coordinates as float32 and merges identical points. Near-coincident
faces from boolean operations then become non-manifold edges. Sources found: the playground's stem
lining ending flush with the rim, rotation inside the playground, the DES cross hole and its flare
sharing faces, the DES dish halves offset by only 0.00001 mm, legend volumes whose top coincided with
the dish, and support cavities with coincident vertical walls.

## Decision

Rules for all geometry:

- **No coincident faces.** Overlap by a small, real amount instead (e.g. dish halves 0.05 mm, cross
  starts below the stem bottom, flare frustums taper at different rates per axis, legend recess is a
  column cut that extends above the dish, legends end 0.3 mm above the inner ceiling, stem walls end
  0.3 mm above the rim, support cavity copy scaled 0.99).
- **Render upright, cut, then rotate** – never let the playground rotate (`KEY_ROTATION=[0,0,0]`,
  rotation in the group pass).
- **3MF for intermediate files** (exact shared vertices), **STL for the final groups**, because Bambu
  Studio only offers "load as one object with multiple parts" for STL.
- **KAT without stem lining** (`STEM_SIDES_WALL_THICKNESS = 0`, `WALL_THICKNESS = 1.8`): the straight
  lining against curved KAT walls left enclosed voids and near-touching faces.
- Every output is checked with `tools/f32.py` (simulates the float32 import) and must report
  0 non-manifold edges. A few zero-area triangles are acceptable (slicers drop them silently).

## Consequences

- A remaining 1.8 mm³ enclosed void under the KAT top (stem topper) is harmless and accepted.
- When changing geometry, re-run `f32.py` on all group STLs.
