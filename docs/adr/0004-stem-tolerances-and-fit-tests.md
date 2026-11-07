# 0004 – Stem tolerances per profile, verified by fit tests

- **Status:** accepted
- **Decided by:** owner (nozzle, tested values), derived (test series)

## Context

The owner first printed with a 0.2 mm nozzle (KAT/DSA test caps: tolerance 0.10 fit best), then
switched to a **0.4 mm nozzle**. A DES cap at 0.10 was too loose. The two templates apply the
tolerance differently:

- **DES** adds it to every half-dimension of the cross (`MXWid/MXLen…+Tol`): slots
  `1.15 + 2t` (horizontal arm) and `1.25 + 2t` (vertical arm), lengths `4.03 + 2t` / `4.23 + 2t`.
- **KAT** (`cherry_cross`): horizontal arm `1.3 + t`, vertical arm `1.1 + 2t`, lengths `4 + t`,
  `4 + t/4`. Its nominal cross is also oriented differently (thicker horizontal arm).

## Decision

- **DES: 0.025** – tested with the 0.4 mm nozzle, "works perfectly" (slots 1.20 × 1.30 mm,
  lengths 4.08 / 4.28 mm). Default of `des-all`.
- **KAT: 0.025** – chosen by the owner after the fit test `kat-test` (0.025 / 0.05 / 0.075 / 0.10;
  at 0.05 the narrower slot would equal the DES fit, but KAT's cross arms are shorter, ≈ 4.0 mm, so
  the range went up to 0.10). Default of `kat-all` since 2026-11-07 (v1.2); before, the sets were
  rendered at the old global default 0.20 for images only.
- Fit tests: `des-test` / `kat-test` render one blank home-row cap per tolerance with flat sides and
  the support insert, one file per tolerance (`Passtest_tol_<t>_body.stl`).
- The global default (`TOL="${2:-0.20}"`, legacy DSA modes) is overridden for `des-all`,
  `des-choc-all` and `kat-all` when no tolerance is given.

## Consequences

- Tolerance values are not interchangeable between profiles; README says so.
- Measure cross slots with `tools/cross.py` (section at z = 2.5–3 mm of the upright cap).
