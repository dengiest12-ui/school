#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${PROJECT_PATH:-SchoolApp.xcodeproj}"
SCHEME="${SCHEME:-SchoolApp}"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 17}"
BUNDLE_ID="${BUNDLE_ID:-ru.codex.schoolclass}"
SCREENSHOT_DIR="${SCREENSHOT_DIR:-.build/screenshots/qa-smoke}"
APP_PATH="${APP_PATH:-}"
SIMULATOR_ID="${SIMULATOR_ID:-}"

mkdir -p "$SCREENSHOT_DIR"
SUMMARY_PATH="$SCREENSHOT_DIR/summary.txt"
RUN_CASES=()

if [[ -z "$SIMULATOR_ID" ]]; then
  SIMULATOR_ID="$(xcrun simctl list devices booted | awk -F '[()]' '/Booted/ {print $2; exit}')"
fi

if [[ -z "$SIMULATOR_ID" ]]; then
  echo "No booted simulator found. Boot an iPhone simulator or pass SIMULATOR_ID." >&2
  exit 1
fi

echo "Building $SCHEME for $DESTINATION"
xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME" -destination "$DESTINATION" clean build

if [[ -z "$APP_PATH" ]]; then
  DERIVED_APP_PATH="$(
    find "$HOME/Library/Developer/Xcode/DerivedData" \
      -path "*/Index.noindex" -prune -o \
      -path "*/Build/Products/Debug-iphonesimulator/$SCHEME.app" -print |
      while IFS= read -r path; do
        printf '%s\t%s\n' "$(stat -f %m "$path")" "$path"
      done |
      sort -rn |
      head -n 1 |
      cut -f2-
  )"
  APP_PATH="$DERIVED_APP_PATH"
fi

if [[ -z "$APP_PATH" || ! -d "$APP_PATH" ]]; then
  echo "Built app was not found. Pass APP_PATH explicitly." >&2
  exit 1
fi

echo "Installing $APP_PATH on $SIMULATOR_ID"
xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"

assert_screenshot() {
  local name="$1"
  local path="$SCREENSHOT_DIR/$name.png"
  local width
  local height
  local bytes

  if [[ ! -s "$path" ]]; then
    echo "Smoke screenshot is missing or empty: $path" >&2
    exit 1
  fi

  width="$(sips -g pixelWidth "$path" 2>/dev/null | awk '/pixelWidth/ {print $2; exit}')"
  height="$(sips -g pixelHeight "$path" 2>/dev/null | awk '/pixelHeight/ {print $2; exit}')"
  bytes="$(stat -f %z "$path")"

  if [[ -z "$width" || -z "$height" || "$width" -lt 300 || "$height" -lt 600 ]]; then
    echo "Smoke screenshot has invalid dimensions: $path (${width:-?}x${height:-?})" >&2
    exit 1
  fi

  if [[ "$bytes" -lt 10000 ]]; then
    echo "Smoke screenshot is suspiciously small: $path ($bytes bytes)" >&2
    exit 1
  fi
}

run_case() {
  local name="$1"
  shift

  echo "Launching smoke case: $name"
  xcrun simctl terminate "$SIMULATOR_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true
  xcrun simctl launch "$SIMULATOR_ID" "$BUNDLE_ID" "$@"
  sleep 2
  xcrun simctl io "$SIMULATOR_ID" screenshot "$SCREENSHOT_DIR/$name.png"
  assert_screenshot "$name"
  RUN_CASES+=("$name")
}

write_summary() {
  {
    echo "QA smoke summary"
    echo "Project: $PROJECT_PATH"
    echo "Scheme: $SCHEME"
    echo "Destination: $DESTINATION"
    echo "Simulator: $SIMULATOR_ID"
    echo "Bundle: $BUNDLE_ID"
    echo "Screenshots: $SCREENSHOT_DIR"
    echo "Cases passed: ${#RUN_CASES[@]}"
    echo
    for name in "${RUN_CASES[@]}"; do
      echo "- $name.png"
    done
  } > "$SUMMARY_PATH"
}

while IFS='|' read -r name args; do
  [[ -z "$name" || "$name" == \#* ]] && continue
  # shellcheck disable=SC2086
  run_case "$name" $args
done <<'SMOKE_CASES'
onboarding-phone|-qa-onboarding -qa-reset-onboarding -qa-onboarding-phone-verified -qa-onboarding-consent
onboarding-apple|-qa-onboarding -qa-reset-onboarding -qa-onboarding-apple -qa-onboarding-consent
today-main|-qa-tab today
today-notifications|-qa-tab today -qa-today-notifications
today-profile|-qa-tab today -qa-today-profile
today-urgent|-qa-tab today -qa-today-urgent
today-homework-list|-qa-tab today -qa-today-homework-list
today-chats|-qa-tab today -qa-today-chats
today-add-child|-qa-tab today -qa-today-add-child
today-paywall|-qa-tab today -qa-no-subscription -qa-today-paywall
child-mode|-qa-role child -qa-tab today
class-parent-permissions|-qa-role parent -qa-tab classRoom
class-committee-collections|-qa-role parentCommittee -qa-tab classRoom
class-collection-report|-qa-role parentCommittee -qa-tab classRoom -qa-collection-detail -qa-collection-report
class-chat-detail|-qa-role parent -qa-tab classRoom -qa-chat-detail
class-member-management|-qa-role parentCommittee -qa-tab classRoom -qa-member-management
class-member-invite|-qa-role parentCommittee -qa-tab classRoom -qa-member-invite
class-photo-album-create|-qa-role parentCommittee -qa-tab classRoom -qa-photo-album-create
class-photo-viewer|-qa-role parentCommittee -qa-tab classRoom -qa-photo-viewer
homework-add|-qa-tab homework -qa-homework-add
homework-ai-report|-qa-tab homework -qa-homework-parse -qa-homework-ai-report
homework-paywall|-qa-tab homework -qa-no-subscription -qa-homework-paywall
homework-filters|-qa-tab homework -qa-homework-filters
homework-empty|-qa-tab homework -qa-homework-empty
homework-archive|-qa-tab homework -qa-homework-archive
calendar-add|-qa-tab calendar -qa-calendar-add
calendar-detail|-qa-tab calendar -qa-calendar-detail
more-profile|-qa-tab more -qa-more-profile
more-children|-qa-tab more -qa-more-children
more-family|-qa-tab more -qa-more-family
more-classes|-qa-tab more -qa-more-classes
more-subscription|-qa-tab more -qa-more-subscription
more-notifications|-qa-tab more -qa-more-notifications
more-security|-qa-tab more -qa-more-security
more-security-lifecycle|-qa-tab more -qa-more-security -qa-more-security-lifecycle
more-privacy|-qa-tab more -qa-more-privacy -qa-more-privacy-consented
more-legal|-qa-tab more -qa-more-legal -qa-more-privacy-consented
more-real-device|-qa-tab more -qa-more-real-device
more-behavior|-qa-tab more -qa-more-behavior
more-support|-qa-tab more -qa-more-support
more-problem|-qa-tab more -qa-more-problem
more-ai-quality|-qa-tab more -qa-more-ai-quality
more-qa-states|-qa-tab more -qa-more-states
more-sync|-qa-tab more -qa-more-sync
more-sync-offline|-qa-tab more -qa-more-sync -qa-more-sync-offline
more-moderation|-qa-tab more -qa-more-moderation
more-beta|-qa-tab more -qa-more-beta
SMOKE_CASES

write_summary

echo "QA smoke completed. Cases: ${#RUN_CASES[@]}. Screenshots: $SCREENSHOT_DIR"
echo "Summary: $SUMMARY_PATH"
