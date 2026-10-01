#!/usr/bin/env bash
# Build OneLine and launch it in the iOS Simulator.
# Usage: ./run.sh [device name]   (default: iPhone 17 Pro)
set -euo pipefail
cd "$(dirname "$0")"
DEVICE="${1:-iPhone 17 Pro}"
BUNDLE=com.alexgarner.oneline
DERIVED="$HOME/Library/Caches/OneLine-build"  # outside ~/Documents: xattrs there break codesign

xcodegen generate >/dev/null
UDID=$(xcrun simctl list devices available | grep -F "$DEVICE (" | head -1 | grep -oE '[0-9A-F-]{36}')
xcrun simctl boot "$UDID" 2>/dev/null || true
open -a Simulator 2>/dev/null || echo "(no standalone Simulator.app; view the device from Xcode)"

xcodebuild build -project OneLine.xcodeproj -scheme OneLine \
  -destination "id=$UDID" -derivedDataPath "$DERIVED" -quiet
xcrun simctl install "$UDID" "$DERIVED"/Build/Products/Debug-iphonesimulator/OneLine.app
xcrun simctl launch "$UDID" "$BUNDLE"
