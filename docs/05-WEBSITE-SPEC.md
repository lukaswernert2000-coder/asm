# ASM · Website-Architektur (Marktplatz + Teaser)

**Status:** Entwurf, zur Freigabe
**Stand:** 2026-09-05

---

## 1. Ziel

Die Domain `asm-app.de` (aktuell nur statische Rechtstexte, gehostet auf Hostinger) wird zu
einer echten Website ausgebaut, die denselben Supabase-Datenbestand liest wie die App.
Primäres Ziel ist **Reichweite über Google**: einzelne Inserate sollen crawlbar/indexierbar
sein, damit z. B. eine Suche nach einem bestimmten Airsoft-Gewehr über die Website zum
Marktplatz führt. Desktop-Komfort für bestehende Nutzer ist ein Nebeneffekt, nicht der
Auslöser dieser Entscheidung.

Die Website ist **zweiphasig**, weil sie vor dem eigentlichen App-Launch live gehen muss –
zu einem Zeitpunkt, an dem es noch keine echten Inserate gibt:

- **Phase 0 (jetzt):** Teaser-Landingpage mit Feature-Vorschau, ohne echte Marktplatz-Routen.
- **Phase 1 (ab App-Launch):** die volle Marktplatz-Website mit Kategorie-, Such- und
  Inserats-Detailseiten.

Beide Phasen laufen im selben Projekt, auf derselben Domain, über denselben Deploy-Weg –
Phase 1 wird nicht neu gebaut, sondern zu Phase 0 hinzugefügt und per Flag freigeschaltet.

## 2. Architektur

- **Next.js** (App Router), liest **direkt gegen Supabase** (Anon-Key, `@supabase/supabase-js`
  serverseitig in Server Components) – kein eigenes Backend, kein API-Layer, kein
  `service_role`-Key. Dieselbe RLS wie die App gilt automatisch mit.
- **Hosting: Hostinger Business** (bereits vorhandener Tarif), über die native
  Node.js-App-Funktion in hPanel. Gegen Hostingers eigene Doku bestätigt: Business-Plan
  unterstützt Node-Apps, Next.js wird automatisch erkannt, SSR/ISR/API-Routen funktionieren
  ohne Einschränkung. Keine zusätzlichen Hosting-Kosten.
- **Deploy:** Hostingers GitHub-Integration – Push auf den verbundenen Branch löst
  automatisch Build + Deploy aus. Ein schlanker CI-Job (nur getriggert bei Änderungen unter
  `web/`) führt vorher `next build` aus, damit kaputte Builds nicht auf den
  Auto-Deploy-Branch gelangen. Berührt die bestehende Flutter-CI nicht.
- **Repo:** neuer Ordner `web/` im bestehenden Repo (Monorepo), neben `lib/`, `android/`,
  `ios/`, `supabase/`. Das bisherige `website/`-Verzeichnis (statische Rechtstexte,
  generiert über `tool/gen_website.dart`) wird abgelöst, sobald Phase 0 live ist – ein
  Generator statt zwei.
- **Domain:** `asm-app.de` bleibt bei Hostinger registriert; DNS/Hosting-Vertrag ändert sich
  nicht, nur der ausgelieferte Inhalt.

## 3. Phase 0 – Teaser (jetzt)

**Umfang:**
- `/` – Landingpage: Hero, Feature-Übersicht mit Screenshots (aus dem Emulator eingefangen),
  deutlicher Hinweis "App erscheint bald".
- `/impressum`, `/datenschutz`, `/agb`, `/nutzungsbedingungen`, `/konto-loeschen` – aus
  denselben `assets/legal/*.md` gerendert, die die App bereits nutzt (eine Quelle statt
  zwei). Pflicht ab dem Moment, in dem die Seite live ist, unabhängig vom App-Status.
- `/sitemap.xml`, `/robots.txt`.
- Bewusst **keine** Kategorie-/Such-/Inserats-Routen – ohne echte Inserate kein sinnvoller
  Inhalt.

**SEO-Erwartung realistisch halten:** rankt für Markenname und generische Begriffe
("Airsoft Marktplatz", "Airsoft gebraucht kaufen/verkaufen"). Long-Tail-Produktsuchen (die
eigentliche Stärke von Phase 1) sind erst mit echten Inseraten möglich.

## 4. Phase 1 – Marktplatz (ab App-Launch)

**Neue Routen im selben Projekt:**
- `/kategorie/[slug]` – Kategorie-Browse. Filter (Preis, Zustand, Antriebsart) als
  URL-Query-Parameter (SEO-/bookmark-freundlich).
- `/suche?q=...` – Volltextsuche.
- `/inserat/[id]` – Detailseite mit vollen Meta-Tags + JSON-LD (`schema.org/Product` +
  `Offer`; `availability` aus `status` abgeleitet: `active`→`InStock`,
  `reserved`→`LimitedAvailability`, `sold`→`SoldOut`).
- `/` wechselt von Teaser- auf echten Marktplatz-Inhalt (neueste Inserate, Kategorien).

