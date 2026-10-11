#!/usr/bin/env bash
# Compile standalone figure sources under assets/figures.
# A figure is built only when its PDF is missing. Delete that PDF to rebuild it.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BUILD_DIR="build/tikz"
FIGURES="assets/figures"
mkdir -p "$BUILD_DIR"

is_document() {
  grep -q '\\begin{document}' "$1"
}

# assets/figures/04/raw/foo.tex and assets/figures/02/00_raw/foo.tex
# both publish assets/figures/<chapter>/foo.pdf
pdf_path_for() {
  local src="$1"
  local dir base out
  dir="$(dirname "$src")"
  base="$(basename "$src" .tex)"
  out="$dir"
  if [[ "$dir" == *"/00_raw" || "$dir" == *"/00_raw/"* ]]; then
    out="${dir%%/00_raw*}"
  elif [[ "$dir" == *"/raw" || "$dir" == *"/raw/"* ]]; then
    out="${dir%%/raw*}"
  fi
  printf '%s/%s.pdf' "$out" "$base"
}

build_figure() {
  local src="$1"
  local pdf fig
  pdf="$(pdf_path_for "$src")"
  fig="$(basename "$src" .tex)"
  if [[ -f "$pdf" ]]; then
    echo "Exists, skip: $pdf"
    return 0
  fi
  echo "Building $fig..."
  lualatex -interaction=nonstopmode -halt-on-error \
    -file-line-error \
    -output-directory="$BUILD_DIR" \
    -jobname="$fig" \
    "$src"
  mkdir -p "$(dirname "$pdf")"
  cp "$BUILD_DIR/${fig}.pdf" "$pdf"
}

found=0
while IFS= read -r src; do
  base="$(basename "$src" .tex)"
  if [[ $# -gt 0 ]]; then
    match=0
    for name in "$@"; do
      if [[ "$name" == "$base" || "$name" == "$base.tex" ]]; then
        match=1
        break
      fi
    done
    [[ "$match" -eq 1 ]] || continue
  fi
  if ! is_document "$src"; then
    continue
  fi
  found=1
  build_figure "$src"
done < <(find "$FIGURES" \( -type d -name build -prune \) -o \( -type f -name '*.tex' -print \) | sort)

if [[ $# -gt 0 && "$found" -eq 0 ]]; then
  echo "No figure source named: $*" >&2
  exit 1
fi
