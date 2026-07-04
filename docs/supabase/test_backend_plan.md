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
