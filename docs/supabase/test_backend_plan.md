# Supabase test backend plan

Date: 2026-07-04
Project: `dengiest12-ui's Project`
Project ref: `tlhjwfauddueioatkahm`
Region: `eu-west-1`

## Decision

Use Supabase Cloud as the fast test backend while the iOS MVP is still being validated.
Do not treat it as the final Russian production hosting decision yet.

## Why this is enough for tests

- Auth is available for account flow experiments.
- Postgres can model classes, roles, children, announcements, homework, collections, payments and sync queue.
- Storage can hold receipt files, class photos and homework attachments.
- RLS lets us test the most important security rule: the server must reject actions outside the user's role.

## Production note

The target audience is mostly in Russia, so final production hosting still needs a separate decision.
Before public release we should compare:

- Supabase Cloud availability and legal fit.
- VPS/self-hosted Postgres + API + object storage.
- Backup, monitoring and incident response ownership.
- Personal data and children's photo storage requirements.

## Current migration

`supabase/migrations/20260704190000_initial_school_schema.sql`

Main tables:

- `profiles`
- `class_rooms`
- `class_members`
- `children`
- `announcements`
- `announcement_reads`
- `homework_items`
- `calendar_events`
- `collections`
- `collection_payments`
- `class_files`
- `collection_expenses`
- `class_photos`
- `sync_mutations`

Storage bucket:

- `class-files`

Key policies:

- Class data is visible to active class members.
- Announcements, homework, calendar events and collections are created by teacher/parent committee roles.
- Parent payment rows are limited to the parent's own child.
- Collection expenses are added by teacher/parent committee roles.
- Class photos are visible to class members, but delete is limited to teacher/parent committee roles.
- Sync mutations are owned by the current authenticated user and can only target classes where the user is a member.

## iOS readiness gate

The iOS app now shows the test backend status in `Еще -> Синхронизация`.

Current verified state:

- Project ref: `tlhjwfauddueioatkahm`
- REST: `https://tlhjwfauddueioatkahm.supabase.co/rest/v1`
- Storage: `https://tlhjwfauddueioatkahm.supabase.co/storage/v1`
- Auth: `https://tlhjwfauddueioatkahm.supabase.co/auth/v1`
- Expected schema: 14 public tables and 44 RLS/storage policies.
- Storage bucket: private `class-files`.
- RLS helpers: moved to non-exposed `private` schema through `supabase/migrations/20260710003000_harden_rls_helpers.sql`.
- RLS smoke seed: `supabase/seeds/rls_smoke_seed.sql`.
- RLS smoke checks: `supabase/tests/rls_smoke.sql`.
- RLS write checks: `supabase/tests/rls_write_smoke.sql`.
- Live REST probe: `GET /class_rooms?select=id,title,invite_code&limit=3` through `URLSession`.
- Auth session gate: `SUPABASE_ACCESS_TOKEN`, `SUPABASE_REFRESH_TOKEN`, `SUPABASE_USER_ID`.
- Password sign-in probe: `POST /auth/v1/token?grant_type=password` through `URLSession`, with the client key in `apikey`, `SUPABASE_TEST_EMAIL` and `SUPABASE_TEST_PASSWORD` in the JSON body, and the returned session saved into a Keychain-first seed session store for immediate signed probes and relaunch testing.
- Onboarding email/password entry: the first onboarding step can now call the same Supabase Auth password grant with user-entered email/password, stores a successful session in the shared Keychain-first seed session store, then runs signed profile/class/children handoff before role/class selection unlocks.
- Auth refresh probe: `POST /auth/v1/token?grant_type=refresh_token` through `URLSession`, with the client key in `apikey` and `SUPABASE_REFRESH_TOKEN` in the JSON body.
- Signed profile probe: `GET /profiles?id=eq.<SUPABASE_USER_ID>&select=id,display_name,phone` through `URLSession`, with the client key in `apikey`, the user access token in `Authorization`, and a separate local account profile bridge after exactly one RLS-filtered row.
- Signed class scope probe: `GET /class_members?user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,role,status,class_rooms(id,title,invite_code)` through `URLSession`, with embedded `class_rooms` rows under RLS, a local class context mapper preview, a separate local bridge and a visible handoff preview that does not replace child/class state.
- Signed children probe: `GET /children?parent_user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,display_name,grade_title,class_rooms(id,title,invite_code)` through `URLSession`, with embedded `class_rooms` rows under RLS, a local child context mapper preview, a separate local bridge, a visible handoff preview that does not replace the selected local child, a QA-gated child source preview, and an app-controlled sync-center toggle for selecting the Supabase-backed child/class context.
- Signed announcements probe: `GET /announcements?class_id=in.(...)&select=id,class_id,title,body,is_urgent,published_at,announcement_reads(user_id,read_at)` through `URLSession`, scoped by saved Supabase class bridge context and the signed user read-state relation; mapped rows are stored in a separate local announcement bridge and shown as a preview in the class feed without replacing the local feed.
- Signed announcement read ack: `POST /announcement_reads` through `URLSession`, with the client key in `apikey`, the user access token in `Authorization`, and an RLS policy that allows inserts only when `user_id = auth.uid()` and the announcement belongs to an active class member.
- Current live behavior: blocked until `SUPABASE_PUBLISHABLE_KEY` or legacy `SUPABASE_ANON_KEY` is provided. The live probe sends the client key in the `apikey` header; `Authorization: Bearer <access token>` is sent only when a real user token exists. Legacy anon bearer remains a fallback when no publishable key is configured. The password sign-in probe is also blocked until seed credentials are passed through the test environment.

