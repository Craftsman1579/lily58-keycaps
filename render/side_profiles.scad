// Side profiles of one column (2 W S X) as it sits on the keyboard: DES (MX), DES-Choc and KAT,
// number row on the left, the user sits on the right. Driven by render/keycaps.sh; paths are
// relative to this file. Upright caps from the raw folders of the German sets.
KAT = "kat_set_tol_0.20";   // set folder of the KAT caps
S = "../stl/";
u = 19.05;
gap = 40;                   // between the profiles

// [title, set folder, rows left to right, mounting turn per row, pre-turn of the raw caps]
groups = [
  ["DES (MX)",   "des_set_tol_0.025",      ["R1", "R2", "R3", "R4"], [180, 0, 0, 0], 0],
  ["DES (Choc)", "des_choc_set_tol_0.025", ["R1", "R2", "R3", "R4"], [180, 0, 0, 0], -90],
  ["KAT",        KAT,                      ["R4", "R3", "R2", "R1"], [0, 0, 0, 0],   0]
];
function x0(g) = g * (4 * u + gap);

for (g = [0 : len(groups) - 1]) {
  G = groups[g];
  for (r = [0 : 3]) translate([x0(g) + r * u, 0, 0]) {
    // front of the cap (-y) to the right (+x): rotate by 90°
    color("#2b2b2b") rotate(90) rotate(G[3][r]) rotate(G[4]) import(str(S, G[1], "/raw/", G[2][r], "_links_02_body.3mf"));
    color("#444") translate([0, 0, -8]) rotate([90, 0, 0])
      text(G[2][r], size = 4.5, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
  }
  color("#444") translate([x0(g) + 1.5 * u, 0, 26]) rotate([90, 0, 0])
    text(G[0], size = 7, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
}
