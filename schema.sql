-- LIGA SKALAMA: backend compartilhado para uma noite pública.
-- Leitura pública; alterações somente para contas explicitamente autorizadas em league_admins.
create table if not exists public.league_night (
  id integer primary key check (id = 1),
  state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create table if not exists public.goals (
  id uuid primary key default gen_random_uuid(),
  player_name text not null,
  team_name text,
  match_number integer not null,
  game_id uuid,
  score_team_name text,
  own_goal boolean not null default false,
  created_at timestamptz not null default now()
);
create table if not exists public.votes (
  id uuid primary key default gen_random_uuid(),
  category text not null check (category in ('star','keeper','rascal')),
  voter_name text not null,
  player_name text not null,
  period_key text not null default 'legacy',
  created_at timestamptz not null default now()
);
-- Existing votes remain intact in the legacy period; uniqueness now applies per voting window.
alter table public.votes add column if not exists period_key text not null default 'legacy';
alter table public.votes drop constraint if exists votes_category_voter_name_key;
create unique index if not exists votes_period_category_voter_unique on public.votes (category, voter_name, period_key);
create table if not exists public.league_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.league_night enable row level security;
alter table public.goals enable row level security;
alter table public.votes enable row level security;
alter table public.league_admins enable row level security;
-- Remove every previous policy so an old permissive policy cannot override the secure rules below.
do $$ declare p record; begin
  for p in select tablename, policyname from pg_policies where schemaname='public' and tablename in ('league_night','goals','votes','league_admins') loop
    execute format('drop policy if exists %I on public.%I',p.policyname,p.tablename);
  end loop;
end $$;
create policy "public can read league night" on public.league_night for select to anon, authenticated using (true);
create policy "public can read goals" on public.goals for select to anon, authenticated using (true);
create policy "public can read votes" on public.votes for select to anon, authenticated using (true);
create policy "organizer can read own access" on public.league_admins for select to authenticated using (user_id = auth.uid());
create policy "organizer can insert league night" on public.league_night for insert to authenticated with check (exists (select 1 from public.league_admins a where a.user_id=auth.uid()));
create policy "organizer can update league night" on public.league_night for update to authenticated using (exists (select 1 from public.league_admins a where a.user_id=auth.uid())) with check (exists (select 1 from public.league_admins a where a.user_id=auth.uid()));
create policy "organizer can insert goals" on public.goals for insert to authenticated with check (exists (select 1 from public.league_admins a where a.user_id=auth.uid()));
create policy "organizer can update goals" on public.goals for update to authenticated using (exists (select 1 from public.league_admins a where a.user_id=auth.uid())) with check (exists (select 1 from public.league_admins a where a.user_id=auth.uid()));
create policy "organizer can delete goals" on public.goals for delete to authenticated using (exists (select 1 from public.league_admins a where a.user_id=auth.uid()));
create policy "organizer can insert votes" on public.votes for insert to authenticated with check (exists (select 1 from public.league_admins a where a.user_id=auth.uid()));
create policy "organizer can update votes" on public.votes for update to authenticated using (exists (select 1 from public.league_admins a where a.user_id=auth.uid())) with check (exists (select 1 from public.league_admins a where a.user_id=auth.uid()));
create policy "organizer can delete votes" on public.votes for delete to authenticated using (exists (select 1 from public.league_admins a where a.user_id=auth.uid()));
revoke all on public.league_admins from anon, authenticated;
grant select on public.league_admins to authenticated;
grant select, insert, update, delete on public.league_night, public.goals, public.votes to anon, authenticated;
insert into public.league_night (id,state) values (1,'{}'::jsonb) on conflict (id) do nothing;
do $$ begin
  alter publication supabase_realtime add table public.league_night;
exception when duplicate_object then null;
end $$;
do $$ begin
  alter publication supabase_realtime add table public.goals;
exception when duplicate_object then null;
end $$;
do $$ begin
  alter publication supabase_realtime add table public.votes;
exception when duplicate_object then null;
end $$;
-- Additional field for recording the minute of each goal in the live match.
alter table public.goals add column if not exists minute integer;
alter table public.goals add column if not exists game_id uuid;


alter table public.goals add column if not exists score_team_name text;
alter table public.goals add column if not exists own_goal boolean not null default false;

