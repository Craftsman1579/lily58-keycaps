# 0015 – Carry case: frames and a middle plate, held by rubber bands

- **Status:** proposed (draft, not printed)
- **Decided by:** owner (middle plate, the two halves face each other keys inwards, the trays are the
  outside, rubber bands hold it, keycaps up to 23.5 mm above the plate so that both boards fit), derived (geometry)

## Context

An alternative to the sleeve (ADR 0013), for both boards (MX and Choc): no box around the halves, the trays
themselves are the outer shell. The tray stays unchanged (ADR 0012).

## Decision

- **Stack:** right half keys up – frame – middle plate – frame – left half keys down. Turned over,
  the left half's outline covers the right one exactly, so every part follows the right outline.
- **Frame** (`part="frame"`, `side=right|left`): a ring that rests on the outer 3 mm of the switch
  plate (`cc_rest`; all keycaps lie inside the PCB outline, checked) and in the open controller zone
  on the wall top, `cc_step` = 1.5 mm lower (the MX plate). On the Choc board (1.9 mm plate) that
  step stays 0.4 mm clear, so the same frame rests on the plate of either board. A 1.6 mm skirt reaches 3 mm down round the plate edge
  (0.3 mm gap) and keeps the half from sliding. Height `cc_caps + cc_air` = 23.5 + 1 mm. Printed with
  the middle-plate face on the bed; no overhangs. Right frame on the right half, left on the left.
- **Middle plate** (`part="mid"`): 2 mm, an engraved "L" faces the left half.
- **Alignment:** four 2.0 mm holes for 1.75 mm filament pieces as dowels (5 mm deep in the frames,
  through the middle plate). The pattern is asymmetric, so the plate only fits one way round.
- **Rubber bands:** two 8 mm wide, 0.8 mm deep grooves (y 65 and 90) in the frames and the middle
  plate, across the straight left and right edges; the bands run over both tray bottoms.
- **Wall height:** the owner set the tallest keycap to 23.5 mm above the plate top (`cc_caps`, 23 was
  too tight) so the MX board fits as well. For reference: DES R1 is 16.7 mm tall from the skirt (MX),
  12.8 mm (Choc). Frame 24.5 mm; case ~78 mm high with the Choc halves, ~85 mm with the MX halves
  (51 mm without). Frames ~60 cm³ each, plate ~32 cm³.
- `part="carry"` renders the stack.

## Measurements

18. Tallest keycap top above the plate top on both boards; must stay below 24.5 mm (`cc_caps` + air).

## Consequences

- Changes to the tray outline or the plate (ADR 0012) change the frames.
- The controller cover (not designed yet) must stay below the frame or get a recess.

## Images

Choc halves with the DES-Choc caps (cap height above the plate estimated):
[closed](../case_carry_view.png), [exploded](../case_carry_explode.png),
[section through the number row](../case_carry_section.png).
