-- 0007_search.sql
create or replace function public.search_listings(
  p_query        text                default null,
  p_category     text                default null,  -- slug, inkl. Unterkategorien
  p_min_price    int                 default null,  -- in Cent
  p_max_price    int                 default null,
  p_conditions   text[]              default null,
  p_propulsions  text[]              default null,
  p_min_joule    numeric             default null,
  p_max_joule    numeric             default null,
  p_ships        boolean             default null,
  p_lat          double precision    default null,
  p_lng          double precision    default null,
  p_radius_km    int                 default null,
  p_sort         text                default 'newest', -- newest|price_asc|price_desc|distance
  p_limit        int                 default 24,
  p_offset       int                 default 0
)
returns table (
  id            uuid,
  title         text,
  price_cents   int,
  negotiable    boolean,
  condition     public.listing_condition,
  status        public.listing_status,
  city          text,
  postal_code   text,
  joule         numeric,
  has_f_marking boolean,
  ships         boolean,
  bumped_at     timestamptz,
  seller_id     uuid,
  category_slug text,
  cover_path    text,
  distance_km   double precision,
  total_count   bigint
)
language sql
stable
security invoker
set search_path = public
as $$
  with scope as (
    select c.id
    from public.categories c
    where p_category is null
       or c.slug = p_category
       or c.parent_id = (select id from public.categories where slug = p_category)
  ),
  filtered as (
    select
      l.*,
      cat.slug as category_slug,
      (select li.storage_path
         from public.listing_images li
        where li.listing_id = l.id and li.kind = 'photo'
        order by li.sort_order
        limit 1) as cover_path,
      case
        when p_lat is null or p_lng is null then null
        else earth_distance(ll_to_earth(l.lat, l.lng), ll_to_earth(p_lat, p_lng)) / 1000.0
      end as distance_km
    from public.listings l
    join public.categories cat on cat.id = l.category_id
    where l.status in ('active', 'reserved')
      and l.category_id in (select id from scope)
      and (p_query      is null or l.search_tsv @@ websearch_to_tsquery('german', p_query))
      and (p_min_price  is null or l.price_cents >= p_min_price)
      and (p_max_price  is null or l.price_cents <= p_max_price)
      and (p_conditions is null or l.condition::text = any(p_conditions))
      and (p_propulsions is null or l.propulsion::text = any(p_propulsions))
      and (p_min_joule  is null or l.joule >= p_min_joule)
      and (p_max_joule  is null or l.joule <= p_max_joule)
      and (p_ships      is null or l.ships = p_ships)
      and (
        p_radius_km is null or p_lat is null or p_lng is null
        -- earth_box nutzt den GiST-Index, ist aber nur eine Bounding-Box
        -- (liefert etwas zu viel). earth_distance filtert danach exakt.
        or (
              earth_box(ll_to_earth(p_lat, p_lng), p_radius_km * 1000)
                @> ll_to_earth(l.lat, l.lng)
          and earth_distance(ll_to_earth(l.lat, l.lng),
                             ll_to_earth(p_lat, p_lng)) <= p_radius_km * 1000
        )
      )
      and not exists (
        select 1 from public.blocks b
        where (b.blocker_id = auth.uid() and b.blocked_id = l.seller_id)
           or (b.blocker_id = l.seller_id and b.blocked_id = auth.uid())
      )
  )
  select
    f.id, f.title, f.price_cents, f.negotiable, f.condition, f.status,
    f.city, f.postal_code, f.joule, f.has_f_marking, f.ships,
    coalesce(f.bumped_at, f.published_at, f.created_at) as bumped_at,
    f.seller_id, f.category_slug, f.cover_path, f.distance_km,
    count(*) over () as total_count
  from filtered f
  order by
    case when p_sort = 'price_asc'  then f.price_cents end asc,
    case when p_sort = 'price_desc' then f.price_cents end desc,
    case when p_sort = 'distance'   then f.distance_km end asc nulls last,
    coalesce(f.bumped_at, f.published_at, f.created_at) desc
  limit  least(coalesce(p_limit, 24), 60)
  offset greatest(coalesce(p_offset, 0), 0);
$$;
