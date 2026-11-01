#!/usr/bin/env bash
# Renders the carry case images (ADR 0015) to docs/: case_carry_view.png (closed, with rubber bands),
# case_carry_explode.png, case_carry_section.png (through the number row). Needs the DES-Choc set
# in stl/des_choc_set_tol_0.025/ (./lily58_keycaps.sh des-choc-all on the des-choc branch).
# Extra arguments go to OpenSCAD, e.g.: case/render_carry.sh -D cc_caps=24
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
scad="$here/carry_scene.scad"
parts="$here/../stl/case/render"
docs="$here/../docs"
mkdir -p "$parts"
[ -d "$here/../stl/des_choc_set_tol_0.025/raw" ] || { echo "missing stl/des_choc_set_tol_0.025/raw"; exit 1; }

backend=()
openscad --help 2>&1 | grep -q -- "--backend" && backend=(--backend=manifold)
base=(-D 'part="none"' -D 'switch_type="choc"')

for p in 1 2 3 4 5 6; do
  echo ">> part $p"
  openscad "${backend[@]}" "${base[@]}" -D P=$p "$@" -o "$parts/p$p.stl" "$scad" 2>&1 | grep -i error || true
done

shot() {  # <output name> <openscad args…>
  local o="$1"; shift
  echo ">> $o"
  openscad "${base[@]}" --colorscheme=Tomorrow "$@" -o "$docs/$o" "$scad" 2>&1 | grep -i error || true
  [ -s "$docs/$o" ] || { echo "   FAILED: $o"; return 1; }
}
shot case_carry_view.png    --imgsize=2000,1300 --camera=71,53,39,62,0,35,460 "$@"
shot case_carry_explode.png --imgsize=2000,1500 --camera=71,53,39,62,0,35,600 -D EXPL=26 "$@"
shot case_carry_section.png --imgsize=2400,1250 --camera=71,39,0,0,0,0,210 --projection=o \
  -D CUT=95.8 -D BAND=0 "$@"
echo ">> done: $docs"
