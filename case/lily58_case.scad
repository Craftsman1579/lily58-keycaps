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

part = "assembly";   // tray | plate | sleeve | snap_test | plate_test | template | assembly | travel
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
pilot_d     = 1.7;    // M2 pilot in the OLED rings for the later cover
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
ring_d    = 6.5;      // support rings under the PCB at the two OLED holes

/* [Snap: a tongue under the plate edge clicks into a groove in the wall top] */
snap_c  = pcb_gap + wall_t / 2;   // centre line, offset from the PCB outline
// [depth from the plate bottom / wall top: from, to, width from, width to]
tongue  = [[0, 0.8, 1.2, 1.2], [0.8, 1.1, 1.2, 1.5], [1.1, 1.3, 1.5, 1.5], [1.3, 1.6, 1.5, 1.0]];
groove  = [[0, 0.9, 1.4, 1.4], [0.9, 1.1, 1.4, 1.7], [1.1, 2.0, 1.7, 1.7]];
// the 1.5 mm bulge passes the 1.4 mm neck and sits in the 1.7 mm widening: tune with snap_test

/* [Rubber feet] */
foot_d     = 8.4;     // 8 mm feet
foot_depth = 1.4;     // 4 mm high feet stick out 2.6 mm; 0.6 mm floor stays above them
feet = [[10, 96], [132, 88], [132, 29], [12, 42]];
foot_out   = 4 - foot_depth;

/* [Tenting: two folding feet per half, recessed so their housings sit flush with the rubber feet] */
tent_size = [66.3, 20.3];   // MEASURE 17: housing 66 × 20 mm + 0.3
tent_h    = 5.5;
// lower-left corners; long side across the inner edge, clear of the five screw heads. Both start at
// the same x, so the unfolded feet lift the half along one line (the thumb cluster allows no less).
tent      = [[25.5, 87.3], [25.5, 12]];   // rear one against the long back edge, just behind a screw head
tent_skin = 0.7;            // floor above the pockets
floor_t   = tent_h - foot_out + tent_skin;   // pockets are tent_h - foot_out = 2.9 mm deep

/* [Travel sleeve (ADR 0013): two chambers, the halves slide in keys up, the tray stays as it is] */
caps_above = 24.0;    // MEASURE 15: tallest keycap top above the plate top
sl_gap     = 0.5;     // around the half in x and y
sl_air     = 1.2;     // above the keycaps; also lets the feet climb over the detent
sl_wall    = 2.0;
detent_h   = 0.8;     // ridge on each chamber floor; the front rubber feet click in behind it
grip_w     = 30;      // finger notches in the side walls at the opening
grip_d     = 20;

/* [Ports on the top edge] */
port_dx  = -2;        // test print: both connectors sit 2 mm closer to the inner edge
usb_x    = lily58_promicro[0] + port_dx;
usb_w    = 13;
usb_z    = 5.4;       // USB-C centre above the PCB top (measured, no overhang)
usb_h    = 7.5;      // USB-C overmolds are about 6.5 mm high
trrs_x   = lily58_trrs[0] + port_dx;
trrs_w   = 9.5;
trrs_z   = 3.7 - pcb_t / 2;     // measured: jack axis 3.7 mm above the PCB centre
trrs_h   = 8.5;

/* [Controller zone: open; a separate cover follows later (no OLED)] */
ctrl_x = 28.5;        // plate starts right of this
ctrl_y = 56.6;        // ... or below this

eps = 0.01;
$fn = 48;

z_pcb   = floor_t + under_clear;                  // PCB bottom
z_plate = z_pcb + pcb_t + plate_above - plate_t;  // plate bottom
z_top   = z_plate + plate_t;                      // plate top
y_top   = lily58_pcb_size[1];
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

// Slot through the top wall.
module port(x, z, w, h) {
  translate([x, y_top + 0.5, z]) rotate([-90, 0, 0]) linear_extrude(outer + 1)
    hull() for (s = [-1, 1]) translate([s * (w - h) / 2, 0]) circle(d = h);
}
module ports() {
  port(usb_x, z_pcb + pcb_t + usb_z, usb_w, usb_h);
  port(trrs_x, z_pcb + pcb_t + trrs_z, trrs_w, trrs_h);
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
    ports();
    translate([0, 0, z_plate + eps]) snap_ring(groove);
  }
  for (h = lily58_oled_holes) translate(h) difference() {   // pilot holes for the later cover
    translate([0, 0, floor_t - eps]) cylinder(d = ring_d, h = z_pcb - floor_t + eps);
    translate([0, 0, floor_t]) cylinder(d = pilot_d, h = 20);
  }
}

module plate_shape(inset = 0) difference() { outline(outer - inset); zone(ctrl_x, ctrl_y); }

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
  for (h = lily58_oled_holes) translate(h) line() circle(d = 2.2);
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
}

module sided() { if (side == "left") mirror([1, 0, 0]) children(); else children(); }

if (part == "tray")       sided() tray();
if (part == "plate")      sided() translate([0, 0, plate_t]) rotate([180, 0, 0]) plate();   // top on the bed
if (part == "sleeve")     translate([0, 0, sl_size[1]]) rotate([-90, 0, 0]) sleeve();  // back wall on the bed
if (part == "travel") {   // both halves in the sleeve
  color("#6d6d6d", 0.35) sleeve();
  in_chamber(0, false) assembly();
  in_chamber(1, true) assembly();
}
if (part == "snap_test")  snap_test();
if (part == "plate_test") plate_test();
if (part == "template")   template();
if (part == "assembly")   sided() assembly();
