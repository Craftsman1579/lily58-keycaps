// Render scenes for the case (ADR 0012), the travel sleeve (ADR 0013) and the carry case (ADR 0015),
// for both boards: -D 'switch_type="mx"' (PandaKB, DES caps) or "choc" (DES-Choc caps).
// Driven by render/case.sh, which first exports the parts (P = 1…7) to stl/render/case/<switch>/:
// imported meshes render without the z-fighting of the live modules. Paths are relative to this file.
include <../case/lily58_case.scad>   // run with -D 'part="none"'

P     = 0;            // 1 tray, 2 plate in place, 3 PCB, 4 frame, 5 middle plate, 6 cover, 7 sleeve
VIEW  = "assembled";  // assembled | exploded | section | cover | bottom | carry | carry_exploded
                      // | carry_section | travel
EXPL  = 24;           // explode distance (exploded views)
CUT   = 45.814;       // y of the section plane (section views); default: through two mounting screws
BAND  = 1;            // rubber bands on the closed carry case
D = str("../stl/render/case/", switch_type, "/");
// Blank caps of the set that fits the board; built by ./lily58_keycaps.sh des-all / des-choc-all
R = choc ? "../stl/des_choc_set_tol_0.025/raw/" : "../stl/des_set_tol_0.025/raw/";
// Cap skirt above the plate top (estimates): MX ~7 mm (housing 6.6 mm), Choc ~4.6 mm
skirt_z = choc ? 4.6 : 7.0;

z_half = foot_out + z_top;   // plate top above the table
z_mid  = z_half + cc_h;

c_tray = "#2b2d31"; c_plate = "#8a8f98"; c_pcb = "#1f6f43"; c_cap = "#ece8df"; c_cover = "#d9822b";
c_frame = "#d9822b"; c_mid = "#3d4148"; c_band = "#151515"; c_foot = "#111111"; c_tent = "#c27c0e";
c_metal = "#b8bcc4"; c_sleeve = "#4a5a6a"; c_bottom = "#5b6470";

// Spare/blank caps per row; thumbs: the 1.5u and the three 1u of the right half in x order.
// DES-Choc raw caps lie rotated by 90° (printed on the front face, ADR 0014; the 1.5u thumb is not
// rotated); R1 sits turned by 180°.
function capfile(k) =
  k[3] == 4 ? (k[5] > 1 ? "Daumen_leer_04" : str("Daumen_leer_0", 5 + round((k[0] - 47) / 19)))
            : str("Ersatz_R", k[3] + 1, "_00");
module caps() for (k = lily58_keys) translate([k[0], k[1], skirt_z]) rotate(k[2])
  rotate(k[3] == 0 ? 180 : k[5] > 1 ? 90 : 0) rotate(choc && !(k[3] == 4 && k[5] > 1) ? -90 : 0) import(str(R, capfile(k), "_body.3mf"));

// Hardware: M2 hex standoffs, M2 screws (head Ø 3.7 × 1.0), tenting foot housings
module standoffs() for (h = lily58_mount_holes) translate([h[0], h[1], so_bot])
  cylinder(d = so_flat / cos(30), h = so_len, $fn = 6);
module screw(len) { translate([0, 0, -1]) cylinder(d = 3.7, h = 1, $fn = 24); translate([0, 0, -1 - len]) cylinder(d = 2, h = len, $fn = 16); }
module screws_bottom() for (h = lily58_mount_holes) translate([h[0], h[1], 0]) mirror([0, 0, 1]) screw(4);
module screws_top() for (h = lily58_mount_holes) translate([h[0], h[1], z_top]) screw(4);
module screws_cover() for (h = cover_holes) translate([h[0], h[1], z_cov + cov_t]) screw(cov_screw);
module tent_housings() for (t = tent) translate([t[0] + 0.15, t[1] + 0.15, 0]) cube([tent_size[0] - 0.3, tent_size[1] - 0.3, tent_h]);

