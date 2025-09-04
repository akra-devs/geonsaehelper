@echo off
setlocal ENABLEDELAYEDEXPANSION

set PORT=%PORT%
if "%PORT%"=="" set PORT=8080

if not exist build\web (
  echo [!] build\web not found. Run: flutter build web --web-renderer html --pwa-strategy=none
  exit /b 1
)

echo Serving build\web at http://localhost:%PORT% (Ctrl+C to stop)
py -3 -m http.server %PORT% -d build\web

