# CLAUDE.md – Lily58 keycap generator and case

Context for new sessions. Read this first, then the ADRs in `docs/adr/` for the *why*.

## Working with the owner

- The owner communicates in **German** – answer in German. Repository texts (README, ADRs, commit
  messages, release notes) are **English**.
- Prints on a Bambu Lab printer with AMS (two filaments), **0.4 mm nozzle**, slices in Bambu Studio.
- Mac with nix-darwin (`~/.config/nix`, separate repo). OpenSCAD comes from there (ADR 0011);
  never touch the work config (`home/work.nix`).
- Repo: `github.com/Craftsman1579/lily58-keycaps` (public, GPL-3.0). Push/release with `gh`
  (needs the keychain → run outside the sandbox).

## Current state (2026-11-07)

- Everything is on `main` (keycaps, DES-Choc, case). Docs: `README.md` in parts marked
  `<!-- part: docs/<name>.md -->` (keycaps, case, travel, rendering, templates, credits), meant to be
  split into separate documents later; images in `docs/img/{keycaps,case,photos}/`.

- **v1.2** (binary STL ZIPs): DES, DES-Choc and KAT, each German + US, all tolerance 0.025 (KAT
  0.025 chosen by the owner, now the `kat-all` default). v1.2 also fixes a step across the middle of
  the DES dish (front dish half was offset in global y; now along its own path, ADR 0009) that
  printed as a left-right ridge on R1/R2/R4. Fix confirmed by a test print (R1, 2026-11-07).
- `stl/` holds only the current sets, `case/` and the `render/` caches; old tolerance sets and fit
  tests were removed (regenerate with the commands below).

- **DES for Choc v1** (`des-choc-*`, ADR 0014): fit test printed, leg tol 0.025 chosen; first full
  set printed: legs shortened to 2.9 mm, 1.5u thumb legs rotated 90° (printed on the side; the 1u thumbs
  stay like the rows). Re-rendered (2026-11-03), not yet reprinted.

### Open items

1. MakerWorld upload planned by the owner; license question open (ADR 0010).
2. DES thumb mirroring is not yet verified on real hands (ADR 0008).
3. Optional: a full blank set as ready-made plates (currently 1 spare cap per row + thumbs + homing).
4. Script comments are still German.
5. **Case** (ADR 0012): draft v6 tray + plate for the owner's PandaKB
   Lily58 RGB MX (no OLED), as flat as possible. M2 hex standoffs in the tray bosses (MX 10 mm,
   Choc 6 mm), M2x4 from below and from the top; the plate covers the wall and snaps into a
   groove (tune with `part="snap_test"`). Controller cover clicks into the same groove, M2x12 into
   heat-set inserts in the tray rings (cover holes measured, MEASURE 19).
   Two folding tenting feet per half in pockets in the bottom, flush with the rubber feet.
   Switch cutout 13.8 mm, confirmed by the plate fit test.
6. **Travel sleeve** (ADR 0013): box with two chambers, halves slide in keys up, tray unchanged.
   Waiting for the keycap height above the plate (`MEASURE 15`).
7. **Carry case** (ADR 0015, both boards): halves keys facing each other, a frame on each, rubber
   bands round it. `cc_caps` per board (owner, measured): MX 23.2 mm, Choc 18 mm. Choc: 1 mm `cc_air`,
   middle plate (`carry_mid.stl`), own frames (`carry_frame_*_choc.stl`). MX: compact, no middle plate,
   0.5 mm `cc_air`, 81 mm high, cable compartment 31.1 x 54 x 38 mm over the controller covers.
   Not printed; cable dimensions not measured yet.
8. **Compact carry case** (ADR 0016, both boards; Choc: 59.2 mm, no compartment, row heights from the model
   except R1, `carry2_frame_*_choc.stl`). MX: left half turned over the long axis, 75.6 mm high, `part="frame2"`,
   four 10 x 1.4 mm magnets per frame instead of bands, two 16.3 mm deep compartments. Row heights measured
   (R1 23.2, R2 17.4, R3 15.7, R4 17.7, thumbs 20 mm). Not printed.

## Commands

```bash
./lily58_keycaps.sh des-all [tol]          # DES German (default tol 0.025)
LAYOUT=us ./lily58_keycaps.sh des-all      # DES US
./lily58_keycaps.sh des-test ["t1 t2 …"]   # DES fit test (default 0.00 0.025 0.05 0.075)
./lily58_keycaps.sh des-choc-all [tol]     # DES for Choc v1, MX spacing (default leg tol 0.025)
./lily58_keycaps.sh des-choc-test ["t1 …"] # Choc fit test
./lily58_keycaps.sh kat-all [tol]          # KAT German (default tol 0.025)
LAYOUT=us ./lily58_keycaps.sh kat-all      # KAT US
./lily58_keycaps.sh kat-test ["t1 t2 …"]   # KAT fit test (default 0.025 0.05 0.075 0.10)
```

Case (ADR 0012):

```bash
case/build.sh [-D name=value …]             # trays + plates L/R, sleeve, snap/plate tests, template → stl/case/
python3 tools/kicad2scad.py <Lily58_Pro.kicad_pcb> common/lily58_layout.scad   # regenerate layout
```

The KiCad file comes from `github.com/kata0510/Lily58` (`Pro/PCB/`, MIT); it is not cloned by any
script. `case/lily58_case.scad` takes `part=tray|plate|cover|sleeve|frame|mid|snap_test|plate_test|template|assembly|travel|carry`, `side=right|left`.

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

## Images (`docs/img/`)

All renders come from `render/` (output names and sources: README part "Images and rendering"):

```bash
render/render_all.sh                    # everything, ~10 min
render/keycaps.sh [des des-us des-choc des-choc-us kat kat-us]   # docs/img/keycaps/
render/case.sh [mx|choc] [-- -D …]      # docs/img/case/ (exports parts to stl/render/case/<board>/)
```

- Keycaps: `render/flat.scad` cuts each raw upright cap flat (same cuts as the group pass) into
  `stl/render/keycaps/<variant>/caps/` (cached, parallel); `tools/scene.py des|des-choc|kat` writes the
  scenes (Lily58 arrangement, DES R1 rotated 180°, KAT 1.5u rotated 90°, DES-Choc raw caps turned
  back by −90°); `render/side_profiles.scad` shows one column per profile. Needs the six sets in
  `stl/` (KAT: `KAT_TOL`, default 0.025).
- Case: `render/case_scene.scad` (`VIEW=assembled|exploded|section|cover|bottom|carry|carry_exploded|
  carry_section|travel`, `switch_type=mx|choc`) with the blank caps of the DES / DES-Choc set. Cap
  height above the plate: MX from the owner's measurements (`row_dz`), Choc scaled to the measured 18 mm. Switches in the
  scenes are schematic (no check uses them).
- After a geometry change of the case or a keycap set, rerun the matching script and check the images.
- Photos: `python3 tools/jpegmeta.py strip in.jpg out.jpg` (removes EXIF/GPS and motion-photo video),
  resize with `sips -Z 1600`, then `jpegmeta.py check`; put them in `docs/img/photos/`.

## Release

1. `python3 tools/stl2bin.py in.stl out.stl` for every group STL (binary, ~5× smaller).
2. Folder `lily58-keycaps-<PROFILE>[-US]-tol<t>/` with the STLs, README.md, LICENSE, `docs/img/`; zip it.
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
