# 0013 – Travel case: a sleeve with two chambers

- **Status:** proposed (draft, keycap height still to measure)
- **Decided by:** owner (tray must stay unchanged, two chambers to slide the halves into, Bambu
  printer with 256 mm bed, nothing else inside), derived (geometry)

## Context

The case from ADR 0012 should travel without changes to the tray. A first draft (snap-on lids with
a groove in the tray wall and magnets in the floor) was dropped because it changed the tray. A box
with both halves side by side would be ~320 mm long and not fit a 256 mm bed in one piece.

## Decision

- **Sleeve** (`part="sleeve"`): a box open at the front with two chambers stacked on top of each
  other. Each half slides in keys up, top (USB) edge first, sitting on its rubber feet. Chamber =
  bounding box of the tray + 0.5 mm around, height = feet + tray + tallest keycap
  (`caps_above`, from the plate top) + 1.2 mm. Walls and divider 2 mm.
- **Holding:** a 0.8 mm rounded ridge across each chamber floor near the opening; the front rubber
  feet climb over it and drop in behind. The 1.2 mm air above the keycaps lets the half lift that
  far. No parts on the tray.
- **Grip:** rounded finger notches (30 × 20 mm) in both side walls at the opening of each chamber.
- **Print:** back wall on the bed, opening up – the divider and side walls are vertical, no
  support. Outside ≈ 157 × 119 × 90 mm (with 24 mm keycap height), ~175 cm³ of filament.
- `part="travel"` renders the sleeve with both halves inside.

## Measurements

15. Height of the tallest keycap top above the plate top (switch + cap), on the real keyboard.

## Consequences

- Changes to tray height or outline (ADR 0012) change the chambers; reprint the sleeve then.
- If the ridge holds too weakly or too firmly, change `detent_h`.
