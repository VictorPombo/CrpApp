#!/usr/bin/env bash
set -euo pipefail

# Checks a built macOS .app for extended attributes that may cause codesign to fail.
# Usage: scripts/check_xattrs.sh /path/to/MyApp.app

APP_BUNDLE="${1:-build/macos/Build/Products/Debug/crp_cursos.app}"

if [ ! -d "$APP_BUNDLE" ]; then
  echo "Error: app bundle not found at $APP_BUNDLE" >&2
  exit 2
fi

echo "Listing extended attributes in $APP_BUNDLE (showing any matches)..."
/usr/bin/xattr -lr "$APP_BUNDLE" || true

COUNT=$(/usr/bin/xattr -lr "$APP_BUNDLE" 2>/dev/null | wc -l || true)
if [ "$COUNT" -gt 0 ]; then
  echo "Found $COUNT extended-attribute lines; consider running xattr -rc on the bundle or using the dev wrapper." >&2
  exit 1
else
  echo "No extended attributes found. OK."
  exit 0
fi
