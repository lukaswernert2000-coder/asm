-- 0003_listings.sql
create type public.listing_condition as enum
  ('neu','neuwertig','gebraucht','leichte_defekte','defekt','bastelobjekt');

create type public.listing_status as enum
  ('draft','active','reserved','sold','archived','blocked');

create type public.propulsion_type as enum
  ('saeg','aep','gbb','co2','hpa','federdruck','sonstige');

create type public.image_kind as enum ('photo','f_marking','ownership_proof');

create table public.listings (
  id            uuid primary key default gen_random_uuid(),
  seller_id     uuid not null references public.profiles(id) on delete cascade,
  category_id   uuid not null references public.categories(id),
  title         text not null check (char_length(title) between 10 and 80),
  description   text not null check (char_length(description) between 30 and 5000),
  price_cents   int  not null check (price_cents >= 0 and price_cents <= 100000000),
  negotiable    boolean not null default false,
  is_giveaway   boolean not null default false,
  accepts_swap  boolean not null default false,
  condition     public.listing_condition not null,
  status        public.listing_status not null default 'draft',
  manufacturer  text,
  model         text,
  joule         numeric(4,2) check (joule is null or (joule >= 0.10 and joule <= 7.50)),
  propulsion    public.propulsion_type,
  caliber       text check (caliber in ('6mm','8mm')),
  has_f_marking boolean not null default false,
  is_modified   boolean not null default false,
  ships         boolean not null default false,
  pickup_only   boolean not null default true,
  postal_code   text not null check (postal_code ~ '^[0-9]{5}$'),
  city          text not null,
  lat           double precision not null,
  lng           double precision not null,
  view_count    int not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  published_at  timestamptz,
  bumped_at     timestamptz,
  sold_at       timestamptz,

  constraint giveaway_is_free check (not is_giveaway or price_cents = 0),
  constraint delivery_chosen  check (ships or pickup_only),
  -- Kernregel des Waffenrechts, direkt in der Datenbank:
  constraint f_marking_required_above_half_joule
    check (joule is null or joule <= 0.5 or has_f_marking),

  search_tsv tsvector generated always as (
      setweight(to_tsvector('german', coalesce(title, '')), 'A')
   || setweight(to_tsvector('german',
        coalesce(manufacturer, '') || ' ' || coalesce(model, '')), 'B')
   || setweight(to_tsvector('german', coalesce(description, '')), 'C')
  ) stored
);

create index listings_search_idx   on public.listings using gin (search_tsv);
create index listings_category_idx on public.listings (category_id, status, bumped_at desc);
create index listings_seller_idx   on public.listings (seller_id, status);
create index listings_geo_idx      on public.listings using gist (ll_to_earth(lat, lng));
create index listings_price_idx    on public.listings (price_cents) where status = 'active';

create table public.listing_images (
  id             uuid primary key default gen_random_uuid(),
  listing_id     uuid not null references public.listings(id) on delete cascade,
  storage_path   text not null,
  kind           public.image_kind not null default 'photo',
  sort_order     int not null default 0,
  width          int,
  height         int,
  created_at     timestamptz not null default now()
);

create index listing_images_listing_idx
  on public.listing_images (listing_id, kind, sort_order);

create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger listings_touch
  before update on public.listings
  for each row execute function public.touch_updated_at();

alter table public.listings enable row level security;
alter table public.listing_images enable row level security;

-- Oeffentlich lesbar: nur sichtbare Status, und Altersgate greift
create policy listings_public_read on public.listings
  for select using (
    status in ('active', 'reserved', 'sold')
    and (
      not exists (
        select 1 from public.categories c
        where c.id = listings.category_id and c.requires_age_18
      )
      or public.is_adult()
    )
  );

create policy listings_owner_read on public.listings
  for select using (seller_id = auth.uid());

create policy listings_owner_write on public.listings
  for insert with check (seller_id = auth.uid());

create policy listings_owner_update on public.listings
  for update using (seller_id = auth.uid()) with check (seller_id = auth.uid());

create policy listings_owner_delete on public.listings
  for delete using (seller_id = auth.uid());

create policy listings_moderator_all on public.listings
  for all using (public.is_moderator());

create policy listing_images_read on public.listing_images
  for select using (
    exists (select 1 from public.listings l where l.id = listing_id)
  );

create policy listing_images_owner_write on public.listing_images
  for all using (
    exists (
      select 1 from public.listings l
      where l.id = listing_id and l.seller_id = auth.uid()
    )
  );
