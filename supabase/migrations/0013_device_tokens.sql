-- 0013_device_tokens.sql
-- Task 6.3: FCM-Geraetetoken pro Nutzer. `token` selbst ist Primary Key
-- (nicht user_id/token zusammen) -- ein Token gehoert genau einem
-- Geraete-Install, ein Re-Registrieren unter einem anderen Account
-- (z. B. Logout + neuer Login auf demselben Geraet) ersetzt die Zeile
-- statt eine Karteileiche fuer den alten Nutzer stehen zu lassen.
create table public.device_tokens (
  token      text primary key,
  user_id    uuid not null references public.profiles(id) on delete cascade,
  platform   text not null check (platform in ('android', 'ios')),
  updated_at timestamptz not null default now()
);

create index device_tokens_user_idx on public.device_tokens (user_id);

alter table public.device_tokens enable row level security;

-- Kein Select fuer andere -- die Notify-Edge-Function liest ueber
-- service_role und umgeht RLS ohnehin, ein Nutzer muss die Geraetetoken
-- einer fremden Person nie sehen.
create policy device_tokens_own on public.device_tokens
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
