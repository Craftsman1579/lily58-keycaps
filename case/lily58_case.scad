// Lily58 case: printed tray with a switch plate (PandaKB Lily58 RGB MX, a Lily58 Pro derivative).
// Values marked MEASURE n are still to be confirmed on the owner's hardware (docs/adr/0012).
//
// Mounting (both variants): M2 hex standoffs (female both ends) sit in hex pockets in the tray
// bosses and reach up through the 4.7 mm PCB holes; an M2x4 from below holds each standoff in the
// tray, an M2x4 from the top pulls the plate down. Both heads sit flush in recesses. MX: 10 mm
// standoffs end just below the plate; sleeves under the plate stand on the PCB, so the plate clamps
// the PCB onto the tray bosses. Choc: 6 mm standoffs, the plate lies on the PCB directly.
// The plate also snaps into a groove in the wall top.
//
// Usage: openscad -D 'part="tray"' -D 'side="left"' -o tray_left.stl case/lily58_case.scad
// Coordinates: right half seen from the top (see common/lily58_layout.scad), z = 0 is the bed.
include <../common/lily58_layout.scad>

part = "assembly";   // tray | plate | cover | sleeve | frame | mid | snap_test | plate_test | template | assembly
                     // | travel | carry
side = "right";      // right | left (left = mirrored right half)
switch_type = "mx";  // mx (PandaKB board) | choc (owner's second Lily58, Choc v1 at MX spacing)
choc = switch_type == "choc";

/* [PCB and switches] */
pcb_t       = lily58_pcb_thickness;  // outline and holes verified with the paper template
plate_above = choc ? 1.9 : 5.0;   // MX standard: plate top 5.0 mm above the PCB top; Choc: the plate
                                  // lies directly on the PCB, else the switches don't reach it (owner)
plate_t     = choc ? 1.9 : 1.5;   // MX switch clips need 1.5 mm; Choc plate 1.9 mm (owner)
cutout      = 13.8;   // switch cutout: confirmed by the plate_test print (2 notches = 13.8 fit best)

/* [Mounting: M2 hex standoffs] */
under_clear = 4.0;    // tallest part below the PCB measured 3.5 mm, + 0.5 mm
boss_d      = 6.5;    // tray bosses the PCB rests on (bottom side is free within Ø 6.6 around the holes)
so_len    = choc ? 6 : 10;  // owner has 6, 8 and 10 mm; MX: reaches from the floor to the plate
so_flat   = 2.7;      // measured: 2.7 across flats, 3.1 across corners – passes the 4.7 mm PCB hole
so_clear  = 0.3;      // hex pocket = so_flat + so_clear (printed holes come out smaller)
so_top    = 0.1;      // the standoff ends this far below the part it clamps (Choc: PCB top, MX: plate)
sleeve_d  = 5.2;      // MX: sleeve under the plate, standing on the PCB; switch housings are 2.9 mm away
sleeve_in = 3.6;      // around the standoff (3.1 across corners)
m2_d      = 2.4;      // M2 clearance
m2_head_d = 4.1;      // head Ø 3.7 mm (owner) × 1.0 mm, + 0.4 clearance
m2_head_h = 1.1;      // recesses: flush in the plate top and in the tray bottom

/* [Tray] */
wall_t    = 4.0;      // the plate lies on the wall top, flush with the outside
pcb_gap   = 0.6;      // PCB edge to inner wall
plate_ch  = 0.8;      // 45° chamfer on the top edge: the plate prints top down, so it lies on the bed
                      // side and grows outward at 45° – a radius there would overhang too flat
bevel     = 3.0;      // 45° chamfer round the bottom edge: looks thinner, no elephant foot
ring_d    = 6.5;      // support rings under the PCB at the two cover holes, insert on top

/* [Snap: a tongue under the plate edge clicks into a groove in the wall top] */
snap_c  = pcb_gap + wall_t / 2;   // centre line, offset from the PCB outline
// [depth from the plate bottom / wall top: from, to, width from, width to]
tongue  = [[0, 0.8, 1.2, 1.2], [0.8, 1.1, 1.2, 1.5], [1.1, 1.3, 1.5, 1.5], [1.3, 1.6, 1.5, 1.0]];
groove  = [[0, 0.9, 1.4, 1.4], [0.9, 1.1, 1.4, 1.7], [1.1, 2.0, 1.7, 1.7]];
// the 1.5 mm bulge passes the 1.4 mm neck and sits in the 1.7 mm widening: tune with snap_test

