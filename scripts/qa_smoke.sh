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

if [[ -z "$SIMULATOR_ID" ]]; then
  SIMULATOR_ID="$(xcrun simctl list devices booted | awk -F '[()]' '/Booted/ {print $2; exit}')"
fi

if [[ -z "$SIMULATOR_ID" ]]; then
  echo "No booted simulator found. Boot an iPhone simulator or pass SIMULATOR_ID." >&2
  exit 1
fi

echo "Building $SCHEME for $DESTINATION"
xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME" -destination "$DESTINATION" build

if [[ -z "$APP_PATH" ]]; then
  DERIVED_APP_PATH="$(find "$HOME/Library/Developer/Xcode/DerivedData" -path "*/Index.noindex/*" -prune -o -path "*/Build/Products/Debug-iphonesimulator/$SCHEME.app" -print -quit)"
  APP_PATH="$DERIVED_APP_PATH"
fi

if [[ -z "$APP_PATH" || ! -d "$APP_PATH" ]]; then
  echo "Built app was not found. Pass APP_PATH explicitly." >&2
  exit 1
fi

echo "Installing $APP_PATH on $SIMULATOR_ID"
xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"

run_case() {
  local name="$1"
  shift

  echo "Launching smoke case: $name"
  xcrun simctl terminate "$SIMULATOR_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true
  xcrun simctl launch "$SIMULATOR_ID" "$BUNDLE_ID" "$@"
  sleep 2
  xcrun simctl io "$SIMULATOR_ID" screenshot "$SCREENSHOT_DIR/$name.png"
}

run_case "onboarding-phone" -qa-onboarding -qa-reset-onboarding -qa-onboarding-phone-verified -qa-onboarding-consent
run_case "onboarding-apple" -qa-onboarding -qa-reset-onboarding -qa-onboarding-apple -qa-onboarding-consent
run_case "today-main" -qa-tab today
run_case "today-notifications" -qa-tab today -qa-today-notifications
run_case "today-profile" -qa-tab today -qa-today-profile
run_case "today-urgent" -qa-tab today -qa-today-urgent
run_case "today-homework-list" -qa-tab today -qa-today-homework-list
run_case "today-chats" -qa-tab today -qa-today-chats
run_case "today-add-child" -qa-tab today -qa-today-add-child
run_case "child-mode" -qa-role child -qa-tab today
run_case "class-parent-permissions" -qa-role parent -qa-tab classRoom
run_case "class-committee-collections" -qa-role parentCommittee -qa-tab classRoom
run_case "class-member-management" -qa-role parentCommittee -qa-tab classRoom -qa-member-management
run_case "class-member-invite" -qa-role parentCommittee -qa-tab classRoom -qa-member-invite
run_case "class-photo-viewer" -qa-role parentCommittee -qa-tab classRoom -qa-photo-viewer
run_case "homework-add" -qa-tab homework -qa-homework-add
run_case "homework-filters" -qa-tab homework -qa-homework-filters
run_case "calendar-add" -qa-tab calendar -qa-calendar-add
run_case "calendar-detail" -qa-tab calendar -qa-calendar-detail
run_case "more-family" -qa-tab more -qa-more-family
run_case "more-subscription" -qa-tab more -qa-more-subscription
run_case "more-notifications" -qa-tab more -qa-more-notifications
run_case "more-security" -qa-tab more -qa-more-security
run_case "more-privacy" -qa-tab more -qa-more-privacy -qa-more-privacy-consented
run_case "more-ai-quality" -qa-tab more -qa-more-ai-quality
run_case "more-qa-states" -qa-tab more -qa-more-states
run_case "more-sync" -qa-tab more -qa-more-sync

echo "QA smoke completed. Screenshots: $SCREENSHOT_DIR"
