#!/usr/bin/env bash
# Back on Track — iOS build helper
# Usage: ./scripts/ios.sh [build|test|install|archive]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IOS="$ROOT/ios"
PROJECT="$IOS/BackOnTrack.xcodeproj"
SCHEME="BackOnTrack"
TEAM="6SPV96FZW9"
DEVICE="00008140-001849813430801C"
BUNDLE="com.danielebuatti.backontrack"
DEV_DIR="/Applications/Xcode.app/Contents/Developer"

export DEVELOPER_DIR="$DEV_DIR"
cd "$IOS"
xcodegen generate >/dev/null

case "${1:-build}" in
  build)
    xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
      -destination 'generic/platform=iOS' \
      CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
    ;;
  test)
    xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
      -destination 'platform=iOS Simulator,name=iPhone 17' \
      CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test
    ;;
  install)
    xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
      -destination "id=$DEVICE" -allowProvisioningUpdates \
      -allowProvisioningDeviceRegistration build
    xcrun devicectl device install app --device "$DEVICE" \
      "$HOME/Library/Developer/Xcode/DerivedData/BackOnTrack-abpyggdgahchsofezlwcrgktiloj/Build/Products/Debug-iphoneos/BackOnTrack.app"
    xcrun devicectl device process launch --device "$DEVICE" "$BUNDLE" || true
    ;;
  archive)
    xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
      -destination 'generic/platform=iOS' \
      -archivePath "$IOS/build/BackOnTrack.xcarchive" \
      -allowProvisioningUpdates archive
    ;;
  *)
    echo "Usage: $0 [build|test|install|archive]" >&2
    exit 2
    ;;
esac