**Datenzugriff:**
- Kategorie- und Suchseiten rufen **`search_listings()`** auf – dieselbe Postgres-Funktion,
  die die App nutzt. Keine zweite Filterlogik.
- Detailseiten lesen direkt aus `listings` + `listing_images` + `categories`.
- **Sicherheitsregel:** Die Detailseiten-Bildergalerie filtert zwingend auf
  `listing_images.kind = 'photo'`. Die Kinds `f_marking` und `ownership_proof` dürfen auf
  der Website nie angezeigt werden.
- Verkaufte Inserate (`status = 'sold'`) bleiben erreichbar (RLS erlaubt das explizit) und
  zeigen ein "Verkauft"-Badge statt Kontakt-Button, statt als 404 Linkwert zu verlieren.
  Nicht-öffentliche Stati liefert RLS für anonyme Anfragen gar nicht erst zurück – "keine
  Zeile gefunden" wird von der Seite als 404 behandelt, keine eigene Statusprüfung nötig.

**Rendering:**
- Detailseiten: ISR, Revalidate 60s.
- Kategorie-/Suchseiten: SSR pro Request (Filter/Pagination variieren pro Aufruf).
- Startseite (Marktplatz-Variante): ISR, Revalidate ~5 Min.

## 5. Umschalt-Mechanismus zwischen Phase 0 und Phase 1

Ein serverseitiger Flag (Env-Variable `MARKETPLACE_LIVE`, gesetzt in Hostingers hPanel):
- `false` (Standard, Phase 0): `/` zeigt Teaser, Marktplatz-Routen sind inaktiv/404.
- `true` (ab App-Launch): `/` zeigt echten Marktplatz-Content, alle Routen aktiv.

Phase 1 kann dadurch **vollständig vor dem eigentlichen Launch gebaut und gegen das
Dev-Supabase-Projekt getestet werden**, ohne öffentlich sichtbar zu sein. Am Launch-Tag wird
nur der Flag umgelegt (und die Supabase-Env-Variablen von Dev- auf Produktions-Projekt
umgestellt, analog zur bestehenden Dev/Prod-Trennung der App) – es muss kein Code mehr
geschrieben werden.

Vorteil gegenüber zwei getrennten Projekten/Domains: Backlinks und Google-Vertrauen, die die
Teaser-Seite bis dahin sammelt, bleiben beim Umschalten vollständig erhalten, weil Domain und
URLs gleich bleiben.

## 6. Fehlerbehandlung

- Supabase-Anfrage schlägt zur Laufzeit fehl (Netzwerk-Hänger, kurzer Ausfall): Seite zeigt
  einen freundlichen Fallback statt abzustürzen; `sitemap.xml` liefert im Fehlerfall die
  zuletzt bekannte Liste statt einer leeren Sitemap.
- Nicht existierende oder nicht-öffentliche Inserat-ID: Next.js `notFound()` (siehe
  Abschnitt 4 – RLS liefert für nicht-öffentliche Stati ohnehin keine Zeile).

## 7. Testing

- Lokale Entwicklung gegen dasselbe Dev-Supabase-Projekt wie die App (`env/dev.json`).
- CI-Job (GitHub Actions, getriggert nur bei Änderungen unter `web/`): `next build` muss
  grün sein, bevor auf den Auto-Deploy-Branch gemerged wird.

## 8. Vorschlag zur Umsetzungsreihenfolge

Diese Spec deckt die Gesamtarchitektur inkl. Phase 1 ab, damit der Umschalt-Mechanismus von
Anfang an mitgedacht ist. Der nächste Schritt (Implementierungsplan) sollte sich aber
zunächst nur auf **Phase 0** beziehen – die App selbst ist noch mitten im MVP (M6/M7,
Security-Review offen, kein Test auf echtem Gerät). Phase 1 bekommt einen eigenen,
späteren Implementierungsplan, sobald der App-Launch absehbar ist.

## 9. Offene Punkte / bewusst nicht Teil dieser Spec

- **Screenshots für den Teaser:** werden separat aus dem Emulator eingefangen (Browse-,
  Detail-, Chat-Screen o. ä.), sobald Phase 0 umgesetzt wird.
- **E-Mail-Warteliste auf dem Teaser:** nicht angefragt, daher nicht Teil der Spec. Ließe
  sich bei Bedarf ergänzen (zusätzliche datenschutzrechtliche Pflichten beachten) – eigene
  Entscheidung.
- **Deep-Link von Website in die App** (z. B. `asm://inserat/<id>`, analog zu den
  bestehenden `asm://auth-callback`/`asm://reset-password`-Schemes): sinnvolle spätere
  Ergänzung für Phase 1, kein Blocker für den ersten Wurf.
- Exakte Hostinger-Konfiguration für ein Unterverzeichnis (`web/`) statt Repo-Root als
  Build-Quelle: wird beim tatsächlichen Einrichten in hPanel geprüft – laut Hostinger-Doku
  sind Build-Command und Output-Verzeichnis frei konfigurierbar, kein Architektur-Risiko.
