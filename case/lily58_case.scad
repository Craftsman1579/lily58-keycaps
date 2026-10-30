// Lily58 case: printed tray with a switch plate (PandaKB Lily58 RGB MX, a Lily58 Pro derivative).
// Draft v1. Values marked MEASURE n still come from the kata0510 Lily58 Pro KiCad data and are
// checked against the owner's PCB (numbers = measurement list in docs/adr/0012).
//
// Usage: openscad -D 'part="tray"' -D 'side="left"' -o tray_left.stl case/lily58_case.scad
// Coordinates: right half seen from the top (see common/lily58_layout.scad), z = 0 is the bed.
include <../common/lily58_layout.scad>

part = "assembly";   // tray | plate | plate_test | template | assembly
side = "right";      // right | left (left = mirrored right half)

/* [PCB and switches] */
pcb_t       = lily58_pcb_thickness;  // MEASURE 1
under_clear = 3.0;    // MEASURE 7: free height below the PCB (hotswap sockets, underglow LEDs)
plate_above = 5.0;    // MX standard: plate top 5.0 mm above the PCB top
plate_t     = 1.5;    // MX switch clips need 1.5 mm
cutout      = 14.0;   // switch cutout; choose with part="plate_test"

/* [Tray] */
floor_t   = 3.0;
wall_t    = 2.4;      // 6 perimeters with a 0.4 mm nozzle
pcb_gap   = 0.6;      // PCB edge to inner wall
rebate    = 1.6;      // ledge the plate rests on; lies outside the PCB, so the PCB passes it
plate_gap = 0.25;     // plate edge to wall
foot_ef   = 0.4;      // elephant-foot chamfer at the bottom edge

/* [Mounting] */
post_d  = 4.2;        // MEASURE 2: posts run through the 4.7 mm PCB holes up to the plate
pilot_d = 1.8;        // M2 self-tapping screw into the post
ring_d  = 6.5;        // MEASURE 7: the PCB rests on these rings (keep clear of sockets/LEDs)
screw_d = 2.4;        // M2 clearance in the plate

/* [Rubber feet] */
foot_d     = 8.4;     // 8 mm feet
foot_depth = 2.0;     // 4 mm high feet stick out 2 mm
feet = [[10, 96], [132, 88], [132, 29], [46, 10]];

/* [Ports on the top edge] */
usb_x    = lily58_promicro[0];  // MEASURE 4
usb_w    = 13;
usb_z    = 11.5;      // MEASURE 4: USB-C centre above the PCB top
usb_h    = 8;
trrs_x   = lily58_trrs[0];      // MEASURE 5
trrs_w   = 9.5;
trrs_z   = 2.5;       // MEASURE 5: jack axis above the PCB top
trrs_h   = 8;

/* [Controller zone: no plate there, OLED cover comes later] */
ctrl_x = 28.5;        // plate starts right of this
ctrl_y = 55.0;        // ... or below this

eps = 0.01;
$fn = 48;

z_pcb   = floor_t + under_clear;              // PCB bottom
z_plate = z_pcb + pcb_t + plate_above - plate_t;  // plate bottom
z_top   = z_plate + plate_t;                  // plate top = wall top
y_top   = lily58_pcb_size[1];

module outline(d) offset(r = d) lily58_pcb_2d();

// Open notch in the top wall, rounded at the bottom.
module port(x, z, w, h) {
  translate([x, y_top, 0]) rotate([-90, 0, 0]) linear_extrude(20, center = true)
    hull() {
      for (s = [-1, 1]) translate([s * (w - h) / 2, -z]) circle(d = h);
      translate([-w / 2, -z_top - 10]) square([w, 1]);
    }
}

module tray() {
  outer = pcb_gap + rebate + wall_t;
  difference() {
    union() {
      translate([0, 0, foot_ef]) linear_extrude(z_top - foot_ef) outline(outer);
      linear_extrude(foot_ef + eps) outline(outer - foot_ef);
    }
    translate([0, 0, floor_t]) linear_extrude(z_top) outline(pcb_gap);
    translate([0, 0, z_plate]) linear_extrude(z_top) outline(pcb_gap + rebate);
    for (f = feet) translate([f[0], f[1], -eps]) cylinder(d = foot_d, h = foot_depth + eps);
    port(usb_x, z_pcb + pcb_t + usb_z, usb_w, usb_h);
    port(trrs_x, z_pcb + pcb_t + trrs_z, trrs_w, trrs_h);
  }
  for (h = lily58_mount_holes) translate(h) difference() {
    union() {
      cylinder(d = ring_d, h = z_pcb);
      cylinder(d = post_d, h = z_plate);
    }
    translate([0, 0, floor_t]) cylinder(d = pilot_d, h = z_top);
  }
}

module plate_2d() difference() {
  outline(pcb_gap + rebate - plate_gap);
  translate([-50, ctrl_y]) square([50 + ctrl_x, 100]);
  for (k = lily58_keys) translate([k[0], k[1]]) rotate(k[2]) square(cutout, center = true);
  for (h = lily58_mount_holes) translate(h) circle(d = screw_d);
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
  color("#b0b0b0") translate([0, 0, z_plate]) linear_extrude(plate_t) plate_2d();
}

module sided() { if (side == "left") mirror([1, 0, 0]) children(); else children(); }

if (part == "tray")       sided() tray();
if (part == "plate")      linear_extrude(plate_t) plate_2d();   // flip it over for the left half
if (part == "plate_test") plate_test();
if (part == "template")   template();
if (part == "assembly")   sided() assembly();
