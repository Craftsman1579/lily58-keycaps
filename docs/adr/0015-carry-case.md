# 0015 – Carry case: frames and a middle plate, held by rubber bands

- **Status:** proposed (draft, wall height not yet confirmed)
- **Decided by:** owner (middle plate, the two halves face each other keys inwards, the trays are the
  outside, rubber bands hold it, sized for the DES-Choc caps), derived (geometry)

## Context

An alternative to the sleeve (ADR 0013) for the Choc board: no box around the halves, the trays
themselves are the outer shell. The tray stays unchanged (ADR 0012).

## Decision

- **Stack:** right half keys up – frame – middle plate – frame – left half keys down. Turned over,
  the left half's outline covers the right one exactly, so every part follows the right outline.
- **Frame** (`part="frame"`, `side=right|left`): a ring that rests on the outer 3 mm of the switch
  plate (`cc_rest`; all keycaps lie inside the PCB outline, checked) and in the open controller zone
  on the wall top, one `plate_t` lower. A 1.6 mm skirt reaches 3 mm down round the plate edge
  (0.3 mm gap) and keeps the half from sliding. Height `caps_above + cc_air` (1 mm air). Printed with
  the middle-plate face on the bed; no overhangs. Right frame on the right half, left on the left.
- **Middle plate** (`part="mid"`): 2 mm, an engraved "L" faces the left half.
- **Alignment:** four 2.0 mm holes for 1.75 mm filament pieces as dowels (5 mm deep in the frames,
  through the middle plate). The pattern is asymmetric, so the plate only fits one way round.
- **Rubber bands:** two 8 mm wide, 0.8 mm deep grooves (y 65 and 90) in the frames and the middle
  plate, across the straight left and right edges; the bands run over both tray bottoms.
- **Wall height:** DES-Choc R1 is the tallest cap, 12.8 mm from the skirt. With the skirt estimated
  ~4.6 mm above the plate, `caps_above` = 18 mm for Choc → frame 19 mm, case ~67 mm high with the
  halves (40 mm without). Frames ~48 cm³ each, plate ~32 cm³.
- `part="carry"` renders the stack.

## Measurements

18. Height of the tallest keycap top above the plate top on the Choc board (sets `caps_above`).

## Consequences

- Changes to the tray outline or the plate (ADR 0012) change the frames.
- The controller cover (not designed yet) must stay below the frame or get a recess.
