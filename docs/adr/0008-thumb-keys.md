# 0008 – Thumb keys: 1.5u Space/Enter, DES high profile, mirroring

- **Status:** accepted
- **Decided by:** owner (1.5u, high profile, assignment), derived (mirroring side)

## Decision

- **Space and Enter are 1.5u** (innermost thumb key of the Lily58 Pro, which takes 1u or 1.5u);
  the original script's 2u was wrong for the Lily58. The other thumb keys are 1u.
- **KAT:** thumbs use row R1; the 1.5u cap is a normal horizontal 1.5u key (the Lily58 switch is
  rotated, so it sits upright and its symbol appears sideways). Printed on its short flat side.
- **DES:** `MX_DES_Thumb.scad`, **high profile**. Order from inner to outer:
  **1.5u (ID 0) – 1u (ID 1) – 1u (ID 1) – 1u angled (ID 2)**.
- DES thumb caps are tilted towards the thumb and asymmetric. Following the repository's own
  placement, unmirrored IDs 1/2 belong to the right half and ID 0 the other way round
  (`T15L`=ID0 mir0, `T15R`=ID0 mir1, `T1L/T2L` mirrored, `T1R/T2R` unmirrored). **Not yet verified
  on the owner's hands**; swap the `mir` flags in `des_shape` if they feel wrong.

## Consequences

- Asymmetric caps need separate left/right chords (ADR 0001).
- Thumb groups: `Daumen_links` (outer → inner: Alt GUI Lower Space), `Daumen_rechts`
  (inner → outer: Enter Raise Backspace GUI), `Daumen_leer` (all 8 blank).
