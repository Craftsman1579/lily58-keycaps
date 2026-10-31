# 0013 – Travel case: a snap-on lid per half, halves held back to back by magnets

- **Status:** proposed (draft, keycap height and magnets still to measure)
- **Decided by:** owner (lid per half, nothing else inside, Bambu printer with 256 mm bed), derived
  (geometry)

## Context

The case from ADR 0012 should travel without a separate box. A box with both halves side by side
would be ~320 mm long and does not fit a 256 mm bed in one piece; a stacked box needs extra walls
around parts that already have walls.

## Decision

- **Lid per half** (`part="lid"`, right and left): a shell that slides 8 mm down over the tray wall
  (gap 0.2 mm, wall 2 mm, top 2 mm). Its ceiling clears the tallest keycap by 1.5 mm
  (`caps_above`, measured from the plate top). It covers the USB/TRRS slots (cables are unplugged
  for travel). Printed top down.
- **Snap:** a 0.5 × 1.6 mm groove runs around the tray wall 4 mm below its top; three short ribs
  (20 mm, 0.35 mm high) on the lid skirt sit on straight PCB edges (top, bottom, outer) where the
  skirt can flex, and click into it. `part="lid_test"` prints the real wall and skirt around one rib
  to tune `rib_h`/`lid_gap` before printing whole lids.
- **Magnets:** four pockets from below in each tray floor; the left half's positions are mirrored,
  so they line up when the halves lie bottom to bottom. The rubber feet also meet foot on foot, so
  the magnets are 4 mm apart – strong magnets (N52) are needed; insert them with opposite poles.
- Closed package ≈ 156 × 120 × 91 mm (with 24 mm keycap height).
- `part="travel"` renders the stacked package for checking.

## Measurements

15. Height of the tallest keycap top above the plate top (switch + cap), on the real keyboard.
16. Magnets on hand: diameter and height.

## Consequences

- Lids use about 66 cm³ of filament each; PETG is tougher than PLA for the snap.
- Changing tray height or wall (ADR 0012) moves the lid with it; reprint lids after such changes.
