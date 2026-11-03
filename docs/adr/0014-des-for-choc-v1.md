# 0014 – DES caps for Choc v1 switches

- **Status:** accepted (fit test and first full set printed; leg length and 1.5u thumb legs corrected, not yet reprinted)
- **Decided by:** owner (second Lily58 with Choc v1 switches at MX spacing 19.05 mm, leg fit from the
  test print), derived (geometry, print orientation)

## Context

The owner has a second Lily58 with Kailh Choc v1 switches, spaced like MX (19.05 mm). pseudoku's
repository only has DES with an MX stem; its Choc files are Chicago Steno. Choc v1 caps clip onto the
switch with two legs instead of a cross.

## Decision

- **Modes** `des-choc-all` and `des-choc-test`, sharing the DES code path (`CHOC=1`). Output in
  `stl/des_choc_set[_us]_tol_<t>/` and `stl/des_choc_passtest/`.
- **Profile:** the DES profiles with every key height (`keyh`, column 5 of `keyParameters`) lowered
  by 4 mm (home row 8.75 → 4.75 mm, number row 15 → 11 mm). The row-to-row sculpt and the dishes stay
  as in the original. The footprint stays 17.16 mm, which fits MX spacing.
- **Legs:** `choc_stem()` from `Choc_Chicago_Steno.scad`: 5.7 mm apart, 1.05 mm wide, waisted by two
  d 7 circles, z −1.1 … 2.0 (1.1 mm below the skirt). A round bridge (d 8, clipped to the outer
  shell) connects them to the top. `legTol` narrows each leg per side (width 1.0 mm at 0.025).
  **Length 2.9 mm**, fixed (independent of `legTol`): the original 3.15 (3.1 after the tolerance)
  was too long in the printed set (owner).
- **Tolerance 0.025:** in the fit test (0.00 / 0.05 / 0.10 / 0.15) both 0.00 and 0.05 fit well.
- **Print orientation:** the cap is rotated by 90° (`rotate(90)` in the job file) and printed on its
  **front** face, not on a side wall as with MX (ADR 0001). On a side wall the two legs would lie on
  top of each other and the upper one would need support in the narrow gap between them. On the
  front they stand side by side, and the leg width lies in the XY plane. Front/back chords are
  measured per shape (`des_choc_shape`);
  mirrored 1u thumbs share them.
- **1.5u thumb:** on the owner's board its switch is turned by 90° relative to the cap, so the legs
  are rotated by 90° inside the cap (`legRot=90`). The cap itself is not rotated and is printed on
  its side wall like MX; that way the legs again stand side by side in print and use the same
  support. Side chords measured (swapped for the mirrored cap), length 26.66 mm. The 1u thumbs were
  briefly rotated the same way by mistake; their switches sit like the rows, so they are handled
  like the rows again.
- **Support** (`choc_support`, like ADR 0002): a 7.2 mm wide plate under both leg ends and the
  bridge, ~0.2 mm clearance, pulled out through the opening. `flat_cut_legs` keeps the legs that
  stick out below the skirt (the normal flat cut starts at z = 0.02).

## Consequences

- MX output is unchanged (`des_cap(choc=false)` takes the old code paths).
- Not yet printed: the full set, the taller rows (R1 at 11 mm) and the thumbs.