Gate before first signed iOS request:

- Add `SUPABASE_PUBLISHABLE_KEY` through build config or test launch environment. Legacy `SUPABASE_ANON_KEY` still works as fallback.
- Seed test auth users, profiles, class rooms, class members and children. Current smoke seed is applied for `QA-3B-2026` and `QA-4A-2026`.
- Provide `SUPABASE_TEST_EMAIL` and `SUPABASE_TEST_PASSWORD` for a seed Auth user when testing password sign-in from the app.
- Run the password sign-in probe and verify Supabase returns access token, refresh token and user id; the app stores the returned seed session in Keychain, with legacy QA/UserDefaults only as fallback for old local test sessions.
- Verify the seed session store shows source, token preview, user id and expiry, survives relaunch for test probes, and can be cleared from Sync Center.
- Verify onboarding email/password success runs signed profile/class/children handoff, saves bridge context and shows the selected account/child/class context before the user chooses role/class.
- Provide a signed seed user's access token, refresh token and user id to the iOS test run.
- Run the Auth refresh probe and verify Supabase returns a refreshed access token before relying on session restore.
- Run the signed profile probe and verify RLS returns exactly one row for `SUPABASE_USER_ID`, then save the mapped account profile into the local account bridge.
- Run the signed class scope probe and verify RLS returns only active `class_members` rows and embedded classes for the signed user.
- Run the signed children probe and verify RLS returns only children where `parent_user_id = SUPABASE_USER_ID`, with embedded class rows for child/class switching.
- Verify the mapper preview produces class id/title, role and invite code, then saves the context into the local bridge while keeping local child/class state untouched.
- Verify the child mapper preview produces child id/name/grade, class id/title and invite code, then saves the context into the local child bridge while keeping the selected local child untouched by default.
- Verify the QA-gated child source preview can switch the Today child selector and Class context to the saved Supabase child bridge without enabling it in normal launches.
- Verify the sync-center child source toggle can enable and disable the saved Supabase child bridge from the app UI, and that both source choices survive app relaunch.
- Run the signed announcements probe after class bridge is available and verify RLS returns only announcements for the signed user's saved classes, including read-state preview from `announcement_reads`.
- Run the signed announcement read ack and verify the server accepts own-class read-state, rejects foreign-class read-state and treats duplicate read rows as already saved in the app.
- Keep announcement publishing/editing behind separate signed write paths before replacing the local announcement feed.
- Run the live `class_rooms` probe with the publishable key, then repeat with a real Supabase Auth session token.
- Run a signed request smoke against `profiles` / `class_rooms` and verify RLS returns only the current user's class.
- Keep file uploads behind signed upload flow before creating file metadata.

