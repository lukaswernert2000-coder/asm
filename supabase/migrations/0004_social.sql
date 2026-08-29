-- 0004_social.sql
create table public.favorites (
  user_id    uuid not null references public.profiles(id) on delete cascade,
  listing_id uuid not null references public.listings(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, listing_id)
);

create table public.blocks (
  blocker_id uuid not null references public.profiles(id) on delete cascade,
  blocked_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  constraint no_self_block check (blocker_id <> blocked_id)
);

create type public.report_target as enum ('listing','user','message');
create type public.report_status as enum ('open','reviewing','resolved','rejected');

create table public.reports (
  id          uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  target_type public.report_target not null,
  target_id   uuid not null,
  reason      text not null,
  details     text check (char_length(details) <= 1000),
  status      public.report_status not null default 'open',
  created_at  timestamptz not null default now(),
  handled_at  timestamptz,
  handled_by  uuid references public.profiles(id),
  resolution  text
);

create index reports_open_idx on public.reports (status, created_at)
  where status = 'open';

alter table public.favorites enable row level security;
alter table public.blocks    enable row level security;
alter table public.reports   enable row level security;

create policy favorites_own on public.favorites
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy blocks_own on public.blocks
  for all using (blocker_id = auth.uid()) with check (blocker_id = auth.uid());

create policy reports_insert_own on public.reports
  for insert with check (reporter_id = auth.uid());

create policy reports_read_own on public.reports
  for select using (reporter_id = auth.uid());

create policy reports_moderator on public.reports
  for all using (public.is_moderator());
