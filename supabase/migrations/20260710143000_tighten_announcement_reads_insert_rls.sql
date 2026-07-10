-- Tighten read-state writes: a user may acknowledge only announcements
-- from classes where they are an active member.

drop policy if exists announcement_reads_upsert_own on public.announcement_reads;

create policy announcement_reads_insert_own_member
on public.announcement_reads for insert
to authenticated
with check (
  user_id = (select auth.uid())
  and exists (
    select 1
    from public.announcements item
    where item.id = announcement_reads.announcement_id
      and private.is_class_member(item.class_id)
  )
);
