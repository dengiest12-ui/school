-- Reproducible Supabase test data for signed RLS smoke checks.
-- These rows are test-only and are safe to recreate with ON CONFLICT.

insert into auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
)
values
  (
    '00000000-0000-0000-0000-000000000000',
    '10000000-0000-4000-8000-000000000001',
    'authenticated',
    'authenticated',
    'school-parent-smoke@example.test',
    null,
    now(),
    '{"provider":"email","providers":["email"],"seed":"school_rls_smoke"}'::jsonb,
    '{"name":"Smoke Parent"}'::jsonb,
    now(),
    now()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '10000000-0000-4000-8000-000000000002',
    'authenticated',
    'authenticated',
    'school-teacher-smoke@example.test',
    null,
    now(),
    '{"provider":"email","providers":["email"],"seed":"school_rls_smoke"}'::jsonb,
    '{"name":"Smoke Teacher"}'::jsonb,
    now(),
    now()
  )
on conflict (id) do update
set
  email = excluded.email,
  raw_app_meta_data = excluded.raw_app_meta_data,
  raw_user_meta_data = excluded.raw_user_meta_data,
  updated_at = now();

insert into public.profiles (id, display_name, phone)
values
  ('10000000-0000-4000-8000-000000000001', 'Smoke Parent', '+70000000001'),
  ('10000000-0000-4000-8000-000000000002', 'Smoke Teacher', '+70000000002')
on conflict (id) do update
set
  display_name = excluded.display_name,
  phone = excluded.phone,
  updated_at = now();

insert into public.class_rooms (id, title, school_name, invite_code, owner_user_id)
values
  ('20000000-0000-4000-8000-000000000001', 'Smoke 3Б', 'Smoke School', 'QA-3B-2026', '10000000-0000-4000-8000-000000000002'),
  ('20000000-0000-4000-8000-000000000002', 'Foreign 4А', 'Smoke School', 'QA-4A-2026', '10000000-0000-4000-8000-000000000002')
on conflict (id) do update
set
  title = excluded.title,
  school_name = excluded.school_name,
  invite_code = excluded.invite_code,
  owner_user_id = excluded.owner_user_id,
  updated_at = now();

insert into public.class_members (id, class_id, user_id, role, status)
values
  ('30000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'parent', 'active'),
  ('30000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000002', 'teacher', 'active'),
  ('30000000-0000-4000-8000-000000000003', '20000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000002', 'teacher', 'active')
on conflict (id) do update
set
  class_id = excluded.class_id,
  user_id = excluded.user_id,
  role = excluded.role,
  status = excluded.status,
  updated_at = now();

insert into public.children (id, class_id, parent_user_id, display_name, grade_title)
values
  ('40000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'Smoke Child', '3Б')
on conflict (id) do update
set
  class_id = excluded.class_id,
  parent_user_id = excluded.parent_user_id,
  display_name = excluded.display_name,
  grade_title = excluded.grade_title,
  updated_at = now();

insert into public.collections (id, class_id, author_user_id, title, amount_per_family, total_count, paid_count, status)
values
  ('50000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000002', 'Smoke bus collection', 1200, 20, 0, 'active')
on conflict (id) do update
set
  class_id = excluded.class_id,
  author_user_id = excluded.author_user_id,
  title = excluded.title,
  amount_per_family = excluded.amount_per_family,
  total_count = excluded.total_count,
  paid_count = excluded.paid_count,
  status = excluded.status,
  updated_at = now();
