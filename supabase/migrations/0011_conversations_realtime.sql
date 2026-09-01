-- 0011_conversations_realtime.sql
-- Chatliste (Task 6.2) liest conversations() jetzt als Realtime-Stream statt
-- per manuellem ref.invalidate() -- letzteres kam beim Live-Testen nicht
-- zuverlaessig bei einer schon aufgebauten, aber gerade im Hintergrund der
-- StatefulShellRoute liegenden Chatliste an (nur ein App-Neustart zeigte
-- danach den korrekten Stand). Siehe DECISIONS.md.
alter publication supabase_realtime add table public.conversations;
