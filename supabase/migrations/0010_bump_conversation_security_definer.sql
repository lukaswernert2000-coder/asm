-- 0010_bump_conversation_security_definer.sql
-- Echter Bug (live beim Testen von Task 6.2 gefunden): bump_conversation()
-- lief als SECURITY INVOKER. `conversations` hat aus gutem Grund keine
-- Update-Policy fuer Kaeufer/Verkaeufer (0005_chat.sql), also blockierte RLS
-- das UPDATE des Triggers selbst -- last_message_at blieb nach jeder neuen
-- Nachricht dauerhaft NULL, die Konversation tauchte nie in der sortierten
-- Chatliste auf. Fix nach demselben Muster wie handle_new_user() (0001):
-- SECURITY DEFINER mit fixiertem search_path.
create or replace function public.bump_conversation()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.conversations
     set last_message_at = new.created_at
   where id = new.conversation_id;
  return new;
end;
$$;
