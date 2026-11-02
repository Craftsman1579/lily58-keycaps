// Flat side cuts for the keycap images, the same cuts the group pass of lily58_keycaps.sh makes
// (flatlib.scad / desflat.scad / chocsupport.scad there): upright caps with their sides cut flat,
// as they are printed. Used by render/keycaps.sh, one cap per run:
//   -D 'F="<raw>/<key>_body.3mf"' -D 'K="des"|"choc"|"kat"' -D C=<chords>
// DES / DES-Choc: C = [R, L] (right/left chord [xb, zb, xt, zt]); KAT: C = [xb, xt, zt].
F = "";
K = "des";
C = [];

function chord_x(c, z) = c[0] + (c[2] - c[0]) * (z - c[1]) / (c[3] - c[1]);
module des_cut(R, L) rotate([90, 0, 0]) linear_extrude(height = 100, center = true)
  polygon([[chord_x(R, 0.02), 0.02], [chord_x(R, 40), 40], [-chord_x(L, 40), 40], [-chord_x(L, 0.02), 0.02]]);
// DES-Choc: keeps the legs below the skirt (the cut starts at z = 0.02)
module choc_cut(R, L) union() { des_cut(R, L); translate([-5, -4, -2]) cube([10, 8, 2.3]); }
module kat_cut(xb, xt, zt) rotate([90, 0, 0]) linear_extrude(height = 100, center = true)
  polygon([[ xb - (xb - xt) * -20 / zt, -20], [ xb - (xb - xt) * 40 / zt, 40],
           [-(xb - (xb - xt) * 40 / zt), 40], [-(xb - (xb - xt) * -20 / zt), -20]]);

intersection() {
  import(F);
  if (K == "des")  des_cut(C[0], C[1]);
  if (K == "choc") choc_cut(C[0], C[1]);
  if (K == "kat")  kat_cut(C[0], C[1], C[2]);
}