// One half, z = 0: the table (bottom of the rubber feet); i = component, e = explode distance.
// 0 tray, 1 PCB, 2 plate, 3 rubber feet, 4 caps, 5 cover, 6 standoffs, 7 screws below, 8 screws on the
// plate, 9 cover screws, 10 tenting foot housings
module half_part(i, e = 0) {
  z = [0, 2, 3, -1, 5, 4.6, 1, -1.6, 3.9, 5.6, -1][i] * e;
  translate([0, 0, z]) {
    if (i == 0) translate([0, 0, foot_out]) import(str(D, "p1.stl"));
    if (i == 1) translate([0, 0, foot_out]) import(str(D, "p3.stl"));
    if (i == 2) translate([0, 0, foot_out]) import(str(D, "p2.stl"));
    if (i == 3) for (f = feet) translate([f[0], f[1], 0]) cylinder(d = foot_d - 0.4, h = foot_out + foot_depth, $fn = 32);
    if (i == 4) translate([0, 0, z_half]) caps();
    if (i == 5) translate([0, 0, foot_out]) import(str(D, "p6.stl"));
    if (i == 6) translate([0, 0, foot_out]) standoffs();
    if (i == 7) translate([0, 0, foot_out]) screws_bottom();
    if (i == 8) translate([0, 0, foot_out]) screws_top();
    if (i == 9) translate([0, 0, foot_out]) screws_cover();
    if (i == 10) tent_housings();   // folded, flush with the rubber feet
  }
}
half_cols = [c_tray, c_pcb, c_plate, c_foot, c_cap, c_cover, c_metal, c_metal, c_metal, c_metal, c_tent];
module half(parts, e = 0) for (i = parts) color(half_cols[i]) half_part(i, e);

// Section of one half: each component cut on its own, so the colours stay; stacked thinly against
// z-fighting
module half_section(y, parts) for (i = parts) color(half_cols[i]) linear_extrude(0.1 + i * 0.01)
  projection(cut = true) rotate([-90, 0, 0]) translate([0, -y, 0]) half_part(i);

// Carry case stack: 0…5 bottom half, 10 bottom frame, 11 middle plate, 12 top frame, 20…25 top half,
// 30 rubber bands.
module comp(w, E) {
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
function carry_comps(E) = concat([0, 1, 2, 3, 4, 5, 10, 11, 12, 20, 21, 22, 23, 24, 25], BAND == 1 && E == 0 ? [30] : []);

if (P == 1) tray();
if (P == 2) translate([0, 0, z_plate]) plate();
if (P == 3) translate([0, 0, z_pcb]) linear_extrude(pcb_t) lily58_pcb_2d();
if (P == 4) frame();
if (P == 5) mid();
if (P == 6) cover();
if (P == 7) sleeve();

if (P == 0) {
  all = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  if (VIEW == "assembled") half([0, 1, 2, 3, 4, 5, 8, 9]);
  if (VIEW == "exploded")  half(all, EXPL);
  if (VIEW == "section")   half_section(CUT, [0, 1, 2, 3, 4, 5, 6, 7, 8]);
  if (VIEW == "cover") {   // assembled, only the controller cover and its screws lifted
    half([0, 1, 2, 3, 4, 8]);
    color(c_cover) translate([0, 0, EXPL]) half_part(5);
    color(c_metal) translate([0, 0, 2.2 * EXPL]) half_part(9);
  }
  if (VIEW == "bottom") rotate([0, 180, 0]) {   // seen from below: inner edge on the right
    color(c_bottom) half_part(0);                 // lighter than c_tray, so the feet stand out
    half([3, 7, 10]);
  }
  if (VIEW == "carry")          for (w = carry_comps(0)) color(col(w)) comp(w, 0);
  if (VIEW == "carry_exploded") for (w = carry_comps(1)) color(col(w)) comp(w, EXPL);
  if (VIEW == "carry_section") {
    ws = carry_comps(0);
    for (j = [0 : len(ws) - 1]) color(col(ws[j])) linear_extrude(0.1 + j * 0.01)
      projection(cut = true) rotate([-90, 0, 0]) translate([0, -CUT, 0]) comp(ws[j], 0);
  }
  if (VIEW == "travel") {
    color(c_sleeve) import(str(D, "p7.stl"));
    in_chamber(0, false) translate([0, 0, -foot_out]) half([0, 1, 2, 3, 4, 5]);
    in_chamber(1, true)  translate([0, 0, -foot_out]) half([0, 1, 2, 3, 4, 5]);
  }
}