/* [Rubber feet] */
foot_d     = 8.4;     // 8 mm feet
foot_depth = 1.4;     // 4 mm high feet stick out 2.6 mm; 0.6 mm floor stays above them
// Outer pair: pockets reach the start of the bottom chamfer (x 142.52 + outer - bevel). Tented, the
// half pivots on them; at x 132 it tipped onto its bottom edge from 18° on (fully unfolded tenting
// feet give 27°), now only from 62° on (chamfer top edge). Fifth foot in the thumb cluster tip, also
// out to the chamfer on both edges; as the front foot it clicks in behind the sleeve detent.
feet = [[10, 96], [139.9, 88], [139.9, 29], [12, 42], [22, 3.5]];
foot_out   = 4 - foot_depth;

/* [Tenting: two folding feet per half, recessed so their housings sit flush with the rubber feet] */
tent_size = [66.3, 20.3];   // MEASURE 17: housing 66 × 20 mm + 0.3
tent_h    = 5.5;
// lower-left corners; long side across the inner edge, clear of the five screw heads. Both start at
// the same x, so the unfolded feet lift the half along one line (the thumb cluster allows no less).
tent      = [[25.5, 87.3], [25.5, 12]];   // rear one against the long back edge, just behind a screw head
tent_skin = 0.7;            // floor above the pockets
floor_t   = tent_h - foot_out + tent_skin;   // pockets are tent_h - foot_out = 2.9 mm deep

caps_above = 24.0;    // MEASURE 15: tallest keycap top above the plate top

/* [Travel sleeve (ADR 0013): two chambers, the halves slide in keys up, the tray stays as it is] */
sl_gap     = 0.5;     // around the half in x and y
sl_air     = 1.2;     // above the keycaps; also lets the feet climb over the detent
sl_wall    = 2.0;
detent_h   = 0.8;     // ridge on each chamber floor; the front rubber feet click in behind it
grip_w     = 30;      // finger notches in the side walls at the opening
grip_d     = 20;

/* [Carry case (ADR 0015): halves keys facing each other, a frame on each, a middle plate between,
   held by rubber bands; the trays are the outside] */
cc_caps   = choc ? 18.0 : 23.2;   // tallest keycap top above the plate top (owner, measured)
// MX: compact variant without a middle plate, the frames meet directly; the opposing number rows
// (they alone reach cc_caps) are 2 * cc_air apart. Choc: frames on a middle plate.
cc_air    = choc ? 1.0 : 0.5;   // buffer above the tallest keycap
cc_mid    = choc ? 2.0 : 0;     // middle plate
cc_rest   = 3.0;      // the frame rests this wide on the plate rim (keycaps stay inside the PCB outline)
cc_gap    = 0.3;      // skirt to the half
cc_skirt  = [1.6, 3.0];   // skirt round the plate edge and the wall top: thickness, depth
// on the frame's centre line; MX: the first one moved out of the cable compartment walls
cc_dowel  = [[choc ? -4 : -3.3, choc ? 80 : 44], [146.5, 60], [60, 110.35], [70, 3.9]];
cc_dowel_d = 2.0;     // 1.75 mm filament pieces as dowels
cc_dowel_h = 5;       // hole depth in the frame (middle plate: through)
cc_band   = [65, 90]; // y of the rubber band grooves; they cross the straight left and right edges
cc_band_w = 8;
cc_band_d = 0.8;
cc_bin      = !choc;  // MX: cable compartment in the free space over the controller covers
cc_bin_wall = 2.0;    // outer wall of the compartment (1.2 mm remain at the band grooves)
cc_bin_key  = 1.2;    // wall towards the keys
cc_bin_x    = 27.8;   // key side of that wall: keycap edges at x 28.52 and y 54.95 stay 0.7 mm clear
cc_bin_y    = 55.65;

/* [Compact carry case (ADR 0016, both boards): the upper half is turned the other way, so the tall number row
   of each half faces the low rows of the other; two frames, closed by magnets] */
