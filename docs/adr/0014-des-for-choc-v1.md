# 0014 – DES caps for Choc v1 switches

- **Status:** accepted (fit test printed; full set not yet printed)
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
- **Legs:** `choc_stem()` from `Choc_Chicago_Steno.scad`: 5.7 mm apart, 1.2 × 3.0 mm, waisted by two
  d 7 circles, z −1.1 … 2.0 (1.1 mm below the skirt). A round bridge (d 8, clipped to the outer
  shell) connects them to the top. `legTol` narrows each leg per side.
- **Tolerance 0.025** (leg 1.15 mm): in the fit test (0.00 / 0.05 / 0.10 / 0.15) both 0.00 and
  0.05 fit well; the owner measured that 1.2 mm goes into the switch and asked for at least 1.15 mm.
- **Print orientation:** the cap is rotated by 90° (`rotate(90)` in the job file) and printed on its
  **front** face, not on a side wall as with MX (ADR 0001). On a side wall the two legs would lie on
  top of each other and the upper one would need support in the narrow gap between them. On the
  front they stand side by side, and the leg width lies in the XY plane. Front/back chords are
  measured per shape (`des_choc_shape`); mirrored thumbs share them.
- **Support** (`choc_support`, like ADR 0002): a 7.2 mm wide plate under both leg ends and the
  bridge, ~0.2 mm clearance, pulled out through the opening. `flat_cut_legs` keeps the legs that
  stick out below the skirt (the normal flat cut starts at z = 0.02).

## Consequences

- MX output is unchanged (`des_cap(choc=false)` takes the old code paths).
- The 1.5u thumb stands 27 mm tall on its 17 mm front face.
- Not yet printed: the full set, the taller rows (R1 at 11 mm) and the thumbs.
