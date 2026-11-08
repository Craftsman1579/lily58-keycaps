# Lily58 keycaps and case

Printable parts for the [Lily58](https://github.com/kata0510/Lily58) split keyboard, generated from
parametric OpenSCAD sources and optimized for FDM printing:

- **Keycaps** in two sculpted profiles, **DES** and **KAT**, each with a German layout (QWERTZ letters
  with US punctuation) or a US layout (QWERTY with punctuation), symbols for the modifier keys and
  multi-color legends. DES also exists for **Choc v1** switches at MX spacing.
- **A case** for MX boards (PandaKB Lily58 RGB MX) and Choc v1 boards: a tray with a snap-in switch
  plate, a controller cover, rubber feet and pockets for folding tenting feet. Plus a travel sleeve
  and a carry case.

Finished keycap STLs are attached as ZIPs to the [latest release](../../releases/latest). The case is
a draft and not released yet.

| Variant | Switches | Layouts | Status |
|---|---|---|---|
| DES keycaps | MX | German, US | printed, released (v1.2) |
| DES keycaps | Choc v1 (MX spacing) | German, US | first set printed, corrected set released (v1.2) |
| KAT keycaps | MX | German, US | released (v1.2), tolerance 0.025 |
| Case (tray, plate, cover) | MX and Choc v1 | – | draft, plate fit test printed |
| Travel sleeve | MX | – | draft |
| Carry case | MX (with cable compartment) and Choc v1 | – | draft |

**Contents:** [Keycaps](#keycaps) · [Case](#case) · [Travel sleeve and carry case](#travel-sleeve-and-carry-case)
· [Images and rendering](#images-and-rendering) · [Changes to the templates](#changes-to-the-templates)
· [Credits and licenses](#credits-and-licenses)

Design decisions and their reasons are recorded in [docs/adr/](docs/adr/README.md).

<!--
  Structure: each top-level section below (marked "part: <file>") stands on its own and can be moved
  into a document of that name. Images live in docs/img/<part>/; links are relative to the repository
  root, so a moved part only needs the prefix "docs/" removed from its image links.
-->

<!-- part: docs/keycaps.md -->
## Keycaps

### Profiles

![Side profile of one column (2 W S X) in DES (MX), DES (Choc) and KAT; the user sits on the right](docs/img/keycaps/side_profiles.png)

*Side view of one column as it sits on the keyboard (number row on the left, user on the right).*

- **DES** (Distorted Elliptical Saddle): strongly sculpted. The number row is tall and tilted
  towards the user, the home row is the lowest, the bottom row tilts away. The tops are deep
  saddle-shaped dishes.
- **DES for Choc v1:** the same sculpt and dishes, every row 4 mm lower, two Choc legs instead of
  the cross stem.
- **KAT**: noticeably flatter, with a moderate row sculpt and spherical dishes.

All pictures in this section except the photos are OpenSCAD renders of the caps with flattened
sides, as they are printed.

### DES (MX)

![DES set with German legends in Lily58 arrangement](docs/img/keycaps/des_set_labeled.png)

![DES set with US legends](docs/img/keycaps/des_us_set_labeled.png)

![DES set without legends](docs/img/keycaps/des_set_blank.png)

![DES close-up: Esc, Q, F with homing bar, Space (1.5u) and GUI](docs/img/keycaps/des_closeup.png)

**R1 is mounted rotated by 180°:** the R1 cap of the DES profile tilts backwards. As the number row
it has to face the user, so its legends are rotated by 180°.

Printed DES caps (0.4 mm nozzle, two filaments). The flat side on the right of each cap is the side
that lay on the print bed:

| | | |
|---|---|---|
| ![Printed GUI key](docs/img/photos/gui_key.jpg) | ![Printed blank key](docs/img/photos/blank_key.jpg) | ![Printed G key](docs/img/photos/g_key.jpg) |

### DES (Choc v1)

![DES-Choc set with German legends in Lily58 arrangement](docs/img/keycaps/des_choc_set_labeled.png)

![DES-Choc set with US legends](docs/img/keycaps/des_choc_us_set_labeled.png)

![DES-Choc set without legends](docs/img/keycaps/des_choc_set_blank.png)

![DES-Choc close-up: Esc, Q, F with homing bar, Space (1.5u) and GUI](docs/img/keycaps/des_choc_closeup.png)

The DES set for Kailh Choc v1 switches at MX spacing (19.05 mm): every row 4 mm lower, two Choc legs
instead of the cross stem (1.0 × 2.9 mm with the default tolerance 0.025). The row caps are printed on
their front face instead of a side, so the legs stand side by side; the 1.5u thumb has its legs turned
by 90° (its switch sits rotated) and is printed on its side (ADR 0014). The fit test and a first full
set are printed; the corrected set (shorter legs, rotated 1.5u legs) is not yet.

### KAT

![KAT set with German legends in Lily58 arrangement](docs/img/keycaps/kat_set_labeled.png)

![KAT set with US legends](docs/img/keycaps/kat_us_set_labeled.png)

![KAT set without legends](docs/img/keycaps/kat_set_blank.png)

![KAT close-up: Esc, Q, F with homing dot, Space (1.5u) and GUI](docs/img/keycaps/kat_closeup.png)

The KAT 1.5u caps are built as regular (horizontal) 1.5u keys; on the Lily58 the switch is rotated,
so they sit upright and their symbol appears sideways. In the KAT files the rows are named after
the profile: R4 = number row, R3 = top row, R2 = home row, R1 = bottom row and thumbs.

### Printed sideways – optimized for FDM

The caps are printed **lying on their side** (DES-Choc: on their front, except the 1.5u thumb), not upright:

- **Smooth top surface:** the curved dish is built from vertical layer contours instead of
  horizontal steps. Printed upright, every layer shows up as a ring in the dish.
- **Stronger stem:** the layer lines run along the stem. Printed upright they run across it, which
  is where the stem tends to break when the cap is pulled off.
- **Flat sides:** the left and right side walls are cut flat along a plane (from the bottom rim
  corner to the top edge). Each cap lies flat on the bed with 80 to 240 mm² of contact; the print
  angle follows from the same plane.
- **Removable support:** a foot stands on the bed in front of the open bottom of the cap, a fin
  reaches through the opening under the stem. The support does not touch the cap anywhere (0.2 mm
  gap to the stem, about 0.3 mm to the wall) and is simply pulled out after printing.
- **Multi-color legends:** legend and cap are separate parts and are printed with two filaments
  (e.g. with the AMS).

### Layouts

German layout:

| Row | Left | Right |
|---|---|---|
| Numbers | Esc 1 2 3 4 5 | 6 7 8 9 0 Del |
| Top | Tab Q W E R T | Z U I O P - |
| Home | Ctrl A S D **F** G | H **J** K L ; ' |
| Bottom | Shift Y X C V B [ | ] N M , . / Shift |
| Thumbs | Alt GUI Lower Enter | Space Raise Backspace GUI |

US layout (follows the Lily58 default keymap):

| Row | Left | Right |
|---|---|---|
| Numbers | Esc 1 2 3 4 5 | 6 7 8 9 0 \` |
| Top | Tab Q W E R T | Y U I O P - |
| Home | Ctrl A S D **F** G | H **J** K L ; ' |
| Bottom | Shift Z X C V B [ | ] N M , . / Shift |
| Thumbs | Alt GUI Lower Enter | Space Raise Backspace GUI |

The German layout is the US layout with Y and Z swapped and Del instead of \`: US punctuation for programming, letters
where a German keyboard has them. Umlauts and ß are not separate keys (long press on A/O/U/S in
the firmware).

**F**/**J** with homing bar or dot. Enter (left) and Space (right) are 1.5u; both layouts share the thumb keys. Ctrl, Alt and GUI use
the Mac symbols ⌃ ⌥ ⌘. Every set also contains one blank spare cap per row, a full set of blank
thumb caps and two blank homing caps.

### Printing the keycaps

- In Bambu Studio, import `*_body.stl` and `*_legends.stl` of a group together and load them as one
  object with multiple parts, then assign the second filament to the legend. Blank groups
  (`Ersatz_*`, `Daumen_leer`, `Homing_leer`) only have a `*_body.stl`.
- The supports are already included, so turn slicer supports off.
- Stem fit with a 0.4 mm nozzle: DES and KAT use a tolerance of 0.025 (DES tested, firm fit),
  DES-Choc narrows each leg by 0.025 per side (1.15 mm). DES and KAT apply the tolerance
  differently, so the values are not interchangeable; print a fit test first with `des-test` /
  `des-choc-test` / `kat-test`.
- Recommended: seam at the back or on the bed side, Arachne wall generator (fine symbol lines),
  slow outer walls.

File names are German: `links`/`rechts` = left/right half, `Daumen` = thumbs, `Ersatz` = spare,
`leer` = blank, `Passtest` = fit test.

### Generating the keycaps

```bash
./lily58_keycaps.sh des-all                 # DES set (German), default tolerance 0.025
LAYOUT=us ./lily58_keycaps.sh des-all       # DES set with US layout
./lily58_keycaps.sh des-all 0.05            # different tolerance
./lily58_keycaps.sh des-test                # DES fit test: blank caps with 0.00 0.025 0.05 0.075
./lily58_keycaps.sh des-choc-all            # DES for Choc v1 (MX spacing), leg tolerance 0.025
LAYOUT=us ./lily58_keycaps.sh des-choc-all  # DES-Choc with US layout
./lily58_keycaps.sh des-choc-test           # Choc fit test: blank caps with 0.00 0.025 0.05 0.075
./lily58_keycaps.sh kat-all                 # KAT set (German), default tolerance 0.025
LAYOUT=us ./lily58_keycaps.sh kat-all       # KAT set with US layout
./lily58_keycaps.sh kat-test                # KAT fit test: blank caps with 0.025 0.05 0.075 0.10
```

The output goes to `~/Documents/lily58_keycaps/stl/<set>/` (set another location with
`KEYCAP_DIR=...`), one `<Group>_body.stl` + `<Group>_legends.stl` per group. A full set takes about
2–3 minutes. The script downloads the templates and libraries itself on the first run.

Requirements:

- OpenSCAD nightly/snapshot with the Manifold backend and `textmetrics` (used to center legends)
- `git` and `unzip`
- Fonts: JetBrains Mono Nerd Font (Bold) for the symbols; Liberation Sans ships with OpenSCAD

<!-- part: docs/case.md -->
## Case

A low tray that follows the PCB outline, a switch plate that snaps into a groove in the wall top,
and a cover over the controller. Designed for the owner's **PandaKB Lily58 RGB MX** (a Lily58 Pro
derivative, no OLED) and a second Lily58 with **Choc v1** switches at MX spacing. The PCB outline and
all positions come from the Lily58 Pro KiCad file (`common/lily58_layout.scad`, checked against the
real PCB with a 1:1 paper template). Status: draft (ADR 0012); the switch cutout is confirmed by a
fit test.

### MX board

![MX half with DES caps, assembled](docs/img/case/mx_assembled.png)

![MX half exploded: rubber feet, tenting feet and screws, tray, standoffs, PCB, plate, cover, caps](docs/img/case/mx_exploded.png)

![MX half, section through two mounting screws](docs/img/case/mx_section.png)

![MX controller cover lifted off with its two M2x12 screws](docs/img/case/mx_cover.png)

The plate (1.5 mm) sits 5.0 mm above the PCB top, as MX switches need. Its top is 16.8 mm above the
desk. 10 mm standoffs reach from the tray floor to just below the plate; sleeves under the plate
stand on the PCB, so the top screws clamp plate, PCB and tray together.

### Choc board

![Choc half with DES-Choc caps, assembled](docs/img/case/choc_assembled.png)

![Choc half exploded](docs/img/case/choc_exploded.png)

![Choc half, section through two mounting screws](docs/img/case/choc_section.png)

![Choc controller cover lifted off](docs/img/case/choc_cover.png)

The plate (1.9 mm) lies directly on the PCB, otherwise the Choc switches would not reach it. Its top
is 13.7 mm above the desk. 6 mm standoffs end just below the PCB top.

### Bottom: rubber feet and tenting feet

![Bottom of the right tray: rubber feet (black), folded tenting feet (orange), M2 screws (grey); inner edge on the right](docs/img/case/bottom.png)

The bottom is the same on both boards:

- **Five rubber feet** (Ø 8 × 4 mm), recessed 1.4 mm. The two on the outer edge and the one in the
  thumb cluster tip reach the start of the bottom chamfer, so tented, the half still stands on them
  (it tips onto its edge only beyond 62°; the fully unfolded tenting feet give about 27°).
- **Two folding tenting feet** (housing 66 × 20 × 5.5 mm) in pockets, flush with the rubber feet,
  aligned so they lift the inner edge evenly.

### Hardware per half

| Part | MX board | Choc board |
|---|---|---|
| M2 hex standoffs (female both ends, 2.7 mm across flats) | 5 × 10 mm | 5 × 6 mm |
| M2x4 from below into the standoffs | 5 | 5 |
| M2x4 from the top through the plate | 5 | 5 |
| M2 heat-set inserts (3.9 mm across flats, 1.5 mm long), in the tray rings | 2 | 2 |
| M2x12 through cover and PCB into the inserts | 2 | 2 |
| Rubber feet Ø 8 × 4 mm | 5 | 5 |
| Folding tenting feet, 66 × 20 × 5.5 mm | 2 | 2 |

**Assembly:** inserts into the tray rings, standoffs into the hex pockets, M2x4 from below; PCB onto
the bosses; plate with the switches on top (it snaps into the groove, the switches go into the
hotswap sockets); M2x4 from the top; cover onto the controller, M2x12 into the inserts.

### Printing and generating the case

```bash
case/build.sh [-D name=value …]   # all parts to stl/case/
```

`case/build.sh` exports trays, plates and covers for both halves (`*_choc.stl` for the Choc board),
the travel sleeve, the carry case parts, a snap test, a plate fit test and a 1:1 paper template
(`template.pdf`/`.svg`). Plates and covers are printed top down, trays on their bottom. Single parts:
`openscad -D 'part="tray"' -D 'side="left"' -D 'switch_type="choc"' -o tray.stl case/lily58_case.scad`.

<!-- part: docs/travel.md -->
## Travel sleeve and carry case

Two ways to carry both halves without changing the trays.

### Travel sleeve (MX)

![Travel sleeve with both MX halves in their chambers](docs/img/case/travel.png)

A box open at the front with two chambers stacked on top of each other (ADR 0013). Each half slides
in keys up, USB edge first, and its front rubber foot (the one in the thumb tip) clicks in behind a
ridge on the chamber floor. Printed on its back wall, no support; about 157 × 119 × 90 mm. Sized for
the MX board (tallest keycap 24 mm above the plate, still to be measured).

### Carry case (MX and Choc)

![Carry case, Choc halves, closed with two rubber bands](docs/img/case/choc_carry.png)

![Carry case, Choc halves, exploded: half, frame, middle plate, frame, half](docs/img/case/choc_carry_exploded.png)

![Carry case, Choc halves, section through the number row](docs/img/case/choc_carry_section.png)

![Carry case, MX halves, closed](docs/img/case/mx_carry.png)

![Carry case, MX halves, exploded](docs/img/case/mx_carry_exploded.png)

![Carry case, MX halves, section through the number row](docs/img/case/mx_carry_section.png)

The halves face each other keys inwards; the trays are the outside (ADR 0015). Between them: a frame
on each half (resting on the plate rim), filament pieces as dowels, two rubber bands round everything.
Each board has its own pair of frames, sized to the measured keycap height above the plate
(MX 23.2 mm → `carry_frame_right/left.stl`, Choc 18 mm → `carry_frame_right/left_choc.stl`).

- **MX:** compact, no middle plate, the frames meet directly; about 81 mm high. The free space over the
  controller covers is a cable compartment for a USB and a TRRS cable (31 × 54 mm, 38 mm deep). The
  controller covers must be mounted, they close it.
- **Choc:** a 2 mm middle plate (`carry_mid.stl`) between the frames; about 67 mm high.
- **MX, maximum compactness (ADR 0016):** `carry2_frame_right/left.stl`, about 75.6 mm high. The left half
  is turned over the long axis so the tall number rows face the low rows; four 10 x 1.4 mm magnets per frame instead of
  rubber bands, a flat cable compartment over each controller cover.

- **Choc, maximum compactness (ADR 0016):** `carry2_frame_right/left_choc.stl`, about 59 mm high, same
  principle and magnets in the four corners, no cable compartment.

![Compact carry case, exploded](docs/img/case/mx_carry2_exploded.png)

![Compact carry case, Choc halves, exploded](docs/img/case/choc_carry2_exploded.png)

<!-- part: docs/rendering.md -->
## Images and rendering

Every render in `docs/img/` can be regenerated from the sources in `render/`:

```bash
render/render_all.sh                     # everything (about 10 minutes)
render/keycaps.sh [variant …]            # keycap images; variants: des des-us des-choc des-choc-us kat kat-us
render/case.sh [mx|choc …] [-- -D …]     # case images; extra OpenSCAD arguments after --
```

The renders use the generated keycap sets, so build them first: `des-all`, `des-choc-all` and
`kat-all`, each also with `LAYOUT=us` (see [Generating the keycaps](#generating-the-keycaps)). KAT
images use the sets of tolerance 0.025 (`KAT_TOL=0.10 render/keycaps.sh kat kat-us` for others).

| Image | Source | Script |
|---|---|---|
| `docs/img/keycaps/<profile>[_us]_set_labeled.png` | set with legends, Lily58 arrangement | `render/keycaps.sh` (scene: `tools/scene.py`) |
| `docs/img/keycaps/<profile>_set_blank.png`, `<profile>_closeup.png` | blank set, five caps | `render/keycaps.sh` |
| `docs/img/keycaps/side_profiles.png` | one column of each profile | `render/keycaps.sh` (scene: `render/side_profiles.scad`) |
| `docs/img/case/<board>_assembled/_exploded/_section/_cover.png` | one half with blank caps | `render/case.sh` (scene: `render/case_scene.scad`) |
| `docs/img/case/<board>_carry[_exploded/_section].png` | carry case | `render/case.sh` |
| `docs/img/case/<board>_carry2[_exploded/_section].png` | compact carry case | `render/case.sh` |
| `docs/img/case/bottom.png`, `travel.png` | tray bottom, travel sleeve | `render/case.sh` |
| `docs/img/photos/*.jpg` | photos of printed caps | – (EXIF removed with `tools/jpegmeta.py`) |

`<profile>` is `des`, `des_choc` or `kat`; `<board>` is `mx` (DES caps) or `choc` (DES-Choc caps).
Keycap images show the caps with flat sides as printed (`render/flat.scad`); the case images use the
blank caps of the matching set. The height of the caps above the plate is estimated (MX 7 mm,
Choc 4.6 mm from the plate to the cap skirt). Intermediate files go to `stl/render/`.

<!-- part: docs/templates.md -->
## Changes to the templates

The templates are not redistributed in modified form; the script downloads them and builds on them.

### PseudoMakeMeKeyCapProfiles (DES, `MX_DES_Standard.scad`, `MX_DES_Thumb.scad`)

The script uses a copy of both profile files without their own `keycap()` call. Instead of
`keycap()`, a custom module `des_cap()` builds the cap from the profile's shape functions and
parameters, with these changes:

- **Stem:** round outside with a diameter of 5.7 instead of 5.5 mm, adjustable tolerance
  (default 0.025).
- **Cross hole:** rebuilt with the same dimensions but without coincident faces, which cause open
  edges on slicer import. The cross starts below the stem bottom; the entry chamfer (1.1× at z = 0)
  is made of two frustums per cross arm.
- **Dish:** the two dish halves overlap by 0.05 mm instead of 0.00001 mm, shifted along the front
  half's own sweep path so the tilted top has no step across the middle (a shift in global y
  printed as a ridge on R1/R2/R4; fixed in v1.2, confirmed by a test print).
- **Legends:** a separate part for multi-color printing, perpendicular to the tilted top and
  centered on the visible shape of the glyph (`textmetrics`). They end 0.3 mm above the inner
  ceiling. The R1 legends are rotated by 180°.
- **Homing:** a raised bar (3 × 1 mm, about 0.6 mm high) instead of the original's dimple.
- **Thumbs:** high-profile variants (1.5u = ID 0, 1u = IDs 1 and 2), mirrored for one half; the
  legends stay readable.
- **Printing:** sides cut flat, laid on the side, removable support.
- **Resolution:** `fn = 60`, `layers = 50`, the values the author gives for output.
- **Choc v1 (`des-choc-*`):** key heights 4 mm lower; legs from `choc_stem()` of
  `Choc_Chicago_Steno.scad`, narrowed per side by the tolerance, 2.9 mm long, with a round bridge to
  the top; printed on the front face, the 1.5u thumb (legs rotated 90°) on the side, with their own
  removable support.

### keycap_playground (KAT, modes `kat-all` and `kat-test`)

The script does not change the playground's code; it only sets parameters and post-processes the
generated caps:

- **Profile:** KAT with rows R1–R4.
- **Stem:** `round_cherry` with 5.7 mm (`STEM_OUTSIDE_TOLERANCE_X = -0.23`).
- **Per-row fixes:** `STEM_HEIGHT`, so the round stem reaches the top in tall rows; `KEY_HEIGHT` and
  `HOMING_DOT_Z`, so legend and homing dot do not end up below the dish; `LEGEND_TRANS` centers the
  legend on its visible shape and on the top instead of the base.
- **Walls:** no stem lining (`STEM_SIDES_WALL_THICKNESS = 0`), `WALL_THICKNESS = 1.8` instead.
- **Printing:** render upright, cut the sides flat, then rotate; removable support instead of the
  built-in one.

<!-- part: docs/credits.md -->
## Credits and licenses

- **[PseudoMakeMeKeyCapProfiles](https://github.com/pseudoku/PseudoMakeMeKeyCapProfiles)** by
  pseudoku: DES profile (Distorted Elliptical Saddle), GPL-3.0. The DES module in
  `lily58_keycaps.sh` contains code derived from it, which is why this project is GPL-3.0 as well.
- **[keycap_playground](https://github.com/riskable/keycap_playground)** by Riskable: parametric
  keycap generator, basis of the KAT caps. Its code is not part of this repository; the script
  downloads it at runtime. The keycap_playground repository does not state a license. The KAT caps
  in the release are generated with it and published with attribution – if you are the author and
  do not agree with this, please open an issue and they will be removed.
- **scad-utils** (Oskar Linde, MIT) and `skin.scad`/`sweep.scad` from the `libraries.zip` of the DES
  repository; also loaded at runtime.
- **Fonts** (not included): Liberation Sans (SIL OFL 1.1); JetBrains Mono Nerd Font (JetBrains Mono:
  SIL OFL 1.1, symbols from the Nerd Fonts set, including Material Design Icons).
- **[Lily58](https://github.com/kata0510/Lily58)** by kata0510 (MIT): the case geometry is derived
  from its Lily58 Pro KiCad file (`tools/kicad2scad.py` → `common/lily58_layout.scad`).

This project is licensed under the **GNU General Public License v3.0**, see [LICENSE](LICENSE).
This also applies to the DES STL files distributed in the release; for the KAT STL files see the
note on keycap_playground above.
