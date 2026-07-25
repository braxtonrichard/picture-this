-- Picture This Phase 1 schema: profiles, vibes, recommendations,
-- experiences, reflections. RLS is enabled from the start; every
-- user-owned table is scoped to auth.uid(). vibes/recommendations are
-- public reference data (read-only from the client, same pattern as
-- EstiMate's `schools` table).

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- profiles
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  display_name text not null default '',
  photo_url text,
  favorite_vibe_ids uuid[] not null default '{}',
  answers jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "profiles: select own" on public.profiles
  for select using (auth.uid() = id);

create policy "profiles: update own" on public.profiles
  for update using (auth.uid() = id);

create policy "profiles: insert own" on public.profiles
  for insert with check (auth.uid() = id);

-- Create a profile row automatically when a new auth user signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, display_name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'display_name', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ---------------------------------------------------------------------------
-- vibes (public reference data — author via the Supabase dashboard/SQL
-- editor for now; there's no in-app authoring UI yet)
-- ---------------------------------------------------------------------------
create table if not exists public.vibes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null default '',
  cover_image_url text not null default '',
  tags text[] not null default '{}',
  created_at timestamptz not null default now()
);

alter table public.vibes enable row level security;

create policy "vibes: read for authenticated users" on public.vibes
  for select to authenticated using (true);

-- ---------------------------------------------------------------------------
-- recommendations (public reference data, same authoring caveat as vibes)
-- ---------------------------------------------------------------------------
create table if not exists public.recommendations (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null,
  image_url text not null default '',
  description text not null default '',
  vibe_ids uuid[] not null default '{}',
  location text,
  created_at timestamptz not null default now()
);

create index if not exists recommendations_vibe_ids_idx
  on public.recommendations using gin (vibe_ids);

alter table public.recommendations enable row level security;

create policy "recommendations: read for authenticated users"
  on public.recommendations for select to authenticated using (true);

-- ---------------------------------------------------------------------------
-- experiences
-- ---------------------------------------------------------------------------
create table if not exists public.experiences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  recommendation_id uuid references public.recommendations (id) on delete set null,
  recommendation_title text not null,
  recommendation_image_url text not null default '',
  status text not null default 'planned'
    check (status in ('planned', 'experienced', 'reflected')),
  created_at timestamptz not null default now(),
  experienced_at timestamptz
);

create index if not exists experiences_user_id_idx on public.experiences (user_id);

alter table public.experiences enable row level security;

create policy "experiences: select own" on public.experiences
  for select using (auth.uid() = user_id);

create policy "experiences: insert own" on public.experiences
  for insert with check (auth.uid() = user_id);

create policy "experiences: update own" on public.experiences
  for update using (auth.uid() = user_id);

create policy "experiences: delete own" on public.experiences
  for delete using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- reflections
-- ---------------------------------------------------------------------------
create table if not exists public.reflections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  experience_id uuid not null references public.experiences (id) on delete cascade,
  rating text not null
    check (rating in ('love', 'like', 'neutral', 'dislike', 'neverAgain')),
  would_repeat boolean not null default false,
  matched_vibe boolean not null default false,
  mood_before smallint,
  mood_after smallint,
  journal_entry text,
  created_at timestamptz not null default now()
);

create index if not exists reflections_user_id_idx on public.reflections (user_id);
create index if not exists reflections_experience_id_idx
  on public.reflections (experience_id);

alter table public.reflections enable row level security;

create policy "reflections: select own" on public.reflections
  for select using (auth.uid() = user_id);

create policy "reflections: insert own" on public.reflections
  for insert with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- submit_reflection: inserts the reflection and flips the experience to
-- 'reflected' in one transaction. security invoker (the default) means
-- this still runs under the caller's RLS — it's a convenience wrapper for
-- atomicity, not a privilege escalation.
-- ---------------------------------------------------------------------------
create or replace function public.submit_reflection(
  p_experience_id uuid,
  p_rating text,
  p_would_repeat boolean,
  p_matched_vibe boolean,
  p_mood_before smallint,
  p_mood_after smallint,
  p_journal_entry text
)
returns uuid
language plpgsql
security invoker
as $$
declare
  v_reflection_id uuid;
begin
  insert into public.reflections (
    user_id, experience_id, rating, would_repeat, matched_vibe,
    mood_before, mood_after, journal_entry
  )
  values (
    auth.uid(), p_experience_id, p_rating, p_would_repeat, p_matched_vibe,
    p_mood_before, p_mood_after, p_journal_entry
  )
  returning id into v_reflection_id;

  update public.experiences
    set status = 'reflected'
    where id = p_experience_id and user_id = auth.uid();

  return v_reflection_id;
end;
$$;
