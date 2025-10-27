#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SPEC="$ROOT/specs/sucnr1_ecl_antagonist.yaml"
TARGET="$ROOT/data/targets/sucnr1_af.cif"
OUTDIR="$ROOT/work/sucnr1_ecl_pep"
MOLDIR="$ROOT/cache/datasets--boltzgen--inference-data/refs/main"

if [ ! -x "$ROOT/.conda_bg/bin/python" ]; then
  echo "error: BoltzGen conda env not found at $ROOT/.conda_bg; run setup first." >&2
  exit 1
fi

# Resolve moldir snapshot (downloaded via boltzgen download)
if [ -f "$MOLDIR" ]; then
  SNAPSHOT=$(cat "$MOLDIR")
  MOLDIR="$ROOT/cache/datasets--boltzgen--inference-data/snapshots/$SNAPSHOT/mols.zip"
fi

if [ ! -f "$TARGET" ]; then
  echo "error: target mmCIF not found: $TARGET" >&2
  echo "Download human SUCNR1 (Q9BXA5) AlphaFold mmCIF (e.g. AF-Q9BXA5-F1-model_v6.cif) and save as $TARGET" >&2
  exit 1
fi

if [ ! -f "$MOLDIR" ]; then
  echo "error: moldir dataset not found. Run:"
  echo "  PYTHONPATH=$ROOT/external/boltzgen/src PATH=$ROOT/.conda_bg/bin:\$PATH \"
  echo "    MPLCONFIGDIR=$ROOT/cache/mpl $ROOT/.conda_bg/bin/python -m boltzgen.cli.boltzgen \"
  echo "    download moldir --cache $ROOT/cache" >&2
  exit 1
fi

export PYTHONPATH="$ROOT/external/boltzgen/src:${PYTHONPATH:-}"
export MPLCONFIGDIR="${MPLCONFIGDIR:-$ROOT/cache/mpl}"
export PATH="$ROOT/.conda_bg/bin:$PATH"

CLI="$ROOT/.conda_bg/bin/python -m boltzgen.cli.boltzgen"

echo "[1/2] boltzgen check …"
"$CLI" check "$SPEC" --output "$ROOT/work/check_vis" --moldir "$MOLDIR"

echo "[2/2] boltzgen run (smoke test, CPU-friendly defaults) …"
mkdir -p "$OUTDIR"
"$CLI" run "$SPEC" \
  --output "$OUTDIR" \
  --protocol peptide-anything \
  --num_designs 50 --budget 10 \
  --inverse_fold_avoid '' \
  --use_kernels false \
  --cache "$ROOT/cache" \
  --moldir "$MOLDIR" \
  --num_workers 1

echo "Done. Results under: $OUTDIR"
