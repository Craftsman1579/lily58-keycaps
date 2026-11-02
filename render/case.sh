#!/usr/bin/env bash
# Renders the case images to docs/img/case/ for both boards (mx = PandaKB with DES caps, choc = Choc v1
# board with DES-Choc caps): assembled, exploded, section, controller cover close-up, carry case
# (closed, exploded, section); once: bottom view (same tray bottom for both), travel sleeve (MX).
# Needs the blank caps of stl/des_set_tol_0.025/ (./lily58_keycaps.sh des-all) and
# stl/des_choc_set_tol_0.025/ (./lily58_keycaps.sh des-choc-all).
# Usage: render/case.sh [mx|choc …] [-- extra OpenSCAD args, e.g. -D cc_caps=24]
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
root="$here/.."
scad="$here/case_scene.scad"
img="$root/docs/img/case"
mkdir -p "$img"

boards=(); extra=()
while [ $# -gt 0 ]; do
  case "$1" in
    --) shift; extra=("$@"); break;;
    *) boards+=("$1"); shift;;
  esac
done
[ ${#boards[@]} -gt 0 ] || boards=(mx choc)

backend=()
openscad --help 2>&1 | grep -q -- "--backend" && backend=(--backend=manifold)

for sw in "${boards[@]}"; do
  set_dir="$root/stl/des_set_tol_0.025/raw"; [ "$sw" = choc ] && set_dir="$root/stl/des_choc_set_tol_0.025/raw"
  [ -d "$set_dir" ] || { echo "missing $set_dir (build the keycap set first)"; exit 1; }
  parts="$root/stl/render/case/$sw"
  mkdir -p "$parts"
  base=(-D 'part="none"' -D "switch_type=\"$sw\"")

  for p in 1 2 3 4 5 6 7; do
    [ "$p" = 7 ] && [ "$sw" = choc ] && continue   # the sleeve is sized for the MX board
    echo ">> $sw part $p"
    openscad "${backend[@]}" "${base[@]}" -D P=$p ${extra[@]+"${extra[@]}"} -o "$parts/p$p.stl" "$scad" 2>&1 | grep -i error || true
  done

  shot() {  # <output name> <openscad args…>
    local o="$1"; shift
    echo ">> $o"
    openscad "${base[@]}" --colorscheme=Tomorrow "$@" ${extra[@]+"${extra[@]}"} -o "$img/$o" "$scad" 2>&1 | grep -i error || true
    [ -s "$img/$o" ] || { echo "   FAILED: $o"; return 1; }
  }
  shot "${sw}_assembled.png"      --imgsize=2000,1300 --camera=71,53,10,50,0,-25,340 -D 'VIEW="assembled"'
  shot "${sw}_exploded.png"       --imgsize=2000,1800 --camera=71,53,55,62,0,-25,700 -D 'VIEW="exploded"'
  shot "${sw}_section.png"        --imgsize=2400,700  --camera=71,18,0,0,0,0,165 --projection=o -D 'VIEW="section"'
  shot "${sw}_cover.png"          --imgsize=2000,1500 --camera=16,82,24,55,0,220,190 -D 'VIEW="cover"' -D EXPL=14
  shot "${sw}_carry.png"          --imgsize=2000,1300 --camera=71,53,39,62,0,35,460 -D 'VIEW="carry"'
  shot "${sw}_carry_exploded.png" --imgsize=2000,1500 --camera=71,53,39,62,0,35,600 -D 'VIEW="carry_exploded"' -D EXPL=26
  shot "${sw}_carry_section.png"  --imgsize=2400,1250 --camera=71,39,0,0,0,0,210 --projection=o \
    -D 'VIEW="carry_section"' -D CUT=95.8 -D BAND=0
  if [ "$sw" = mx ]; then
    shot bottom.png     --imgsize=2000,1500 --camera=-71,53,0,0,0,0,310 --projection=o -D 'VIEW="bottom"'
    shot travel.png     --imgsize=2000,1500 --camera=78,59,45,65,0,20,480 -D 'VIEW="travel"'
  fi
done
echo ">> done: $img"
