-- 0012_conversations_last_message.sql
-- Echter Bug (live beim Testen von Task 6.2 gefunden): die Chatliste zeigte
-- die letzte Nachricht ueber eine zweite, separate Subscription
-- (conversationMessagesProvider) an -- die blieb bei einer schon
-- aufgebauten, aber gerade im Hintergrund liegenden Chatliste stehen
-- (gleiche Ursache wie der last_message_at-Bug oben: Riverpod-Updates fuer
-- Provider ausserhalb des aktuell sichtbaren Screens kamen unzuverlaessig
-- an), waehrend die Chat-Detailseite mit derselben Subscription immer
-- korrekt aktualisierte. Fix: letzte Nachricht direkt auf `conversations`
-- denormalisieren, befuellt vom selben (jetzt SECURITY DEFINER) Trigger wie
-- last_message_at -- die Chatliste braucht dann nur noch den bereits
-- reparierten conversations()-Realtime-Stream, keine zweite Subscription
-- mehr. Siehe DECISIONS.md.
alter table public.conversations
  add column last_message_body text,
  add column last_message_sender_id uuid references public.profiles(id);

create or replace function public.bump_conversation()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.conversations
     set last_message_at = new.created_at,
         last_message_body = coalesce(new.body, '[Bild]'),
         last_message_sender_id = new.sender_id
   where id = new.conversation_id;
  return new;
end;
$$;
