-- 0005_chat.sql
create table public.conversations (
  id              uuid primary key default gen_random_uuid(),
  listing_id      uuid not null references public.listings(id) on delete cascade,
  buyer_id        uuid not null references public.profiles(id) on delete cascade,
  seller_id       uuid not null references public.profiles(id) on delete cascade,
  last_message_at timestamptz,
  created_at      timestamptz not null default now(),
  constraint one_conversation_per_buyer_and_listing unique (listing_id, buyer_id),
  constraint buyer_is_not_seller check (buyer_id <> seller_id)
);

create index conversations_buyer_idx  on public.conversations (buyer_id, last_message_at desc);
create index conversations_seller_idx on public.conversations (seller_id, last_message_at desc);

create table public.messages (
  id              uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id       uuid not null references public.profiles(id) on delete cascade,
  body            text check (char_length(body) between 1 and 2000),
  image_path      text,
  created_at      timestamptz not null default now(),
  read_at         timestamptz,
  constraint message_has_content check (body is not null or image_path is not null)
);

create index messages_conversation_idx on public.messages (conversation_id, created_at desc);

create or replace function public.bump_conversation()
returns trigger language plpgsql as $$
begin
  update public.conversations
     set last_message_at = new.created_at
   where id = new.conversation_id;
  return new;
end;
$$;

create trigger messages_bump_conversation
  after insert on public.messages
  for each row execute function public.bump_conversation();

alter table public.conversations enable row level security;
alter table public.messages      enable row level security;

create policy conversations_participants on public.conversations
  for select using (buyer_id = auth.uid() or seller_id = auth.uid());

create policy conversations_buyer_create on public.conversations
  for insert with check (
    buyer_id = auth.uid()
    and not exists (
      select 1 from public.blocks b
      where (b.blocker_id = seller_id and b.blocked_id = auth.uid())
         or (b.blocker_id = auth.uid() and b.blocked_id = seller_id)
    )
  );

create policy messages_read on public.messages
  for select using (
    exists (
      select 1 from public.conversations c
      where c.id = conversation_id
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );

create policy messages_insert on public.messages
  for insert with check (
    sender_id = auth.uid()
    and exists (
      select 1 from public.conversations c
      where c.id = conversation_id
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );

-- Nur das Lesen-Flag darf nachtraeglich gesetzt werden
create policy messages_mark_read on public.messages
  for update using (
    exists (
      select 1 from public.conversations c
      where c.id = conversation_id
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
    and sender_id <> auth.uid()
  );

-- Realtime aktivieren
alter publication supabase_realtime add table public.messages;
