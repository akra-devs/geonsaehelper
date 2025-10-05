#!/usr/bin/env bash
set -euo pipefail

OUT="dist/web"
ZIP="dist/geonsaehelper_web.zip"

rm -rf dist
mkdir -p dist

echo "Building Flutter web (HTML renderer, no PWA SW)..."
flutter build web --web-renderer html --pwa-strategy=none

echo "Packaging build/web to $ZIP"
mkdir -p "$OUT"
cp -R build/web/* "$OUT"/
cd dist
zip -r "$(basename "$ZIP")" web >/dev/null
cd - >/dev/null

echo "Done. Deliver dist/geonsaehelper_web.zip to recipients."

