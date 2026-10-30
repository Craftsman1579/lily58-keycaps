#!/usr/bin/env bash
# Exports the case parts to stl/case/: tray_right, tray_left, plate (print 2, flip one for the left
# half), plate_test, and template.pdf/.svg (1:1 paper template of the PCB).
# Extra arguments go to OpenSCAD, e.g.: case/build.sh -D cutout=14.1 -D under_clear=3.5
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
run plate.stl      -D 'part="plate"' "$@"
run plate_test.stl -D 'part="plate_test"' "$@"
run template.svg   -D 'part="template"' "$@"
run template.pdf   -D 'part="template"' "$@" || echo "   (no PDF export in this OpenSCAD build, use the SVG)"
echo ">> done: $out"
