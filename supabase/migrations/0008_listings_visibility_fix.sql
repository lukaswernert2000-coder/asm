-- 0008_listings_visibility_fix.sql
-- Nutzervorgabe (siehe DECISIONS.md, "Altersgate bewusst nicht verdrahtet"): Inserate und
-- Kategorien bleiben fuer alle sichtbar (Gast, Minderjaehrig, Erwachsen). Das Altersgate
-- greift erst an der Kauf-/Kontaktieren-Aktion (Task 5.1 "Nachricht schreiben"), nicht an
-- der Sichtbarkeit der Zeile. Die urspruengliche Policy aus 0003_listings.sql filterte
-- `requires_age_18`-Zeilen komplett aus dem select-Ergebnis fuer Nicht-Erwachsene -- das
-- widersprach dieser Vorgabe direkt und wird hier korrigiert.
drop policy listings_public_read on public.listings;

create policy listings_public_read on public.listings
  for select using (status in ('active', 'reserved', 'sold'));

-- public.is_adult() bleibt bestehen (0001_profiles.sql) fuer die eigentliche
-- Kauf-/Kontaktieren-Gate in M5/M6 -- hier nur nicht mehr fuer die Sichtbarkeit verwendet.
