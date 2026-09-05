-- 0015_security_audit_hardening.sql
-- Task 7.3: Behebt die Befunde aus `supabase db advisors --type security`,
-- die risikofrei und ohne Funktionsverlust behebbar sind. Andere Befunde
-- bewusst unveraendert gelassen, siehe DECISIONS.md:
-- - is_adult()/is_moderator() bleiben oeffentlich ausfuehrbar -- sie werden
--   aus RLS-Policy-Ausdruecken heraus aufgerufen, die selbst mit den
--   Rechten der anon/authenticated-Rolle laufen. Ein EXECUTE-Entzug wuerde
--   jede Policy brechen, die sie referenziert, nicht nur den direkten
--   RPC-Aufruf.
-- - cube/earthdistance/pg_trgm liegen im public-Schema (Standard bei
--   Supabase-Erweiterungen). Ein Verschieben in ein eigenes Schema haette
--   search_path-Auswirkungen auf die produktiv genutzte PLZ-Umkreissuche
--   und wird hier bewusst nicht angegangen.
-- - "Leaked Password Protection" ist eine Auth-Einstellung im Dashboard,
--   keine Migration -- an den Nutzer weitergegeben.

-- touch_updated_at() ist KEIN SECURITY DEFINER (laeuft ohnehin nur mit den
-- Rechten des aufrufenden Triggers) -- das Risiko eines mutable search_path
-- ist hier gering, trotzdem fuer Konsistenz mit handle_new_user()/
-- is_adult()/is_moderator()/bump_conversation() nachgezogen.
create or replace function public.touch_updated_at()
returns trigger language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- handle_new_user() und bump_conversation() sind reine Trigger-Funktionen
-- (auth.users- bzw. messages-INSERT) -- niemals als direkter RPC-Aufruf
-- gedacht. Ein Trigger braucht dafuer kein EXECUTE der aufloesenden Rolle
-- (Trigger laufen nicht ueber denselben Berechtigungspfad wie ein direkter
-- Funktionsaufruf), das Entziehen schliesst also nur die unbeabsichtigte
-- /rest/v1/rpc/...-Erreichbarkeit, ohne Registrierung oder Chat zu
-- beeinflussen.
revoke execute on function public.handle_new_user() from public, anon, authenticated;
revoke execute on function public.bump_conversation() from public, anon, authenticated;
