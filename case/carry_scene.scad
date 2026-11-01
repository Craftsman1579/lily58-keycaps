// Render scene for the carry case (ADR 0015): Choc halves with the DES-Choc caps, frames, middle
// plate, rubber bands. Driven by case/render_carry.sh, which first exports the parts (P = 1…5) to
// stl/case/render/ – imported meshes render without the z-fighting of the live modules.
// Paths are relative to this file.
include <lily58_case.scad>   // run with -D 'part="none"' -D 'switch_type="choc"'

P    = 0;     // 1 tray, 2 plate in place, 3 PCB, 4 frame, 5 middle plate; 0 = scene
EXPL = 0;     // explode distance
CUT  = -1;    // y of the section plane, -1 = none
BAND = 1;     // rubber bands (closed scene only)
D = "../stl/case/render/";
R = "../stl/des_choc_set_tol_0.025/raw/";
skirt_z = 4.6;   // estimate: cap skirt above the plate top on Choc switches

z_half = foot_out + z_top;
z_mid  = z_half + cc_h;

c_tray = "#2b2d31"; c_plate = "#8a8f98"; c_pcb = "#1f6f43"; c_cap = "#ece8df";
c_frame = "#d9822b"; c_mid = "#3d4148"; c_band = "#151515"; c_foot = "#111111";

// Spare/blank caps per row; thumbs: the 1.5u and the three 1u of the right half in x order.
// The raw caps lie rotated by 90° (printed on the front face, ADR 0014); R1 sits turned by 180°.
function capfile(k) =
  k[3] == 4 ? (k[5] > 1 ? "Daumen_leer_04" : str("Daumen_leer_0", 5 + round((k[0] - 47) / 19)))
            : str("Ersatz_R", k[3] + 1, "_00");
module caps() for (k = lily58_keys) translate([k[0], k[1], skirt_z]) rotate(k[2])
  rotate(k[3] == 0 ? 180 : k[5] > 1 ? 90 : 0) rotate(-90) import(str(R, capfile(k), "_body.3mf"));

// One half, z = 0: bottom of the rubber feet; i = component.
module half_part(i) {
  if (i == 0) translate([0, 0, foot_out]) import(str(D, "p1.stl"));
  if (i == 1) translate([0, 0, foot_out]) import(str(D, "p3.stl"));
  if (i == 2) translate([0, 0, foot_out]) import(str(D, "p2.stl"));
  if (i == 3) for (f = feet) translate([f[0], f[1], 0]) cylinder(d = foot_d - 0.4, h = foot_out + foot_depth, $fn = 32);
  if (i == 4) translate([0, 0, z_half]) caps();
}
half_cols = [c_tray, c_pcb, c_plate, c_foot, c_cap];

// Stack components: 0…4 bottom half, 10 bottom frame, 11 middle plate, 12 top frame, 20…24 top half,
// 30 rubber bands.
module comp(w) {
  E = EXPL;
  if (w < 10) translate([0, 0, -2 * E]) half_part(w);
  if (w == 10) translate([0, 0, z_mid - E]) mirror([0, 0, 1]) import(str(D, "p4.stl"));
  if (w == 11) translate([0, 0, z_mid]) import(str(D, "p5.stl"));
  if (w == 12) translate([0, 0, z_mid + cc_mid + E]) import(str(D, "p4.stl"));
  if (w >= 20 && w < 30) translate([0, 0, 2 * z_mid + cc_mid + 2 * E]) mirror([0, 0, 1]) half_part(w - 20);
  if (w == 30) for (y = cc_band) translate([0, y - cc_band_w / 2 + 0.5, 0])
    rotate([-90, 0, 0]) linear_extrude(cc_band_w - 1) {
      bw = lily58_pcb_size[0] + 2 * (cc_out - cc_band_d);
      bh = 2 * z_mid + cc_mid;
      translate([-cc_out + cc_band_d, -bh]) difference() { offset(r = 1.2) square([bw, bh]); square([bw, bh]); }
    }
}
function col(w) = w < 10 ? half_cols[w] : w >= 20 && w < 30 ? half_cols[w - 20]
                : w == 11 ? c_mid : w == 30 ? c_band : c_frame;
comps = concat([0, 1, 2, 3, 4, 10, 11, 12, 20, 21, 22, 23, 24], BAND == 1 && EXPL == 0 ? [30] : []);

if (P == 1) tray();
if (P == 2) translate([0, 0, z_plate]) plate();
if (P == 3) translate([0, 0, z_pcb]) linear_extrude(pcb_t) lily58_pcb_2d();
if (P == 4) frame();
if (P == 5) mid();
if (P == 0) {
  if (CUT < 0) for (w = comps) color(col(w)) comp(w);
  // section: each component cut on its own, so the colours stay; stacked thinly to avoid z-fighting
  else for (w = comps) color(col(w)) linear_extrude(0.1 + (w % 10) * 0.01)
    projection(cut = true) rotate([-90, 0, 0]) translate([0, -CUT, 0]) comp(w);
}
