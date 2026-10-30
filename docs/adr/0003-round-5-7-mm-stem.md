# 0003 – Round 5.7 mm stem

- **Status:** accepted
- **Decided by:** owner (round, ~5.7 mm), derived (implementation and verification)

## Context

The first printed test caps used keycap_playground's square `box_cherry` stem (5.37 mm). They did
not fit the owner's Gateron switches: the stem's corners (≈ 7 mm across the diagonal) hit the
rectangular opening of the switch housing. DES originally uses a round 5.5 mm stem.

## Decision

- Round stem with an outer diameter of **5.7 mm** in all profiles.
  - KAT/DSA: `STEM_TYPE = "round_cherry"`, `STEM_OUTSIDE_TOLERANCE_X = -0.23`
    (diameter = 5.47 − tolerance).
  - DES: `cylinder(d=5.7)` in `des_cap()` instead of 5.5.
- The cross hole is unchanged in size by this decision (tolerance see ADR 0004).
- KAT rows R4/R5 need a taller `STEM_HEIGHT` (4.5 / 5.5): the playground's round stem only reaches
  `1 + 2·STEM_HEIGHT` mm high and otherwise floats below the top. The cross depth stays 4 mm.

## Consequences

- Fits Cherry- and Gateron-style housings.
- More wall at the cross arm tips (≈ 0.75 mm vs 0.6 mm with the box stem), where caps usually crack.
- Printed sideways the round stem can become slightly oval; if one direction binds, reduce the
  diameter rather than the cross tolerance.
