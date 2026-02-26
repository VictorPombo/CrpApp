#!/bin/bash
set -euo pipefail

# Script to build macOS Runner without automatic codesigning, strip extended attributes
# then sign ad-hoc and open the app. Run from project root: macos/scripts/build_and_sign_local.sh

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$PROJECT_ROOT"

DERIVED_PATH="$PROJECT_ROOT/build/macos/DerivedData"
# When using -derivedDataPath, Xcode writes products under that derived data directory
BUILD_PRODUCTS_DIR="$DERIVED_PATH/Build/Products/Debug"
APP_BUNDLE="$BUILD_PRODUCTS_DIR/crp_cursos.app"

echo "Derived path: $DERIVED_PATH"

# Build without code signing
echo "Building with CODE_SIGNING_ALLOWED=NO..."
xcodebuild -workspace macos/Runner.xcworkspace -scheme Runner -configuration Debug CODE_SIGNING_ALLOWED=NO -derivedDataPath "$DERIVED_PATH"

# Ensure app exists
if [ ! -d "$APP_BUNDLE" ]; then
  echo "Error: built app not found at $APP_BUNDLE"
  exit 1
fi

# Remove extended attributes (best-effort)
echo "Removing extended attributes from built .app (this may show some errors which are safe)"
/usr/bin/xattr -rc "$APP_BUNDLE" || true

# Explicitly try to delete common offending attributes (ignore errors)
/usr/bin/find "$APP_BUNDLE" -print0 | /usr/bin/xargs -0 -I{} /usr/bin/xattr -d com.apple.FinderInfo "{}" 2>/dev/null || true
/usr/bin/find "$APP_BUNDLE" -print0 | /usr/bin/xargs -0 -I{} /usr/bin/xattr -d com.apple.provenance "{}" 2>/dev/null || true
/usr/bin/find "$APP_BUNDLE" -print0 | /usr/bin/xargs -0 -I{} /usr/bin/xattr -d "com.apple.fileprovider.fpfs#P" "{}" 2>/dev/null || true

# Some extended attributes (provenance / FinderInfo / resource forks) are stubbornly
# preserved by some copy operations. Use ditto --norsrc to recreate the bundle without
# Finder metadata/resource forks, then remove any leftover xattrs again.
echo "Recreating app bundle with 'ditto --norsrc' to strip Finder/resource forks"
TMP_DIR=$(mktemp -d)
/usr/bin/ditto --norsrc "$APP_BUNDLE" "$TMP_DIR/crp_cursos.app" || true
rm -rf "$APP_BUNDLE"
mv "$TMP_DIR/crp_cursos.app" "$APP_BUNDLE"
rm -rf "$TMP_DIR"

# Second pass: ensure no xattrs remain
/usr/bin/xattr -rc "$APP_BUNDLE" || true

# Ad-hoc sign the app bundle so it can be launched locally
echo "Signing app (ad-hoc)..."
/usr/bin/codesign --force --sign - --timestamp=none "$APP_BUNDLE"

# Verify signature
echo "Verifying code signature..."
/usr/bin/codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE" || true

# Open the app
echo "Opening app: $APP_BUNDLE"
open "$APP_BUNDLE"

echo "Done. If the app didn't launch, check the output above for errors."
