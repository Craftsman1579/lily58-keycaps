# 0010 – Publishing: public GitHub repo, GPL-3.0, release ZIPs

- **Status:** accepted
- **Decided by:** owner (repo, visibility, KAT STLs, English), derived (license analysis)

## Decision

- **Repository:** `github.com/Craftsman1579/lily58-keycaps`, **public**, in **English** (owner asked
  to switch the README and repo texts to English; script comments are still German).
- **License: GPL-3.0.** PseudoMakeMeKeyCapProfiles is GPL-3.0 and `des_cap()` contains code derived
  from it. The README documents every change to both templates and credits all sources.
- **keycap_playground has no license.** Its code is never committed (downloaded at runtime). The
  owner decided to **publish the KAT STLs anyway**, with attribution and a takedown note in the
  README.
- **Release assets:** binary STL (5× smaller than OpenSCAD's ASCII, identical float32 geometry,
  `tools/stl2bin.py`), zipped together with README, LICENSE and `docs/` images. v1.0 = DES German,
  v1.1 = DES German + US. KAT ZIPs follow after the KAT fit test (ADR 0004).
- **Images:** renders in `docs/` (sets with/without legends, close-ups, side profile) and real photos.
  **Photos are stripped of all metadata** (GPS, camera model, embedded motion-photo video) with
  `tools/jpegmeta.py strip` before committing.
- **Not committed:** template clones, `des_libs/`, `jobs/`, `stl/` (see `.gitignore`).
- **MakerWorld:** planned by the owner. MakerWorld does not seem to offer GPL; either ask pseudoku
  for permission to use a MakerWorld license or publish on Printables (GPL available) and link.
  Not legal advice.

## Consequences

- Never publish files containing personal metadata; check with `jpegmeta.py check`.
- `gh` needs the macOS keychain, so run it outside the sandbox.
