# 0005 – DES as main profile, KAT as second profile

- **Status:** accepted
- **Decided by:** owner

## Context

The project started with DSA (uniform profile) from keycap_playground. The owner wanted per-row
sculpting, tried KAT (playground), then asked for the DES profile from
pseudoku/PseudoMakeMeKeyCapProfiles with the same preferences, and finally wanted KAT "just as
polished" as DES.

## Decision

- **DES** is the main set (`des-all`), built from `MX_DES_Standard.scad` (rows) and
  `MX_DES_Thumb.scad` (thumbs) through a custom module `des_cap()` (see README "Changes").
  Row mapping (DES names): R1 numbers = keyID 5, R2 top = 2, R3 home = 1, R4 bottom = 0.
- **KAT** is the second set (`kat-all`), built from keycap_playground by parameters only.
  KAT row names run the other way: **R4 numbers, R3 top, R2 home, R1 bottom + thumbs**
  (derived from the tilt of each row's top surface).
- **DES R1 is mounted rotated by 180°:** in the profile the R1 cap tilts backwards (like R4); as the
  number row it must face the user. Only its legends are rotated (ADR 0007).
- DSA modes (`test`, `all`) remain as legacy and are not maintained.
- A side profile of one column of both profiles is in `docs/side_profiles.png`.

## Consequences

- Group/file names follow each profile's row names (R1 means different rows in DES and KAT).
- Any change must be applied to both `kat_key` and `des_key` pipelines.
