#!/usr/bin/env bash
set -euo pipefail

PORT="
${PORT:-8080}"
DIR="build/web"

if [ ! -d "$DIR" ]; then
  echo "[!] $DIR not found. Run: flutter build web --web-renderer html --pwa-strategy=none"
  exit 1
fi

echo "Serving $DIR at http://localhost:${PORT} (Ctrl+C to stop)"
python3 -m http.server "$PORT" -d "$DIR"

