# CLAUDE.md – Lily58 keycap generator

Context for new sessions. Read this first, then the ADRs in `docs/adr/` for the *why*.

## Working with the owner

- The owner communicates in **German** – answer in German. Repository texts (README, ADRs, commit
  messages, release notes) are **English**.
- Prints on a Bambu Lab printer with AMS (two filaments), **0.4 mm nozzle**, slices in Bambu Studio.
- Mac with nix-darwin (`~/.config/nix`, separate repo). OpenSCAD comes from there (ADR 0011);
  never touch the work config (`home/work.nix`).
- Repo: `github.com/Craftsman1579/lily58-keycaps` (public, GPL-3.0). Push/release with `gh`
  (needs the keychain → run outside the sandbox).

## Current state (2026-10-30)

- DES sets German + US, tolerance 0.025 – tested, released as **v1.1** (binary STL ZIPs).
- KAT sets German + US rendered at the old default 0.20 (images only). **KAT fit test**
  (`stl/kat_passtest`, tolerances 0.025/0.05/0.075/0.10) is waiting for the owner's print result.

- **DES for Choc v1** (`des-choc-*`, ADR 0014): fit test printed, leg tol 0.025 chosen; German set
  rendered and checked, not yet printed. US set not rendered.

### Open items

1. KAT fit test result → set it as `kat-all` default (like the `des-all` override after `TOL=`),
   render `kat-all` and `LAYOUT=us kat-all`, check them (see below), release **v1.2** with KAT ZIPs,
   update README/ADR 0004.
2. MakerWorld upload planned by the owner; license question open (ADR 0010).
3. DES thumb mirroring is not yet verified on real hands (ADR 0008).
4. Optional: a full blank set as ready-made plates (currently 1 spare cap per row + thumbs + homing).
5. Script comments are still German.

## Commands

```bash
./lily58_keycaps.sh des-all [tol]          # DES German (default tol 0.025)
LAYOUT=us ./lily58_keycaps.sh des-all      # DES US
./lily58_keycaps.sh des-test ["t1 t2 …"]   # DES fit test (default 0.00 0.025 0.05 0.075)
./lily58_keycaps.sh des-choc-all [tol]     # DES for Choc v1, MX spacing (default leg tol 0.025)
./lily58_keycaps.sh des-choc-test ["t1 …"] # Choc fit test
./lily58_keycaps.sh kat-all [tol]          # KAT German (default tol 0.20, to be replaced)
LAYOUT=us ./lily58_keycaps.sh kat-all      # KAT US
./lily58_keycaps.sh kat-test ["t1 t2 …"]   # KAT fit test (default 0.025 0.05 0.075 0.10)
```

`test` and `all` are legacy DSA modes (no flat sides, old support) – not maintained.
Output: `~/Documents/lily58_keycaps/stl/<mode folder>/` = `<Group>_body.stl` + `<Group>_legends.stl`,
intermediates in `raw/` (upright 3MF per key + `<Group>.lst`). A full run takes ~2–3 min.

## How the script works

1. Downloads keycap_playground / PseudoMakeMeKeyCapProfiles into this folder (gitignored), unpacks
   the DES `libraries.zip` to `des_libs/` (`OPENSCADPATH`).
2. Writes OpenSCAD helpers into `jobs/` via heredocs: `lily58_base.scad` (playground base config),
   `flatlib.scad` (KAT flat cut), `desflat.scad` (DES flat cut + `print_pose`), `deslib.scad`
   (`des_cap()`), `des_Standard.scad`/`des_Thumb.scad` (profile copies without their `keycap()` call),
   `stemsupport.scad` (removable support), `symbols.ttf` (copied font).
3. Per key (`kat_key` / `des_key`): writes `jobs/<name>.scad`, renders the **upright** body and legend
   to `raw/*.3mf`, appends a line to `raw/<Group>.lst` (chord, height, kind).
4. Group pass: per key `translate(offset) pose { intersection(body, flat_cut) ; stem_support }` →
   `<Group>_body.stl`; legends → `<Group>_legends.stl`.

