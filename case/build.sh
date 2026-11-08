#!/usr/bin/env bash
# Exports the case parts to stl/case/: tray_right/left, plate_right/left and cover_right/left
# (top down on the bed), the same six for the Choc board (*_choc.stl, plate directly on the PCB),
# travel sleeve, carry case frames per board (carry_frame_right/left, *_choc.stl), carry_mid (Choc), snap_test,
# plate_test, and template.pdf/.svg (1:1 paper template of the PCB).
# Extra arguments go to OpenSCAD, e.g.: case/build.sh -D cutout=14.0 -D under_clear=3.8
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
out="$here/../stl/case"
mkdir -p "$out"
scad="$here/lily58_case.scad"

backend=()
openscad --help 2>&1 | grep -q -- "--backend" && backend=(--backend=manifold)

run() {  # <output file> <openscad -D args…>
  local o="$1"; shift
  echo ">> $o"
  openscad "${backend[@]}" -o "$out/$o" "$@" "$scad" 2>&1 | grep -i -E "error|warning" | grep -v NoError || true
  [ -s "$out/$o" ] || { echo "   FAILED: $o"; return 1; }
}

run tray_right.stl -D 'part="tray"' -D 'side="right"' "$@"
run tray_left.stl  -D 'part="tray"' -D 'side="left"'  "$@"
run plate_right.stl -D 'part="plate"' -D 'side="right"' "$@"
run plate_left.stl  -D 'part="plate"' -D 'side="left"'  "$@"
run cover_right.stl -D 'part="cover"' -D 'side="right"' "$@"
run cover_left.stl  -D 'part="cover"' -D 'side="left"'  "$@"
run tray_right_choc.stl  -D 'part="tray"'  -D 'side="right"' -D 'switch_type="choc"' "$@"
run tray_left_choc.stl   -D 'part="tray"'  -D 'side="left"'  -D 'switch_type="choc"' "$@"
run plate_right_choc.stl -D 'part="plate"' -D 'side="right"' -D 'switch_type="choc"' "$@"
run plate_left_choc.stl  -D 'part="plate"' -D 'side="left"'  -D 'switch_type="choc"' "$@"
run cover_right_choc.stl -D 'part="cover"' -D 'side="right"' -D 'switch_type="choc"' "$@"
run cover_left_choc.stl  -D 'part="cover"' -D 'side="left"'  -D 'switch_type="choc"' "$@"
run carry_frame_right.stl -D 'part="frame"' -D 'side="right"' "$@"
run carry_frame_left.stl  -D 'part="frame"' -D 'side="left"'  "$@"
run carry_frame_right_choc.stl -D 'part="frame"' -D 'side="right"' -D 'switch_type="choc"' "$@"
run carry_frame_left_choc.stl  -D 'part="frame"' -D 'side="left"'  -D 'switch_type="choc"' "$@"
run carry_mid.stl         -D 'part="mid"' -D 'switch_type="choc"' "$@"   # Choc only, the MX frames meet directly
run carry2_frame_right.stl -D 'part="frame2"' -D 'side="right"' "$@"   # compact MX carry case, ADR 0016
run carry2_frame_left.stl  -D 'part="frame2"' -D 'side="left"'  "$@"
run carry2_frame_right_choc.stl -D 'part="frame2"' -D 'side="right"' -D 'switch_type="choc"' "$@"
run carry2_frame_left_choc.stl  -D 'part="frame2"' -D 'side="left"'  -D 'switch_type="choc"' "$@"
run snap_test.stl  -D 'part="snap_test"' "$@"
run sleeve.stl     -D 'part="sleeve"' "$@"
run plate_test.stl -D 'part="plate_test"' "$@"
run template.svg   -D 'part="template"' "$@"
run template.pdf   -D 'part="template"' "$@" || echo "   (no PDF export in this OpenSCAD build, use the SVG)"
echo ">> done: $out"
