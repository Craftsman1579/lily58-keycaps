// Lily58 case: printed tray with a switch plate (PandaKB Lily58 RGB MX, a Lily58 Pro derivative).
// Values marked MEASURE n are still to be confirmed on the owner's hardware (docs/adr/0012).
//
// Mounting (M2): the PCB lies directly on five printed bosses (a spigot centres it in each 4.7 mm
// hole) and is held by M2x8 socket-head screws that tap their own thread into the bosses; a printed
// washer on the PCB keeps the head from slipping through the hole. The plate is not screwed: it sits
// on the rebate and is held by the switches.
// Assembly: screw the bare PCB in, lay the plate on, then plug the switches through it.
//
// Usage: openscad -D 'part="tray"' -D 'side="left"' -o tray_left.stl case/lily58_case.scad
// Coordinates: right half seen from the top (see common/lily58_layout.scad), z = 0 is the bed.
include <../common/lily58_layout.scad>

part = "assembly";   // tray | plate | washer | sleeve | plate_test | template | assembly | travel
side = "right";      // right | left (left = mirrored right half)

/* [PCB and switches] */
pcb_t       = lily58_pcb_thickness;  // outline and holes verified with the paper template
plate_above = 5.0;    // MX standard: plate top 5.0 mm above the PCB top
plate_t     = 1.5;    // MX switch clips need 1.5 mm
cutout      = 13.8;   // switch cutout: owner's first test 13.8; fine-tune with part="plate_test"

/* [M2 mounting] */
under_clear = 4.0;    // tallest part below the PCB measured 3.5 mm, + 0.5 mm
boss_d      = 6.5;    // the PCB rests on these (bottom side is free within Ø 6.6 around the holes)
spigot_d    = 4.3;    // centres the PCB in its 4.7 mm holes
pilot_d     = 1.7;    // M2 self-tapping into the boss
washer_d    = 5.4;    // on top of the PCB, under the screw head; switch housings are 2.9 mm away
washer_t    = 1.0;
screw_d     = 2.4;    // M2 clearance in the washer

/* [Tray] */
wall_t    = 2.4;      // 6 perimeters with a 0.4 mm nozzle
pcb_gap   = 0.6;      // PCB edge to inner wall
rebate    = 1.6;      // ledge the plate rests on; lies outside the PCB, so the PCB passes it
plate_gap = 0.25;     // plate edge to wall
bevel     = 3.0;      // 45° chamfer round the bottom edge: looks thinner, no elephant foot
ring_d    = 6.5;      // support rings under the PCB at the two OLED holes
floor_t   = 2.0;

/* [Rubber feet] */
foot_d     = 8.4;     // 8 mm feet
foot_depth = 1.4;     // 4 mm high feet stick out 2.6 mm; 0.6 mm floor stays above them
feet = [[10, 96], [132, 88], [132, 29], [46, 10]];

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

/* [Controller zone: no OLED; the plate carries a cover box there] */
ctrl_x = 28.5;        // plate starts right of this
cover_x = 27.0;       // cover edges: 1 mm clear of the neighbouring keycaps (they overhang the zone)
cover_y = 56.0;
cover_clear = 7.7;    // underside above the PCB top: Pro Micro top measured 7.4 (9.0 above the bottom)
cover_t = 1.2;        // the USB slot opens through the top edge as a notch
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

// Screw: M2x8 socket head (DIN 912, Ø 3.8): washer 1 + PCB 1.6 + 5.4 mm into the boss.

module outline(d) offset(r = d) lily58_pcb_2d();
module zone(x, y) translate([-50, y]) square([50 + x, 100]);

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
          translate([0, 0, bevel]) linear_extrude(z_top - bevel) outline(outer);
          for (i = [0 : 0.2 : bevel - 0.1]) translate([0, 0, i]) linear_extrude(0.2 + eps) outline(outer - bevel + i + 0.2);
        }
        translate([0, 0, floor_t]) linear_extrude(z_top) outline(pcb_gap);
        translate([0, 0, z_plate]) linear_extrude(z_top) outline(pcb_gap + rebate);
      }
      for (h = lily58_mount_holes) translate(h) {
        cylinder(d = boss_d, h = z_pcb);
        cylinder(d = spigot_d, h = z_pcb + pcb_t - 0.1);
      }
    }
    for (f = feet) translate([f[0], f[1], -eps]) cylinder(d = foot_d, h = foot_depth + eps);
    for (h = lily58_mount_holes) translate([h[0], h[1], foot_depth + 0.6]) cylinder(d = pilot_d, h = 20);
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
  translate([0, 0, -eps]) cylinder(d = screw_d, h = washer_t + 2 * eps);
}

// Travel sleeve: open at the front, chamber 0 at the bottom, chamber 1 above; local y runs from
// the opening (0) to the back wall. A half goes in keys up, its top (USB) edge first.
foot_out = 4 - foot_depth;                        // 4 mm feet stick out this far
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
  for (h = lily58_mount_holes) color("#d0d0d0") translate([h[0], h[1], z_pcb + pcb_t]) washer();
  color("#2e7d32") translate([0, 0, z_pcb]) linear_extrude(pcb_t) lily58_pcb_2d();
  color("#b0b0b0") plate();
}

module sided() { if (side == "left") mirror([1, 0, 0]) children(); else children(); }

if (part == "tray")       sided() tray();
if (part == "plate")      sided() translate([0, 0, -z_plate]) plate();   // plate bottom on the bed
if (part == "washer")     washer();
if (part == "sleeve")     translate([0, 0, sl_size[1]]) rotate([-90, 0, 0]) sleeve();  // back wall on the bed
if (part == "travel") {   // both halves in the sleeve
  color("#6d6d6d", 0.35) sleeve();
  in_chamber(0, false) assembly();
  in_chamber(1, true) assembly();
}
if (part == "plate_test") plate_test();
if (part == "template")   template();
if (part == "assembly")   sided() assembly();