## Latest iOS verification

Date: 2026-07-10

- Targeted UI test: `testSupabaseClassBridgeShowsWithoutReplacingSelectedChild` passed in `.build/SupabaseClassBridgeHandoffUITest-2.xcresult`.
- Targeted UI test: `testSupabaseChildBridgeShowsWithoutReplacingSelectedChild` passed in `.build/SupabaseChildBridgeUITest.xcresult`.
- Targeted UI test: `testSupabaseChildSourcePreviewSwitchesSelectedChildContext` passed in `.build/SupabaseChildSourcePreviewUITest.xcresult`.
- Targeted UI test: `testSupabaseChildSourceCanBeEnabledFromSyncCenter` passed in `.build/SupabaseChildSourceSyncToggleUITest.xcresult`.
- Targeted UI test: `testSupabaseChildSourcePersistsAndCanReturnLocalAfterRelaunch` passed in `.build/SupabaseChildSourcePersistenceToggleUITest.xcresult`.
- Targeted UI retest: `testSupabaseChildSourceCanBeEnabledFromSyncCenter` and `testSupabaseChildSourcePersistsAndCanReturnLocalAfterRelaunch` passed in `.build/SupabaseChildSourceEnableAndPersistRetest.xcresult`.
- Targeted UI retest: `testSupabaseChildBridgeShowsWithoutReplacingSelectedChild` passed in `.build/SupabaseChildBridgeDefaultRetest.xcresult`.
- Targeted UI test: `testSupabaseReadinessShowsSchemaAndMissingKeyGate` passed with signed children coverage in `.build/SupabaseSignedChildrenUITest.xcresult`.
- Targeted UI test: `testSupabaseReadinessShowsSchemaAndMissingKeyGate` passed with password sign-in gate coverage in `.build/SupabasePasswordSignInGateUITest-2.xcresult`.
- Targeted UI test: `testSupabaseStoredSeedSessionCanBeClearedAfterRelaunch` passed in `.build/SupabaseStoredSeedSessionUITest.xcresult`.
- Targeted UI test: `testOnboardingSupabaseEmailRequiresSuccessfulAuthBeforeRoleStep` passed in `.build/SupabaseOnboardingEmailGateUITest.xcresult`.
- Targeted UI tests: `testOnboardingSupabaseEmailRequiresSuccessfulAuthBeforeRoleStep` and `testOnboardingSupabaseHandoffUnlocksRoleAndClassStep` passed in `.build/SupabaseOnboardingHandoffUITest.xcresult`.
- Targeted UI test: `testOnboardingSupabaseHandoffUnlocksRoleAndClassStep` passed with account profile handoff coverage in `.build/SupabaseOnboardingProfileHandoffUITest.xcresult`.
- Targeted UI test: `testSupabaseAnnouncementBridgeShowsInClassFeedPreview` passed in `.build/SupabaseAnnouncementBridgeUITest-2.xcresult`.
- Targeted UI test: `testSupabaseAnnouncementReadAckBlocksBeforeClientKey` passed in `.build/SupabaseAnnouncementReadAckOnlyUITest.xcresult`.
- Targeted UI test: `testSupabaseHomeworkBridgeShowsWithoutReplacingLocalHomework` passed in `.build/SupabaseHomeworkBridgeUITest.xcresult`.
- Targeted UI test: `testSupabaseCalendarBridgeShowsWithoutReplacingLocalEvents` passed in `.build/SupabaseCalendarBridgeUITest.xcresult`.
- Targeted UI test: `testSupabaseCollectionBridgeShowsWithoutGrantingParentManageRights` passed in `.build/SupabaseCollectionsBridgeUITest.xcresult`.
- Targeted UI test: `testSupabasePhotoBridgeShowsWithoutGrantingParentDeleteRights` passed in `.build/SupabasePhotosBridgeUITest.xcresult`.
- Targeted UI test: `testSupabaseSyncMutationWriteBlocksBeforeClientKey` passed in `.build/SupabaseSyncMutationWriteUITest-4.xcresult`.
- Targeted UI test: `testSupabaseCollectionPaymentWriteBlocksBeforeClientKey` passed in `.build/SupabaseCollectionPaymentWriteUITest.xcresult`.
- Targeted UI test: `testSupabaseCollectionExpenseWriteBlocksBeforeClientKey` passed in `.build/SupabaseCollectionExpenseWriteUITest.xcresult`.
- Targeted UI test: `testSupabaseClassFileMetadataWriteBlocksBeforeClientKey` passed in `.build/SupabaseClassFileMetadataWriteUITest-2.xcresult`.
- Targeted UI test: `testSupabaseClassPhotoMetadataWriteBlocksBeforeClientKey` passed in `.build/SupabaseClassPhotoMetadataWriteUITest.xcresult`.
- Partial current UI rerun: first 7 tests in `scripts/qa_ui_tests.sh` passed before `testMvpMetricsEventPersistsAfterRelaunch` exposed a viewport-sensitive assertion; the stabilized retest passed in `.build/MvpMetricsUITest-4.xcresult`, and the remaining rerun confirmed `testSyncNetworkErrorKeepsQueuedMutation` plus `testSupabaseReadinessShowsSchemaAndMissingKeyGate` in `.build/SchoolAppUITestsRemaining/`. Further tail reruns were blocked by CoreSimulator/xcodebuild hanging before test output, not by an app assertion.
- Full UI suite: 20 tests expected after adding seed session store coverage; rerun when CoreSimulator is stable to refresh `.build/SchoolAppUITests/summary.txt`.
- Full smoke suite: 50 scenarios, screenshots in `.build/screenshots/qa-smoke`, including `more-sync-supabase.png`.
- One earlier targeted UI run was interrupted by the Simulator/Xcode runner; the same test passed after rerun on the concrete Simulator ID.

