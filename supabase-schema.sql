-- ============================================================================
-- Habit Tracker — Supabase schema (optional cloud sync)
-- ============================================================================
-- The Habit Tracker app runs 100% locally (localStorage) by default.
-- Run this file in your own Supabase project's SQL Editor ONLY if you want
-- to enable the cloud mode described in README.md ("Going live with Supabase").
--
-- Design follows the official Supabase agent skills:
--   * RLS is ENABLED on every table in the exposed `public` schema.
--   * Policies use `TO authenticated` (never the deprecated auth.role())
--     combined with an ownership predicate: (select auth.uid()) = user_id.
--     The (select ...) wrapper lets Postgres evaluate auth.uid() once per
--     query instead of once per row (RLS performance best practice).
--   * UPDATE policies carry both USING and WITH CHECK so a user cannot
--     reassign a row's user_id to someone else.
--   * Columns used by RLS policies and foreign keys are indexed.
--   * Authorization is keyed to auth.uid() only — never to user-editable
--     profile metadata, which is unsafe for access decisions.
--   * Only the publishable key belongs in browser code. Never put the
--     secret service-role key in the app.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: habits — one row per habit owned by a user
-- ----------------------------------------------------------------------------
create table if not exists public.habits (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,
  name        text not null check (char_length(name) between 1 and 80),
  color       text not null default '#6133b4'
              check (color ~ '^#[0-9a-fA-F]{6}$'),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- Table: habit_logs — one row per habit per completed day
-- user_id is stored on the log as well so RLS policies stay a simple,
-- index-friendly ownership check (no join needed inside the policy).
-- ----------------------------------------------------------------------------
create table if not exists public.habit_logs (
  id          uuid primary key default gen_random_uuid(),
  habit_id    uuid not null references public.habits (id) on delete cascade,
  user_id     uuid not null references auth.users (id) on delete cascade,
  log_date    date not null,
  created_at  timestamptz not null default now(),
  unique (habit_id, log_date)
);

-- Indexes: foreign keys + every column used inside RLS policies
create index if not exists habits_user_id_idx     on public.habits (user_id);
create index if not exists habit_logs_user_id_idx on public.habit_logs (user_id);
create index if not exists habit_logs_habit_id_idx on public.habit_logs (habit_id);
create index if not exists habit_logs_log_date_idx on public.habit_logs (log_date);

-- ============================================================================
-- Row Level Security — ENABLED on both tables.
-- With RLS on and the policies below, the anon role can see nothing and each
-- signed-in user can only ever read/write their own rows.
-- ============================================================================
alter table public.habits     enable row level security;
alter table public.habit_logs enable row level security;

-- ----------------------------------------------------------------------------
-- Policies: habits
-- ----------------------------------------------------------------------------
create policy "habits: read own"
  on public.habits for select
  to authenticated
  using ( (select auth.uid()) = user_id );

create policy "habits: insert own"
  on public.habits for insert
  to authenticated
  with check ( (select auth.uid()) = user_id );

create policy "habits: update own"
  on public.habits for update
  to authenticated
  using ( (select auth.uid()) = user_id )
  with check ( (select auth.uid()) = user_id );

create policy "habits: delete own"
  on public.habits for delete
  to authenticated
  using ( (select auth.uid()) = user_id );

-- ----------------------------------------------------------------------------
-- Policies: habit_logs
-- ----------------------------------------------------------------------------
create policy "habit_logs: read own"
  on public.habit_logs for select
  to authenticated
  using ( (select auth.uid()) = user_id );

create policy "habit_logs: insert own"
  on public.habit_logs for insert
  to authenticated
  with check ( (select auth.uid()) = user_id );

create policy "habit_logs: update own"
  on public.habit_logs for update
  to authenticated
  using ( (select auth.uid()) = user_id )
  with check ( (select auth.uid()) = user_id );

create policy "habit_logs: delete own"
  on public.habit_logs for delete
  to authenticated
  using ( (select auth.uid()) = user_id );

-- ============================================================================
-- Grants for the Data API.
-- RLS above is what actually restricts rows; these grants only make the
-- tables reachable by signed-in users at all. Nothing is granted to `anon`,
-- so signed-out visitors cannot touch either table.
-- ============================================================================
grant select, insert, update, delete on public.habits     to authenticated;
grant select, insert, update, delete on public.habit_logs to authenticated;
