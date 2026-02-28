#!/usr/bin/env bash
set -e

SRC="assets/plantuml"
OUT="assets/diagrams"

mkdir -p "$OUT"

echo "Generating PlantUML diagrams..."

find "$SRC" -name "*.plantuml" | while read -r file; do
  echo "Processing: $file"
  plantuml --format svg --output-dir $(realpath $OUT) $file
done

echo "Done. SVG diagrams generated in $OUT."