Additional iOS verification:

- MVP metrics persistence retest passed in `.build/MvpMetricsUITest-3.xcresult` after making the test-event action explicit and visible.
- The app now reports RLS as unproven until a signed user request returns only the seeded user's class rows.
- The app now has a separate password sign-in probe for seed Auth users; without client key or seed credentials it blocks before network, and on success it passes the session into signed profile/classes/children probes and stores it in a Keychain-first seed session store.
- The seed session store now appears in Sync Center, survives relaunch for test probes and can be cleared from the app; Keychain is the primary store, while legacy QA/UserDefaults remains only a fallback during this transition.
- Onboarding now has a first real Supabase email/password path: without a successful Auth response the app stays on the account step, and after success the returned session is written to Keychain before role/class selection unlocks.
- Onboarding now runs a post-auth handoff: using the fresh Supabase session it loads signed profile, class memberships and children, saves account/class/child bridge contexts, enables the Supabase child source preview for that launch and shows the selected account/child/class summary before role/class selection.
- The app now has a signed homework bridge: Sync Center can request `GET /homework_items` by saved Supabase class context and the Homework screen shows the mapped preview separately from local homework until a full repository switch is ready.
- The app now has a signed calendar bridge: Sync Center can request `GET /calendar_events` by saved Supabase class context and the Calendar screen shows the mapped preview separately from local events until a full repository switch is ready.
- The app now has a signed collections bridge: Sync Center can request `GET /collections` by saved Supabase class context and the Class collections screen shows the mapped preview separately from local collections while preserving parent no-manage restrictions.
- The app now has a signed class photos bridge: Sync Center can request `GET /class_photos` by saved Supabase class context and the Class photos screen shows mapped metadata separately from local albums while preserving parent no-delete/no-create restrictions.
- The app now has a signed sync mutation write gate: Sync Center can prepare and send an idempotent `POST /sync_mutations` row under user/class RLS, and it blocks before network access without client key, user bearer, user id or class bridge.
- The app now has a signed collection payment write gate: Sync Center can prepare `POST /collection_payments` for the signed parent, saved child bridge and saved collection bridge while keeping `is_confirmed = false` so parent payment does not become committee confirmation.
- The app now has a signed collection expense write gate: Sync Center can prepare `POST /collection_expenses` for a teacher/committee signed session and saved collection bridge, while RLS `can_manage_class` remains the authority and receipt files stay behind the separate signed upload/class_files flow.
- The app now has a signed class file metadata write gate: Sync Center can prepare `POST /class_files` for a signed class member after private storage upload, so receipts and class photos can later link to the returned file row without bypassing class membership RLS.
- The app now has a signed class photo metadata write gate: Sync Center can prepare `POST /class_photos` from a saved class bridge plus class_files bridge, so uploaded private objects can become album photos only through signed class-member RLS.
- Production Auth is still incomplete: signup/email confirmation, phone OTP, native Apple ID, profile creation and class membership mapping must still be connected to live Supabase data before release.
- The app now has a separate Auth refresh probe that blocks safely without client key/refresh token and accepts any 2xx Supabase Auth token response as success.
- The app now has a separate signed profile probe that blocks safely without client key, access token or user id, then expects exactly one RLS-filtered profile row before saving the local account profile bridge.
- The app now has a separate signed class scope probe that blocks safely without client key, access token or user id, then expects active `class_members` rows with embedded `class_rooms` before class context mapping.
- The signed class scope probe now maps active membership rows into a local class context preview and keeps local data untouched when mapper prerequisites are missing.
- The signed class scope probe now saves mapped active class contexts into a separate local bridge only after a successful signed mapper; current local children and selected child remain untouched until the repository switch is implemented.
- The saved bridge context now appears as a handoff preview on Today, Class and Profile screens with localized role labels; targeted UI verifies it does not replace the selected local child.
- The signed children probe now maps parent-owned child rows into a separate local child bridge after successful signed RLS proof; QA seed verifies `Smoke Child -> QA-3B-2026` appears on Today/Class/Profile while the selected local child remains `Миша, 3Б`.
- The QA-gated Supabase child source preview now lets Today/Class use the saved child bridge as the effective child source: QA seed verifies `Smoke Child, 3Б` and class code `QA-3B-2026`, while the default launch still keeps `Миша, 3Б`.
- The sync-center now exposes a child source toggle: "Включить источник" switches the app to the saved Supabase child bridge, and "Локальные дети" returns Today/Class to the local child store.
- The app-controlled child source toggle now has relaunch coverage: enabled Supabase source survives app restart, and disabling it survives restart back to local children.
- The signed announcements probe now maps Supabase class announcements plus per-user read-state into a separate local bridge; the Class feed shows a Supabase announcement preview while the existing local announcement feed remains active until signed read/write flows are connected.
- The sync-center now has a signed announcement read ack gate: without client key/session it blocks before network, and with a signed session it is prepared to insert into `announcement_reads`; successful or duplicate inserts mark the local announcement bridge as read.

