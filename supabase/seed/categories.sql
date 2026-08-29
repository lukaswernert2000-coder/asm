-- supabase/seed/categories.sql
-- 8 Hauptkategorien + Unterkategorien aus 00-SPEC.md Abschnitt 5.
insert into public.categories
  (slug, name, icon, sort_order, requires_age_18, requires_f_marking,
   requires_joule, requires_propulsion)
values
  ('asg-05j',            'ASGs bis 0,5 J',      'asg05j',    1, false, false, true,  true),
  ('langwaffen',         'Gewehre & MPs',       'rifle',     2, true,  true,  true,  true),
  ('pistolen',           'Pistolen',            'pistol',    3, true,  true,  true,  true),
  ('ersatzteile-tuning', 'Ersatzteile & Tuning','gear',      4, false, false, false, false),
  ('zubehoer',           'Zubehör',             'accessory', 5, false, false, false, false),
  ('ausruestung',        'Ausrüstung',          'vest',      6, false, false, false, false),
  ('bekleidung',         'Bekleidung',          'shirt',     7, false, false, false, false),
  ('sonstiges',          'Sonstiges',           'dots',      8, false, false, false, false);

insert into public.categories
  (parent_id, slug, name, sort_order, requires_age_18, requires_f_marking,
   requires_joule, requires_propulsion)
select p.id, v.slug, v.name, v.sort_order,
       p.requires_age_18, p.requires_f_marking,
       p.requires_joule, p.requires_propulsion
