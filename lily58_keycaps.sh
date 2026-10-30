#!/usr/bin/env bash
# ============================================================================
#  Lily58-Keycaps (DES, KAT, DSA) fuer den Seitendruck auf FDM-Druckern
#
#  Baut auf PseudoMakeMeKeyCapProfiles (pseudoku, GPL-3.0) und Riskables
#  keycap_playground auf; Credits und Aenderungen siehe README.md.
#  SPDX-License-Identifier: GPL-3.0-only
#
#  Aufruf:
#    ./lily58_keycaps.sh test          -> 4 Testkappen (Stem-Toleranz 0.10/0.15/0.20/0.25)
#    ./lily58_keycaps.sh all 0.20      -> kompletter Satz mit Toleranz 0.20
#    ./lily58_keycaps.sh kat-test      -> KAT-Passtest: leere Home-Kappen, je Toleranz eine
#                                         Datei (Standard 0.025 0.05 0.075 0.10)
#    ./lily58_keycaps.sh kat-all       -> KAT-Satz, deutsches Layout, Symbole,
#                                         Seiten plan (Standard-Toleranz 0.20)
#    LAYOUT=us ./lily58_keycaps.sh kat-all -> KAT-Satz mit US-QWERTY-Belegung
#    ./lily58_keycaps.sh des-all       -> derselbe Satz im DES-Profil (pseudoku):
#                                         MX_DES_Standard + MX_DES_Thumb
#                                         (Standard-Toleranz 0.025)
#    LAYOUT=us ./lily58_keycaps.sh des-all -> DES-Satz mit US-QWERTY-Belegung
#    ./lily58_keycaps.sh des-test      -> DES-Passtest: leere Home-Kappen, je Toleranz eine
#                                         Datei (Standard 0.00 0.025 0.05 0.075,
#                                         eigene Werte: des-test "0.03 0.06")
#
#  Optional:
#    INNER=1 ./lily58_keycaps.sh all 0.20   -> zusaetzlich [ und ] fuer die
#                                              inneren Tasten der untersten Reihe
#    KEYCAP_DIR=/pfad/zum/ordner ...        -> anderen Zielordner erzwingen
#
#  Laeuft unter Linux, macOS und Windows (Git Bash).
# ============================================================================
set -euo pipefail

MODE="${1:-test}"
TOL="${2:-0.20}"   # 0.20 fuer 0.4-mm-Duese
# DES rechnet die Toleranz auf jede Seite des Kreuzes; 0.025 hat im Passtest gepasst
if [ "$MODE" = "des-all" ] && [ -z "${2:-}" ]; then TOL=0.025; fi

# --- 1. Dokumente-Ordner finden ---------------------------------------------
find_docs () {
  if [ -n "${KEYCAP_DIR:-}" ]; then echo "$KEYCAP_DIR"; return; fi
  if [ "${OS:-}" = "Windows_NT" ]; then
    for d in "$HOME/OneDrive/Dokumente" "$HOME/OneDrive/Documents"; do
      [ -d "$d" ] && { echo "$d"; return; }
    done
  fi
  if command -v xdg-user-dir >/dev/null 2>&1; then
    d="$(xdg-user-dir DOCUMENTS 2>/dev/null || true)"
    if [ -n "$d" ] && [ "$d" != "$HOME" ] && [ -d "$d" ]; then echo "$d"; return; fi
  fi
  for d in "$HOME/Documents" "$HOME/Dokumente"; do
    [ -d "$d" ] && { echo "$d"; return; }
  done
  echo "$HOME/Documents"
}
DOCS="$(find_docs)"
WORK="$DOCS/lily58_keycaps"
REPO="$WORK/keycap_playground"
JOBS="$WORK/jobs"
mkdir -p "$WORK" "$JOBS"
echo ">> Arbeitsordner: $WORK"

# --- 2. Werkzeuge pruefen -----------------------------------------------------
command -v git >/dev/null 2>&1 || { echo "FEHLER: git nicht gefunden."; exit 1; }

OPENSCAD=""
for c in openscad \
         "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD" \
         "/c/Program Files/OpenSCAD/openscad.com" \
         "/c/Program Files/OpenSCAD/openscad.exe" \
         "/c/Program Files/OpenSCAD (Nightly)/openscad.com" \
         "/c/Program Files/OpenSCAD (Nightly)/openscad.exe"; do
  if command -v "$c" >/dev/null 2>&1 || [ -x "$c" ]; then OPENSCAD="$c"; break; fi
done
[ -n "$OPENSCAD" ] || { echo "FEHLER: OpenSCAD nicht gefunden. Bitte installieren."; exit 1; }
echo ">> OpenSCAD: $OPENSCAD"

# Schnelles Manifold-Backend nutzen, falls die Version es kann
BACKEND=()
if "$OPENSCAD" --help 2>&1 | grep -q -- "--backend"; then
  BACKEND=(--backend=Manifold)
  echo ">> Manifold-Backend aktiv (schnell)"
else
  echo ">> Hinweis: Alte OpenSCAD-Version ohne Manifold - Rendern dauert deutlich laenger."