// plate top to plate top. MX: 41.25 with the measured row heights + 0.75 mm air; Choc: 30.8 from the
// cap model scaled to the measured 18 mm number row + 1.0 mm air
c2_gap     = choc ? 31.8 : 42.0;
c2_mag     = [10, 1.4];   // magnet diameter, height (owner, measured)
c2_mag_clr = 0.25;     // pocket diameter = magnet + this
// the other two are their point reflections; bosses clear of all caps (Choc: the four corners)
c2_mag_pos = choc ? [[12, 2], [143, 8]] : [[12, 2], [143, 61]];
c2_dowel   = [[-4, 15], [-4, 30]];   // same
c2_bin_wall = 1.6;     // outer wall of the cable compartments
c2_deck    = 1.2;      // deck over the other half's compartment, lies on the print bed
c2_roof_z  = 1.0;      // the roof over the windows starts this far from the meeting face
c2_roof_k  = choc ? 1.15 : 1.0;   // inward per height (Choc: lower frame, 49° from vertical to still close)
c2_bin     = !choc;    // cable compartments; Choc: the cover leaves only about 8 mm of depth, so none


port_dx  = -2;        // test print: both connectors sit 2 mm closer to the inner edge
usb_x    = lily58_promicro[0] + port_dx;
usb_w    = 16;       // 13 x 7.5 was too tight for the owner's cables (+3 mm)
usb_z    = 5.4;       // USB-C centre above the PCB top (measured, no overhang)
usb_h    = 10.5;      // bottom 0.15 mm above the PCB top
trrs_x   = lily58_trrs[0] + port_dx;
trrs_w   = 9.5;
trrs_z   = 3.7 - pcb_t / 2;     // measured: jack axis 3.7 mm above the PCB centre
trrs_h   = 8.5;

/* [Controller zone and cover: the cover clicks into the wall groove like the plate; two posts press
   on the PCB, M2x12 from the top through cover and PCB into heat-set inserts in the tray rings] */
// Cover holes (the OLED holes): measured on the owner's PCB (MEASURE 19), Ø 2.1 mm. Hole 1 sits
// 0.9 mm closer to the inner edge than in the Lily58 Pro data (lily58_oled_holes), both 0.65 mm
// further up; x of hole 1 is the mean of the edge measurement and the hole spacing (2.05 / 2.35).
cover_holes  = [[2.2, 59.08], [25.05, 59.08]];
cover_hole_d = 2.1;
ctrl_x = 28.5;        // plate starts right of this
ctrl_y = 55.5;        // ... or below this: 1.0 mm clear of the nearest keycap, so the cover
                      // keeps 1.3 mm between its plate-side edge and the screw head recesses
cov_gap  = 7.7;       // cover underside above the PCB top (owner; Pro Micro top 7.4 mm)
cov_t    = 1.5;
cov_wall = 1.5;       // inner walls along the plate edge, down to the plate top
cov_clr  = 0.2;       // gap to the plate edge
cov_ch_out = 3.0;     // 45° chamfers on the top edges: along the case outline like the tray's bottom
cov_ch_in  = 0.8;     // bevel; along the plate edge like the plate (the inner walls are only 1.5 mm)
cov_ch_v   = 1.0;     // vertical corner towards the keys
cov_post = 4.5;       // posts on the PCB round the cover holes (4 mm pad)
ins_d    = 3.6;       // heat-set M2 insert 3.9 mm across flats, 1.5 mm long (owner): melt-in hole
ins_h    = 1.8;       // insert + 0.3 mm for the displaced plastic
ins_tip  = 2.0;       // below the insert: room for the screw tip (d m2_d)
cov_screw = 12;       // owner has M2 x 10/12/16/20

eps = 0.01;
$fn = 48;

z_pcb   = floor_t + under_clear;                  // PCB bottom
z_plate = z_pcb + pcb_t + plate_above - plate_t;  // plate bottom
z_top   = z_plate + plate_t;                      // plate top
y_top   = lily58_pcb_size[1];
z_cov   = z_pcb + pcb_t + cov_gap;                // cover underside
// M2x12: head flush in the cover top; the tip must pass the 1.5 mm insert and stay in the tip room
cov_tip = z_cov + cov_t - m2_head_h - cov_screw;
echo(str("cover screw tip ", (z_pcb - 1.5) - cov_tip, " mm below the insert (room ", ins_h + ins_tip - 1.5, ")"));
assert(cov_tip < z_pcb - 1.5 && cov_tip > z_pcb - ins_h - ins_tip, "cover screw length");
outer   = pcb_gap + wall_t;

