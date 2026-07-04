#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${PROJECT_PATH:-SchoolApp.xcodeproj}"
SCHEME="${SCHEME:-SchoolApp}"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 17}"
RESULT_ROOT="${RESULT_ROOT:-.build/SchoolAppUITests}"
SUMMARY_FILE="$RESULT_ROOT/summary.txt"

TESTS=(
  "testChildModeShowsOnlyChildTabs"
  "testParentCannotCreateClassCollection"
  "testParentCannotManageCollectionStatusOrReceipts"
  "testParentCannotPublishAnnouncement"
  "testParentCannotInviteClassMembers"
  "testParentCannotDeleteClassPhotos"
  "testBehaviorQAGateListsCriticalInvariants"
  "testMvpMetricsEventPersistsAfterRelaunch"
  "testSyncNetworkErrorKeepsQueuedMutation"
  "testSelectedChildPersistsAcrossTabsAndChangesClassContext"
  "testAnnouncementAcknowledgementPersistsAfterRelaunch"
  "testCollectionExpensePersistsAfterRelaunch"
  "testManualHomeworkPersistsAfterRelaunch"
  "testCalendarEventPersistsAfterRelaunch"
)

rm -rf "$RESULT_ROOT"
mkdir -p "$RESULT_ROOT"

{
  echo "Project: $PROJECT_PATH"
  echo "Scheme: $SCHEME"
  echo "Destination: $DESTINATION"
  echo "Started: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo
} > "$SUMMARY_FILE"

for test_name in "${TESTS[@]}"; do
  result_bundle="$RESULT_ROOT/$test_name.xcresult"
  echo "Running UI test: $test_name"

  xcodebuild test \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -resultBundlePath "$result_bundle" \
    -enableCodeCoverage NO \
    -only-testing:"SchoolAppUITests/SchoolAppUITests/$test_name"

  echo "- $test_name: passed ($result_bundle)" >> "$SUMMARY_FILE"
done

{
  echo
  echo "Completed: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Passed: ${#TESTS[@]}"
} >> "$SUMMARY_FILE"

echo "UI tests completed. Passed: ${#TESTS[@]}. Summary: $SUMMARY_FILE"
