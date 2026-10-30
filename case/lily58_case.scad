// Lily58 case: printed tray with a switch plate (PandaKB Lily58 RGB MX, a Lily58 Pro derivative).
// Values marked MEASURE n are still to be confirmed on the owner's hardware (docs/adr/0012).
//
// Mounting (M3): a hex standoff stands in a pocket in the floor at each of the five PCB holes,
// held by a button-head screw from below. The PCB lies on a printed washer on the standoff (the
// 4.7 mm PCB holes are about as wide as the standoff) and is screwed down with a socket-head screw
// from the top. The plate is not screwed: it sits on the rebate and is held by the switches.
// Assembly: screw the bare PCB in, lay the plate on, then plug the switches through it.
//
// Usage: openscad -D 'part="tray"' -D 'side="left"' -o tray_left.stl case/lily58_case.scad
// Coordinates: right half seen from the top (see common/lily58_layout.scad), z = 0 is the bed.
include <../common/lily58_layout.scad>

part = "assembly";   // tray | plate | washer | plate_test | template | assembly
side = "right";      // right | left (left = mirrored right half)

/* [PCB and switches] */
pcb_t       = lily58_pcb_thickness;  // outline and holes verified with the paper template
plate_above = 5.0;    // MX standard: plate top 5.0 mm above the PCB top
plate_t     = 1.5;    // MX switch clips need 1.5 mm
cutout      = 14.0;   // switch cutout; choose with part="plate_test"

/* [M3 standoffs] */
standoff_l  = 6.0;    // female-female; owner has 4, 6, 8, 10 mm (6 gives both screws enough thread)
standoff_af = 5.0;    // MEASURE 13: hex across flats
pocket      = 2.0;    // standoff sits this deep in the floor (keeps it from turning)
skin        = 1.0;    // floor between the screw head recess and the standoff
head_d      = 6.2;    // recess for the M3 button head below (ISO 7380: 5.7 × 1.65 mm)
head_h      = 1.0;    // the head sticks out 0.65 mm; the feet add 2 mm
washer_d    = 6.5;    // printed washer between standoff and PCB (bottom side is free there)
washer_t    = 1.0;
m3_d        = 3.4;
// The tallest part below the PCB is 3.5 mm; the standoff sets the actual clearance.
z_base      = head_h + skin;                       // standoff bottom
under_clear = z_base + standoff_l + washer_t - 3.0; // above a 3 mm floor
assert(under_clear >= 3.5, "standoff too short: parts below the PCB are 3.5 mm high");

/* [Tray] */
wall_t    = 2.4;      // 6 perimeters with a 0.4 mm nozzle
pcb_gap   = 0.6;      // PCB edge to inner wall
rebate    = 1.6;      // ledge the plate rests on; lies outside the PCB, so the PCB passes it
plate_gap = 0.25;     // plate edge to wall
foot_ef   = 0.4;      // elephant-foot chamfer at the bottom edge
ring_d    = 6.5;      // support rings under the PCB at the two OLED holes
floor_t   = 3.0;
boss_d    = standoff_af / cos(30) + 2.4;  // hex pocket rises from the floor where needed

/* [Rubber feet] */
foot_d     = 8.4;     // 8 mm feet
foot_depth = 2.0;     // 4 mm high feet stick out 2 mm
feet = [[10, 96], [132, 88], [132, 29], [46, 10]];

/* [Ports on the top edge] */
usb_x    = lily58_promicro[0];
usb_w    = 13;
usb_z    = 5.4;       // USB-C centre above the PCB top (measured, no overhang)
usb_h    = 7.5;      // USB-C overmolds are about 6.5 mm high
trrs_x   = lily58_trrs[0];      // wide slot covers the footprint's ±1.3 mm variants
trrs_w   = 9.5;
trrs_z   = 3.7 - pcb_t / 2;     // measured: jack axis 3.7 mm above the PCB centre
trrs_h   = 8.5;

/* [Controller zone: no OLED; the plate carries a cover box there] */
ctrl_x = 28.5;        // plate starts right of this
cover_x = 27.0;       // cover edges: 1 mm clear of the neighbouring keycaps (they overhang the zone)
cover_y = 56.0;
cover_clear = 8.0;    // underside above the PCB top: Pro Micro top measured 9.0 above the PCB bottom
cover_t = 2.0;        // leaves 0.85 mm above the USB slot
skirt_t = 1.2;        // the outer skirts stand on the rebate like the plate edge
reset_d = 2.5;        // paper-clip hole above the reset switch

eps = 0.01;
$fn = 48;

