-- 0006_storage.sql
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('listing-images', 'listing-images', true,  10485760,
     array['image/jpeg','image/png','image/webp','image/heic']),
  ('avatars',        'avatars',        true,   2097152,
     array['image/jpeg','image/png','image/webp']),
  ('chat-images',    'chat-images',    false, 10485760,
     array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

-- Pfadkonvention: listing-images/<user_id>/<listing_id>/<uuid>.jpg
create policy "listing images public read" on storage.objects
  for select using (bucket_id = 'listing-images');

create policy "listing images owner write" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'listing-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "listing images owner delete" on storage.objects
  for delete to authenticated using (
    bucket_id = 'listing-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "avatars public read" on storage.objects
  for select using (bucket_id = 'avatars');

create policy "avatars owner write" on storage.objects
  for all to authenticated using (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text
  ) with check (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "chat images participant read" on storage.objects
  for select to authenticated using (
    bucket_id = 'chat-images'
    and exists (
      select 1 from public.conversations c
      where c.id::text = (storage.foldername(name))[1]
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );

create policy "chat images participant write" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'chat-images'
    and exists (
      select 1 from public.conversations c
      where c.id::text = (storage.foldername(name))[1]
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );
