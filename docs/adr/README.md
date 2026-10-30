# Architecture Decision Records

Decisions behind the keycap generator, in the order they were made (October 2026). Each record
states who decided: **owner** = the repository owner's choice, **derived** = worked out during
development (usually after measuring or testing), with the owner's approval.

| # | Decision | Status |
|---|---|---|
| [0001](0001-print-sideways-with-flat-sides.md) | Print caps sideways with flattened side walls | accepted |
| [0002](0002-removable-support-insert.md) | Removable support insert standing on the bed | accepted |
| [0003](0003-round-5-7-mm-stem.md) | Round 5.7 mm stem | accepted |
| [0004](0004-stem-tolerances-and-fit-tests.md) | Stem tolerances per profile, verified by fit tests | accepted (KAT value pending) |
| [0005](0005-profiles-des-and-kat.md) | DES as main profile, KAT as second profile | accepted |
| [0006](0006-layouts.md) | German layout without special characters, US layout | accepted |
| [0007](0007-legends.md) | Multi-color legends: symbols, centering, orientation | accepted |
| [0008](0008-thumb-keys.md) | Thumb keys: 1.5u Space/Enter, DES high profile, mirroring | accepted |
| [0009](0009-slicer-clean-meshes.md) | Meshes must survive slicer import without errors | accepted |
| [0010](0010-publishing-and-licensing.md) | Publishing: public GitHub repo, GPL-3.0, release ZIPs | accepted |
| [0011](0011-toolchain.md) | Toolchain: OpenSCAD snapshot via Nix, single bash script | accepted |
