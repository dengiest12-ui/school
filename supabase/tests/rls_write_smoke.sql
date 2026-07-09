-- Supabase RLS write checks for role-sensitive MVP actions.
-- Expected:
-- - parent cannot publish announcements
-- - parent cannot create collections
-- - parent cannot add collection expenses
-- - teacher can publish announcements, create collections and add expenses

begin;
create temp table rls_write_results (
  check_name text not null,
  passed boolean not null,
  detail text not null
) on commit drop;
grant insert, select on table rls_write_results to authenticated;

set local role authenticated;
select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000001', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

do $$
begin
  begin
    insert into public.announcements (class_id, author_user_id, title, body)
    values (
      '20000000-0000-4000-8000-000000000001',
      '10000000-0000-4000-8000-000000000001',
      'Parent should not publish',
      'RLS smoke'
    );

    insert into rls_write_results values ('parent_announcement_insert_blocked', false, 'insert unexpectedly allowed');
  exception
    when insufficient_privilege then
      insert into rls_write_results values ('parent_announcement_insert_blocked', true, sqlstate);
  end;

  begin
    insert into public.collections (class_id, author_user_id, title, amount_per_family)
    values (
      '20000000-0000-4000-8000-000000000001',
      '10000000-0000-4000-8000-000000000001',
      'Parent should not create collection',
      1000
    );

    insert into rls_write_results values ('parent_collection_insert_blocked', false, 'insert unexpectedly allowed');
  exception
    when insufficient_privilege then
      insert into rls_write_results values ('parent_collection_insert_blocked', true, sqlstate);
  end;

  begin
    insert into public.collection_expenses (collection_id, author_user_id, title, amount)
    values (
      '50000000-0000-4000-8000-000000000001',
      '10000000-0000-4000-8000-000000000001',
      'Parent should not add expense',
      100
    );

    insert into rls_write_results values ('parent_expense_insert_blocked', false, 'insert unexpectedly allowed');
  exception
    when insufficient_privilege then
      insert into rls_write_results values ('parent_expense_insert_blocked', true, sqlstate);
  end;
end $$;

select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000002', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

do $$
begin
  begin
    insert into public.announcements (class_id, author_user_id, title, body)
    values (
      '20000000-0000-4000-8000-000000000001',
      '10000000-0000-4000-8000-000000000002',
      'Teacher can publish',
      'RLS smoke'
    );

    insert into rls_write_results values ('teacher_announcement_insert_allowed', true, 'insert allowed');
  exception
    when others then
      insert into rls_write_results values ('teacher_announcement_insert_allowed', false, sqlstate || ': ' || sqlerrm);
  end;

  begin
    insert into public.collections (class_id, author_user_id, title, amount_per_family)
    values (
      '20000000-0000-4000-8000-000000000001',
      '10000000-0000-4000-8000-000000000002',
      'Teacher can create collection',
      1000
    );

    insert into rls_write_results values ('teacher_collection_insert_allowed', true, 'insert allowed');
  exception
    when others then
      insert into rls_write_results values ('teacher_collection_insert_allowed', false, sqlstate || ': ' || sqlerrm);
  end;

  begin
    insert into public.collection_expenses (collection_id, author_user_id, title, amount)
    values (
      '50000000-0000-4000-8000-000000000001',
      '10000000-0000-4000-8000-000000000002',
      'Teacher can add expense',
      100
    );

    insert into rls_write_results values ('teacher_expense_insert_allowed', true, 'insert allowed');
  exception
    when others then
      insert into rls_write_results values ('teacher_expense_insert_allowed', false, sqlstate || ': ' || sqlerrm);
  end;
end $$;

select *
from rls_write_results
order by check_name;

rollback;
