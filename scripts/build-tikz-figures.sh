#!/usr/bin/env bash
# Compile standalone PGFPlots figures to assets/figures/<chapter>/*.pdf
# when their sources are newer than the existing PDF.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BUILD_DIR="build/tikz"
mkdir -p "$BUILD_DIR"

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

# src pdf [dependency...]
build_figure() {
  local src="$1"
  local pdf="$2"
  shift 2
  local fig
  fig="$(basename "$src" .tex)"
  if [[ ! -f "$src" ]]; then
    echo "Missing TikZ source: $src" >&2
    exit 1
  fi
  if needs_rebuild "$pdf" "$src" "$@"; then
    echo "Building $fig..."
    lualatex -interaction=nonstopmode -halt-on-error \
      -file-line-error \
      -output-directory="$BUILD_DIR" \
      -jobname="$fig" \
      "$src"
    mkdir -p "$(dirname "$pdf")"
    cp "$BUILD_DIR/${fig}.pdf" "$pdf"
  else
    echo "Up to date: $fig"
  fi
}

RAW04="assets/figures/04/raw"
OUT04="assets/figures/04"
STYLES04="$RAW04/im-dynamics-styles.tex"
PREAMBLE04="$RAW04/im-standalone-preamble.tex"
RAW05="assets/figures/05/raw"
OUT05="assets/figures/05"

figures04=(im-aging im-cooldown im-weighted)
# Every standalone .tex directly in the chapter 05 raw folder.
figures05=()
for src in "$RAW05"/*.tex; do
  [[ -f "$src" ]] || continue
  figures05+=("$(basename "$src" .tex)")
done

if [[ $# -gt 0 ]]; then
  figures04=()
  figures05=()
  for fig in "$@"; do
    if [[ -f "$RAW04/${fig}.tex" ]]; then
      figures04+=("$fig")
    elif [[ -f "$RAW05/${fig}.tex" ]]; then
      figures05+=("$fig")
    else
      echo "Missing TikZ source: $fig (looked in $RAW04 and $RAW05)" >&2
      exit 1
    fi
  done
fi

if ((${#figures04[@]})); then
  for fig in "${figures04[@]}"; do
    build_figure "$RAW04/${fig}.tex" "$OUT04/${fig}.pdf" "$STYLES04" "$PREAMBLE04"
  done
fi

if ((${#figures05[@]})); then
  for fig in "${figures05[@]}"; do
    build_figure "$RAW05/${fig}.tex" "$OUT05/${fig}.pdf"
  done
fi
