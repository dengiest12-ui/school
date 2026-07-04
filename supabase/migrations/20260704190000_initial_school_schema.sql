-- Initial Supabase schema for the School Class MVP.
-- The migration is intentionally portable Postgres SQL so it can move from
-- Supabase Cloud to a self-hosted/VPS backend later.

create extension if not exists pgcrypto;

create type public.class_role as enum ('parent', 'parent_committee', 'teacher', 'child');
create type public.member_status as enum ('active', 'invited', 'left', 'blocked');
create type public.collection_status as enum ('draft', 'active', 'soon', 'closed');
create type public.sync_mutation_status as enum ('queued', 'accepted', 'blocked', 'failed');
create type public.file_kind as enum ('receipt', 'class_photo', 'homework_attachment', 'profile_avatar');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  phone text,
  avatar_file_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.class_rooms (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  school_name text,
  invite_code text not null unique,
  owner_user_id uuid not null references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.class_members (
  id uuid primary key default gen_random_uuid(),
  class_id uuid not null references public.class_rooms(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role public.class_role not null,
  status public.member_status not null default 'active',
  child_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (class_id, user_id, role, child_id)
);

create table public.children (
  id uuid primary key default gen_random_uuid(),
  class_id uuid not null references public.class_rooms(id) on delete cascade,
  parent_user_id uuid not null references public.profiles(id) on delete cascade,
  display_name text not null,
  grade_title text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.class_members
  add constraint class_members_child_fk
  foreign key (child_id) references public.children(id) on delete cascade;

create table public.announcements (
  id uuid primary key default gen_random_uuid(),
  class_id uuid not null references public.class_rooms(id) on delete cascade,
  author_user_id uuid not null references public.profiles(id) on delete restrict,
  title text not null,
  body text not null,
  is_urgent boolean not null default false,
  published_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.announcement_reads (
  announcement_id uuid not null references public.announcements(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  read_at timestamptz not null default now(),
  primary key (announcement_id, user_id)
);

create table public.homework_items (
  id uuid primary key default gen_random_uuid(),
  class_id uuid not null references public.class_rooms(id) on delete cascade,
  author_user_id uuid not null references public.profiles(id) on delete restrict,
  subject text not null,
  title text not null,
  details text,
  due_at timestamptz,
  assignee_child_id uuid references public.children(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.calendar_events (
  id uuid primary key default gen_random_uuid(),
  class_id uuid not null references public.class_rooms(id) on delete cascade,
  author_user_id uuid not null references public.profiles(id) on delete restrict,
  title text not null,
  details text,
  starts_at timestamptz not null,
  linked_collection_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.collections (
  id uuid primary key default gen_random_uuid(),
  class_id uuid not null references public.class_rooms(id) on delete cascade,
  author_user_id uuid not null references public.profiles(id) on delete restrict,
  title text not null,
  amount_per_family numeric(12, 2) not null default 0,
  total_count integer not null default 0,
  paid_count integer not null default 0,
  status public.collection_status not null default 'draft',
  due_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.calendar_events
  add constraint calendar_events_linked_collection_fk
  foreign key (linked_collection_id) references public.collections(id) on delete set null;

create table public.collection_payments (
  id uuid primary key default gen_random_uuid(),
  collection_id uuid not null references public.collections(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  payer_user_id uuid not null references public.profiles(id) on delete cascade,
  amount numeric(12, 2) not null default 0,
  is_confirmed boolean not null default false,
  confirmed_by_user_id uuid references public.profiles(id) on delete set null,
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (collection_id, child_id)
);

create table public.class_files (
  id uuid primary key default gen_random_uuid(),
  class_id uuid not null references public.class_rooms(id) on delete cascade,
  owner_user_id uuid not null references public.profiles(id) on delete restrict,
  kind public.file_kind not null,
  bucket text not null default 'class-files',
  object_path text not null,
  file_name text not null,
  mime_type text,
  size_bytes bigint,
  scan_status text not null default 'pending',
  created_at timestamptz not null default now(),
  unique (bucket, object_path)
);

create table public.collection_expenses (
  id uuid primary key default gen_random_uuid(),
  collection_id uuid not null references public.collections(id) on delete cascade,
  author_user_id uuid not null references public.profiles(id) on delete restrict,
  title text not null,
  amount numeric(12, 2) not null default 0,
  receipt_file_id uuid references public.class_files(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.class_photos (
  id uuid primary key default gen_random_uuid(),
  class_id uuid not null references public.class_rooms(id) on delete cascade,
  author_user_id uuid not null references public.profiles(id) on delete restrict,
  file_id uuid not null references public.class_files(id) on delete cascade,
  caption text,
  created_at timestamptz not null default now()
);

create table public.sync_mutations (
  id uuid primary key default gen_random_uuid(),
  mutation_id text not null unique,
  user_id uuid not null references public.profiles(id) on delete cascade,
  class_id uuid references public.class_rooms(id) on delete cascade,
  entity_type text not null,
  operation text not null,
  base_version integer not null default 1,
  payload jsonb not null default '{}'::jsonb,
  status public.sync_mutation_status not null default 'queued',
  retry_after_seconds integer,
  blocked_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index class_members_user_idx on public.class_members(user_id);
create index class_members_class_idx on public.class_members(class_id);
create index children_parent_idx on public.children(parent_user_id);
create index announcements_class_idx on public.announcements(class_id, published_at desc);
create index homework_class_idx on public.homework_items(class_id, due_at);
create index collections_class_idx on public.collections(class_id, status);
create index class_files_class_idx on public.class_files(class_id, kind);
create index sync_mutations_user_status_idx on public.sync_mutations(user_id, status);

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.is_class_member(target_class_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.class_members
    where class_id = target_class_id
      and user_id = auth.uid()
      and status = 'active'
  );
$$;

create or replace function public.has_class_role(target_class_id uuid, allowed_roles public.class_role[])
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.class_members
    where class_id = target_class_id
      and user_id = auth.uid()
      and status = 'active'
      and role = any(allowed_roles)
  );
$$;

create or replace function public.can_manage_class(target_class_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.has_class_role(target_class_id, array['parent_committee'::public.class_role, 'teacher'::public.class_role]);
$$;

create or replace function public.owns_child(target_child_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.children
    where id = target_child_id
      and parent_user_id = auth.uid()
  );
$$;

create trigger profiles_touch_updated_at
before update on public.profiles
for each row execute function public.touch_updated_at();

create trigger class_rooms_touch_updated_at
before update on public.class_rooms
for each row execute function public.touch_updated_at();

create trigger class_members_touch_updated_at
before update on public.class_members
for each row execute function public.touch_updated_at();

create trigger children_touch_updated_at
before update on public.children
for each row execute function public.touch_updated_at();

create trigger announcements_touch_updated_at
before update on public.announcements
for each row execute function public.touch_updated_at();

create trigger homework_touch_updated_at
before update on public.homework_items
for each row execute function public.touch_updated_at();

create trigger calendar_events_touch_updated_at
before update on public.calendar_events
for each row execute function public.touch_updated_at();

create trigger collections_touch_updated_at
before update on public.collections
for each row execute function public.touch_updated_at();

create trigger collection_payments_touch_updated_at
before update on public.collection_payments
for each row execute function public.touch_updated_at();

create trigger collection_expenses_touch_updated_at
before update on public.collection_expenses
for each row execute function public.touch_updated_at();

create trigger sync_mutations_touch_updated_at
before update on public.sync_mutations
for each row execute function public.touch_updated_at();

alter table public.profiles enable row level security;
alter table public.class_rooms enable row level security;
alter table public.class_members enable row level security;
alter table public.children enable row level security;
alter table public.announcements enable row level security;
alter table public.announcement_reads enable row level security;
alter table public.homework_items enable row level security;
alter table public.calendar_events enable row level security;
alter table public.collections enable row level security;
alter table public.collection_payments enable row level security;
alter table public.class_files enable row level security;
alter table public.collection_expenses enable row level security;
alter table public.class_photos enable row level security;
alter table public.sync_mutations enable row level security;

create policy profiles_select_own_or_classmate
on public.profiles for select
using (
  id = auth.uid()
  or exists (
    select 1
    from public.class_members own_member
    join public.class_members other_member on other_member.class_id = own_member.class_id
    where own_member.user_id = auth.uid()
      and own_member.status = 'active'
      and other_member.user_id = profiles.id
      and other_member.status = 'active'
  )
);

create policy profiles_insert_own
on public.profiles for insert
with check (id = auth.uid());

create policy profiles_update_own
on public.profiles for update
using (id = auth.uid())
with check (id = auth.uid());

create policy class_rooms_select_member
on public.class_rooms for select
using (public.is_class_member(id));

create policy class_rooms_insert_owner
on public.class_rooms for insert
with check (owner_user_id = auth.uid());

create policy class_rooms_update_manager
on public.class_rooms for update
using (public.can_manage_class(id) or owner_user_id = auth.uid())
with check (public.can_manage_class(id) or owner_user_id = auth.uid());

create policy class_members_select_class_member
on public.class_members for select
using (public.is_class_member(class_id) or user_id = auth.uid());

create policy class_members_insert_manager
on public.class_members for insert
with check (public.can_manage_class(class_id) or user_id = auth.uid());

create policy class_members_update_manager
on public.class_members for update
using (public.can_manage_class(class_id))
with check (public.can_manage_class(class_id));

create policy children_select_class_or_parent
on public.children for select
using (parent_user_id = auth.uid() or public.is_class_member(class_id));

create policy children_insert_parent
on public.children for insert
with check (parent_user_id = auth.uid());

create policy children_update_parent_or_manager
on public.children for update
using (parent_user_id = auth.uid() or public.can_manage_class(class_id))
with check (parent_user_id = auth.uid() or public.can_manage_class(class_id));

create policy announcements_select_member
on public.announcements for select
using (public.is_class_member(class_id));

create policy announcements_insert_manager
on public.announcements for insert
with check (author_user_id = auth.uid() and public.can_manage_class(class_id));

create policy announcements_update_manager
on public.announcements for update
using (public.can_manage_class(class_id))
with check (public.can_manage_class(class_id));

create policy announcement_reads_select_member
on public.announcement_reads for select
using (
  user_id = auth.uid()
  or exists (
    select 1 from public.announcements item
    where item.id = announcement_reads.announcement_id
      and public.can_manage_class(item.class_id)
  )
);

create policy announcement_reads_upsert_own
on public.announcement_reads for insert
with check (user_id = auth.uid());

create policy homework_select_member
on public.homework_items for select
using (public.is_class_member(class_id));

create policy homework_insert_manager
on public.homework_items for insert
with check (author_user_id = auth.uid() and public.can_manage_class(class_id));

create policy homework_update_manager
on public.homework_items for update
using (public.can_manage_class(class_id))
with check (public.can_manage_class(class_id));

create policy calendar_select_member
on public.calendar_events for select
using (public.is_class_member(class_id));

create policy calendar_insert_manager
on public.calendar_events for insert
with check (author_user_id = auth.uid() and public.can_manage_class(class_id));

create policy calendar_update_manager
on public.calendar_events for update
using (public.can_manage_class(class_id))
with check (public.can_manage_class(class_id));

create policy collections_select_member
on public.collections for select
using (public.is_class_member(class_id));

create policy collections_insert_manager
on public.collections for insert
with check (author_user_id = auth.uid() and public.can_manage_class(class_id));

create policy collections_update_manager
on public.collections for update
using (public.can_manage_class(class_id))
with check (public.can_manage_class(class_id));

create policy payments_select_member
on public.collection_payments for select
using (
  public.owns_child(child_id)
  or exists (
    select 1 from public.collections item
    where item.id = collection_payments.collection_id
      and public.can_manage_class(item.class_id)
  )
);

create policy payments_insert_parent
on public.collection_payments for insert
with check (payer_user_id = auth.uid() and public.owns_child(child_id));

create policy payments_update_parent_or_manager
on public.collection_payments for update
using (
  payer_user_id = auth.uid()
  or exists (
    select 1 from public.collections item
    where item.id = collection_payments.collection_id
      and public.can_manage_class(item.class_id)
  )
)
with check (
  payer_user_id = auth.uid()
  or exists (
    select 1 from public.collections item
    where item.id = collection_payments.collection_id
      and public.can_manage_class(item.class_id)
  )
);

create policy files_select_member
on public.class_files for select
using (public.is_class_member(class_id));

create policy files_insert_member
on public.class_files for insert
with check (owner_user_id = auth.uid() and public.is_class_member(class_id));

create policy files_update_owner_or_manager
on public.class_files for update
using (owner_user_id = auth.uid() or public.can_manage_class(class_id))
with check (owner_user_id = auth.uid() or public.can_manage_class(class_id));

create policy expenses_select_manager
on public.collection_expenses for select
using (
  exists (
    select 1 from public.collections item
    where item.id = collection_expenses.collection_id
      and public.is_class_member(item.class_id)
  )
);

create policy expenses_insert_manager
on public.collection_expenses for insert
with check (
  author_user_id = auth.uid()
  and exists (
    select 1 from public.collections item
    where item.id = collection_expenses.collection_id
      and public.can_manage_class(item.class_id)
  )
);

create policy photos_select_member
on public.class_photos for select
using (public.is_class_member(class_id));

create policy photos_insert_member
on public.class_photos for insert
with check (author_user_id = auth.uid() and public.is_class_member(class_id));

create policy photos_delete_manager
on public.class_photos for delete
using (public.can_manage_class(class_id));

create policy sync_mutations_select_own
on public.sync_mutations for select
using (user_id = auth.uid());

create policy sync_mutations_insert_own
on public.sync_mutations for insert
with check (user_id = auth.uid() and (class_id is null or public.is_class_member(class_id)));

create policy sync_mutations_update_own
on public.sync_mutations for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'class-files',
  'class-files',
  false,
  15728640,
  array['image/jpeg', 'image/png', 'image/heic', 'application/pdf']
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy class_files_storage_select_member
on storage.objects for select
using (
  bucket_id = 'class-files'
  and exists (
    select 1
    from public.class_files file
    where file.bucket = storage.objects.bucket_id
      and file.object_path = storage.objects.name
      and public.is_class_member(file.class_id)
  )
);

create policy class_files_storage_insert_member
on storage.objects for insert
with check (
  bucket_id = 'class-files'
  and auth.uid() is not null
);

create policy class_files_storage_update_owner
on storage.objects for update
using (bucket_id = 'class-files' and owner = auth.uid())
with check (bucket_id = 'class-files' and owner = auth.uid());

create policy class_files_storage_delete_owner
on storage.objects for delete
using (bucket_id = 'class-files' and owner = auth.uid());
