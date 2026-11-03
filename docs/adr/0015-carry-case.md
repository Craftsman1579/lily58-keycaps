# 0015 – Carry case: frames and a middle plate, held by rubber bands

- **Status:** proposed (draft, not printed)
- **Decided by:** owner (middle plate, the two halves face each other keys inwards, the trays are the
  outside, rubber bands hold it, measured keycap height above the plate: MX 23.2 mm, Choc 18 mm), derived (geometry)

## Context

An alternative to the sleeve (ADR 0013), for both boards (MX and Choc): no box around the halves, the trays
themselves are the outer shell. The tray stays unchanged (ADR 0012).

## Decision

- **Stack:** right half keys up – frame – middle plate – frame – left half keys down. Turned over,
  the left half's outline covers the right one exactly, so every part follows the right outline.
- **Frame** (`part="frame"`, `side=right|left`): a ring that rests on the outer 3 mm of the switch
  plate (`cc_rest`; all keycaps lie inside the PCB outline, checked). Over the controller cover
  (ADR 0012) it is open inside the skirt, `cc_cover` = 7.8 mm deep: the cover stands 7.3 mm above
  the plate on the Choc board (4.2 on MX), + 0.5 mm, so it fits with or without the cover. A 1.6 mm
  skirt reaches 3 mm down round the plate edge (0.3 mm gap) and keeps the half from sliding. Height `cc_caps + cc_air` (MX 23.2 + 1 = 24.2 mm,
  Choc 18 + 1 = 19 mm), so each board has its own pair of frames (`carry_frame_right/left.stl`,
  `carry_frame_right/left_choc.stl`). Printed with the middle-plate face on the bed; no overhangs.
  Right frame on the right half, left on the left.
- **Middle plate** (`part="mid"`): 2 mm, an engraved "L" faces the left half. Same for both boards.
- **Alignment:** four 2.0 mm holes for 1.75 mm filament pieces as dowels (5 mm deep in the frames,
  through the middle plate). The pattern is asymmetric, so the plate only fits one way round.
- **Rubber bands:** two 8 mm wide, 0.8 mm deep grooves (y 65 and 90) in the frames and the middle
  plate, across the straight left and right edges; the bands run over both tray bottoms.
- **Wall height per board:** the owner measured the tallest keycap top above the plate top: MX 23.2 mm,
  Choc 18 mm (`cc_caps`, chosen by `switch_type`); `cc_air` = 1 mm buffer above it. An earlier
  common value of 23.5 mm for both boards left the Choc halves 5.5 mm of play. Frames 24.2 mm (MX) and
  19 mm (Choc), plus the 3 mm skirt; case ~84 mm high with the MX halves (50 mm without), ~67 mm with
  the Choc halves (40 mm without). Frames ~58 cm³ (MX) / ~45 cm³ (Choc) each, plate ~32 cm³.
- `part="carry"` renders the stack.

## Measurements

18. Tallest keycap top above the plate top: MX 23.2 mm, Choc 18 mm (owner, measured).

## Consequences

- Changes to the tray outline or the plate (ADR 0012) change the frames.
- A taller controller cover needs a deeper `cc_cover`.

## Images

Both boards, each with its own frames and blank DES / DES-Choc caps (cap height in the scene estimated):
[Choc closed](../img/case/choc_carry.png), [Choc exploded](../img/case/choc_carry_exploded.png),
[Choc section through the number row](../img/case/choc_carry_section.png), and the same for MX
(`docs/img/case/mx_carry*.png`). Rendered by `render/case.sh` (scene: `render/case_scene.scad`).
