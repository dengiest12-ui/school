-- Harden RLS helper functions so they are not exposed as public REST RPCs.
-- Policies still call them internally through the non-exposed private schema.

create schema if not exists private;

revoke all on schema private from public;
grant usage on schema private to anon, authenticated, service_role;

alter function if exists public.has_class_role(uuid, public.class_role[]) set schema private;
alter function if exists public.can_manage_class(uuid) set schema private;
alter function if exists public.is_class_member(uuid) set schema private;
alter function if exists public.owns_child(uuid) set schema private;

create or replace function private.has_class_role(target_class_id uuid, allowed_roles public.class_role[])
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select exists (
    select 1 from public.class_members
    where class_id = target_class_id
      and user_id = auth.uid()
      and status = 'active'
      and role = any(allowed_roles)
  );
$$;

create or replace function private.can_manage_class(target_class_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select private.has_class_role(target_class_id, array['parent_committee'::public.class_role, 'teacher'::public.class_role]);
$$;

create or replace function private.is_class_member(target_class_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select exists (
    select 1 from public.class_members
    where class_id = target_class_id
      and user_id = auth.uid()
      and status = 'active'
  );
$$;

create or replace function private.owns_child(target_child_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select exists (
    select 1 from public.children
    where id = target_child_id
      and parent_user_id = auth.uid()
  );
$$;

revoke all on function private.has_class_role(uuid, public.class_role[]) from public;
revoke all on function private.can_manage_class(uuid) from public;
revoke all on function private.is_class_member(uuid) from public;
revoke all on function private.owns_child(uuid) from public;

grant execute on function private.has_class_role(uuid, public.class_role[]) to anon, authenticated, service_role;
grant execute on function private.can_manage_class(uuid) to anon, authenticated, service_role;
grant execute on function private.is_class_member(uuid) to anon, authenticated, service_role;
grant execute on function private.owns_child(uuid) to anon, authenticated, service_role;

alter function public.touch_updated_at() set search_path = public, pg_temp;
revoke all on function public.rls_auto_enable() from public;
revoke execute on function public.rls_auto_enable() from anon, authenticated;
