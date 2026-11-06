begin;
create extension if not exists pgtap with schema extensions;
select plan(30);

create function pg_temp.add_user(user_id uuid, user_email text, confirmed boolean default true)
returns void language sql as $$
  insert into auth.users (id, instance_id, aud, role, email, email_confirmed_at, raw_user_meta_data)
  values (user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
    user_email, case when confirmed then now() end, '{}'::jsonb)
$$;

create function pg_temp.act_as(user_id uuid) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claims',
    json_build_object('sub', user_id, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
end $$;

create function pg_temp.xp(user_id uuid) returns integer language sql as $$
  select xp from public.leaderboard where uid = user_id
$$;

select pg_temp.add_user('00000000-0000-4000-8000-00000000000a', 'ada@alustudent.com');
select pg_temp.add_user('00000000-0000-4000-8000-00000000000b', 'ben@alustudent.com');
select pg_temp.add_user('00000000-0000-4000-8000-00000000000c', 'pat@alu.edu');
select pg_temp.add_user('00000000-0000-4000-8000-00000000000d', 'eve@alu.edu');
select pg_temp.add_user('00000000-0000-4000-8000-00000000000e', 'sam@alu.edu');
select pg_temp.add_user('00000000-0000-4000-8000-00000000000f', 'new@alustudent.com', false);

delete from public.invites;
delete from public.departments;
insert into public.departments (id, label, categories) values
  ('plumbing', 'Plumbing', '{water}'), ('electrical', 'Electrical', '{electricity}');
insert into public.invites (email, role, department_id) values
  ('pat@alu.edu', 'faculty', 'plumbing'),
  ('eve@alu.edu', 'faculty', 'electrical'),
  ('sam@alu.edu', 'admin', null);

-- Provisioning

select pg_temp.act_as('00000000-0000-4000-8000-00000000000a');
select is(public.provision_account('Ada'), 'student'::public.person_role,
  'a verified ALU student email becomes a student');
select is(public.provision_account('Ada again'), 'student'::public.person_role,
  'provisioning twice returns the existing role');
select is(pg_temp.xp('00000000-0000-4000-8000-00000000000a'), 0,
  'a new student starts on the leaderboard at zero');

select pg_temp.act_as('00000000-0000-4000-8000-00000000000f');
select throws_ok($$ select public.provision_account() $$, 'P0001', 'unverified',
  'an unverified email is not provisioned');

reset role;
select pg_temp.add_user('00000000-0000-4000-8000-000000000010', 'stranger@gmail.com');
select pg_temp.act_as('00000000-0000-4000-8000-000000000010');
select throws_ok($$ select public.provision_account() $$, 'P0001', 'no-access',
  'an email outside ALU without an invite is refused');

select pg_temp.act_as('00000000-0000-4000-8000-00000000000c');
select is(public.provision_account(), 'faculty'::public.person_role,
  'an invited faculty member gets the faculty role');
select is((select department_id from public.profiles where email = 'pat@alu.edu'), 'plumbing',
  'and the team from the invite');
select pg_temp.act_as('00000000-0000-4000-8000-00000000000d');
select public.provision_account();
select pg_temp.act_as('00000000-0000-4000-8000-00000000000e');
select is(public.provision_account(), 'admin'::public.person_role, 'an invited admin gets the admin role');
select pg_temp.act_as('00000000-0000-4000-8000-00000000000b');
select public.provision_account('Ben');

reset role;
select is((select count(*)::integer from public.invites), 0, 'used invites are removed');

-- Direct writes are closed

select pg_temp.act_as('00000000-0000-4000-8000-00000000000a');
select throws_ok($$ update public.profiles set role = 'admin' where id = auth.uid() $$, '42501', null,
  'a student cannot change their own role');
select throws_ok($$ update public.leaderboard set xp = 9999 $$, '42501', null,
  'a student cannot write their own XP');
select throws_ok($$ insert into public.reports (id, title, description, location, category,
    reported_by, reported_by_name, updated_by)
  values (gen_random_uuid(), 't', 'd', 'l', 'water', auth.uid(), 'Ada', auth.uid()) $$, '42501', null,
  'reports cannot be inserted directly');

-- Filing and awards

select lives_ok($$ select public.file_report('10000000-0000-4000-8000-000000000001', 'Leaking tap',
  'The tap by the second floor kitchen drips all day.', 'Block B', 'water', '') $$,
  'a student files a report');
select is(pg_temp.xp('00000000-0000-4000-8000-00000000000a'), 15,
  'filing with a detailed description earns 15 XP');
select is((select reported_by_name from public.reports where id = '10000000-0000-4000-8000-000000000001'),
  'Ada', 'the reporter name comes from the profile, not the client');
select throws_ok($$ select public.approve_report('10000000-0000-4000-8000-000000000001') $$, '42501', null,
  'a student cannot approve');

-- Upvotes

select pg_temp.act_as('00000000-0000-4000-8000-00000000000b');
select public.set_upvote('10000000-0000-4000-8000-000000000001', true);
select public.set_upvote('10000000-0000-4000-8000-000000000001', true);
select is((select upvotes from public.reports where id = '10000000-0000-4000-8000-000000000001'), 1,
  'upvoting twice counts once');
select is(pg_temp.xp('00000000-0000-4000-8000-00000000000b'), 2, 'backing a report earns 2 XP');
select is((select count(*)::integer from public.xp_events), 1,
  'a student only sees their own XP events');
select public.set_upvote('10000000-0000-4000-8000-000000000001', false);
select is((select upvotes from public.reports where id = '10000000-0000-4000-8000-000000000001'), 0,
  'removing the upvote lowers the count');

-- Nudges

select pg_temp.act_as('00000000-0000-4000-8000-00000000000a');
select lives_ok($$ select public.nudge_report('10000000-0000-4000-8000-000000000001') $$,
  'the reporter nudges an open report');
select throws_ok($$ select public.nudge_report('10000000-0000-4000-8000-000000000001') $$, '42501', null,
  'a second nudge within 24 hours is refused');

-- Faculty ownership

select pg_temp.act_as('00000000-0000-4000-8000-00000000000d');
select throws_ok($$ select public.approve_report('10000000-0000-4000-8000-000000000001') $$, '42501', null,
  'faculty cannot approve another team''s report');
select pg_temp.act_as('00000000-0000-4000-8000-00000000000c');
select lives_ok($$ select public.approve_report('10000000-0000-4000-8000-000000000001') $$,
  'the owning team approves');
select is(pg_temp.xp('00000000-0000-4000-8000-00000000000a'), 45,
  'approval awards the reporter 25 XP on top of filing and the nudge');
select public.resolve_report('10000000-0000-4000-8000-000000000001');

select pg_temp.act_as('00000000-0000-4000-8000-00000000000a');
select public.confirm_fix('10000000-0000-4000-8000-000000000001');
select is(pg_temp.xp('00000000-0000-4000-8000-00000000000a'), 110,
  'resolution and a confirmed fix award 50 and 15 more');

-- Withdrawal revokes, suspension blocks

select public.file_report('10000000-0000-4000-8000-000000000002', 'Dark corridor', 'Bulb out.',
  'Block C', 'electricity', '');
select public.delete_report('10000000-0000-4000-8000-000000000002');
select is(pg_temp.xp('00000000-0000-4000-8000-00000000000a'), 110,
  'withdrawing a report before approval takes back its XP');

select pg_temp.act_as('00000000-0000-4000-8000-00000000000e');
select throws_ok($$ select public.set_suspended(auth.uid(), true) $$, '42501', null,
  'an admin cannot suspend themselves');
select public.set_suspended('00000000-0000-4000-8000-00000000000b', true);
select pg_temp.act_as('00000000-0000-4000-8000-00000000000b');
select throws_ok($$ select public.file_report(gen_random_uuid(), 't', 'd', 'l', 'water', '') $$,
  '42501', null, 'a suspended student cannot file');
select is((select count(*)::integer from public.reports), 0,
  'a suspended student cannot read reports');

select * from finish();
rollback;
