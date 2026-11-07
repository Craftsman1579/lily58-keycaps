#!/usr/bin/env bash
# Renders the keycap images to docs/img/keycaps/ for every variant: the set with legends in the
# Lily58 arrangement; per profile also the blank set and a close-up (German set), and the side profiles.
# The caps are shown with flat sides, as printed (render/flat.scad); flattened caps are cached in
# stl/render/keycaps/<variant>/.
# Needs the sets in stl/ (see the table below): ./lily58_keycaps.sh des-all, des-choc-all, kat-all,
# each also with LAYOUT=us.
# Usage: render/keycaps.sh [variant …]   variants: des des-us des-choc des-choc-us kat kat-us
#        KAT_TOL=0.10 render/keycaps.sh kat   (KAT sets of another tolerance; default 0.025)
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
img="$root/docs/img/keycaps"
mkdir -p "$img"
kat_tol="${KAT_TOL:-0.025}"

# variant -> set folder in stl/, profile (scene.py / flat.scad), image prefix
variant() {
  case "$1" in
    des)         echo "des_set_tol_0.025 des des des";;
    des-us)      echo "des_set_us_tol_0.025 des des des_us";;
    des-choc)    echo "des_choc_set_tol_0.025 des-choc choc des_choc";;
    des-choc-us) echo "des_choc_set_us_tol_0.025 des-choc choc des_choc_us";;
    kat)         echo "kat_set_tol_${kat_tol} kat kat kat";;
    kat-us)      echo "kat_set_us_tol_${kat_tol} kat kat kat_us";;
    *) echo "unknown variant: $1" >&2; exit 1;;
  esac
}

variants=("$@")
[ ${#variants[@]} -gt 0 ] || variants=(des des-us des-choc des-choc-us kat kat-us)

backend=()
openscad --help 2>&1 | grep -q -- "--backend" && backend=(--backend=manifold)
jobs_n="$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)"

shot() {  # <scene .scad> <output png> <openscad args…>
  local s="$1" o="$2"; shift 2
  echo ">> $(basename "$o")"
  openscad --colorscheme=Tomorrow "$@" -o "$o" "$s" 2>&1 | grep -i "^error" || true
  [ -s "$o" ] || { echo "   FAILED: $o"; return 1; }
}

for v in "${variants[@]}"; do
  read -r set prof cut name <<< "$(variant "$v")"
  raw="$root/stl/$set/raw"
  [ -d "$raw" ] || { echo "missing $raw (build the set first)"; exit 1; }
  work="$root/stl/render/keycaps/$v"
  caps="$work/caps"
  mkdir -p "$caps"

  # 1. Flatten every cap of the set (only caps whose raw file is newer than the cached STL)
  todo="$work/flatten.txt"; : > "$todo"
  for lst in "$raw"/*.lst; do
    while read -r key a b c d e f; do
      src="$raw/${key}_body.3mf"; dst="$caps/$key.stl"
      [ -s "$dst" ] && [ "$dst" -nt "$src" ] && continue
      if [ "$cut" = kat ]; then chords="[$b,$c,$d]"   # name ang xb xt zt kind h
      else chords="[$a,$b]"; fi                       # name R L len kind hgt
      printf '%s\t%s\t%s\n' "$src" "$dst" "$chords" >> "$todo"
    done < "$lst"
  done
  echo ">> $v: flattening $(wc -l < "$todo" | tr -d ' ') caps"
  export cut here BACKEND="${backend[*]-}"
  tr '\n' '\0' < "$todo" | xargs -0 -n 1 -P "$jobs_n" bash -c '
    IFS="$(printf "\t")" read -r src dst chords <<< "$1"
    openscad $BACKEND -D "F=\"$src\"" -D "K=\"$cut\"" -D "C=$chords" -o "$dst" "$here/flat.scad" >/dev/null 2>&1 \
      || echo "   FAILED: $dst"' _

  # 2. Scenes (scene.py) and images
  python3 "$root/tools/scene.py" "$prof" "$caps" "$raw" "$work"
  set_cam=(--imgsize=2000,1000 --camera=150,-235,447,150,30,0)
  shot "$work/set_labels.scad" "$img/${name}_set_labeled.png" "${set_cam[@]}"
  case "$v" in *-us) continue;; esac          # blank caps and close-up are the same for both layouts
  shot "$work/set_blank.scad" "$img/${name}_set_blank.png" "${set_cam[@]}"
  cx=46; [ "$prof" = kat ] && cx=50
  shot "$work/closeup.scad" "$img/${name}_closeup.png" --imgsize=2000,800 --camera=$cx,-80,113,$cx,2,4
done

# 3. Side profiles of one column (2 W S X) of every profile, when all three German sets exist
if [ -d "$root/stl/des_set_tol_0.025/raw" ] && [ -d "$root/stl/des_choc_set_tol_0.025/raw" ] \
   && [ -d "$root/stl/kat_set_tol_${kat_tol}/raw" ]; then
  shot "$here/side_profiles.scad" "$img/side_profiles.png" -D "KAT=\"kat_set_tol_${kat_tol}\"" \
    --imgsize=2400,700 --camera=125,0,9,90,0,0,250 --projection=o
fi
echo ">> done: $img"