// Choc: standoff z 3.1 … 9.1; below it 3.1 - 1.1 = 2.0 mm of floor, so an M2x4 has 2.0 mm of thread;
// from the top an M2x4 passes 0.8 mm of plate and 0.1 mm gap and has 3.1 mm (5.1 of the 6 mm together).
// MX: standoff z 2.6 … 12.6; an M2x4 from below has 2.5 mm of thread, one from the top passes 0.4 mm of
// plate and 0.1 mm gap and has 3.5 mm.
so_bot  = (choc ? z_pcb + pcb_t : z_plate) - so_top - so_len;   // standoff bottom

module outline(d) offset(r = d) lily58_pcb_2d();
module zone(x, y) translate([-50, y]) square([50 + x, 100]);
module ring(c, w) difference() { outline(c + w / 2); outline(c - w / 2); }

// Ring with a varying cross-section, built from 0.1 mm slices, going down from z = 0.
module snap_ring(segs) for (g = segs) for (d = [g[0] : 0.1 : g[1] - 0.05])
  translate([0, 0, -d - 0.1]) linear_extrude(0.1 + eps)
    ring(snap_c, g[2] + (g[3] - g[2]) * (d + 0.05 - g[0]) / (g[1] - g[0]));

// Slot through the top wall; open = also open upwards (cover: the USB plug reaches its top).
module port(x, z, w, h, open = false) {
  translate([x, y_top + 0.5, z]) rotate([-90, 0, 0]) linear_extrude(outer + 1)
    hull() for (s = [-1, 1], u = open ? [0, 30] : [0]) translate([s * (w - h) / 2, -u]) circle(d = h);
}
// USB and TRRS share one opening (the bridge between them would be 0.35 mm). The Choc tray wall ends
// below the USB slot, so it keeps the separate TRRS slot and stays as printed.
module ports(open = false, merge = true) {
  module both() {
    port(usb_x, z_pcb + pcb_t + usb_z, usb_w, usb_h, open);
    port(trrs_x, z_pcb + pcb_t + trrs_z, trrs_w, trrs_h, open);
  }
  if (merge) hull() both(); else both();
}

module tray() {
  difference() {
    union() {
      difference() {
        union() {
          translate([0, 0, bevel]) linear_extrude(z_plate - bevel) outline(outer);
          for (i = [0 : 0.2 : bevel - 0.1]) translate([0, 0, i]) linear_extrude(0.2 + eps) outline(outer - bevel + i + 0.2);
        }
        translate([0, 0, floor_t]) linear_extrude(z_top) outline(pcb_gap);
      }
      for (h = lily58_mount_holes) translate(h) {
        cylinder(d = boss_d, h = z_pcb);
      }
    }
    for (f = feet) translate([f[0], f[1], -eps]) cylinder(d = foot_d, h = foot_depth + eps);
    for (t = tent) translate([t[0], t[1], -eps]) cube([tent_size[0], tent_size[1], tent_h - foot_out + eps]);
    for (h = lily58_mount_holes) translate(h) {
      translate([0, 0, -eps]) cylinder(d = m2_head_d, h = m2_head_h + eps);
      cylinder(d = m2_d, h = 20, center = true);
      translate([0, 0, so_bot]) cylinder(d = (so_flat + so_clear) / cos(30), h = 20, $fn = 6);
    }
    ports(merge = !choc);
    translate([0, 0, z_plate + eps]) snap_ring(groove);
  }
  for (h = cover_holes) translate(h) difference() {   // heat-set inserts for the cover screws
    translate([0, 0, floor_t - eps]) cylinder(d = ring_d, h = z_pcb - floor_t + eps);
    translate([0, 0, z_pcb - ins_h]) cylinder(d = ins_d, h = ins_h + eps);
    translate([0, 0, z_pcb - ins_h - ins_tip]) cylinder(d = m2_d, h = ins_tip + eps);
  }
}

module plate_shape(inset = 0) difference() { outline(outer - inset); zone(ctrl_x, ctrl_y); }

