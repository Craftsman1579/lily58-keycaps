# 0006 – German layout without special characters, US layout

- **Status:** accepted
- **Decided by:** owner

## Decision

**German layout** (default):

- QWERTZ letters and numbers only, **no special characters** (no ß, ´, +, #, <, ., -, …) and
  **no umlauts** – the owner types Ä/Ö/Ü via long-press on A/O/U.
- Positions of special characters get **blank caps**.
- Modifiers as symbols: Shift, Tab, Ctrl, GUI, Del, Esc, Enter, Space, plus Alt, Backspace,
  Lower, Raise (owner: "also symbols"). **No Home key** (not needed).
- **Del (⌦) stays top right, Backspace (⌫) on the right thumb** – owner decided to keep it after
  checking both symbols point the correct way (⌦ right, ⌫ left).
- Blank backups: one spare cap per row, a full set of blank thumb caps, two blank homing caps.

**US layout** (`LAYOUT=us`), added later:

- QWERTY with punctuation as in the Lily58 default keymap: `` ` `` top right, `-` next to P,
  `;` `'` on the home row, `[` `]` on the inner keys, `,` `.` `/` on the bottom row.
- Same modifier symbols, thumbs and blank groups as the German set.

| | German | US |
|---|---|---|
| Numbers | Esc 1 2 3 4 5 · 6 7 8 9 0 Del | Esc 1 2 3 4 5 · 6 7 8 9 0 \` |
| Top | Tab Q W E R T · Z U I O P □ | Tab Q W E R T · Y U I O P - |
| Home | Ctrl A S D F G · H J K L □ □ | Ctrl A S D F G · H J K L ; ' |
| Bottom | Shift Y X C V B □ · □ N M □ □ □ Shift | Shift Z X C V B [ · ] N M , . / Shift |
| Thumbs | Alt GUI Lower Space · Enter Raise Bksp GUI | same |

## Consequences

- Key lists are assembled per layout (`KEYLIST`) plus the shared groups; globbing is disabled
  while reading them (`set -f`) because of `[`.
- Output folders: `des_set_tol_<t>` / `des_set_us_tol_<t>`, `kat_set_tol_<t>` /
  `kat_set_us_tol_<t>`.