## Latest Supabase verification

Date: 2026-07-10

- Security advisor after RLS helper hardening: no warnings for exposed `SECURITY DEFINER` helper RPCs.
- Remaining security advisor warning: leaked password protection is disabled in Supabase Auth settings; this is a project Auth setting to enable before public auth testing.
- RLS SQL smoke:
  - `anon` sees 0 class rows.
  - Seed parent `10000000-0000-4000-8000-000000000001` sees only `QA-3B-2026`.
  - Seed teacher `10000000-0000-4000-8000-000000000002` sees `QA-3B-2026` and `QA-4A-2026`.
  - Seed parent sees only child `Smoke Child`.
- RLS write smoke:
  - Seed parent is blocked from publishing announcements.
  - Seed parent can insert `announcement_reads` for an own-class announcement.
  - Seed parent is blocked from inserting `announcement_reads` for a foreign-class announcement.
  - Seed parent is blocked from creating collections.
  - Seed parent is blocked from adding collection expenses.
  - Seed teacher can publish announcements, create collections and add collection expenses.
- iOS verification:
  - Targeted Supabase RLS smoke UI test passed in `.build/SupabaseRlsSmokeUITest.xcresult`.
  - Full UI run passed through the first 11 tests and was interrupted by an Xcode launch timeout on `testAnnouncementAcknowledgementPersistsAfterRelaunch`; the same test and the remaining persistence tests passed in separate reruns.
  - Full smoke suite passed 50 scenarios, summary in `.build/screenshots/qa-smoke/summary.txt`.