// Controller cover in tray coordinates: top plate, walls on the tray wall (tongue in the groove),
// inner walls along the plate edge down to the plate top, posts on the PCB, ports cut through.
module cover_shape() intersection() { outline(outer); offset(delta = -cov_clr) zone(ctrl_x, ctrl_y); }
// Outline inset by a, plate-side edges inset by b; the corner towards the keys chamfered.
module cover_layer(a, b) intersection() {
  outline(outer - a);
  x = ctrl_x - cov_clr - b; y = ctrl_y + cov_clr + b; k = cov_ch_v;
  polygon([[-50, y], [x - k, y], [x, y + k], [x, 200], [-50, 200]]);
}
// Envelope that cuts the chamfers: 0.1 mm slices over the top cov_ch_out.
module cover_env() {
  z0 = z_cov + cov_t - cov_ch_out;
  translate([0, 0, -1]) linear_extrude(z0 + 1) cover_layer(0, 0);
  for (z = [0 : 0.1 : cov_ch_out - 0.05]) translate([0, 0, z0 + z]) linear_extrude(0.1 + eps)
    cover_layer(z + 0.1, max(0, z + 0.1 - (cov_ch_out - cov_ch_in)));
}
module cover() intersection() { cover_raw(); cover_env(); }
module cover_raw() {
  difference() {
    union() {
      translate([0, 0, z_cov]) linear_extrude(cov_t) cover_shape();
      translate([0, 0, z_plate]) linear_extrude(z_cov - z_plate + eps)
        intersection() { difference() { outline(outer); outline(pcb_gap); } cover_shape(); }
      translate([0, 0, z_top]) linear_extrude(z_cov - z_top + eps) difference() {
        cover_shape();
        translate([-50, ctrl_y + cov_clr + cov_wall]) square([50 + ctrl_x - cov_clr - cov_wall, 100]);
      }
      for (h = cover_holes) translate([h[0], h[1], z_pcb + pcb_t]) cylinder(d = cov_post, h = cov_gap + eps);
      translate([0, 0, z_plate]) intersection() {
        snap_ring(tongue);
        translate([0, 0, -5]) linear_extrude(5 + eps) cover_shape();
      }
    }
    for (h = cover_holes) translate(h) {
      cylinder(d = m2_d, h = 100);
      translate([0, 0, z_cov + cov_t - m2_head_h]) cylinder(d = m2_head_d, h = 10);
    }
    ports(open = true);
  }
}

// Plate in its own coordinates: z = 0 is its bottom, the tongue hangs below.
module plate() {
  difference() {
    union() {
      linear_extrude(plate_t - plate_ch) plate_shape();
      for (z = [0 : 0.1 : plate_ch - 0.05]) translate([0, 0, plate_t - plate_ch + z])
        linear_extrude(0.1 + eps) plate_shape(z + 0.1);
    }
    for (k = lily58_keys) translate([k[0], k[1], -1]) rotate(k[2]) linear_extrude(plate_t + 2) square(cutout, center = true);
    for (h = lily58_mount_holes) translate([h[0], h[1], 0]) {
      translate([0, 0, -1]) cylinder(d = m2_d, h = plate_t + 2);
      translate([0, 0, plate_t - m2_head_h]) cylinder(d = m2_head_d, h = m2_head_h + 1);
    }
  }
  sleeve_h = plate_above - plate_t;                // plate bottom down to the PCB top (0 for Choc)
  if (sleeve_h > 0) for (h = lily58_mount_holes) translate([h[0], h[1], -sleeve_h]) difference() {
    cylinder(d = sleeve_d, h = sleeve_h + eps);
    translate([0, 0, -eps]) cylinder(d = sleeve_in, h = sleeve_h + eps);
  }
  intersection() {
    snap_ring(tongue);
    translate([0, 0, -5]) linear_extrude(5 + eps) plate_shape();
  }
}

// Travel sleeve: open at the front, chamber 0 at the bottom, chamber 1 above; local y runs from
// the opening (0) to the back wall. A half goes in keys up, its top (USB) edge first.
half_w   = lily58_pcb_size[0] + 2 * outer;
half_d   = lily58_pcb_size[1] + 2 * outer;
half_h   = foot_out + z_top + caps_above;
ch_w     = half_w + 2 * sl_gap;
ch_d     = half_d + 2 * sl_gap;
ch_h     = half_h + sl_air;
sl_size  = [ch_w + 2 * sl_wall, ch_d + sl_wall, 2 * ch_h + 3 * sl_wall];
y_detent = min([for (f = feet) f[1]]) + outer + 2 * sl_gap - foot_d / 2 - 2.5;
echo(str("sleeve outside: ", sl_size));

