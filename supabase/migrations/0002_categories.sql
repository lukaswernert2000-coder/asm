-- 0002_categories.sql
create table public.categories (
  id                  uuid primary key default gen_random_uuid(),
  parent_id           uuid references public.categories(id) on delete cascade,
  slug                text not null unique,
  name                text not null,
  icon                text,
  sort_order          int not null default 0,
  requires_age_18     boolean not null default false,
  requires_f_marking  boolean not null default false,
  requires_joule      boolean not null default false,
  requires_propulsion boolean not null default false,
  is_active           boolean not null default true
);

create index categories_parent_idx on public.categories(parent_id, sort_order);

alter table public.categories enable row level security;

create policy categories_select_all on public.categories
  for select using (is_active);

create policy categories_moderator_write on public.categories
  for all using (public.is_moderator());
