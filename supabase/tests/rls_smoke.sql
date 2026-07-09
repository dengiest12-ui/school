-- Supabase RLS smoke checks for the School Class MVP seed data.
-- Expected:
-- - anon sees 0 classes
-- - parent seed sees only QA-3B-2026
-- - teacher seed sees QA-3B-2026 and QA-4A-2026
-- - parent seed sees only Smoke Child

begin;
set local role anon;
select set_config('request.jwt.claim.role', 'anon', true);
select
  'anon_class_rooms' as check_name,
  count(*) = 0 as passed,
  count(*) as visible_count,
  coalesce(array_agg(invite_code order by invite_code), array[]::text[]) as visible_invite_codes
from public.class_rooms;
rollback;

begin;
set local role authenticated;
select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000001', true);
select set_config('request.jwt.claim.role', 'authenticated', true);
select
  'parent_class_rooms' as check_name,
  count(*) = 1 and array_agg(invite_code order by invite_code) = array['QA-3B-2026'] as passed,
  count(*) as visible_count,
  array_agg(invite_code order by invite_code) as visible_invite_codes
from public.class_rooms;
rollback;

begin;
set local role authenticated;
select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000002', true);
select set_config('request.jwt.claim.role', 'authenticated', true);
select
  'teacher_class_rooms' as check_name,
  count(*) = 2 and array_agg(invite_code order by invite_code) = array['QA-3B-2026', 'QA-4A-2026'] as passed,
  count(*) as visible_count,
  array_agg(invite_code order by invite_code) as visible_invite_codes
from public.class_rooms;
rollback;

begin;
set local role authenticated;
select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000001', true);
select set_config('request.jwt.claim.role', 'authenticated', true);
select
  'parent_children' as check_name,
  count(*) = 1 and array_agg(display_name order by display_name) = array['Smoke Child'] as passed,
  count(*) as visible_count,
  array_agg(display_name order by display_name) as visible_children
from public.children;
rollback;
