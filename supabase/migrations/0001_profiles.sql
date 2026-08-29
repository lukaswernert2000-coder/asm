-- 0001_profiles.sql
create extension if not exists "uuid-ossp";
create extension if not exists cube;
create extension if not exists earthdistance;
create extension if not exists pg_trgm;

create type public.user_role as enum ('user', 'moderator');

create table public.profiles (
  id                 uuid primary key references auth.users(id) on delete cascade,
  username           text not null unique
                       check (char_length(username) between 3 and 24
                              and username ~ '^[a-zA-Z0-9_]+$'),
  display_name       text check (char_length(display_name) <= 40),
  avatar_path        text,
  bio                text check (char_length(bio) <= 500),
  postal_code        text check (postal_code ~ '^[0-9]{5}$'),
  city               text,
  lat                double precision,
  lng                double precision,
  birth_date         date,
  is_commercial      boolean not null default false,
  commercial_name    text,
  commercial_address text,
  role               public.user_role not null default 'user',
  is_banned          boolean not null default false,
  created_at         timestamptz not null default now(),
  last_seen_at       timestamptz not null default now(),
  deleted_at         timestamptz,
  constraint commercial_needs_details check (
    not is_commercial
    or (commercial_name is not null and commercial_address is not null)
  )
);

create index profiles_username_trgm on public.profiles using gin (username gin_trgm_ops);

-- Profil automatisch beim Registrieren anlegen
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, username)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data->>'username',
      'user_' || substr(replace(new.id::text, '-', ''), 1, 10)
    )
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Volljaehrigkeits-Check, wird von den Listing-Policies genutzt
create or replace function public.is_adult()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce((
    select birth_date is not null
       and birth_date <= (current_date - interval '18 years')
    from public.profiles
    where id = auth.uid()
  ), false);
$$;

create or replace function public.is_moderator()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select role = 'moderator' from public.profiles where id = auth.uid()),
    false);
$$;

-- RLS
alter table public.profiles enable row level security;

create policy profiles_select_all on public.profiles
  for select using (deleted_at is null);

create policy profiles_update_own on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

create policy profiles_moderator_all on public.profiles
  for all using (public.is_moderator());

-- Spaltenrechte: Geburtsdatum und Geschaeftsanschrift sind nicht oeffentlich
revoke all on public.profiles from anon, authenticated;

grant select (id, username, display_name, avatar_path, bio, postal_code, city,
              is_commercial, commercial_name, role, created_at, last_seen_at)
  on public.profiles to anon, authenticated;

grant update (username, display_name, avatar_path, bio, postal_code, city,
              lat, lng, birth_date, is_commercial, commercial_name,
              commercial_address, last_seen_at)
  on public.profiles to authenticated;