function ch_z(i) = sl_wall + i * (ch_h + sl_wall);   // chamber floor
module sleeve() {
  difference() {
    cube(sl_size);
    for (i = [0, 1]) {
      translate([sl_wall, -eps, ch_z(i)]) cube([ch_w, ch_d + eps, ch_h]);
      for (x = [-1, ch_w + sl_wall - 1])
        translate([x, -eps, ch_z(i) + ch_h / 2 - grip_w / 2]) hull() {
          cube([sl_wall + 2, eps, grip_w]);
          translate([0, grip_d - grip_w / 2, grip_w / 2]) rotate([0, 90, 0]) cylinder(d = grip_w, h = sl_wall + 2);
        }
    }
  }
  for (i = [0, 1]) translate([sl_wall, y_detent, ch_z(i) + detent_h - 1.5])
    rotate([0, 90, 0]) cylinder(r = 1.5, h = ch_w);
}

// A half (tray coordinates) placed in chamber i; mirrored for the left half.
module in_chamber(i, left) {
  translate([sl_wall + sl_gap + outer + (left ? lily58_pcb_size[0] : 0), sl_gap + outer, ch_z(i) + foot_out])
    if (left) mirror([1, 0, 0]) children(); else children();
}

// Carry case: frame in its own coordinates, z = 0 lies on the middle plate, the half rests on z = cc_h
// (plate top). Over the controller cover the frame is open inside the skirt, cc_cover deep: the cover
// stands 7.3 mm above the plate on the Choc board (plate 1.9 mm above the PCB), 4.2 mm on MX.
cc_h     = cc_caps + cc_air;
cc_cover = cov_gap + cov_t - plate_above + 0.5;
cc_out = outer + cc_gap + cc_skirt[0];
echo(str("carry case height: ", 2 * (foot_out + z_top + cc_h) + cc_mid, " (", 2 * cc_h + cc_mid, " without the halves)"));

module cc_band_cut() for (y = cc_band) difference() {
  translate([-50, y - cc_band_w / 2]) square([250, cc_band_w]);
  outline(cc_out - cc_band_d);
}
module cc_dowels(h) for (d = cc_dowel) translate([d[0], d[1], -eps]) cylinder(d = cc_dowel_d, h = h + eps, $fn = 24);

// Cable compartment: open towards the other frame, the controller cover is its floor. Standing in a
// y-z plane a coil can use the full depth of both frames.
module cc_bin_2d() intersection() { outline(cc_out - cc_bin_wall); zone(cc_bin_x - cc_bin_key, cc_bin_y + cc_bin_key); }
if (cc_bin) echo(str("carry case cable compartment: x ", cc_bin_x - cc_bin_key + cc_out - cc_bin_wall, ", y ",
  y_top + cc_out - cc_bin_wall - cc_bin_y - cc_bin_key, ", z ", 2 * (cc_h - cc_cover) + cc_mid));

module frame() difference() {
  union() {
    linear_extrude(cc_h) difference() { outline(cc_out); outline(outer - cc_rest); }
    translate([0, 0, cc_h - eps]) linear_extrude(cc_skirt[1] + eps) difference() { outline(cc_out); outline(outer + cc_gap); }
    if (cc_bin) linear_extrude(cc_h - cc_cover) intersection() { outline(cc_out); zone(cc_bin_x, cc_bin_y); }
  }
  if (cc_bin) translate([0, 0, -1]) linear_extrude(cc_h - cc_cover + 2) cc_bin_2d();
  translate([0, 0, cc_h - cc_cover]) linear_extrude(cc_cover + 1)
    intersection() { outline(outer + cc_gap); offset(delta = cc_gap) zone(ctrl_x, ctrl_y); }
  translate([0, 0, -1]) linear_extrude(cc_h + cc_skirt[1] + 2) cc_band_cut();
  cc_dowels(cc_dowel_h);
}

