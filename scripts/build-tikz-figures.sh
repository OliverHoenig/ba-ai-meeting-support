#!/usr/bin/env bash
# Compile standalone IM PGFPlots figures to assets/figures/04/*.pdf
# when their sources are newer than the existing PDF.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

RAW="assets/figures/04/raw"
OUT="assets/figures/04"
BUILD_DIR="build/tikz"
STYLES="$RAW/im-dynamics-styles.tex"
PREAMBLE="$RAW/im-standalone-preamble.tex"

mkdir -p "$BUILD_DIR"

figures=(im-aging im-cooldown im-weighted)
if [[ $# -gt 0 ]]; then
  figures=("$@")
fi

needs_rebuild() {
  local pdf="$1"
  shift
  [[ ! -f "$pdf" ]] && return 0
  local src
  for src in "$@"; do
    [[ "$src" -nt "$pdf" ]] && return 0
  done
  return 1
}

for fig in "${figures[@]}"; do
  src="$RAW/${fig}.tex"
  pdf="$OUT/${fig}.pdf"
  if [[ ! -f "$src" ]]; then
    echo "Missing TikZ source: $src" >&2
    exit 1
  fi
  if needs_rebuild "$pdf" "$src" "$STYLES" "$PREAMBLE"; then
    echo "Building $fig..."
    lualatex -interaction=nonstopmode -halt-on-error \
      -file-line-error \
      -output-directory="$BUILD_DIR" \
      -jobname="$fig" \
      "$src"
    cp "$BUILD_DIR/${fig}.pdf" "$pdf"
  else
    echo "Up to date: $fig"
  fi
done