z_pcb   = floor_t + under_clear;                  // PCB bottom
z_plate = z_pcb + pcb_t + plate_above - plate_t;  // plate bottom
z_top   = z_plate + plate_t;                      // plate top = wall top
z_cover = z_pcb + pcb_t + cover_clear;            // cover underside
y_top   = lily58_pcb_size[1];
outer   = pcb_gap + rebate + wall_t;
plate_r = pcb_gap + rebate - plate_gap;           // plate outline offset from the PCB

// Screws: below M3x(skin + a) button head, on top M3x(pcb_t + washer_t + b) socket head (DIN 912,
// Ø 5.5: the switch housings are 2.9 mm from the hole centres), with a + b <= standoff_l.
// 6 mm standoff: M3x4 below (a = 3), M3x5 on top (b = 2.4).

module outline(d) offset(r = d) lily58_pcb_2d();
module zone(x, y) translate([-50, y]) square([50 + x, 100]);
module hex(af, h) cylinder(d = af / cos(30), h = h, $fn = 6);

// Slot through the top edge; the tray wall holds its lower part, the cover skirt the upper part.
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
          translate([0, 0, foot_ef]) linear_extrude(z_top - foot_ef) outline(outer);
          linear_extrude(foot_ef + eps) outline(outer - foot_ef);
        }
        translate([0, 0, floor_t]) linear_extrude(z_top) outline(pcb_gap);
        translate([0, 0, z_plate]) linear_extrude(z_top) outline(pcb_gap + rebate);
      }
      for (h = lily58_mount_holes) translate(h) cylinder(d = boss_d, h = max(floor_t, z_base + pocket));
    }
    for (f = feet) translate([f[0], f[1], -eps]) cylinder(d = foot_d, h = foot_depth + eps);
    for (h = lily58_mount_holes) translate(h) {
      translate([0, 0, -eps]) cylinder(d = head_d, h = head_h + eps);
      cylinder(d = m3_d, h = 20, center = true);
      translate([0, 0, z_base]) hex(standoff_af + 0.3, 20);
    }
    ports();
  }
  for (h = lily58_oled_holes) translate(h) cylinder(d = ring_d, h = z_pcb);
}

module plate_2d() difference() {
  outline(plate_r);
  zone(ctrl_x, cover_y + skirt_t / 2);
  for (k = lily58_keys) translate([k[0], k[1]]) rotate(k[2]) square(cutout, center = true);
}

// Cover box over the controller zone, part of the plate. Its outer skirts stand on the rebate;
// the inner skirt (towards the keys) stops at the plate top, clear of the Pro Micro.
module cover() {
  difference() {
    translate([0, 0, z_plate]) linear_extrude(z_cover + cover_t - z_plate)
      intersection() { outline(plate_r); zone(cover_x, cover_y); }
    translate([0, 0, z_plate - eps]) linear_extrude(z_cover - z_plate + eps)
      intersection() { outline(plate_r - skirt_t); zone(cover_x - skirt_t, cover_y + skirt_t); }
    translate([cover_x - skirt_t - 1, cover_y + skirt_t + 1, z_plate - eps])
      cube([skirt_t + 2, 100, z_top - z_plate + eps]);
    translate([lily58_reset[0], lily58_reset[1], z_plate]) cylinder(d = reset_d, h = 20);
    ports();
  }
}

module plate() {
  translate([0, 0, z_plate]) linear_extrude(plate_t) plate_2d();
  cover();
}

module washer() difference() {
  cylinder(d = washer_d, h = washer_t);
  translate([0, 0, -eps]) cylinder(d = m3_d, h = washer_t + 2 * eps);
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
  for (h = lily58_mount_holes) translate([h[0], h[1], z_base]) {
    color("#c9a227") difference() {
      hex(standoff_af, standoff_l);
      translate([0, 0, -eps]) cylinder(d = 3, h = standoff_l + 2 * eps);
    }
    color("#d0d0d0") translate([0, 0, standoff_l]) washer();
  }
  color("#2e7d32") translate([0, 0, z_pcb]) linear_extrude(pcb_t) lily58_pcb_2d();
  color("#b0b0b0") plate();
}

module sided() { if (side == "left") mirror([1, 0, 0]) children(); else children(); }

if (part == "tray")       sided() tray();
if (part == "plate")      sided() translate([0, 0, -z_plate]) plate();   // plate bottom on the bed
if (part == "washer")     washer();
if (part == "plate_test") plate_test();
if (part == "template")   template();
if (part == "assembly")   sided() assembly();