// The right half lies keys up below it, the left half keys down on top: turned over, the left
// outline covers the right one, so the stack is the right outline; "L" faces the left half.
module mid() difference() {
  linear_extrude(cc_mid) outline(cc_out);
  translate([0, 0, -1]) linear_extrude(cc_mid + 2) cc_band_cut();
  translate([0, 0, -1]) cc_dowels(cc_mid + 2);
  translate([90, 60, cc_mid - 0.4]) linear_extrude(1) text("L", size = 12, halign = "center", valign = "center");
}

module carry() {
  z_mid = foot_out + z_top + cc_h;
  translate([0, 0, foot_out]) assembly();
  color("#6d6d6d") translate([0, 0, z_mid]) mirror([0, 0, 1]) frame();
  color("#9e9e9e") translate([0, 0, z_mid]) mid();
  color("#6d6d6d") translate([0, 0, z_mid + cc_mid]) frame();   // left frame, turned over
  translate([0, 0, 2 * z_mid + cc_mid - foot_out]) mirror([0, 0, 1]) assembly();
}

// Compact carry case: stack coordinates of the right half, z = 0 is its plate top, keys up, the frames
// meet at z = c2_m. The left half lies turned over about the long (x) axis, so it appears point-reflected
// in the plane; the common outline is the union of both, and everything below is point-symmetric where
// the two frames have to meet. Each frame carries the compartment over its own controller cover and
// the deck that closes the compartment of the other half.
c2_m = c2_gap / 2;
c2_cover = cov_gap + cov_t - plate_above + 0.5;
function c2_ref(p) = [lily58_pcb_size[0] - p[0], y_top - p[1]];
c2_mags   = concat(c2_mag_pos, [for (p = c2_mag_pos) c2_ref(p)]);
c2_dowels = concat(c2_dowel, [for (p = c2_dowel) c2_ref(p)]);
module c2_reflect() translate([lily58_pcb_size[0], y_top]) rotate(180) children();
module c2_u(d) union() { outline(d); c2_reflect() outline(d); }
module c2_zone() intersection() { outline(cc_out); zone(cc_bin_x, cc_bin_y); }
module c2_bin_2d() intersection() { outline(cc_out - c2_bin_wall); zone(cc_bin_x - cc_bin_key, cc_bin_y + cc_bin_key); }
echo(str("compact carry case height: ", 2 * (foot_out + z_top) + c2_gap));
if (c2_bin) echo(str("compact carry case compartments (each): x ", cc_bin_x - cc_bin_key + cc_out - c2_bin_wall,
  ", y ", y_top + cc_out - c2_bin_wall - cc_bin_y - cc_bin_key, ", z ", c2_m - c2_cover));

// Roof over the windows: where the other half sticks out past this one, the case would be open. A solid
// wedge grows from the ring at 45° (no support, the meeting face is on the bed) and ends flush with the
// skirt, 0.3 mm round the tray. The slope stays clear of the other half's keycaps.
module c2_roof() difference() {
  // slices end inside the ring and the band below it, so they add no second outer surface
  for (z = [-cc_skirt[1] : 0.2 : c2_m - c2_roof_z - 0.1]) translate([0, 0, z]) linear_extrude(0.2 + eps) difference() {
    c2_u(cc_out - 0.5);
    offset(delta = -c2_roof_k * (c2_m - c2_roof_z - z)) c2_u(outer - cc_rest);
  }
  translate([0, 0, -cc_skirt[1] - 1]) linear_extrude(c2_m + cc_skirt[1] + 2) outline(outer + cc_gap);
}

module frame2() difference() {
  union() {
    c2_roof();
    linear_extrude(c2_m) difference() { c2_u(cc_out); c2_u(outer - cc_rest); }
    // skirt round the plate edge and outer band of the roof: everything outside the common outline
    translate([0, 0, -cc_skirt[1]]) linear_extrude(cc_skirt[1] + eps) difference() { c2_u(cc_out); c2_u(outer + cc_gap); }
    if (c2_bin) translate([0, 0, c2_cover]) linear_extrude(c2_m - c2_cover) c2_zone();
    if (c2_bin) translate([0, 0, c2_m - c2_deck]) linear_extrude(c2_deck) c2_reflect() c2_zone();
    intersection() {
      for (p = c2_mags) translate([p[0], p[1], c2_m - c2_mag[1] - 1.2]) cylinder(d = c2_mag[0] + 2.4, h = c2_mag[1] + 1.2);
      linear_extrude(100) c2_u(cc_out);
    }
  }
  translate([0, 0, -1]) linear_extrude(c2_cover + 1) intersection() { outline(outer + cc_gap); offset(delta = cc_gap) zone(ctrl_x, ctrl_y); }
  if (c2_bin) translate([0, 0, c2_cover - eps]) linear_extrude(c2_m - c2_cover + 1) c2_bin_2d();
  for (p = c2_mags) translate([p[0], p[1], c2_m - c2_mag[1] - 0.1]) cylinder(d = c2_mag[0] + c2_mag_clr, h = c2_mag[1] + 1);
  for (p = c2_dowels) translate([p[0], p[1], c2_m - cc_dowel_h]) cylinder(d = cc_dowel_d, h = cc_dowel_h + 1, $fn = 24);
}

