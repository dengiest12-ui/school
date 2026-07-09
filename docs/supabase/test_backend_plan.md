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
- Live REST probe: `GET /class_rooms?select=id,title,invite_code&limit=3` through `URLSession`.
- Auth session gate: `SUPABASE_ACCESS_TOKEN`, `SUPABASE_REFRESH_TOKEN`, `SUPABASE_USER_ID`.
- Current live behavior: blocked until `SUPABASE_ANON_KEY` is provided; when a user access token exists, the live probe sends it as `Authorization: Bearer <access token>` while keeping the anon key in the `apikey` header.

Gate before first signed iOS request:

- Add `SUPABASE_ANON_KEY` through build config or test launch environment.
- Seed test auth users, profiles, class rooms, class members and children. Current smoke seed is applied for `QA-3B-2026` and `QA-4A-2026`.
- Provide a signed seed user's access token, refresh token and user id to the iOS test run.
- Run the live `class_rooms` probe with anon key, then repeat with a real Supabase Auth session token.
- Run a signed request smoke against `profiles` / `class_rooms` and verify RLS returns only the current user's class.
- Keep file uploads behind signed upload flow before creating file metadata.

## Latest iOS verification

Date: 2026-07-09

- Targeted UI test: `testSupabaseReadinessShowsSchemaAndMissingKeyGate` passed in `.build/SupabaseAuthSessionUITest.xcresult`.
- Full UI suite: 15 tests, 0 failures, summary in `.build/SchoolAppUITests/summary.txt`.
- Full smoke suite: 50 scenarios, screenshots in `.build/screenshots/qa-smoke`, including `more-sync-supabase.png`.
- One earlier targeted UI run was interrupted by the Simulator/Xcode runner; the same test passed after rerun on the concrete Simulator ID.

Additional iOS verification:

- MVP metrics persistence retest passed in `.build/MvpMetricsUITest-3.xcresult` after making the test-event action explicit and visible.
- The app now reports RLS as unproven until a signed user request returns only the seeded user's class rows.

## Latest Supabase verification

Date: 2026-07-10

- Security advisor after RLS helper hardening: no warnings for exposed `SECURITY DEFINER` helper RPCs.
- Remaining security advisor warning: leaked password protection is disabled in Supabase Auth settings; this is a project Auth setting to enable before public auth testing.
- RLS SQL smoke:
  - `anon` sees 0 class rows.
  - Seed parent `10000000-0000-4000-8000-000000000001` sees only `QA-3B-2026`.
  - Seed teacher `10000000-0000-4000-8000-000000000002` sees `QA-3B-2026` and `QA-4A-2026`.
  - Seed parent sees only child `Smoke Child`.
- iOS verification:
  - Targeted Supabase RLS smoke UI test passed in `.build/SupabaseRlsSmokeUITest.xcresult`.
  - Full UI run passed through the first 11 tests and was interrupted by an Xcode launch timeout on `testAnnouncementAcknowledgementPersistsAfterRelaunch`; the same test and the remaining persistence tests passed in separate reruns.
  - Full smoke suite passed 50 scenarios, summary in `.build/screenshots/qa-smoke/summary.txt`.
