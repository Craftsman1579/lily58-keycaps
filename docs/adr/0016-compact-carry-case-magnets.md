# 0016 – Compact carry case: halves turned against each other, closed by magnets

- **Status:** proposed (draft, not printed)
- **Decided by:** owner (maximum compactness for both boards, offset halves, magnets, no compartment on Choc if too small), derived (geometry)

## Context

The carry case of ADR 0015 stacks the halves so that each key faces itself. The number row is the
tallest (23.2 mm above the plate, measured), so it sets the height twice. A height map of all caps was
searched for the best relative placement (1 mm steps, both ways of turning the upper half over). The
table was made from the cap model, scaled so that the number row reaches the measured 23.2 mm; the row
heights measured afterwards (R2 17.4, R3 15.7, R4 17.7, tallest thumb 20.0 mm) raise the 75.5 mm by 0.35 mm.

| Upper half | Offset | Height | Footprint of the halves | Volume |
|---|---|---|---|---|
| turned over the short axis (ADR 0015) | none | 80.9 mm | 151.7 x 115.5 mm | 1418 cm³ |
| turned over the long axis | none | 75.5 mm | 151.7 x 115.5 mm | 1322 cm³ |
| turned over the long axis | y 19 mm | 70.0 mm | 151.7 x 134.5 mm | 1428 cm³ |
| turned over the long axis | x 25, y 20 mm | 68.0 mm | 176.7 x 135.5 mm | 1628 cm³ |

## Decision

- **Stack:** the left half is turned over the long axis, so it lies point-reflected over the right half
  and the number row of each half faces the low rows of the other. No offset: any offset costs more
  footprint than it saves in height. Plate to plate 42 mm: real cap meshes with the measured heights
  collide below 41.25 mm, so 0.75 mm of air remain. Total height 75.6 mm with
  the rubber feet, envelope 155.5 x 119.3 mm (as in ADR 0015).
- **Frames** (`part="frame2"`, `carry2_frame_right/left.stl`): two rings along the union of both outlines,
  21 mm high, meeting face on the bed, no support. Each rests on its plate rim where its own outline is
  the outside of the case; the skirt exists only there.
- **Magnets:** four per frame, 10 x 1.4 mm (owner, measured), in bosses at the meeting face. The bosses
  are wider than the ring, so the positions were searched: point-symmetric, compartments left free, caps
  under each boss at most 14.7 mm high (boss starts at 18.4 mm). Pockets are open at the meeting face,
  0.1 mm deeper than the magnet; glue the magnets in. All magnets of one frame with the same pole
  outwards, the other frame the opposite.
- **Dowels:** four 2.0 mm holes for 1.75 mm filament (5 mm deep per frame), glued in one frame, take the
  shear. No rubber bands.
- **Roof:** where the other half sticks out past this one the case would be open (a window at each
  notch, narrow strips along the edges). Each frame closes this with a solid wedge that grows from the ring
  at 45°, so it needs no support, and ends flush with the skirt, 0.3 mm round the tray.
- **Cable compartments:** one over each controller cover, 31.5 x 54.4 x 16.3 mm. Each frame carries the
  walls of its own compartment and a 1.2 mm deck closing the other one, printed on the bed.

### Choc board

Same stack, searched separately (cover 7.3 mm above the plate): turned over the long axis without an offset
is again the smallest volume. Only the number row is measured (18 mm); the other rows come from the cap model
scaled to it (R2 12.0, R3 9.9, R4 12.3, thumbs 12.2 to 14.6 mm).

- Caps collide below 30.8 mm plate to plate; `c2_gap` 31.8 mm, 1.0 mm air. Total height 59.2 mm with the rubber
  feet instead of 67.4 mm (ADR 0015), same envelope. Files `carry2_frame_right/left_choc.stl`, about 60 cm³ each.
- **No cable compartment:** the high cover would leave only about 8 mm of depth, too little for plugs.
- Magnets (same 10 x 1.4 mm, four per frame) sit in the four corners, caps under each boss at most 10.9 mm.
- The frames are lower, so the 45° roof would not reach across the notch; it grows at 49° from vertical
  (`c2_roof_k` 1.15) and closes completely.

## Consequences

- Only the tallest thumb height was measured. If the lower thumbs (19.1 and 17.5 mm in the model) were
  also 20 mm, the caps would need 42.03 mm and just touch.
- The holding force of the magnets is not tested.
- The solid roof wedges make each frame about 78 cm³ (52 cm³ without them).
- The compartments are shallower than the single one of ADR 0015 (16.3 mm instead of 38), so cables lie as
  flat coils; there are two of them.
- Changes to the tray outline, plate or caps change the frames and the magnet positions.

## Images

MX: [closed](../img/case/mx_carry2.png), [exploded](../img/case/mx_carry2_exploded.png),
[section through the number row](../img/case/mx_carry2_section.png).
Choc: [closed](../img/case/choc_carry2.png), [exploded](../img/case/choc_carry2_exploded.png),
[section through the number row](../img/case/choc_carry2_section.png).