Key lists: `<Group> [<row>] <kind>:<value>[:<units>] …` (KAT) / `<Group> <shape>:<kind>:<value>` (DES).
Kinds: `t` text, `h` text + homing, `s` symbol (decimal code point), `b` blank, `d` blank + homing.
Per-shape constants (chords, heights, stem heights, `top_y`, mirroring, legend rotation) live in
`kat_row` and `des_shape`; they were measured, not guessed (ADR 0001).

## Verification checklist (after every geometry change)

Tools are in `tools/` (Python 3, no extra packages):

| Check | Command |
|---|---|
| Slicer import (float32), must be 0 non-manifold edges | `python3 tools/f32.py <file.stl> <label>` |
| Group: caps = supports, support on bed, min. clearance ≥ 0.2 mm | `python3 tools/grpsup.py <Group_body.stl> <label>` |
| Indexed 3MF mesh check | `python3 tools/check3mf.py <file.3mf>` |
| Cross hole / stem size (section of an upright cap) | `python3 tools/cross.py <upright.stl> <z> <label>` |
| Side chord of an upright cap (for flat cut / angle) | `python3 tools/chord2.py <upright.stl> <label> R\|L` |
| Bodies / voids in a mesh | `python3 tools/shells.py <file.stl> <label>` |
| Wall thickness over the flat face | `python3 tools/thick.py <posed.stl> <label>` |
| Legend centering (rough; confirm visually) | `python3 tools/legcenter3.py des\|kat <raw dir> <jobs dir>` |

`supcheck.py` checks a single support against its cap; `destops.dat` holds DES top poses for
`legcenter3.py`. To convert OpenSCAD's STL output to `.stl` files for an upright check, wrap the
3MF: `import("raw/<key>_body.3mf");` and export with OpenSCAD.

## Images (`docs/`)

- Flattened upright caps per key: `intersection() { import(raw/<key>_body.3mf); flat_cut(...); }`
  (KAT: `flat_cut(xb, xt, zt)` from `flatlib.scad`; DES: `flat_cut(R, L)` from `desflat.scad`,
  values from the `.lst` files) → STL folder.
- `python3 tools/scene.py des|kat <caps dir> <raw dir> <out dir>` writes `set_labels.scad`,
  `set_blank.scad`, `closeup.scad` (Lily58 arrangement, DES R1 rotated 180°, KAT 1.5u rotated 90°).
- Render (preview mode keeps colors):
  sets `openscad -o x.png --imgsize=2000,1000 --camera=150,-235,447,150,30,0 --colorscheme=Tomorrow`,
  close-up `--imgsize=2000,800 --camera=46,-80,113,46,2,4` (KAT centre x=50),
  side profile orthographic `--camera=-160,-27,10,0,-27,10 --projection=o`.
- Photos: `python3 tools/jpegmeta.py strip in.jpg out.jpg` (removes EXIF/GPS and motion-photo video),
  resize with `sips -Z 1600`, then `jpegmeta.py check`.

## Release

1. `python3 tools/stl2bin.py in.stl out.stl` for every group STL (binary, ~5× smaller).
2. Folder `lily58-keycaps-<PROFILE>[-US]-tol<t>/` with the STLs, README.md, LICENSE, `docs/`; zip it.
3. `gh release create vX.Y <zips> --title … --notes-file …` (outside the sandbox).

## Gotchas

- The shell is **zsh**: unquoted variables are not word-split; use bash (`bash -c`) for scripts that
  rely on splitting, and quote `$var:t`-like expansions (`${var}`).
- Don't edit `lily58_keycaps.sh` while it is running. `kat-*` and `des-*` share job file names –
  run modes sequentially.
- Patching the script: write a Python patch file and run it; the command-safety check rejects
  commands that contain `rm` with variable paths, even inside heredocs.
- OpenSCAD needs `--enable=textmetrics` (the script adds it); scad-utils warnings are harmless.
- `hull(cap) − cap` also contains thin shells outside concave DES walls, the dish, and enclosed voids
  – the support code masks these (ADR 0002).
- KAT rows are named R4 (numbers) … R1 (bottom); DES rows R1 (numbers) … R4 (bottom).
