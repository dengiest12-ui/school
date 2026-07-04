#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${PROJECT_PATH:-SchoolApp.xcodeproj}"
SCHEME="${SCHEME:-SchoolApp}"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 17}"
RESULT_BUNDLE="${RESULT_BUNDLE:-.build/SchoolAppUITests.xcresult}"

rm -rf "$RESULT_BUNDLE"

xcodebuild test \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -resultBundlePath "$RESULT_BUNDLE" \
  -enableCodeCoverage NO \
  -only-testing:SchoolAppUITests

echo "UI tests completed. Result bundle: $RESULT_BUNDLE"
