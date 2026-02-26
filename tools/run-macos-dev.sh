#!/usr/bin/env bash
set -euo pipefail

# Convenience script for developers to build & open the macOS app locally
# It uses the existing macos/scripts/build_and_sign_local.sh which builds
# without automatic codesigning, strips extended attributes and signs ad-hoc.

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "Running flutter pub get..."
flutter pub get

echo "Invoking macos/scripts/build_and_sign_local.sh"
chmod +x macos/scripts/build_and_sign_local.sh
macos/scripts/build_and_sign_local.sh

echo "Done. The app should be open (or you can open build/macos/Build/Products/Debug/crp_cursos.app)"
