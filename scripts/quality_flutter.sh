#!/usr/bin/env bash
set -euo pipefail

# App-Flutter CI quality gate. Keep the same command sequence for local smoke
# checks and Woodpecker; no signing or release credentials are required.
if [[ ! -f pubspec.yaml || ! -d lib || ! -d test || ! -d tool ]]; then
  echo 'FLUTTER_QUALITY_GATE=FAIL: execute from the app-flutter repository root' >&2
  exit 1
fi

echo '===== FLUTTER / DART ====='
flutter --version
dart --version

echo
echo '===== PUB GET ====='
flutter pub get

echo
echo '===== FORMAT ====='
dart format --output=none --set-exit-if-changed lib test tool

echo
echo '===== APP IDENTITY ====='
dart run tool/configure_app.dart --check

echo
echo '===== ARCHITECTURE ====='
dart run tool/check_architecture.dart

echo
echo '===== ANALYZE ====='
flutter analyze

echo
echo '===== TEST ====='
flutter test

echo
echo 'FLUTTER_QUALITY_GATE=PASS'