from (values
  -- 5.1 asg-05j
  ('asg-05j', 'asg-05j-langwaffen',      'Gewehre & MPs bis 0,5 J',  1),
  ('asg-05j', 'asg-05j-pistolen',        'Pistolen bis 0,5 J',       2),
  ('asg-05j', 'asg-05j-shotguns',        'Shotguns bis 0,5 J',       3),
  ('asg-05j', 'asg-05j-sonstige',        'Sonstige bis 0,5 J',       4),

  -- 5.2 langwaffen
  ('langwaffen', 'langwaffen-saeg',        'S-AEG (Elektro)',      1),
  ('langwaffen', 'langwaffen-gbbr',        'GBBR (Gas)',           2),
  ('langwaffen', 'langwaffen-hpa',         'HPA',                  3),
  ('langwaffen', 'langwaffen-federdruck',  'Federdruck & Sniper',  4),
  ('langwaffen', 'langwaffen-shotgun',     'Shotguns',             5),
  ('langwaffen', 'langwaffen-support',     'Support & LMG',        6),
  ('langwaffen', 'langwaffen-sonstige',    'Sonstige Langwaffen',  7),

  -- 5.3 pistolen
  ('pistolen', 'pistolen-gbb',        'GBB (Gas)',           1),
  ('pistolen', 'pistolen-co2',        'CO2',                 2),
  ('pistolen', 'pistolen-aep',        'AEP (Elektro)',       3),
  ('pistolen', 'pistolen-federdruck', 'Federdruck',          4),
  ('pistolen', 'pistolen-revolver',   'Revolver',            5),
  ('pistolen', 'pistolen-sonstige',   'Sonstige Pistolen',   6),

  -- 5.4 ersatzteile-tuning
  ('ersatzteile-tuning', 'tuning-gearbox',            'Gearbox & Internals',                      1),
  ('ersatzteile-tuning', 'tuning-externals',          'Externals & Body',                         2),
  ('ersatzteile-tuning', 'tuning-hopup-laeufe',       'Hop-Up & Läufe',                            3),
  ('ersatzteile-tuning', 'tuning-motoren-elektronik', 'Motoren, MOSFET & Elektronik',              4),
  ('ersatzteile-tuning', 'tuning-federn-kolben',      'Federn, Kolben & Zylinder',                 5),
  ('ersatzteile-tuning', 'tuning-hpa-komponenten',    'HPA-Komponenten (Engine, Regulator, Line)', 6),
  ('ersatzteile-tuning', 'tuning-gbb-teile',          'GBB-Ersatzteile (Nozzle, Valve, Dichtungen)', 7),
  ('ersatzteile-tuning', 'tuning-werkzeug-wartung',   'Werkzeug, Öle & Wartung',                   8),

  -- 5.5 zubehoer
  ('zubehoer', 'zubehoer-magazine',            'Magazine',                            1),
  ('zubehoer', 'zubehoer-akkus-ladegeraete',   'Akkus & Ladegeräte',                  2),
  ('zubehoer', 'zubehoer-gas-co2',             'Gas & CO2',                           3),
  ('zubehoer', 'zubehoer-bbs',                 'BBs & Munition',                      4),
  ('zubehoer', 'zubehoer-zielhilfen',          'Zielhilfen (Red Dot, ZF, Laser)',     5),
  ('zubehoer', 'zubehoer-lampen-ir',           'Lampen & IR-Illuminatoren',           6),
  ('zubehoer', 'zubehoer-slings-holster',      'Slings & Holster',                    7),
  ('zubehoer', 'zubehoer-griffe-schaefte',     'Griffe, Schäfte & Rails',             8),
  ('zubehoer', 'zubehoer-suppressor-tracer',   'Suppressor & Tracer',                 9),
  ('zubehoer', 'zubehoer-granaten-minen',      'Granaten & Minen',                    10),
  ('zubehoer', 'zubehoer-funk',                'Funk & Comms',                        11),
  ('zubehoer', 'zubehoer-sonstiges',           'Sonstiges Zubehör',                   12),

  -- 5.6 ausruestung
  ('ausruestung', 'ausruestung-plattentraeger',  'Plattenträger & Westen',              1),
  ('ausruestung', 'ausruestung-chestrigs',       'Chest Rigs',                          2),
  ('ausruestung', 'ausruestung-pouches',         'Pouches & Taschen',                   3),
  ('ausruestung', 'ausruestung-guertel',         'Gürtel & Battle Belts',               4),
  ('ausruestung', 'ausruestung-rucksaecke',      'Rucksäcke',                           5),
  ('ausruestung', 'ausruestung-schutzbrillen',   'Schutzbrillen & Masken',              6),
  ('ausruestung', 'ausruestung-helme',           'Helme & Zubehör',                     7),
  ('ausruestung', 'ausruestung-protektoren',     'Knie-, Ellenbogen- & Handschutz',     8),
  ('ausruestung', 'ausruestung-nachtsicht',      'Nachtsicht & Thermal',                9),
  ('ausruestung', 'ausruestung-hydration',       'Hydration',                           10),
  ('ausruestung', 'ausruestung-feldausruestung', 'Feldausrüstung & Camping',            11),
  ('ausruestung', 'ausruestung-waffentaschen',   'Waffentaschen & Transport',           12),

  -- 5.7 bekleidung
  ('bekleidung', 'bekleidung-combatshirts',   'Combat Shirts',                    1),
  ('bekleidung', 'bekleidung-hosen',          'Hosen',                            2),
  ('bekleidung', 'bekleidung-jacken',         'Jacken & Parkas',                  3),
  ('bekleidung', 'bekleidung-ghillie',        'Ghillie & Tarnmaterial',           4),
  ('bekleidung', 'bekleidung-schuhe',         'Stiefel & Schuhe',                 5),
  ('bekleidung', 'bekleidung-kopfbedeckung',  'Caps, Boonies & Kopftücher',       6),
  ('bekleidung', 'bekleidung-handschuhe',     'Handschuhe',                       7),
  ('bekleidung', 'bekleidung-patches',        'Patches & Abzeichen',              8),
  ('bekleidung', 'bekleidung-sonstiges',      'Sonstige Bekleidung',              9),

  -- 5.8 sonstiges
  ('sonstiges', 'sonstiges-gesuche',    'Gesuche',                              1),
  ('sonstiges', 'sonstiges-konvolute',  'Konvolute & Restposten',               2),
  ('sonstiges', 'sonstiges-literatur',  'Literatur & Medien',                   3),
  ('sonstiges', 'sonstiges-deko',       'Deko & Replikate (ohne Funktion)',     4),
  ('sonstiges', 'sonstiges-tickets',    'Event-Tickets & Spieltage',            5),
  ('sonstiges', 'sonstiges-diverses',   'Diverses',                             6)
) as v(parent_slug, slug, name, sort_order)
join public.categories p on p.slug = v.parent_slug;
