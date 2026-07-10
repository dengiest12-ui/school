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
- Auth refresh probe: `POST /auth/v1/token?grant_type=refresh_token` through `URLSession`, with the client key in `apikey` and `SUPABASE_REFRESH_TOKEN` in the JSON body.
- Signed profile probe: `GET /profiles?id=eq.<SUPABASE_USER_ID>&select=id,display_name,phone` through `URLSession`, with the client key in `apikey` and the user access token in `Authorization`.
- Signed class scope probe: `GET /class_members?user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,role,status,class_rooms(id,title,invite_code)` through `URLSession`, with embedded `class_rooms` rows under RLS, a local class context mapper preview and a separate local bridge that does not replace child/class state.
- Current live behavior: blocked until `SUPABASE_PUBLISHABLE_KEY` or legacy `SUPABASE_ANON_KEY` is provided. The live probe sends the client key in the `apikey` header; `Authorization: Bearer <access token>` is sent only when a real user token exists. Legacy anon bearer remains a fallback when no publishable key is configured.

Gate before first signed iOS request:

- Add `SUPABASE_PUBLISHABLE_KEY` through build config or test launch environment. Legacy `SUPABASE_ANON_KEY` still works as fallback.
- Seed test auth users, profiles, class rooms, class members and children. Current smoke seed is applied for `QA-3B-2026` and `QA-4A-2026`.
- Provide a signed seed user's access token, refresh token and user id to the iOS test run.
- Run the Auth refresh probe and verify Supabase returns a refreshed access token before relying on session restore.
- Run the signed profile probe and verify RLS returns exactly one row for `SUPABASE_USER_ID`.
- Run the signed class scope probe and verify RLS returns only active `class_members` rows and embedded classes for the signed user.
- Verify the mapper preview produces class id/title, role and invite code, then saves the context into the local bridge while keeping local child/class state untouched.
- Run the live `class_rooms` probe with the publishable key, then repeat with a real Supabase Auth session token.
- Run a signed request smoke against `profiles` / `class_rooms` and verify RLS returns only the current user's class.
- Keep file uploads behind signed upload flow before creating file metadata.

## Latest iOS verification

Date: 2026-07-10

- Targeted UI test: `testSupabaseReadinessShowsSchemaAndMissingKeyGate` passed in `.build/SupabaseClassContextBridgeUITest.xcresult`.
- Full UI suite: 15 tests, 0 failures, summary in `.build/SchoolAppUITests/summary.txt`.
- Full smoke suite: 50 scenarios, screenshots in `.build/screenshots/qa-smoke`, including `more-sync-supabase.png`.
- One earlier targeted UI run was interrupted by the Simulator/Xcode runner; the same test passed after rerun on the concrete Simulator ID.

Additional iOS verification:

- MVP metrics persistence retest passed in `.build/MvpMetricsUITest-3.xcresult` after making the test-event action explicit and visible.
- The app now reports RLS as unproven until a signed user request returns only the seeded user's class rows.
- The app now has a separate Auth refresh probe that blocks safely without client key/refresh token and accepts any 2xx Supabase Auth token response as success.
- The app now has a separate signed profile probe that blocks safely without client key, access token or user id, then expects exactly one RLS-filtered profile row before local account mapping.
- The app now has a separate signed class scope probe that blocks safely without client key, access token or user id, then expects active `class_members` rows with embedded `class_rooms` before class context mapping.
- The signed class scope probe now maps active membership rows into a local class context preview and keeps local data untouched when mapper prerequisites are missing.
- The signed class scope probe now saves mapped active class contexts into a separate local bridge only after a successful signed mapper; current local children and selected child remain untouched until the repository switch is implemented.

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
  - Seed parent is blocked from creating collections.
  - Seed parent is blocked from adding collection expenses.
  - Seed teacher can publish announcements, create collections and add collection expenses.
- iOS verification:
  - Targeted Supabase RLS smoke UI test passed in `.build/SupabaseRlsSmokeUITest.xcresult`.
  - Full UI run passed through the first 11 tests and was interrupted by an Xcode launch timeout on `testAnnouncementAcknowledgementPersistsAfterRelaunch`; the same test and the remaining persistence tests passed in separate reruns.
  - Full smoke suite passed 50 scenarios, summary in `.build/screenshots/qa-smoke/summary.txt`.
