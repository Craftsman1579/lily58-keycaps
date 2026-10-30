# 0011 – Toolchain: OpenSCAD snapshot via Nix, single bash script

- **Status:** accepted
- **Decided by:** owner (Nix, keep work config untouched), derived (versions and flags)

## Decision

- **OpenSCAD** comes from the owner's nix-darwin config (`~/.config/nix`, separate repo
  `Craftsman1579/nix-config`): `pkgsUnstable.openscad-unstable` in `home/alex-darwin.nix`, plus an
  `openscad` symlink (the binary is called `openscad-unstable`). The **work config (`home/work.nix`)
  must stay untouched**. Applied with `sudo darwin-rebuild switch --flake ~/.config/nix#my-macbook`
  (the owner types the sudo password).
- Snapshot because it has the **Manifold backend** (fast, ~1 s per cap) and **`textmetrics`**
  (legend centering). The stable 2021.01 build has neither.
- **One script** (`lily58_keycaps.sh`, bash) does everything: downloads templates
  (`git clone`/`pull`), unpacks the DES `libraries.zip` into `des_libs/` (`OPENSCADPATH`), writes the
  OpenSCAD helper files into `jobs/` via heredocs, renders per key, assembles groups.
- Output under `~/Documents/lily58_keycaps/stl/` (`KEYCAP_DIR` overrides the base folder).

## Consequences

- Old scad-utils emits many harmless warnings (`-undefined`, `len()`); renders still succeed.
- `kat-*` and `des-*` write job files with the same names into `jobs/`; run modes one after another.
- Do not edit the script while a render is running (bash reads it incrementally).