// Snap fit test: the real wall and plate edge on a straight piece of the bottom edge.
module snap_box() translate([50, -8, -1]) cube([30, 16, 40]);
module snap_test() {
  intersection() { tray(); snap_box(); }
  translate([0, 25, plate_t]) rotate([180, 0, 0]) intersection() { plate(); translate([0, 0, -z_plate]) snap_box(); }
}

// Fit test: cutouts cutout-0.1 … cutout+0.2; the number of notches on the edge = position 1…4.
module plate_test() linear_extrude(plate_t) difference() {
  square([4 * 20 + 4, 24]);
  for (i = [0:3]) {
    translate([2 + 10 + 20 * i, 12]) square(cutout - 0.1 + 0.1 * i, center = true);
    for (j = [0:i]) translate([2 + 10 + 20 * i + (j - i / 2) * 3, 0]) circle(d = 1.6);
  }
}

// 1:1 paper template of the PCB (right half, switch side up) to check outline and holes.
module line(w = 0.3) difference() { children(); offset(delta = -w) children(); }
module template() {
  line() lily58_pcb_2d();
  for (h = lily58_mount_holes) translate(h) line() circle(d = lily58_mount_hole_d);
  // cover holes (measured) with a 4 mm ring and a cross through the centre
  for (h = cover_holes) translate(h) {
    line() circle(d = cover_hole_d);
    line() circle(d = 4);
    for (r = [0, 90]) rotate(r) square([8, 0.2], center = true);
  }
  for (k = lily58_keys) translate([k[0], k[1]]) rotate(k[2]) line() square(cutout, center = true);
  // 100 mm scale bar: check the print scale with a ruler
  translate([0, -12]) {
    square([100, 0.4]);
    for (i = [0:10]) translate([10 * i, 0]) square([0.4, i % 5 ? 2 : 4]);
  }
}

module assembly() {
  color("#3a3a3a") tray();
  color("#2e7d32") translate([0, 0, z_pcb]) linear_extrude(pcb_t) lily58_pcb_2d();
  color("#b0b0b0") translate([0, 0, z_plate]) plate();
  color("#b0b0b0") cover();
}

module sided() { if (side == "left") mirror([1, 0, 0]) children(); else children(); }

if (part == "tray")       sided() tray();
if (part == "plate")      sided() translate([0, 0, plate_t]) rotate([180, 0, 0]) plate();   // top on the bed
if (part == "cover")      sided() translate([0, 0, z_cov + cov_t]) rotate([180, 0, 0]) cover();   // top on the bed
if (part == "sleeve")     translate([0, 0, sl_size[1]]) rotate([-90, 0, 0]) sleeve();  // back wall on the bed
if (part == "travel") {   // both halves in the sleeve
  color("#6d6d6d", 0.35) sleeve();
  in_chamber(0, false) assembly();
  in_chamber(1, true) assembly();
}
// Middle-plate face on the bed: turned over onto its half the outline mirrors, so the frame for the
// right half is the mirrored one.
if (part == "frame")      { if (side == "left") frame(); else mirror([1, 0, 0]) frame(); }
if (part == "mid")        mid();
if (part == "frame2")     sided() translate([0, 0, c2_m]) rotate([180, 0, 0]) frame2();   // meeting face on the bed
if (part == "carry")      carry();
if (part == "snap_test")  snap_test();
if (part == "plate_test") plate_test();
if (part == "template")   template();
if (part == "assembly")   sided() assembly();
