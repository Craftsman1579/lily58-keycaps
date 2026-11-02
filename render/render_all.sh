#!/usr/bin/env bash
# Regenerates every image in docs/img/ (keycaps and case). Needs the keycap sets in stl/:
#   ./lily58_keycaps.sh des-all && LAYOUT=us ./lily58_keycaps.sh des-all
#   ./lily58_keycaps.sh des-choc-all && LAYOUT=us ./lily58_keycaps.sh des-choc-all
#   ./lily58_keycaps.sh kat-all && LAYOUT=us ./lily58_keycaps.sh kat-all
# Takes about 10 minutes.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
"$here/keycaps.sh"
"$here/case.sh"