fi
# textmetrics() liefert die sichtbare Ausdehnung des Textes; halign/valign="center"
# zentriert nur nach Schrittweite, Symbole sitzen damit bis ueber 1 mm daneben
TEXTM=()
"$OPENSCAD" --help 2>&1 | grep -q textmetrics && TEXTM=(--enable=textmetrics)
need_textmetrics () {
  [ ${#TEXTM[@]} -gt 0 ] || { echo "FEHLER: OpenSCAD ohne textmetrics (Nightly/Snapshot noetig) - Legenden waeren nicht zentriert."; exit 1; }
}

# --- 3. Repo klonen / aktualisieren --------------------------------------------
if [ -d "$REPO/.git" ]; then
  echo ">> Repo vorhanden, aktualisiere ..."
  git -C "$REPO" pull --ff-only || echo ">> (Update uebersprungen)"
else
  echo ">> Klone Repo ..."
  git clone https://github.com/riskable/keycap_playground.git "$REPO"
fi

# --- 4. Basis-Konfiguration (DSA, auf der Seite, Lily58) ----------------------
# Spaetere Zuweisungen ueberschreiben in OpenSCAD fruehere - daher include + override.
# Seitendruck: glatte Mulde oben, Schichten laufen laengs zum Stem (stabiler).
# Die DSA-Seitenwand ist leicht gewoelbt (~0.4 mm); bei 112.4 Grad liegt der
# Scheitel mittig auf, beide Enden stehen gleich hoch. Brim empfohlen.
cat > "$REPO/lily58_base.scad" <<'EOF'
include <keycap_playground.scad>

KEY_PROFILE        = "dsa";
KEY_ROTATION       = [0,112.4,90];  // auf der Seite drucken
STEM_SIDE_SUPPORTS = [0,1,0,0];     // eingebaute Stuetze unter dem Stem (abbrechen)
// Runder Stem: passt in die Gehaeuseoeffnung von Cherry und Gateron (der eckige
// box_cherry-Stem eckt mit den Ecken an). Durchmesser = 5.47 - Toleranz -> 5.7 mm.
STEM_TYPE                = "round_cherry";
STEM_OUTSIDE_TOLERANCE_X = -0.23;
LEGEND_FONTS       = ["Liberation Sans:style=Bold"]; // liegt OpenSCAD bei
LEGEND_FONT_SIZES  = [5];
HOMING_DOT_LENGTH  = 0;
ROW_SPACING        = KEY_UNIT + 4;  // etwas Luft zwischen den Kappen
EOF

# --- 5. Render-Helfer -----------------------------------------------------------
OUT=""
# job <name> <row|single>   (Overrides kommen per stdin)
job () {
  local name="$1" kind="$2" f="$JOBS/$1.scad" body legs
  { echo "include <../keycap_playground/lily58_base.scad>"; cat; } > "$f"
  if [ "$kind" = row ]; then
    body='["row","row_stems"]'; legs='["row_legends"]'
  else
    body='["keycap","stem"]';   legs='["legends"]'
  fi
  echo ">> [$name] Kappe + Stem ..."
  "$OPENSCAD" "${BACKEND[@]}" -o "$OUT/${name}_body.stl" \
      -D "STEM_INSIDE_TOLERANCE=$TOL" -D "RENDER=$body" "$f"
  echo ">> [$name] Legenden ..."
  "$OPENSCAD" "${BACKEND[@]}" -o "$OUT/${name}_legends.stl" \
      -D "STEM_INSIDE_TOLERANCE=$TOL" -D "RENDER=$legs" "$f"
}

# --- 6a. Testkappen -------------------------------------------------------------
if [ "$MODE" = "test" ]; then
  OUT="$WORK/stl/test"; mkdir -p "$OUT"
  for TOL in 0.10 0.15 0.20 0.25; do
    job "test_tol_${TOL}" single <<'EOF'
LEGENDS = ["A"];
EOF
  done
  echo
  echo ">> Fertig. Testkappen liegen in: $OUT"
  echo ">> Drucken, am MX Red testen, dann: ./lily58_keycaps.sh all <beste Toleranz>"
  exit 0
fi

# Symbole kommen aus der JetBrains Mono Nerd Font (Material-Design-Tastensymbole);
# sie wird neben die Jobs kopiert und dort per use <symbols.ttf> geladen.
copy_symfont () {
  local d SYMFONT=""
  for d in "$HOME/Library/Fonts" "/Library/Fonts" "$HOME/.local/share/fonts" "/usr/share/fonts" "/c/Windows/Fonts"; do
    [ -d "$d" ] || continue
    SYMFONT="$(find -L "$d" -name 'JetBrainsMonoNerdFont-Bold.ttf' 2>/dev/null | head -1)"
    [ -n "$SYMFONT" ] && break
  done
  [ -n "$SYMFONT" ] || { echo "FEHLER: JetBrainsMonoNerdFont-Bold.ttf nicht gefunden (Nerd Fonts installieren)."; exit 1; }
  rm -f "$JOBS/symbols.ttf"; cp "$SYMFONT" "$JOBS/symbols.ttf"; chmod u+w "$JOBS/symbols.ttf"   # Nix-Store-Kopien sind schreibgeschuetzt
}

# Herausziehbare Stem-Stuetze fuer kat-all und des-all: steht vor der Oeffnung auf dem Bett,
# ein Steg reicht durch die Oeffnung unter den Stem; sie beruehrt die Kappe nirgends.
write_stemsupport () {
  cat > "$JOBS/stemsupport.scad" <<'EOF'
// Herausziehbare Stem-Stuetze fuer den Seitendruck, im aufrechten Kappen-System (+x = Druckseite).
// Fuss vor der Oeffnung steht auf dem Bett (Sehnenebene R), Steg reicht durch die Oeffnung unter
// den Stem. Beruehrt die Kappe nicht: ~0.3 mm zur Wand, 0.2 mm zum Stem (Radius 2.85).
// file = aufrechte Kappe, R = [xb, zb, xt, zt] der Druckseite, H = Kappenhoehe
function sup_chord_x(c, z) = c[0] + (c[2]-c[0])*(z-c[1])/(c[3]-c[1]);

module stem_support(file, R, H, t=1.2, stem_r=2.85, gap_stem=0.2) {
  x0 = stem_r + gap_stem;
  // Innenraum: Huelle minus Kappe ohne den ~0.9 mm breiten Huellenrand (dort liegen die duennen
  // Schalen an eingezogenen Aussenwaenden), seitlich um ~0.3 mm (bei x~6.5) geschrumpft, Decke
  // 0.3 mm tiefer. Die abgesenkte Kopie ist seitlich minimal kleiner, damit senkrechte Innenwaende
  // nicht deckungsgleich aufeinanderliegen.
  module hollow() scale([0.955,0.955,1]) intersection() {
    difference() { hull() import(file); import(file); }
    scale([0.9,0.9,1]) hull() import(file);
  }
  module cavity() intersection() {
    hollow();
    translate([0,0,-0.3]) scale([0.99,0.99,1]) hollow();
  }
  // Steg unter dem Stem; die unterste Innenraum-Schicht wird bis vor die Oeffnung verlaengert
  // (ueberlappt den Innenraum, der bei schraegem Rand erst knapp ueber z=0 beginnt; leicht
  // verkleinert, damit senkrechte Innenwaende nicht deckungsgleich aufeinanderliegen)
  module fin_region() union() {
    cavity();
    translate([0,0,-0.55]) scale([0.98,0.98,1]) intersection() { cavity(); translate([-20,-20,0]) cube([40,40,0.6]); }
  }
  intersection() {
    fin_region();
    translate([x0, -t/2, -0.35]) cube([20, t, H - 3.2 + 0.35]);   // darueber liegt die Mulde
  }
  // Fuss vor der Oeffnung: oben so schmal wie der Steg, am Bett 5 mm breit
  hull() {
    translate([x0, -t/2, -3]) cube([0.05, t, 2.7]);
    rotate([90,0,0]) linear_extrude(5, center=true)
      polygon([[sup_chord_x(R,-0.3)-0.6,-0.3], [sup_chord_x(R,-0.3),-0.3],
               [sup_chord_x(R,-3),-3], [sup_chord_x(R,-3)-0.6,-3]]);
  }
}
EOF
}

# --- 6c. KAT-Satz mit deutschem Layout (QWERTZ, ohne Sonderzeichen) -----------
# Zahlen R4, QWERTZ R3, Home R2, untere Reihe und Daumen R1; leere Kappen dort,
# wo im deutschen Layout Sonderzeichen liegen, plus je Reihe eine Ersatzkappe.
# Seiten links/rechts werden entlang der Sehne plan geschnitten (untere Randecke
# XB,0 -> obere Seitenkante XT,ZT der aufrechten Kappe); der Druckwinkel ergibt
# sich aus derselben Sehne, damit die plane Seite voll auf dem Bett liegt.
# Saubere Netze fuer den Slicer: Kappen aufrecht rendern, im Kappen-System
# schneiden und erst zum Schluss drehen (Drehen im Playground erzeugt Splitter-
# dreiecke), Zwischenschritte als 3MF, Stem-Waende 0.3 mm ueber dem Rand enden
# lassen (deckungsgleiche Flaechen mit dem Rand ergeben sonst offene Kanten).
# Die Gruppen sind STL, weil Bambu Studio nur STL als ein Objekt mit Teilen laedt.
if [ "$MODE" = "kat-all" ] || [ "$MODE" = "kat-test" ]; then
  KATLAYOUT="${LAYOUT:-de}"   # de = QWERTZ ohne Sonderzeichen, us = US-QWERTY wie im Lily58-Standard
  if [ "$MODE" = "kat-test" ]; then OUT="$WORK/stl/kat_passtest"
  elif [ "$KATLAYOUT" = us ]; then OUT="$WORK/stl/kat_set_us_tol_${TOL}"
  else OUT="$WORK/stl/kat_set_tol_${TOL}"; fi
  RAW="$OUT/raw"
  rm -rf "$RAW"; rm -f "$OUT"/*.stl "$OUT"/*.3mf; mkdir -p "$RAW"
  REL="../stl/$(basename "$OUT")/raw"   # Pfad aus Sicht von $JOBS

  need_textmetrics
  copy_symfont
  write_stemsupport

  cat > "$JOBS/flatlib.scad" <<'EOF'
// Seitenwaende links/rechts plan schneiden, im Kappen-Koordinatensystem (aufrecht)
module flat_cut(xb, xt, zt) {
  rotate([90,0,0]) linear_extrude(height=100, center=true)
    polygon([[ xb-(xb-xt)*-20/zt, -20], [ xb-(xb-xt)*40/zt, 40],
             [-(xb-(xb-xt)*40/zt), 40], [-(xb-(xb-xt)*-20/zt), -20]]);
}
EOF

  #           Hoehe Stem Sehne XT ZT
  #           Hoehe Stem Sehne XT ZT  top_y (Versatz der Oberseite nach hinten, aus profiles.scad)
  kat_row () {
    case "$1" in
      1) echo "10.95 4   6.05 10.42 0.75";;
      2) echo "9.15  4   5.99 8.97  0.75";;
      3) echo "10.9  4   6.05 10.39 0.75";;
      4) echo "11.9  4.5 6.07 11.45 0.65";;
    esac
  }

  # kat_key <name> <reihe> <art> <wert> [<laenge in u>]
  #   art: t = Text, h = Text mit Homing-Punkt, s = Symbol (Unicode-Codepunkt dezimal), b = leer,
  #        d = leer mit Homing-Punkt
  #   1.5u gibt es nur fuer R1 (Daumen); XB = halbe Kappenlaenge unten
  kat_key () {
    local name="$1" row="$2" kind="$3" val="$4" units="${5:-1}" f="$JOBS/$1.scad"
    local h sh xt zt topy xb=9.12 ang leg font size=5 dot=0 dotz=-0.35
    read -r h sh xt zt topy <<< "$(kat_row "$row")"
    if [ "$units" = "1.5" ]; then xb=13.89; xt=11.16; zt=9.87; fi
    ang=$(awk -v xb=$xb -v xt="$xt" -v zt="$zt" 'BEGIN{printf "%.2f", 90+atan2(xb-xt,zt)*45/atan2(1,1)}')
    font='"Liberation Sans:style=Bold"'
    case "$kind" in
      t) leg="\"$val\"";;
      h) leg="\"$val\""; dot=3; dotz=0.6;;   # Standardhoehe liegt bei KAT unter der Mulde
      s) leg="chr($val)"; font='"JetBrainsMono Nerd Font:style=Bold"'; size=5.5;;
      b) leg='""';;
      d) leg='""'; dot=3; dotz=0.6;;
    esac
    cat > "$f" <<EOF
use <symbols.ttf>
include <../keycap_playground/lily58_base.scad>
KEY_PROFILE       = "kat";
KEY_ROW           = $row;
KEY_HEIGHT        = $h;
STEM_HEIGHT       = $sh;
KEY_ROTATION      = [0,0,0];       // gedreht wird erst nach dem Seitenschnitt
STEM_WALLS_INSET  = 0.3;
STEM_SIDE_SUPPORTS = [0,0,0,0];   // Stuetze kommt als herausziehbarer Einsatz (stemsupport.scad)
// keine Stem-Auskleidung (laesst an den gewoelbten KAT-Waenden eingeschlossene Hohlraeume),
// stattdessen Wand so dick wie bisher Wand + Auskleidung (1.01 + 0.8)
STEM_SIDES_WALL_THICKNESS = 0;
WALL_THICKNESS    = 1.8;
KEY_LENGTH        = KEY_UNIT*$units - BETWEENSPACE;
LEGENDS           = [$leg];
LEGEND_FONTS      = [$font];
LEGEND_FONT_SIZES = [$size];
HOMING_DOT_LENGTH = $dot;
HOMING_DOT_Z      = $dotz;
// Legende nach ihrer sichtbaren Form zentrieren (halign/valign zentrieren nur nach Schrittweite),
// auf der Mitte der Oberseite statt der Grundflaeche (top_y)
LEGEND_TRANS      = LEGENDS[0] == "" ? [[0,0,0]] :
  let(tm = textmetrics(LEGENDS[0], size=LEGEND_FONT_SIZES[0], font=LEGEND_FONTS[0], halign="center", valign="center"))
  [[-(tm.position[0]+tm.size[0]/2), $topy-(tm.position[1]+tm.size[1]/2), 0]];
EOF
    echo ">> [$name] R$row ${kind}:${val}"
    "$OPENSCAD" "${BACKEND[@]}" "${TEXTM[@]}" -o "$RAW/${name}_body.3mf" \
        -D "STEM_INSIDE_TOLERANCE=$TOL" -D 'RENDER=["keycap","stem"]' "$f" >/dev/null 2>&1
    if [ "$kind" != b ] && [ "$kind" != d ]; then
      "$OPENSCAD" "${BACKEND[@]}" "${TEXTM[@]}" -o "$RAW/${name}_legends.3mf" \
          -D "STEM_INSIDE_TOLERANCE=$TOL" -D 'RENDER=["legends"]' "$f" >/dev/null 2>&1
    fi
    [ -s "$RAW/${name}_body.3mf" ] || { echo "FEHLER: $name wurde nicht gerendert."; exit 1; }
    if [ "$kind" != b ] && [ "$kind" != d ] && [ ! -s "$RAW/${name}_legends.3mf" ]; then
      echo "FEHLER: Legende fuer $name fehlt."; exit 1
    fi
    echo "$name $ang $xb $xt $zt $kind $h" >> "$RAW/${name%_*}.lst"
  }

  if [ "$MODE" = "kat-test" ]; then
  # Passtest: leere Home-Kappe (KAT R2, das Kreuzloch ist in allen Reihen gleich), je Toleranz eine
  # Datei. KAT verrechnet die Toleranz anders als DES: waagerechter Arm 1.3+t, senkrechter 1.1+2t.
  for TOL in ${2:-0.025 0.05 0.075 0.10}; do
    kat_key "Passtest_tol_${TOL}_00" 2 b -
  done
  else
  # Gruppe <name> <reihe> <art:wert> ...   (Reihenfolge von aussen nach innen bzw. links nach rechts);
  # Belegung der Hauptreihen je nach Layout, danach die fuer beide gleichen Gruppen
  if [ "$KATLAYOUT" = us ]; then
    KEYLIST=$(cat <<'KEYS'
R4_links      4  s:987831 t:1 t:2 t:3 t:4 t:5
R4_rechts     4  t:6 t:7 t:8 t:9 t:0 t:`
R3_links      3  s:983826 t:Q t:W t:E t:R t:T
R3_rechts     3  t:Y t:U t:I t:O t:P t:-
R2_links      2  s:984628 t:A t:S t:D h:F t:G
R2_rechts     2  t:H h:J t:K t:L t:; t:'
R1_links      1  s:984630 t:Z t:X t:C t:V t:B t:[
R1_rechts     1  t:] t:N t:M t:, t:. t:/ s:984630
KEYS
)
  else
    KEYLIST=$(cat <<'KEYS'
R4_links      4  s:987831 t:1 t:2 t:3 t:4 t:5
R4_rechts     4  t:6 t:7 t:8 t:9 t:0 s:8998
R3_links      3  s:983826 t:Q t:W t:E t:R t:T
R3_rechts     3  t:Z t:U t:I t:O t:P b:-
R2_links      2  s:984628 t:A t:S t:D h:F t:G
R2_rechts     2  t:H h:J t:K t:L b:- b:-
R1_links      1  s:984630 t:Y t:X t:C t:V t:B b:-
R1_rechts     1  b:- t:N t:M b:- b:- b:- s:984630
KEYS
)
  fi
  KEYLIST+=$'\n'"$(cat <<'KEYS'
Daumen_links  1  s:984629 s:984627 s:9660 s:987216:1.5
Daumen_rechts 1  s:983825:1.5 s:9650 s:9003 s:984627
Ersatz_R4     4  b:-
Ersatz_R3     3  b:-
Ersatz_R2     2  b:-
Ersatz_R1     1  b:-
Daumen_leer   1  b:- b:- b:- b:-:1.5 b:-:1.5 b:- b:- b:-
Homing_leer   2  d:- d:-
KEYS
)"
  set -f   # Satzzeichen wie [ nicht als Dateinamen-Muster auslegen
  while read -r grp row keys; do
    [ -z "$grp" ] && continue
    n=0
    for k in $keys; do
      IFS=: read -r kind val units <<< "$k"
      kat_key "${grp}_$(printf '%02d' $n)" "$row" "$kind" "$val" "$units"
      n=$((n+1))
    done
  done <<< "$KEYLIST"
  set +f
  fi
  # Daumen: Space und Enter 1.5u (innerste Daumentaste des Lily58 Pro)
  # Symbole: 987831 Esc, 8998 Entf, 983826 Tab, 984628 Strg, 984630 Shift,
  #          984629 Alt, 984627 GUI, 9660 Lower, 987216 Space, 983825 Enter,
  #          9650 Raise, 9003 Backspace

  # Gruppen zusammensetzen: Kappen nebeneinander, Seiten plan geschnitten
  for lst in "$RAW"/*.lst; do
    grp="$(basename "$lst" .lst)"; g="$JOBS/group_${grp}.scad"; gl="$JOBS/group_${grp}_legends.scad"
    printf 'include <flatlib.scad>\ninclude <stemsupport.scad>\n' > "$g"; : > "$gl"; idx=0; haslegs=0
    while read -r name ang xb xt zt kind h; do
      # Auflage jeder Kappe auf z=0 heben (die untere Randecke liegt nach der Drehung bei -xb*sin(ang))
      echo "translate([$idx*(KEY_UNIT+4),0,$xb*sin($ang)]) rotate([0,$ang,90]) intersection() { import(\"$REL/${name}_body.3mf\"); flat_cut($xb, $xt, $zt); }" >> "$g"
      echo "translate([$idx*(KEY_UNIT+4),0,$xb*sin($ang)]) rotate([0,$ang,90]) stem_support(\"$REL/${name}_body.3mf\", [$xb,0,$xt,$zt], $h);" >> "$g"
      if [ "$kind" != b ] && [ "$kind" != d ]; then
        echo "translate([$idx*(KEY_UNIT+4),0,$xb*sin($ang)]) rotate([0,$ang,90]) import(\"$REL/${name}_legends.3mf\");" >> "$gl"; haslegs=1
      fi
      idx=$((idx+1))
    done < "$lst"
    sed -i.bak '1a\
KEY_UNIT = 19.05;' "$g" && rm -f "$g.bak"
    echo ">> [Gruppe $grp] Kappen ..."
    "$OPENSCAD" "${BACKEND[@]}" -o "$OUT/${grp}_body.stl" "$g" >/dev/null 2>&1
    if [ "$haslegs" = 1 ]; then
      sed -i.bak '1i\
KEY_UNIT = 19.05;' "$gl" && rm -f "$gl.bak"
      echo ">> [Gruppe $grp] Legenden ..."
      "$OPENSCAD" "${BACKEND[@]}" -o "$OUT/${grp}_legends.stl" "$gl" >/dev/null 2>&1
    fi
  done

  echo
  echo ">> Fertig: $(cat "$RAW"/*.lst | wc -l | tr -d ' ') Kappen in $OUT"
  echo ">> Je Gruppe: *_body.stl + *_legends.stl -> zusammen in Bambu Studio ziehen."
  exit 0
fi

# --- 6d. DES-Satz (pseudoku/PseudoMakeMeKeyCapProfiles), gleiches Layout -------
# Hauptreihen aus MX_DES_Standard (R1 Zahlen = keyID 5, R2 QWERTZ = 2, R3 Home = 1,
# R4 unten = 0), Daumen aus MX_DES_Thumb (High-Profile: 1.5u = 0, 1u = 1, aussen 2).
# Die Daumenkappen sind seitlich geneigt; ungespiegelt passen ID 1/2 zur rechten
# Haelfte, ID 0 umgekehrt (so ordnet das Repo sie an).
# Eigenes Kappenmodul (deslib.scad) mit den Formfunktionen des Profils: runder 5.7-mm-
# Stem, Legende als eigenes Teil, Homing-Steg, Spiegelung mit
# lesbarer Schrift, und ohne die deckungsgleichen Flaechen des Originals (Kreuzloch,
# Mulden-Naht), die beim Slicer-Import offene Kanten ergeben.
if [ "$MODE" = "des-all" ] || [ "$MODE" = "des-test" ]; then
  DESREPO="$WORK/PseudoMakeMeKeyCapProfiles"; DESLIB="$WORK/des_libs"
  if [ -d "$DESREPO/.git" ]; then
    git -C "$DESREPO" pull --ff-only || echo ">> (DES-Update uebersprungen)"
  else
    git clone --depth 1 https://github.com/pseudoku/PseudoMakeMeKeyCapProfiles.git "$DESREPO"
  fi
  [ -d "$DESLIB/libraries" ] || { mkdir -p "$DESLIB" && unzip -q -o "$DESREPO/libraries.zip" -d "$DESLIB"; }
  export OPENSCADPATH="$DESLIB/libraries"

  DESLAYOUT="${LAYOUT:-de}"   # de = QWERTZ ohne Sonderzeichen, us = US-QWERTY wie im Lily58-Standard
  if [ "$MODE" = "des-test" ]; then OUT="$WORK/stl/des_passtest"
  elif [ "$DESLAYOUT" = us ]; then OUT="$WORK/stl/des_set_us_tol_${TOL}"
  else OUT="$WORK/stl/des_set_tol_${TOL}"; fi
  RAW="$OUT/raw"; mkdir -p "$RAW"
  for lst in "$RAW"/*.lst; do [ -e "$lst" ] && : > "$lst"; done   # Gruppenlisten neu beginnen
  REL="../stl/$(basename "$OUT")/raw"   # Pfad aus Sicht von $JOBS
  need_textmetrics
  copy_symfont
  write_stemsupport

  # Profile ohne ihren eigenen keycap()-Aufruf, damit sie per include nutzbar sind
  for p in Standard Thumb; do
    sed '/^ *mirror(\[0,0,0\]) *keycap(/,/^ *);/d' "$DESREPO/MX_DES_$p.scad" > "$JOBS/des_$p.scad"
  done

  cat > "$JOBS/deslib.scad" <<'EOF'
// DES-Kappe mit den Lily58-Einstellungen; Profil wird von der aufrufenden Datei per include geladen
module des_cap(keyID, part="body", legend="", font="Liberation Sans:style=Bold", size=5,
               dot=false, dotz=0, mir=0, legrot=0, stemD=5.7) {
  FrontPath = quantize_trajectories(FrontTrajectory(keyID), steps = stepsize, loop=false, start_position= $t*4);
  BackPath  = quantize_trajectories(BackTrajectory(keyID),  steps = stepsize, loop=false, start_position= $t*4);
  function FrontDishArc(t) =  pow((t)/(len(FrontPath)),FrontArcExpo(keyID))*FrontFinArc(keyID) + (1-pow(t/(len(FrontPath)),FrontArcExpo(keyID)))*FrontInitArc(keyID);
  function BackDishArc(t)  =  pow((t)/(len(FrontPath)),BackArcExpo(keyID))*BackFinArc(keyID) + (1-pow(t/(len(FrontPath)),BackArcExpo(keyID)))*BackInitArc(keyID);
  FrontCurve = [ for(i=[0:len(FrontPath)-1]) transform(FrontPath[i], DishShape(DishDepth(keyID), FrontDishArc(i), 1, d = 0)) ];
  BackCurve  = [ for(i=[0:len(BackPath)-1])  transform(BackPath[i],  DishShape(DishDepth(keyID),  BackDishArc(i), 1, d = 0)) ];
  H  = KeyHeight(keyID);
  cx = -TopWidShift(keyID); cy = -TopLenShift(keyID);
  topRot = CapRotation(layers-1, keyID);

  module outer() skin([for (i=[0:layers-1]) transform(translation(CapTranslation(i, keyID)) * rotation(CapRotation(i, keyID)), elliptical_rectangle(CapTransform(i, keyID), b = CapRoundness(i,keyID),fn=fn))]);
  module inner() translate([0,0,-.001]) skin([for (i=[0:layers-1]) transform(translation(InnerTranslation(i, keyID)) * rotation(CapRotation(i, keyID)), elliptical_rectangle(InnerTransform(i, keyID), b = CapRoundness(i,keyID),fn=fn))]);
  module dish() {
    // vordere Haelfte 0.05 statt 0.00001 versetzt: die Haelften ueberlappen statt fast zu beruehren
    translate([-TopWidShift(keyID),0.05-TopLenShift(keyID),H-DishHeightDif(keyID)])rotate([0,-YAngleSkew(keyID),0])rotate([0,-90+XAngleSkew(keyID),90-ZAngleSkew(keyID)])skin(FrontCurve);
    translate([-TopWidShift(keyID),-TopLenShift(keyID),H-DishHeightDif(keyID)])rotate([0,-YAngleSkew(keyID),0])rotate([0,-90-XAngleSkew(keyID),270-ZAngleSkew(keyID)])skin(BackCurve);
  }
  // Kreuzloch wie im Original (stem_internal, 5.25 tief, Einfuehrschraege 1.1 -> 1.0); das Kreuz
  // beginnt unter dem Stem-Boden, damit es keine gemeinsame Flaeche mit ihm hat
  module stem() translate([0,0,StemBrimDep]) difference() {
    cylinder(d=stemD, h=H-StemBrimDep, $fn=64);
    translate([0,0,-0.5]) linear_extrude(5.75) polygon(stem_internal());
    flare_arm(MXWid, MXWidT);   // waagerechter Arm
    flare_arm(MXLenT, MXLen);   // senkrechter Arm
  }
  // Einfuehrschraege je Arm: bei z=0 auf 1.1 aufgeweitet wie im Original; Breite (x) und Laenge (y)
  // verjuengen sich verschieden schnell, damit keine Kante exakt durch eine Kreuzecke laeuft
  module flare_arm(hx, hy) hull() {
    translate([0,0,-0.3]) linear_extrude(0.01) square([2*hx*1.16, 2*hy*1.18], center=true);
    translate([0,0, 0.75]) linear_extrude(0.01) square([2*hx*0.95, 2*hy*0.90], center=true);
  }
  // Textsaeule senkrecht zur Oberseite; Text vorgespiegelt, damit er nach mirror() lesbar bleibt,
  // und nach seiner sichtbaren Form zentriert (halign/valign zentrieren nur nach Schrittweite)
  tm = textmetrics(legend, size=size, font=font, halign="center", valign="center");
  module column() translate([cx,cy,H]) rotate(topRot) translate([0,0,-6]) linear_extrude(12)
    mirror([mir,0,0]) rotate(legrot) translate([-(tm.position[0]+tm.size[0]/2), -(tm.position[1]+tm.size[1]/2)])
      text(legend, size=size, font=font, halign="center", valign="center");
  // Legende endet 0.3 mm ueber der Innendecke (sonst deckungsgleich mit der Innenflaeche)
  module legendvol() intersection() { column(); difference() { outer(); dish(); translate([0,0,0.3]) inner(); } }
  // Aussparung in der Kappe: Textsaeule bis ueber die Mulde (nicht deckungsgleich mit der Muldenflaeche)
  module legendcut() difference() { column(); translate([0,0,0.3]) inner(); }
  // Homing-Steg 3 x 1 mm vorne in der Mulde, dotz = Hoehe der Muldenoberflaeche dort
  module homing() translate([cx, cy-4.3, dotz+0.1]) rotate([0,90,0]) cylinder(d=1, h=3, center=true, $fn=24);

  if (part == "body") {
    mirror([mir,0,0]) {
      difference() {
        union() { difference() { outer(); inner(); } stem(); }
        dish();
        if (legend != "") legendcut();
      }
      if (dot) homing();
    }
  } else if (part == "legend" && legend != "") {
    mirror([mir,0,0]) legendvol();
  }
}
EOF

  cat > "$JOBS/desflat.scad" <<'EOF'
// Seiten plan schneiden; R/L = [xb, zb, xt, zt] der rechten (+x) bzw. linken (-x) Sehne
function chord_x(c, z) = c[0] + (c[2]-c[0])*(z-c[1])/(c[3]-c[1]);
module flat_cut(R, L) {
  rotate([90,0,0]) linear_extrude(height=100, center=true)
    polygon([[chord_x(R,0.02),0.02], [chord_x(R,40),40], [-chord_x(L,40),40], [-chord_x(L,0.02),0.02]]);
}
// Kappe aus dem aufrechten System auf die rechte Seite legen, Auflage auf z=0
module print_pose(R) {
  a = 90 + atan2(R[0]-R[2], R[3]-R[1]);
  translate([0,0,R[0]*sin(a) - R[1]*cos(a)]) rotate([0,a,90]) children();
}
EOF

  # Kappenformen: Profil, keyID, gespiegelt, Sehne rechts, Sehne links, Laenge (y), Legendendrehung,
  # Kappenhoehe (KeyHeight, fuer die Stuetze)
  # (Sehnen bei fn=60/layers=50 an der aufrechten Kappe gemessen, wie bei kat-all).
  # R1 ist im Profil nach hinten geneigt (wie R4), muss als Zahlenreihe aber zum Nutzer zeigen:
  # die Kappe wird um 180 Grad gedreht aufgesteckt, daher auch die Legende um 180 Grad.
  des_shape () {
    case "$1" in
      S_R1) echo "Standard 5 0 [9.036,0,5.762,15.810] [9.036,0,5.762,15.810] 17.16 180 15";;
      S_R2) echo "Standard 2 0 [9.036,0,6.049,10.022] [9.036,0,6.050,10.021] 17.16 0 9.75";;
      S_R3) echo "Standard 1 0 [9.036,0,6.203,8.586] [9.036,0,6.205,8.584] 17.16 0 8.75";;
      S_R4) echo "Standard 0 0 [9.036,0,6.132,10.541] [9.036,0,6.132,10.542] 17.16 0 10.55";;
      T15L) echo "Thumb 0 0 [9.047,-0.032,6.746,12.521] [9.047,0.032,6.978,9.997] 26.66 0 12";;
      T15R) echo "Thumb 0 1 [9.047,0.032,6.978,9.997] [9.047,-0.032,6.746,12.521] 26.66 0 12";;
      T1L)  echo "Thumb 1 1 [9.036,0.016,7.499,9.812] [9.036,-0.016,7.430,11.211] 17.16 0 11";;
      T1R)  echo "Thumb 1 0 [9.036,-0.016,7.430,11.211] [9.036,0.016,7.499,9.812] 17.16 0 11";;
      T2L)  echo "Thumb 2 1 [9.038,0.032,7.965,10.462] [9.038,-0.032,7.694,13.402] 17.16 0 13";;
      T2R)  echo "Thumb 2 0 [9.038,-0.032,7.694,13.402] [9.038,0.032,7.965,10.462] 17.16 0 13";;
    esac
  }

  # des_key <name> <form> <art> <wert>   (Arten wie bei kat_key: t, h, s, b, d)
  des_key () {
    local name="$1" shape="$2" kind="$3" val="$4" f="$JOBS/$1.scad"
    local prof id mir R L len legrot hgt leg font='"Liberation Sans:style=Bold"' size=5 dot=false
    read -r prof id mir R L len legrot hgt <<< "$(des_shape "$shape")"
    case "$kind" in
      t) leg="\"$val\"";;
      h) leg="\"$val\""; dot=true;;
      s) leg="chr($val)"; font='"JetBrainsMono Nerd Font:style=Bold"'; size=5.5;;
      b) leg='""';;
      d) leg='""'; dot=true;;
    esac
    cat > "$f" <<EOF
use <symbols.ttf>
include <des_$prof.scad>
include <deslib.scad>
Tol    = $TOL;
fn     = 60;   // Ausgabequalitaet laut Profil
layers = 50;
des_cap($id, part=PART, legend=$leg, font=$font, size=$size, mir=$mir, legrot=$legrot, dot=$dot, dotz=7.593);
EOF
    echo ">> [$name] $shape ${kind}:${val}"
    "$OPENSCAD" "${BACKEND[@]}" "${TEXTM[@]}" -o "$RAW/${name}_body.3mf" -D 'PART="body"' "$f" >/dev/null 2>&1
    if [ "$kind" != b ] && [ "$kind" != d ]; then
      "$OPENSCAD" "${BACKEND[@]}" "${TEXTM[@]}" -o "$RAW/${name}_legends.3mf" -D 'PART="legend"' "$f" >/dev/null 2>&1
    fi
    [ -s "$RAW/${name}_body.3mf" ] || { echo "FEHLER: $name wurde nicht gerendert."; exit 1; }
    if [ "$kind" != b ] && [ "$kind" != d ] && [ ! -s "$RAW/${name}_legends.3mf" ]; then
      echo "FEHLER: Legende fuer $name fehlt."; exit 1
    fi
    echo "$name $R $L $len $kind $hgt" >> "$RAW/${name%_*}.lst"
  }

  if [ "$MODE" = "des-test" ]; then
  # Passtest: leere Home-Kappe (das Kreuzloch ist in allen Reihen gleich), je Toleranz eine Datei
  for TOL in ${2:-0.00 0.025 0.05 0.075}; do
    des_key "Passtest_tol_${TOL}_00" S_R3 b -
  done
  else
  # Belegung der Hauptreihen je nach Layout, danach die fuer beide gleichen Gruppen
  if [ "$DESLAYOUT" = us ]; then
    KEYLIST=$(cat <<'KEYS'
R1_links      S_R1:s:987831 S_R1:t:1 S_R1:t:2 S_R1:t:3 S_R1:t:4 S_R1:t:5
R1_rechts     S_R1:t:6 S_R1:t:7 S_R1:t:8 S_R1:t:9 S_R1:t:0 S_R1:t:`
R2_links      S_R2:s:983826 S_R2:t:Q S_R2:t:W S_R2:t:E S_R2:t:R S_R2:t:T
R2_rechts     S_R2:t:Y S_R2:t:U S_R2:t:I S_R2:t:O S_R2:t:P S_R2:t:-
R3_links      S_R3:s:984628 S_R3:t:A S_R3:t:S S_R3:t:D S_R3:h:F S_R3:t:G
R3_rechts     S_R3:t:H S_R3:h:J S_R3:t:K S_R3:t:L S_R3:t:; S_R3:t:'
R4_links      S_R4:s:984630 S_R4:t:Z S_R4:t:X S_R4:t:C S_R4:t:V S_R4:t:B S_R4:t:[
R4_rechts     S_R4:t:] S_R4:t:N S_R4:t:M S_R4:t:, S_R4:t:. S_R4:t:/ S_R4:s:984630
KEYS
)
  else
    KEYLIST=$(cat <<'KEYS'
R1_links      S_R1:s:987831 S_R1:t:1 S_R1:t:2 S_R1:t:3 S_R1:t:4 S_R1:t:5
R1_rechts     S_R1:t:6 S_R1:t:7 S_R1:t:8 S_R1:t:9 S_R1:t:0 S_R1:s:8998
R2_links      S_R2:s:983826 S_R2:t:Q S_R2:t:W S_R2:t:E S_R2:t:R S_R2:t:T
R2_rechts     S_R2:t:Z S_R2:t:U S_R2:t:I S_R2:t:O S_R2:t:P S_R2:b:-
R3_links      S_R3:s:984628 S_R3:t:A S_R3:t:S S_R3:t:D S_R3:h:F S_R3:t:G
R3_rechts     S_R3:t:H S_R3:h:J S_R3:t:K S_R3:t:L S_R3:b:- S_R3:b:-
R4_links      S_R4:s:984630 S_R4:t:Y S_R4:t:X S_R4:t:C S_R4:t:V S_R4:t:B S_R4:b:-
R4_rechts     S_R4:b:- S_R4:t:N S_R4:t:M S_R4:b:- S_R4:b:- S_R4:b:- S_R4:s:984630
KEYS
)
  fi
  KEYLIST+=$'\n'"$(cat <<'KEYS'
Daumen_links  T2L:s:984629 T1L:s:984627 T1L:s:9660 T15L:s:987216
Daumen_rechts T15R:s:983825 T1R:s:9650 T1R:s:9003 T2R:s:984627
Ersatz_R1     S_R1:b:-
Ersatz_R2     S_R2:b:-
Ersatz_R3     S_R3:b:-
Ersatz_R4     S_R4:b:-
Daumen_leer   T2L:b:- T1L:b:- T1L:b:- T15L:b:- T15R:b:- T1R:b:- T1R:b:- T2R:b:-
Homing_leer   S_R3:d:- S_R3:d:-
KEYS
)"
  set -f   # Satzzeichen wie [ nicht als Dateinamen-Muster auslegen
  while read -r grp keys; do
    [ -z "$grp" ] && continue
    n=0
    for k in $keys; do
      IFS=: read -r shape kind val <<< "$k"
      des_key "${grp}_$(printf '%02d' $n)" "$shape" "$kind" "$val"
      n=$((n+1))
    done
  done <<< "$KEYLIST"
  set +f
  fi
  # Reihen: R1 Zahlen, R2 QWERTZ/QWERTY, R3 Home, R4 unten (DES-Bezeichnung); Daumen links von
  # aussen nach innen, rechts von innen nach aussen. Symbole wie bei kat-all.

  # Gruppen: Kappen nebeneinander (Abstand nach Kappenlaenge), Seiten plan, auf die Seite gelegt
  for lst in "$RAW"/*.lst; do
    [ -s "$lst" ] || continue
    grp="$(basename "$lst" .lst)"; g="$JOBS/desgroup_${grp}.scad"; gl="$JOBS/desgroup_${grp}_legends.scad"
    printf 'include <desflat.scad>\ninclude <stemsupport.scad>\n' > "$g"; echo "include <desflat.scad>" > "$gl"
    pos=0; prev=0; haslegs=0
    while read -r name R L len kind hgt; do
      pos=$(awk -v p="$pos" -v a="$prev" -v b="$len" 'BEGIN{print (a==0 ? 0 : p + a/2 + 5 + b/2)}'); prev=$len
      echo "translate([$pos,0,0]) print_pose($R) intersection() { import(\"$REL/${name}_body.3mf\"); flat_cut($R, $L); }" >> "$g"
      echo "translate([$pos,0,0]) print_pose($R) stem_support(\"$REL/${name}_body.3mf\", $R, $hgt);" >> "$g"
      if [ "$kind" != b ] && [ "$kind" != d ]; then
        echo "translate([$pos,0,0]) print_pose($R) import(\"$REL/${name}_legends.3mf\");" >> "$gl"; haslegs=1
      fi
    done < "$lst"
    echo ">> [Gruppe $grp] Kappen ..."
    "$OPENSCAD" "${BACKEND[@]}" -o "$OUT/${grp}_body.stl" "$g" >/dev/null 2>&1
    if [ "$haslegs" = 1 ]; then
      echo ">> [Gruppe $grp] Legenden ..."
      "$OPENSCAD" "${BACKEND[@]}" -o "$OUT/${grp}_legends.stl" "$gl" >/dev/null 2>&1
    fi
  done

  echo
  echo ">> Fertig: $(cat "$RAW"/*.lst | wc -l | tr -d ' ') Kappen in $OUT"
  echo ">> Je Gruppe: *_body.stl + *_legends.stl -> zusammen in Bambu Studio ziehen."
  exit 0
fi

[ "$MODE" = "all" ] || { echo "Unbekannter Modus: $MODE (test | kat-test | kat-all | des-all | des-test | all)"; exit 1; }

# --- 6b. Kompletter Satz ------------------------------------------------------
OUT="$WORK/stl/set_tol_${TOL}"; mkdir -p "$OUT"

# Linke Haelfte, 4 Reihen x 6 (Buchstaben/Zahlen, Schrift 5 mm)
job left_num  row <<'EOF'
ROW = [["1"],["2"],["3"],["4"],["5"]];
EOF
job left_top  row <<'EOF'
ROW = [["Q"],["W"],["E"],["R"],["T"]];
EOF
job left_home row <<'EOF'
ROW = [["A"],["S"],["D"],["G"]];
EOF
job left_bot  row <<'EOF'
ROW = [["Z"],["X"],["C"],["V"],["B"]];
EOF

# Rechte Haelfte, 4 Reihen x 6
job right_num  row <<'EOF'
ROW = [["6"],["7"],["8"],["9"],["0"],["`"]];
EOF
job right_top  row <<'EOF'
ROW = [["Y"],["U"],["I"],["O"],["P"],["-"]];
EOF
job right_home row <<'EOF'
ROW = [["H"],["K"],["L"],[";"],["'"]];
EOF
job right_bot  row <<'EOF'
ROW = [["N"],["M"],[","],["."],["/"]];
EOF

# Homing-Tasten F und J
job home_F single <<'EOF'
LEGENDS = ["F"];
HOMING_DOT_LENGTH = 3;
EOF
job home_J single <<'EOF'
LEGENDS = ["J"];
HOMING_DOT_LENGTH = 3;
EOF

# Modifier der Hauptreihen (kleinere Schrift)
job mods_main row <<'EOF'
ROW = [["Esc"],["Tab"],["Ctrl"],["Shift"],["Shift"]];
LEGEND_FONT_SIZES = [3.2];
EOF

# Daumen 1u: links Alt, GUI, Lower - rechts Raise, Bksp, GUI
job thumbs_1u row <<'EOF'
ROW = [["Alt"],["GUI"],["LWR"],["RSE"],["Bksp"],["GUI"]];
LEGEND_FONT_SIZES = [3.2];
EOF

# Daumen 2u: links Space, rechts Enter
# Um X statt Z gedreht, damit die Kappe auf der langen Seite liegt (nicht 37 mm hochkant).
# Tipp: Fuer quer stehende Schrift LEGEND_ROTATION = [[0,0,90]]; ergaenzen.
job thumb_2u_space single <<'EOF'
LEGENDS = ["Space"];
LEGEND_FONT_SIZES = [3.5];
KEY_LENGTH = KEY_UNIT*2 - BETWEENSPACE;
KEY_ROTATION = [112.4,0,0];       // auf der langen Seite statt hochkant
STEM_SIDE_SUPPORTS = [0,0,1,0];
EOF
job thumb_2u_enter single <<'EOF'
LEGENDS = ["Enter"];
LEGEND_FONT_SIZES = [3.5];
KEY_LENGTH = KEY_UNIT*2 - BETWEENSPACE;
KEY_ROTATION = [112.4,0,0];       // auf der langen Seite statt hochkant
STEM_SIDE_SUPPORTS = [0,0,1,0];
EOF

COUNT=56
# Optional: innere Tasten der untersten Reihe
if [ "${INNER:-0}" = "1" ]; then
  job inner row <<'EOF'
ROW = [["["],["]"]];
EOF
  COUNT=58
fi

echo
echo ">> Fertig: $COUNT Kappen in $OUT"
echo ">> Je Gruppe: *_body.stl + *_legends.stl -> zusammen in Bambu Studio ziehen."
