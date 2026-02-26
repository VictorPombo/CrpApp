# crp_cursos

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## macOS development (dev workflow)

This repository currently encounters macOS codesign failures during the normal
`flutter run -d macos` flow when extended attributes (Finder provenance, file
provider metadata, etc.) are present inside the built `.app`. To make local
development reliable while we fix the root cause, use the provided dev wrapper
which builds without automatic codesigning, strips extended attributes from the
built bundle, signs it ad-hoc and opens the app.

Usage — quick:

```bash
# from repo root
./tools/run-macos-dev.sh
```

What the wrapper does:
- runs `flutter pub get`
- builds the macOS Runner via `xcodebuild` with `CODE_SIGNING_ALLOWED=NO`
- cleans extended attributes from the resulting `.app`
- ad-hoc codesigns the `.app` and opens it

If you want to inspect whether a built `.app` contains problematic attributes
before signing, run:

```bash
# inspect default debug app path
./scripts/check_xattrs.sh

# or point to a custom path
./scripts/check_xattrs.sh /path/to/crp_cursos.app
```

Notes:
- This is a developer-time workaround so you can preview UI changes quickly.
- We'll keep working on a permanent fix so that `flutter run -d macos` works
	directly. For now the wrapper is the most reliable way to view the app on
	macOS without codesign failures.

