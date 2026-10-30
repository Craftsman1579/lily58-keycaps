# 0007 – Multi-color legends: symbols, centering, orientation

- **Status:** accepted
- **Decided by:** owner (symbols wanted, ESC must be centered, R1 legends were upside down),
  derived (glyph choice and implementation)

## Decision

- **Separate parts:** every cap is exported as `*_body.stl` + `*_legends.stl`; the body has the
  legend recess, the legend fills it through the top wall. Printed with two filaments (AMS).
- **Fonts:** letters/numbers Liberation Sans Bold 5 mm; symbols JetBrains Mono Nerd Font Bold
  5.5 mm, copied next to the jobs and loaded with `use <symbols.ttf>`.
- **Symbols** (decimal code points in the key lists): Esc 987831 (MD "ESC"), Tab 983826,
  Ctrl 984628 (⌃), Shift 984630, Alt 984629 (⌥), GUI 984627 (⌘), Enter 983825, Space 987216,
  Backspace 9003 (⌫), Del 8998 (⌦), Lower 9660 (▼), Raise 9650 (▲). Mac symbols because ⎈ ⎇ ❖ are
  missing in all available fonts; Material Design glyphs because the Unicode ⇧/⏎ outlines are only
  ≈ 0.3 mm thick.
- **Centering:** `halign/valign="center"` centers on the advance width, not the ink (ESC was 1.22 mm
  off). Legends are shifted by the ink-box center from `textmetrics()`
  (needs `--enable=textmetrics`; the script aborts without it). KAT additionally shifts by the row's
  `top_y` so the legend sits on the top, not the base.
- **DES legends** are perpendicular to the tilted top, placed at the top centre; mirrored thumb caps
  pre-mirror the text so it stays readable; R1 legends are rotated 180° (ADR 0005).
- **KAT legend height:** `KEY_HEIGHT` must equal the row height, otherwise the playground clips
  or drops the legend.
- **Homing:** DES raised bar 3 × 1 mm at the front of the dish (`dotz = 7.593`, ≈ 0.6 mm proud);
  KAT `HOMING_DOT_Z = 0.6` (the default sits below the dish).

## Consequences

- Verify centering by rendering caps perpendicular to their top (numeric "top centre" metrics are
  unreliable on strongly sculpted caps; `tools/legcenter3.py` is only a rough check).
- Smallest US punctuation (`.`) is ≈ 1 × 1 mm – printable with a 0.4 mm nozzle.
