-- 0009_description_min_length.sql
-- Nutzervorgabe: die Mindestlaenge der Inserat-Beschreibung sinkt von 30 auf
-- 15 Zeichen. Die Obergrenze (5000) bleibt unveraendert.
alter table public.listings
  drop constraint listings_description_check;

alter table public.listings
  add constraint listings_description_check
  check (char_length(description) between 15 and 5000);
