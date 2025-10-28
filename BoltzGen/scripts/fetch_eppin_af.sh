#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TARGET_DIR="$ROOT_DIR/data/targets/eppin"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

URL_V6="https://alphafold.ebi.ac.uk/files/AF-O95925-F1-model_v6.cif"
URL_V4="https://alphafold.ebi.ac.uk/files/AF-O95925-F1-model_v4.cif"

echo "Downloading EPPIN AlphaFold model (Q9Y639)…"
OUT_FILE="AF-O95925-F1.cif"

if curl -fL "$URL_V6" -o "$OUT_FILE"; then
  echo "Saved: $(pwd)/$OUT_FILE (v6 source)"
else
  echo "v6 not available; falling back to v4"
  curl -fL "$URL_V4" -o "$OUT_FILE"
  echo "Saved: $(pwd)/$OUT_FILE (v4 source)"
fi
