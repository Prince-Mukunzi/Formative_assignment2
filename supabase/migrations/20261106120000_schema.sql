-- Clients read through row level security and write only through the
-- functions below, which check the caller's role and the report's state.

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create type public.person_role as enum ('student', 'faculty', 'admin');
create type public.report_status as enum ('awaitingApproval', 'inProgress', 'resolved', 'declined');
create type public.report_category as enum ('facilities', 'water', 'electricity', 'furniture', 'sanitation', 'safety');

create table public.departments (
  id text primary key,
  label text not null check (char_length(label) between 1 and 80),
  categories public.report_category[] not null default '{}'
);

create table public.locations (
  name text primary key check (char_length(name) between 1 and 120)
);

create table public.profiles (
  id uuid primary key references auth.users on delete cascade,
  name text not null check (char_length(name) between 1 and 80),
  email text not null unique,
  role public.person_role not null,
  department_id text references public.departments on delete set null,
  suspended boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.invites (
  email text primary key check (email = lower(email)),
  role public.person_role not null check (role <> 'student'),
  department_id text references public.departments on delete cascade,
  invited_by uuid references public.profiles on delete set null,
  created_at timestamptz not null default now(),
  check ((role = 'faculty') = (department_id is not null))
);

create table public.reports (
  id uuid primary key,
  title text not null check (char_length(title) between 1 and 120),
  description text not null check (char_length(description) <= 2000),
  location text not null check (char_length(location) between 1 and 120),
  category public.report_category not null,
  image_url text not null default '' check (char_length(image_url) <= 2048),
  status public.report_status not null default 'awaitingApproval',
  upvotes integer not null default 0 check (upvotes >= 0),
  nudges integer not null default 0,
  reopen_count integer not null default 0,
  reported_by uuid not null references public.profiles on delete cascade,
  reported_by_name text not null,
  assigned_department_id text references public.departments on delete set null,
  created_at timestamptz not null default now(),
  approved_at timestamptz,
  resolved_at timestamptz,
  verified_at timestamptz,
  last_nudged_at timestamptz,
  updated_at timestamptz not null default now(),
  updated_by uuid not null
);

create index reports_created_at on public.reports (created_at desc);

create table public.upvotes (
  report_id uuid not null references public.reports on delete cascade,
  uid uuid not null references public.profiles on delete cascade,
  created_at timestamptz not null default now(),
  primary key (report_id, uid)
);

create index upvotes_uid on public.upvotes (uid);

-- Events outlive a deleted report on purpose: XP already earned stays,
-- except for reports withdrawn before approval.
create table public.xp_events (
  uid uuid not null references public.profiles on delete cascade,
  key text not null,
  reason text not null,
  report_id uuid not null,
  at timestamptz not null default now(),
  seen boolean not null default false,
  primary key (uid, key)
);

-- Kept apart from profiles so ranking never exposes emails.
create table public.leaderboard (
  uid uuid primary key references public.profiles on delete cascade,
  name text not null,
  xp integer not null default 0
);

create index leaderboard_xp on public.leaderboard (xp desc);

-- Access helpers

create function public.active_role() returns public.person_role
language sql stable security definer set search_path = '' as $$
  select role from public.profiles where id = auth.uid() and not suspended
$$;

create function public.has_role(wanted public.person_role) returns boolean
language sql stable security definer set search_path = '' as $$
  select coalesce(public.active_role() = wanted, false)
$$;

create function public.is_active() returns boolean
language sql stable security definer set search_path = '' as $$
  select public.active_role() is not null
$$;

create function private.me() returns public.profiles
language plpgsql stable security definer set search_path = '' as $$
declare
  found_profile public.profiles;
begin
  select * into found_profile from public.profiles
  where id = auth.uid() and not suspended;
  if not found then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  return found_profile;
end $$;

create function private.require_role(wanted public.person_role) returns public.profiles
language plpgsql stable security definer set search_path = '' as $$
declare
  caller public.profiles := private.me();
begin
  if caller.role <> wanted then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  return caller;
end $$;

create function private.owns_report(caller public.profiles, report public.reports) returns boolean
language sql stable security definer set search_path = '' as $$
  select caller.role = 'admin'
    or (caller.role = 'faculty' and caller.department_id is not null and (
      case when report.assigned_department_id is not null
        then report.assigned_department_id = caller.department_id
        else exists (
          select 1 from public.departments d
          where d.id = caller.department_id and report.category = any (d.categories)
        )
      end))
$$;

create function private.lock_report(report_id uuid) returns public.reports
language plpgsql security definer set search_path = '' as $$
declare
  report public.reports;
begin
  select * into report from public.reports where id = report_id for update;
  if not found then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  return report;
end $$;

create function private.reporters_report(report_id uuid) returns public.reports
language plpgsql security definer set search_path = '' as $$
declare
  caller public.profiles := private.require_role('student');
  report public.reports := private.lock_report(report_id);
begin
  if report.reported_by <> caller.id then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  return report;
end $$;

create function private.staff_report(report_id uuid) returns public.reports
language plpgsql security definer set search_path = '' as $$
declare
  caller public.profiles := private.me();
  report public.reports := private.lock_report(report_id);
begin
  if not private.owns_report(caller, report) then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  return report;
end $$;

-- XP

create function public.xp_for(reason text) returns integer
language sql immutable set search_path = '' as $$
  select case reason
    when 'reportFiled' then 10
    when 'photoAdded' then 5
    when 'detailAdded' then 5
    when 'reportApproved' then 25
    when 'reportResolved' then 50
    when 'fixChecked' then 15
    when 'upvoteGiven' then 2
    when 'nudgeSent' then 5
  end
$$;

-- Keys match the app's predictions, so a retried award is a no-op.
create function private.grant_xp(student uuid, reason text, report_id uuid, scope text default null)
returns void language plpgsql security definer set search_path = '' as $$
begin
  insert into public.xp_events (uid, key, reason, report_id)
  values (student, reason || ':' || coalesce(scope, report_id::text), reason, report_id)
  on conflict do nothing;
  if found then
    update public.leaderboard set xp = xp + public.xp_for(reason) where uid = student;
  end if;
end $$;

create function private.award_report() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  reporter uuid := new.reported_by;
begin
  if tg_op = 'INSERT' then
    perform private.grant_xp(reporter, 'reportFiled', new.id);
  end if;
  if new.image_url <> '' then
    perform private.grant_xp(reporter, 'photoAdded', new.id);
  end if;
  if char_length(new.description) >= 30 then
    perform private.grant_xp(reporter, 'detailAdded', new.id);
  end if;
  if tg_op = 'UPDATE' then
    if old.status = 'awaitingApproval' and new.status = 'inProgress' then
      perform private.grant_xp(reporter, 'reportApproved', new.id);
    end if;
    if old.status <> 'resolved' and new.status = 'resolved' then
      perform private.grant_xp(reporter, 'reportResolved', new.id);
    end if;
    -- A reporter saying "still broken" earns the same as confirming; a
    -- faculty reopen does not.
    if (old.verified_at is null and new.verified_at is not null)
      or (old.status = 'resolved' and new.status = 'inProgress' and new.updated_by = reporter) then
      perform private.grant_xp(reporter, 'fixChecked', new.id);
    end if;
    if new.nudges > old.nudges then
      perform private.grant_xp(reporter, 'nudgeSent', new.id,
        new.id::text || ':' || to_char(now() at time zone 'utc', 'YYYY-MM-DD'));
    end if;
  end if;
  return null;
end $$;

create trigger reports_award after insert or update on public.reports
for each row execute function private.award_report();

create function private.revoke_withdrawn() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  total integer;
begin
  if old.status <> 'awaitingApproval' then
    return null;
  end if;
  with removed as (
    delete from public.xp_events
    where uid = old.reported_by and report_id = old.id
    returning reason
  )
  select coalesce(sum(public.xp_for(reason)), 0) into total from removed;
  update public.leaderboard set xp = xp - total where uid = old.reported_by;
  return null;
end $$;

create trigger reports_revoke after delete on public.reports
for each row execute function private.revoke_withdrawn();

create function private.award_upvote() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  perform private.grant_xp(new.uid, 'upvoteGiven', new.report_id);
  return null;
end $$;

create trigger upvotes_award after insert on public.upvotes
for each row execute function private.award_upvote();

-- Accounts

create function public.provision_account(display_name text default null) returns public.person_role
language plpgsql security definer set search_path = '' as $$
declare
  caller uuid := auth.uid();
  account auth.users;
  invite public.invites;
  existing public.person_role;
  granted public.person_role;
  chosen_name text;
  normalized_email text;
begin
  select * into account from auth.users where id = caller;
  if not found then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if account.email_confirmed_at is null then
    raise exception 'unverified' using errcode = 'P0001';
  end if;

  select role into existing from public.profiles where id = caller;
  if found then
    return existing;
  end if;

  normalized_email := lower(account.email);
  select * into invite from public.invites where email = normalized_email for update;
  if found then
    granted := invite.role;
  elsif normalized_email like '%@alustudent.com' then
    granted := 'student';
  else
    raise exception 'no-access' using errcode = 'P0001';
  end if;

  chosen_name := left(coalesce(
    nullif(trim(display_name), ''),
    nullif(trim(account.raw_user_meta_data ->> 'name'), ''),
    nullif(trim(account.raw_user_meta_data ->> 'full_name'), ''),
    split_part(normalized_email, '@', 1)
  ), 80);

  insert into public.profiles (id, name, email, role, department_id)
  values (caller, chosen_name, normalized_email, granted, invite.department_id);
  delete from public.invites where email = normalized_email;
  if granted = 'student' then
    insert into public.leaderboard (uid, name) values (caller, chosen_name);
  end if;
  return granted;
end $$;

-- Inviting someone who already has an account changes their role at once.
create function public.invite_member(invitee text, member_role public.person_role, department text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare
  caller public.profiles := private.require_role('admin');
  normalized_email text := lower(trim(invitee));
  department_for_role text := case when member_role = 'faculty' then department end;
begin
  if member_role = 'student' then
    raise exception 'students join with their own email' using errcode = '22023';
  end if;
  update public.profiles
  set role = member_role, department_id = department_for_role
  where email = normalized_email;
  if found then
    delete from public.leaderboard l using public.profiles p
    where p.email = normalized_email and l.uid = p.id;
    return;
  end if;
  insert into public.invites (email, role, department_id, invited_by)
  values (normalized_email, member_role, department_for_role, caller.id)
  on conflict (email) do update
  set role = excluded.role, department_id = excluded.department_id,
      invited_by = excluded.invited_by, created_at = now();
end $$;

-- An admin cannot suspend themselves, so the last admin is never locked out.
create function public.set_suspended(member uuid, is_suspended boolean) returns void
language plpgsql security definer set search_path = '' as $$
declare
  caller public.profiles := private.require_role('admin');
begin
  if member = caller.id then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  update public.profiles set suspended = is_suspended where id = member;
end $$;

create function public.move_to_department(member uuid, department text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  perform private.require_role('admin');
  update public.profiles set department_id = department where id = member;
end $$;

-- Directory

-- A category has one owner, so saving a team takes its categories from the others.
create function public.save_department(department text, department_label text, owned public.report_category[])
returns void language plpgsql security definer set search_path = '' as $$
begin
  perform private.require_role('admin');
  update public.departments
  set categories = array(select unnest(categories) except select unnest(owned))
  where id <> department;
  insert into public.departments (id, label, categories)
  values (department, department_label, owned)
  on conflict (id) do update set label = excluded.label, categories = excluded.categories;
end $$;

create function public.remove_department(department text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  perform private.require_role('admin');
  delete from public.departments where id = department;
end $$;

create function public.add_location(location text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  perform private.require_role('admin');
  insert into public.locations (name) values (trim(location)) on conflict do nothing;
end $$;

create function public.remove_location(location text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  perform private.require_role('admin');
  delete from public.locations where name = location;
end $$;

-- Reports

create function public.file_report(
  report_id uuid, title text, description text, location text,
  category public.report_category, image_url text
) returns void language plpgsql security definer set search_path = '' as $$
declare
  caller public.profiles := private.require_role('student');
begin
  insert into public.reports (
    id, title, description, location, category, image_url,
    reported_by, reported_by_name, updated_by
  ) values (
    report_id, title, description, location, category, image_url,
    caller.id, caller.name, caller.id
  );
end $$;

create function public.edit_report(
  report_id uuid, title text, description text, location text,
  category public.report_category, image_url text
) returns void language plpgsql security definer set search_path = '' as $$
declare
  report public.reports := private.reporters_report(report_id);
begin
  if report.status <> 'awaitingApproval' then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  update public.reports r set
    title = edit_report.title,
    description = edit_report.description,
    location = edit_report.location,
    category = edit_report.category,
    image_url = edit_report.image_url,
    updated_by = auth.uid(),
    updated_at = now()
  where r.id = report_id;
end $$;

create function public.set_upvote(report_id uuid, upvoted boolean) returns void
language plpgsql security definer set search_path = '' as $$
declare
  caller public.profiles := private.require_role('student');
  change integer;
begin
  perform private.lock_report(report_id);
  if upvoted then
    insert into public.upvotes (report_id, uid) values (report_id, caller.id)
    on conflict do nothing;
  else
    delete from public.upvotes u where u.report_id = set_upvote.report_id and u.uid = caller.id;
  end if;
  if not found then
    return;
  end if;
  change := case when upvoted then 1 else -1 end;
  update public.reports r
  set upvotes = upvotes + change, updated_at = now()
  where r.id = report_id;
end $$;

create function public.nudge_report(report_id uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare
  report public.reports := private.reporters_report(report_id);
begin
  if report.status not in ('awaitingApproval', 'inProgress')
    or (report.last_nudged_at is not null and report.last_nudged_at > now() - interval '24 hours') then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  update public.reports r set
    nudges = nudges + 1, last_nudged_at = now(),
    updated_by = auth.uid(), updated_at = now()
  where r.id = report_id;
end $$;

create function public.confirm_fix(report_id uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare
  report public.reports := private.reporters_report(report_id);
begin
  if report.status <> 'resolved' or report.verified_at is not null then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  update public.reports r set
    verified_at = now(), updated_by = auth.uid(), updated_at = now()
  where r.id = report_id;
end $$;

create function private.reopen(report_id uuid) returns void
language sql security definer set search_path = '' as $$
  update public.reports set
    status = 'inProgress', approved_at = now(), resolved_at = null,
    verified_at = null, reopen_count = reopen_count + 1,
    updated_by = auth.uid(), updated_at = now()
  where id = report_id
$$;

-- Reporters reopen only a fix they have not confirmed; staff can also
-- reopen a declined report.
create function public.reopen_report(report_id uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare
  caller public.profiles := private.me();
  report public.reports := private.lock_report(report_id);
begin
  if caller.role = 'student' then
    if report.reported_by <> caller.id
      or report.status <> 'resolved' or report.verified_at is not null then
      raise exception 'not allowed' using errcode = '42501';
    end if;
  elsif not private.owns_report(caller, report)
    or report.status not in ('resolved', 'declined') then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  perform private.reopen(report_id);
end $$;

create function private.move_status(
  report_id uuid, expected public.report_status, target public.report_status
) returns void language plpgsql security definer set search_path = '' as $$
declare
  report public.reports := private.staff_report(report_id);
begin
  if report.status <> expected then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  update public.reports set
    status = target,
    approved_at = case when target = 'inProgress' then now() else approved_at end,
    resolved_at = case when target = 'resolved' then now() else resolved_at end,
    updated_by = auth.uid(), updated_at = now()
  where id = report_id;
end $$;

create function public.approve_report(report_id uuid) returns void
language sql security definer set search_path = '' as $$
  select private.move_status(report_id, 'awaitingApproval', 'inProgress')
$$;

create function public.decline_report(report_id uuid) returns void
language sql security definer set search_path = '' as $$
  select private.move_status(report_id, 'awaitingApproval', 'declined')
$$;

create function public.resolve_report(report_id uuid) returns void
language sql security definer set search_path = '' as $$
  select private.move_status(report_id, 'inProgress', 'resolved')
$$;

create function public.reassign_report(report_id uuid, department text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  perform private.staff_report(report_id);
  update public.reports r set
    assigned_department_id = department, updated_by = auth.uid(), updated_at = now()
  where r.id = report_id;
end $$;

create function public.delete_report(report_id uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare
  caller public.profiles := private.me();
  report public.reports := private.lock_report(report_id);
begin
  if not (caller.role = 'admin'
    or (caller.role = 'student' and report.reported_by = caller.id
      and report.status = 'awaitingApproval')) then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  delete from public.reports where id = report_id;
end $$;

create function public.mark_xp_seen(keys text[]) returns void
language sql security definer set search_path = '' as $$
  update public.xp_events set seen = true where uid = auth.uid() and key = any (keys)
$$;

-- Row level security: reads only. Every write above runs as the owner.

alter table public.departments enable row level security;
alter table public.locations enable row level security;
alter table public.profiles enable row level security;
alter table public.invites enable row level security;
alter table public.reports enable row level security;
alter table public.upvotes enable row level security;
alter table public.xp_events enable row level security;
alter table public.leaderboard enable row level security;

create policy "active members read departments" on public.departments
  for select to authenticated using (public.is_active());
create policy "active members read locations" on public.locations
  for select to authenticated using (public.is_active());
-- A suspended member still reads their own profile to see why they are blocked.
create policy "members read themselves, admins read everyone" on public.profiles
  for select to authenticated using (id = auth.uid() or public.has_role('admin'));
create policy "admins read invites" on public.invites
  for select to authenticated using (public.has_role('admin'));
create policy "active members read reports" on public.reports
  for select to authenticated using (public.is_active());
create policy "members read their upvotes" on public.upvotes
  for select to authenticated using (uid = auth.uid() and public.is_active());
create policy "members read their xp" on public.xp_events
  for select to authenticated using (uid = auth.uid());
create policy "active members read the leaderboard" on public.leaderboard
  for select to authenticated using (public.is_active());

revoke insert, update, delete, truncate on all tables in schema public from anon, authenticated;
revoke all on all tables in schema public from anon;

revoke execute on all functions in schema public from public, anon;
grant execute on all functions in schema public to authenticated;
revoke execute on all functions in schema private from public, anon, authenticated;

-- Photos

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('report-photos', 'report-photos', true, 5242880, array['image/jpeg', 'image/png', 'image/heic']);

create policy "students upload to their own folder" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'report-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
    and public.has_role('student')
  );

create policy "active members see photos" on storage.objects
  for select to authenticated
  using (bucket_id = 'report-photos' and public.is_active());

create policy "owners and admins remove photos" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'report-photos'
    and ((storage.foldername(name))[1] = auth.uid()::text or public.has_role('admin'))
  );

-- Live updates

alter publication supabase_realtime add table
  public.departments, public.locations, public.profiles, public.reports,
  public.upvotes, public.xp_events, public.leaderboard;
